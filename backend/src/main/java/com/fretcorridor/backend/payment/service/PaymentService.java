package com.fretcorridor.backend.payment.service;

import com.fretcorridor.backend.common.exception.ApiException;
import com.fretcorridor.backend.payment.dto.PaymentResponse;
import com.fretcorridor.backend.payment.entity.Payment;
import com.fretcorridor.backend.payment.entity.PaymentStatus;
import com.fretcorridor.backend.payment.repository.PaymentRepository;
import com.fretcorridor.backend.shipment.entity.Offer;
import com.fretcorridor.backend.shipment.entity.OfferStatus;
import com.fretcorridor.backend.shipment.entity.ShipmentRequest;
import com.fretcorridor.backend.shipment.entity.ShipmentStatus;
import com.fretcorridor.backend.shipment.repository.OfferRepository;
import com.fretcorridor.backend.shipment.repository.ShipmentRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final ShipmentRequestRepository shipmentRepository;
    private final OfferRepository offerRepository;
    private final PaymentRepository paymentRepository;
    private final PaymentProvider paymentProvider;

    @Transactional
    public PaymentResponse initiate(UUID userId, UUID shipmentRequestId, UUID offerId) {
        ShipmentRequest shipmentRequest = shipmentRepository.findByIdAndUserId(shipmentRequestId, userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Demande introuvable"));

        if (shipmentRequest.getStatus() != ShipmentStatus.ACCEPTEE) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "Aucune offre acceptee pour cette demande - impossible de payer");
        }

        Offer offer = offerRepository.findByIdAndShipmentRequestId(offerId, shipmentRequestId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Offre introuvable"));

        if (offer.getStatus() != OfferStatus.ACCEPTEE) {
            throw new ApiException(HttpStatus.CONFLICT, "Cette offre n'a pas ete acceptee");
        }

        paymentRepository.findByShipmentRequestIdAndUserId(shipmentRequestId, userId)
                .filter(p -> p.getStatus() == PaymentStatus.REUSSI)
                .ifPresent(p -> {
                    throw new ApiException(HttpStatus.CONFLICT, "Cette demande a deja ete payee");
                });

        // Le montant vient exclusivement de l'offre en base, jamais du
        // client - un client compromis ne peut pas se faire facturer moins
        // cher en falsifiant une requete.
        var result = paymentProvider.charge(shipmentRequestId, offer.getPriceXaf());

        Payment payment = Payment.builder()
                .shipmentRequestId(shipmentRequestId)
                .offerId(offerId)
                .userId(userId)
                .amountXaf(offer.getPriceXaf())
                .provider("SIMULATED")
                .providerReference(result.providerReference())
                .status(result.success() ? PaymentStatus.REUSSI : PaymentStatus.ECHOUE)
                .build();
        payment = paymentRepository.save(payment);

        if (result.success()) {
            shipmentRequest.setStatus(ShipmentStatus.EN_COURS);
            shipmentRepository.save(shipmentRequest);
        }
        // En cas d'echec : la demande reste ACCEPTEE, le chargeur peut
        // reessayer (pas de transition d'etat, pas de nouvelle offre requise).

        return toResponse(payment);
    }

    @Transactional(readOnly = true)
    public PaymentResponse getForShipment(UUID userId, UUID shipmentRequestId) {
        Payment payment = paymentRepository.findByShipmentRequestIdAndUserId(shipmentRequestId, userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Aucun paiement pour cette demande"));
        return toResponse(payment);
    }

    private PaymentResponse toResponse(Payment payment) {
        return new PaymentResponse(
                payment.getId(), payment.getShipmentRequestId(), payment.getOfferId(),
                payment.getAmountXaf(), payment.getProvider(), payment.getProviderReference(),
                payment.getStatus(), payment.getCreatedAt());
    }
}
