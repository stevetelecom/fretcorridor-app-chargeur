package com.fretcorridor.backend.tracking.service;

import com.fretcorridor.backend.common.exception.ApiException;
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

    @Transactional
    public void changeStatus(ShipmentRequest shipmentRequest, ShipmentStatus newStatus) {
        shipmentRequest.setStatus(newStatus);
        shipmentRepository.save(shipmentRequest);
        historyRepository.save(ShipmentStatusHistory.builder()
                .shipmentRequestId(shipmentRequest.getId())
                .status(newStatus)
                .build());
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
