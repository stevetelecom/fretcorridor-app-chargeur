package com.fretcorridor.backend.tracking.service;

import com.fretcorridor.backend.auth.entity.User;
import com.fretcorridor.backend.auth.repository.UserRepository;
import com.fretcorridor.backend.common.exception.ApiException;
import com.fretcorridor.backend.notification.service.NotificationService;
import com.fretcorridor.backend.payment.entity.Payment;
import com.fretcorridor.backend.payment.entity.PaymentStatus;
import com.fretcorridor.backend.payment.repository.PaymentRepository;
import com.fretcorridor.backend.shipment.entity.ShipmentRequest;
import com.fretcorridor.backend.shipment.entity.ShipmentStatus;
import com.fretcorridor.backend.shipment.repository.ShipmentRequestRepository;
import com.fretcorridor.backend.tracking.dto.DeliveryProofResponse;
import com.fretcorridor.backend.tracking.dto.LastPositionResponse;
import com.fretcorridor.backend.tracking.dto.ShipmentStatusHistoryEntry;
import com.fretcorridor.backend.tracking.dto.ShipmentTrackingResponse;
import com.fretcorridor.backend.tracking.entity.ShipmentStatusHistory;
import com.fretcorridor.backend.tracking.repository.ShipmentStatusHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.Duration;
import java.util.List;
import java.time.Instant;
import java.util.UUID;

/**
 * Seul point d'entree pour faire evoluer le statut d'une demande. Toute
 * transition passe ici (auth, offer, payment, admin) afin que la
 * chronologie consultee par le chargeur (UC-MKT-03) ne puisse jamais
 * manquer un changement d'etat, meme ajoute plus tard par un autre module.
 */
@Service
@RequiredArgsConstructor
public class ShipmentTrackingService {

    private final ShipmentRequestRepository shipmentRepository;
    private final ShipmentStatusHistoryRepository historyRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    // PaymentRepository (pas PaymentService) volontairement : injecter
    // PaymentService creerait un cycle PaymentService -> ShipmentTrackingService
    // -> PaymentService. Le repository suffit pour la liberation du sequestre.
    private final PaymentRepository paymentRepository;

    // Libelles FR courts pour le corps de la notification push - distincts
    // des libelles plus longs de l'ecran de suivi Flutter (pas besoin de
    // les faire correspondre exactement, ce sont deux UI differentes).
    private static final java.util.Map<ShipmentStatus, String> PUSH_MESSAGES = java.util.Map.of(
            ShipmentStatus.OFFRE_RECUE, "Vous avez reçu une offre pour votre demande.",
            ShipmentStatus.EN_COURS, "Votre transport a démarré.",
            ShipmentStatus.LIVREE, "Votre colis a été livré.",
            ShipmentStatus.ANNULEE, "Votre demande a été annulée."
    );

    @Transactional
    public void changeStatus(ShipmentRequest shipmentRequest, ShipmentStatus newStatus) {
        shipmentRequest.setStatus(newStatus);
        shipmentRepository.save(shipmentRequest);
        historyRepository.save(ShipmentStatusHistory.builder()
                .shipmentRequestId(shipmentRequest.getId())
                .status(newStatus)
                .build());
        notifyAfterCommit(shipmentRequest.getUserId(), newStatus);
    }

