package com.fretcorridor.backend.shipment;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fretcorridor.backend.tracking.service.ShipmentTrackingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Couvre le parcours complet UC-MKT-01 -> UC-MKT-02 -> UC-MKT-03 -> UC-PAY-01
 * -> UC-PAY-02 (plan §4, Sprints 3-5) : publication d'une demande, generation
 * et acceptation d'une offre, paiement avec sequestre, confirmation de
 * livraison et liberation des fonds. PostgreSQL reel via Testcontainers,
 * authentification JWT reelle (register + login) - aucun mock de securite,
 * exactement le chemin qu'un vrai chargeur emprunte dans l'app.
 *
 * recordDeliveryProof est appele directement via ShipmentTrackingService
 * (pas de endpoint HTTP admin expose a ce jour dans le perimetre solo) -
 * a adapter si un AdminController venait a etre ajoute plus tard.
 */
@Testcontainers
@SpringBootTest
@AutoConfigureMockMvc
class ShipmentOfferPaymentFlowTest {

    @Container
    static PostgreSQLContainer<?> postgres =
            new PostgreSQLContainer<>("postgis/postgis:16-3.4-alpine");

    @DynamicPropertySource
    static void configure(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;
    @Autowired ShipmentTrackingService trackingService;

    private String token;

    @BeforeEach
    void registerAndLogin() throws Exception {
        String phone = "+2376" + (10000000 + (int) (Math.random() * 89999999));

        var register = Map.of(
                "accountType", "PARTICULIER",
                "firstName", "Flow",
                "lastName", "Test",
                "phoneNumber", phone,
                "pin", "4242"
        );
        mockMvc.perform(post("/api/auth/register")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(register)))
                .andExpect(status().isCreated());

        var login = Map.of("phoneNumber", phone, "pin", "4242");
        MvcResult result = mockMvc.perform(post("/api/auth/login")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(login)))
                .andExpect(status().isOk())
                .andReturn();

