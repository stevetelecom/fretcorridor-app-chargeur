package com.fretcorridor.backend.shipment.service;

import com.fretcorridor.backend.shipment.entity.Offer;
import com.fretcorridor.backend.shipment.entity.OfferStatus;
import com.fretcorridor.backend.shipment.entity.ShipmentRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

/**
 * Genere 2 a 4 offres simulees pour une demande publiee (UC-MKT-02).
 *
 * SIMPLIFICATION ASSUMEE ET DOCUMENTEE : ce perimetre solo n'integre pas le
 * vrai moteur de matching MAT/OPT (developpe separement dans le projet
 * FretCorridor a 3, hors de ce plan). Les offres sont generees a partir
 * d'une liste de transporteurs fictifs et d'une variation aleatoire autour
 * du prix estime par PriceEstimationService - jamais une valeur totalement
 * arbitraire, pour rester coherent avec la fourchette deja affichee au
 * chargeur avant publication.
 *
 * A remplacer par un vrai appel au moteur de matching des qu'il existe,
 * sans changer OfferResponse ni les endpoints - seul le contenu de cette
 * classe change.
 */
@Service
public class MockOfferGenerationService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private static final List<String> CARRIER_NAMES = List.of(
            "Transport Express Cameroun", "Douala Logistique SARL",
            "Corridor Nord Transit", "Fret Rapide CEMAC", "TransAfrique Yaoundé"
    );

    public List<Offer> generateFor(ShipmentRequest shipmentRequest) {
        int offerCount = 2 + RANDOM.nextInt(3); // 2 a 4 offres

        return CARRIER_NAMES.stream()
                .limit(CARRIER_NAMES.size())
                .toList()
                .subList(0, Math.min(offerCount, CARRIER_NAMES.size()))
                .stream()
                .map(carrierName -> buildOffer(shipmentRequest, carrierName))
                .toList();
    }

    private Offer buildOffer(ShipmentRequest shipmentRequest, String carrierName) {
        // Variation +/- 10% autour du milieu de la fourchette deja estimee -
        // les offres restent credibles vis-a-vis du prix annonce au chargeur.
        BigDecimal midPrice = shipmentRequest.getEstimatedPriceMin()
                .add(shipmentRequest.getEstimatedPriceMax())
                .divide(BigDecimal.valueOf(2), RoundingMode.HALF_UP);

        double variation = 0.9 + RANDOM.nextDouble() * 0.2; // entre 0.9 et 1.1
        BigDecimal price = midPrice.multiply(BigDecimal.valueOf(variation))
                .setScale(0, RoundingMode.HALF_UP);

        double rating = 3.5 + RANDOM.nextDouble() * 1.5; // entre 3.5 et 5.0

        Instant pickupAt = Instant.now().plus(1 + RANDOM.nextInt(3), ChronoUnit.DAYS);
        Instant deliveryAt = pickupAt.plus(1 + RANDOM.nextInt(4), ChronoUnit.DAYS);

        return Offer.builder()
                .shipmentRequestId(shipmentRequest.getId())
                .carrierDisplayName(carrierName)
                .carrierRating(BigDecimal.valueOf(rating).setScale(1, RoundingMode.HALF_UP))
                .priceXaf(price)
                .estimatedPickupAt(pickupAt)
                .estimatedDeliveryAt(deliveryAt)
                .status(OfferStatus.PROPOSEE)
                .build();
    }
}