    /**
     * Envoie la notification seulement si la transaction en cours commit
     * avec succes (afterCommit) - si le changement de statut est
     * finalement annule (rollback suite a une exception plus loin dans le
     * meme appel), aucune notification trompeuse n'est envoyee.
     */
    private void notifyAfterCommit(UUID userId, ShipmentStatus newStatus) {
        String body = PUSH_MESSAGES.get(newStatus);
        if (body == null) {
            return; // pas de notification pour BROUILLON/PUBLIEE/ACCEPTEE (etapes intermediaires silencieuses)
        }
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                userRepository.findById(userId).map(User::getFcmToken)
                        .ifPresent(token -> notificationService.sendToToken(token, "FretCorridor", body));
            }
        });
    }

    @Transactional
    public void changeStatusAsAdmin(UUID shipmentRequestId, ShipmentStatus newStatus) {
        changeStatus(getOwnedByAdmin(shipmentRequestId), newStatus);
    }

    @Transactional
    public void recordPosition(UUID shipmentRequestId, double lat, double lng) {
        ShipmentRequest shipmentRequest = getOwnedByAdmin(shipmentRequestId);
        shipmentRequest.setLastPositionLat(lat);
        shipmentRequest.setLastPositionLng(lng);
        shipmentRequest.setLastPositionRecordedAt(Instant.now());
        shipmentRepository.save(shipmentRequest);
    }

    @Transactional
    public void recordDeliveryProof(UUID shipmentRequestId, String photoUrl) {
        ShipmentRequest shipmentRequest = getOwnedByAdmin(shipmentRequestId);
        shipmentRequest.setDeliveryProofPhotoUrl(photoUrl);
        shipmentRequest.setDeliveredAt(Instant.now());
        changeStatus(shipmentRequest, ShipmentStatus.LIVREE);
        releaseEscrowIfAny(shipmentRequestId);
    }

    /**
     * Libere le sequestre (UC-PAY-02) : la livraison venant d'etre
     * confirmee, les fonds retenus depuis le paiement sont marques comme
     * verses au transporteur. Ne fait rien si aucun paiement SEQUESTRE
     * n'existe (ex. demande annulee avant paiement puis forcee a LIVREE
     * par erreur admin - ne doit pas lever d'exception ici).
     */
    private void releaseEscrowIfAny(UUID shipmentRequestId) {
        paymentRepository.findByShipmentRequestId(shipmentRequestId)
                .filter(p -> p.getStatus() == PaymentStatus.SEQUESTRE)
                .ifPresent(payment -> {
                    payment.setStatus(PaymentStatus.LIBERE);
                    paymentRepository.save(payment);
                });
    }

    /**
     * Vue complete pour l'ecran de suivi chargeur (UC-MKT-03). A la
     * difference des methodes admin, verifie ici que la demande appartient
     * bien a userId - un chargeur ne doit jamais voir le suivi d'un autre.
     */
    @Transactional(readOnly = true)
    public ShipmentTrackingResponse getTracking(UUID userId, UUID shipmentRequestId) {
        ShipmentRequest shipmentRequest = shipmentRepository.findByIdAndUserId(shipmentRequestId, userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Demande introuvable"));

        List<ShipmentStatusHistoryEntry> history = historyRepository
                .findByShipmentRequestIdOrderByCreatedAtAsc(shipmentRequestId).stream()
                .map(h -> new ShipmentStatusHistoryEntry(h.getStatus(), h.getCreatedAt()))
                .toList();

        LastPositionResponse lastPosition = null;
        if (shipmentRequest.getLastPositionRecordedAt() != null) {
            long ageSeconds = Duration.between(shipmentRequest.getLastPositionRecordedAt(), Instant.now()).getSeconds();
            lastPosition = new LastPositionResponse(
                    shipmentRequest.getLastPositionLat(),
                    shipmentRequest.getLastPositionLng(),
                    shipmentRequest.getLastPositionRecordedAt(),
                    ageSeconds);
        }

        DeliveryProofResponse deliveryProof = null;
        if (shipmentRequest.getDeliveryProofPhotoUrl() != null) {
            deliveryProof = new DeliveryProofResponse(
                    shipmentRequest.getDeliveryProofPhotoUrl(), shipmentRequest.getDeliveredAt());
        }

        return new ShipmentTrackingResponse(shipmentRequest.getStatus(), history, lastPosition, deliveryProof);
    }

    /** Le mini-outil admin agit sur n'importe quelle demande (pas de notion
     * de proprietaire pour lui) - a la difference des endpoints chargeur. */
    private ShipmentRequest getOwnedByAdmin(UUID shipmentRequestId) {
        return shipmentRepository.findById(shipmentRequestId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Demande introuvable"));
    }
}
