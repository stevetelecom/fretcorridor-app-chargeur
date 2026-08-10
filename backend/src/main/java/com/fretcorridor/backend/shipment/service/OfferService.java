package com.fretcorridor.backend.shipment.service;

import com.fretcorridor.backend.common.exception.ApiException;
import com.fretcorridor.backend.shipment.dto.OfferResponse;
import com.fretcorridor.backend.shipment.entity.Offer;
import com.fretcorridor.backend.shipment.entity.OfferStatus;
import com.fretcorridor.backend.shipment.entity.ShipmentRequest;
import com.fretcorridor.backend.shipment.entity.ShipmentStatus;
import com.fretcorridor.backend.shipment.repository.OfferRepository;
import com.fretcorridor.backend.shipment.repository.ShipmentRequestRepository;
import com.fretcorridor.backend.tracking.service.ShipmentTrackingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OfferService {

    private final ShipmentRequestRepository shipmentRepository;
    private final OfferRepository offerRepository;
    private final MockOfferGenerationService mockOfferGenerationService;
    private final ShipmentTrackingService trackingService;

    /**
     * Recupere les offres d'une demande - les genere a la premiere
     * consultation si la demande est PUBLIEE et n'en a encore aucune
     * (evite un job planifie pour ce perimetre solo ; le mock est
     * volontairement synchrone et rapide).
     */
    @Transactional
    public List<OfferResponse> listOrGenerate(UUID userId, UUID shipmentRequestId) {
        ShipmentRequest shipmentRequest = shipmentRepository.findByIdAndUserId(shipmentRequestId, userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Demande introuvable"));

        List<Offer> existing = offerRepository.findByShipmentRequestIdOrderByPriceXafAsc(shipmentRequestId);

        if (existing.isEmpty() && shipmentRequest.getStatus() == ShipmentStatus.PUBLIEE) {
            List<Offer> generated = mockOfferGenerationService.generateFor(shipmentRequest);
            existing = offerRepository.saveAll(generated);

            trackingService.changeStatus(shipmentRequest, ShipmentStatus.OFFRE_RECUE);
        }

        return existing.stream().map(this::toResponse).toList();
    }

    @Transactional
    public OfferResponse accept(UUID userId, UUID shipmentRequestId, UUID offerId) {
        ShipmentRequest shipmentRequest = shipmentRepository.findByIdAndUserId(shipmentRequestId, userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Demande introuvable"));

        if (shipmentRequest.getStatus() != ShipmentStatus.OFFRE_RECUE) {
            // Empeche une double acceptation ou l'acceptation d'une offre
            // sur une demande deja traitee - regle metier UC-MKT-03.
            throw new ApiException(HttpStatus.CONFLICT,
                    "Cette demande n'est plus au statut permettant d'accepter une offre");
        }

        Offer offer = offerRepository.findByIdAndShipmentRequestId(offerId, shipmentRequestId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Offre introuvable"));

        if (offer.getStatus() != OfferStatus.PROPOSEE) {
            throw new ApiException(HttpStatus.CONFLICT, "Cette offre n'est plus disponible");
        }

        offer.setStatus(OfferStatus.ACCEPTEE);
        offerRepository.save(offer);

        // Toutes les autres offres de la meme demande deviennent caduques -
        // un chargeur ne peut accepter qu'un seul transporteur par demande.
        List<Offer> others = offerRepository.findByShipmentRequestIdOrderByPriceXafAsc(shipmentRequestId);
        others.stream()
                .filter(o -> !o.getId().equals(offerId) && o.getStatus() == OfferStatus.PROPOSEE)
                .forEach(o -> {
                    o.setStatus(OfferStatus.REFUSEE);
                    offerRepository.save(o);
                });

        trackingService.changeStatus(shipmentRequest, ShipmentStatus.ACCEPTEE);

        return toResponse(offer);
    }

    private OfferResponse toResponse(Offer offer) {
        return new OfferResponse(
                offer.getId(), offer.getShipmentRequestId(), offer.getCarrierDisplayName(),
                offer.getCarrierRating(), offer.getPriceXaf(), offer.getEstimatedPickupAt(),
                offer.getEstimatedDeliveryAt(), offer.getStatus(), offer.getCreatedAt());
    }
}