        token = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("accessToken").asText();
    }

    private UUID firstCatalogItemId() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/package-catalog")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode catalog = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(catalog.isArray()).isTrue();
        assertThat(catalog.size()).isGreaterThan(0);
        return UUID.fromString(catalog.get(0).get("id").asText());
    }

    private UUID createPublishedShipment() throws Exception {
        // Map.ofEntries plutot que Map.of : 13 paires depassent la limite de
        // 10 entrees supportee par Map.of(K,V,K,V,...).
        var body = Map.ofEntries(
                Map.entry("pickupAddress", "Marché Central, Douala"),
                Map.entry("pickupLat", 4.0483),
                Map.entry("pickupLng", 9.7043),
                Map.entry("destinationAddress", "Carrefour Warda, Yaoundé"),
                Map.entry("destinationLat", 3.8480),
                Map.entry("destinationLng", 11.5021),
                Map.entry("packageCatalogItemId", firstCatalogItemId()),
                Map.entry("quantity", 2),
                Map.entry("fragile", false),
                Map.entry("requestedPickupDate", LocalDate.now().plusDays(1).toString()),
                Map.entry("deliveryMode", "STANDARD"),
                Map.entry("recipientName", "Jean Mballa"),
                Map.entry("recipientPhone", "+237690000000")
        );

        MvcResult result = mockMvc.perform(post("/api/shipment-requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isCreated())
                .andReturn();

        JsonNode created = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(created.get("status").asText()).isEqualTo("PUBLIEE");
        return UUID.fromString(created.get("id").asText());
    }

    private JsonNode firstOffer(UUID shipmentId) throws Exception {
        MvcResult result = mockMvc.perform(get("/api/shipment-requests/" + shipmentId + "/offers")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode offers = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(offers.isArray()).isTrue();
        assertThat(offers.size()).isGreaterThanOrEqualTo(2); // 2 a 4 offres, cf. MockOfferGenerationService
        return offers.get(0);
    }

    /**
     * Paie en reessayant jusqu'a succes : SimulatedPaymentProvider echoue
     * volontairement 5% du temps (realisme operateur mobile money), et
     * PaymentService.initiate permet de reessayer sans nouvelle offre tant
     * que le paiement precedent n'est pas SEQUESTRE/LIBERE. 10 tentatives
     * rendent un echec de test du a l'alea negligeable (0.95^10 > 99.9%
     * de reussite avant la derniere tentative).
     */
    private JsonNode payUntilSuccess(UUID shipmentId, UUID offerId) throws Exception {
        JsonNode last = null;
        for (int i = 0; i < 10; i++) {
            MvcResult result = mockMvc.perform(post("/api/shipment-requests/" + shipmentId + "/payment")
                            .header("Authorization", "Bearer " + token)
                            .contentType("application/json")
                            .content(objectMapper.writeValueAsString(Map.of("offerId", offerId))))
                    .andExpect(status().isOk())
                    .andReturn();
            last = objectMapper.readTree(result.getResponse().getContentAsString());
            if (last.get("status").asText().equals("SEQUESTRE")) {
                return last;
            }
        }
        throw new AssertionError("Paiement jamais reussi apres 10 tentatives (probabilite negligeable) : " + last);
    }

    @Test
    void parcoursComplet_publicationAOffreAPaiementASequestreALivraisonALiberation() throws Exception {
        UUID shipmentId = createPublishedShipment();

        // Sprint 3 : generation + acceptation d'une offre
        JsonNode offer = firstOffer(shipmentId);
        UUID offerId = UUID.fromString(offer.get("id").asText());

        mockMvc.perform(post("/api/shipment-requests/" + shipmentId + "/offers/" + offerId + "/accept")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());

        // Sprint 4 : paiement -> SEQUESTRE (fonds retenus, pas encore verses)
        JsonNode payment = payUntilSuccess(shipmentId, offerId);
        assertThat(payment.get("status").asText()).isEqualTo("SEQUESTRE");

        // Sprint 5 : confirmation de livraison -> declenche la liberation
        trackingService.recordDeliveryProof(shipmentId, "https://example.com/proof.jpg");

        MvcResult afterDelivery = mockMvc.perform(get("/api/shipment-requests/" + shipmentId + "/payment")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode paymentAfterDelivery = objectMapper.readTree(afterDelivery.getResponse().getContentAsString());
        assertThat(paymentAfterDelivery.get("status").asText()).isEqualTo("LIBERE");

        // Chronologie coherente : LIVREE bien atteint, preuve exposee
        MvcResult tracking = mockMvc.perform(get("/api/shipment-requests/" + shipmentId + "/tracking")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode trackingBody = objectMapper.readTree(tracking.getResponse().getContentAsString());
        assertThat(trackingBody.get("currentStatus").asText()).isEqualTo("LIVREE");
        assertThat(trackingBody.get("deliveryProof")).isNotNull();
        assertThat(trackingBody.get("deliveryProof").get("photoUrl").asText())
                .isEqualTo("https://example.com/proof.jpg");
    }

    @Test
    void doublePaiement_apresSequestre_estRejete() throws Exception {
        UUID shipmentId = createPublishedShipment();
        JsonNode offer = firstOffer(shipmentId);
        UUID offerId = UUID.fromString(offer.get("id").asText());

        mockMvc.perform(post("/api/shipment-requests/" + shipmentId + "/offers/" + offerId + "/accept")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());

        payUntilSuccess(shipmentId, offerId);

        // Nouvelle tentative de paiement sur une demande deja SEQUESTRE : rejetee.
        mockMvc.perform(post("/api/shipment-requests/" + shipmentId + "/payment")
                        .header("Authorization", "Bearer " + token)
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(Map.of("offerId", offerId))))
                .andExpect(status().isConflict());
    }

    @Test
    void accepterUneOffreDejaRefusee_estRejete() throws Exception {
        UUID shipmentId = createPublishedShipment();

        MvcResult result = mockMvc.perform(get("/api/shipment-requests/" + shipmentId + "/offers")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode offers = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(offers.size()).isGreaterThanOrEqualTo(2);

        UUID acceptedOfferId = UUID.fromString(offers.get(0).get("id").asText());
        UUID otherOfferId = UUID.fromString(offers.get(1).get("id").asText());

        mockMvc.perform(post("/api/shipment-requests/" + shipmentId + "/offers/" + acceptedOfferId + "/accept")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());

        // La 2e offre a ete auto-refusee (OfferService.accept) : impossible
        // de l'accepter a son tour.
        mockMvc.perform(post("/api/shipment-requests/" + shipmentId + "/offers/" + otherOfferId + "/accept")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isConflict());
    }

    @Test
    void payer_sansOffreAcceptee_estRejete() throws Exception {
        UUID shipmentId = createPublishedShipment();
        JsonNode offer = firstOffer(shipmentId);
        UUID offerId = UUID.fromString(offer.get("id").asText());

        // Aucun accept() avant de payer : la demande est encore OFFRE_RECUE, pas ACCEPTEE.
        mockMvc.perform(post("/api/shipment-requests/" + shipmentId + "/payment")
                        .header("Authorization", "Bearer " + token)
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(Map.of("offerId", offerId))))
                .andExpect(status().isConflict());
    }
}
