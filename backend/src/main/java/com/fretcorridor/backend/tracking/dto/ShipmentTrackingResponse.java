package com.fretcorridor.backend.tracking.dto;

import com.fretcorridor.backend.shipment.entity.ShipmentStatus;

import java.util.List;

/**
 * Reponse complete de l'ecran de suivi cote chargeur. lastPosition et
 * deliveryProof sont nullables : rien n'a encore ete injecte par l'admin
 * tant que la demande n'a pas atteint EN_COURS / LIVREE.
 */
public record ShipmentTrackingResponse(
        ShipmentStatus currentStatus,
        List<ShipmentStatusHistoryEntry> statusHistory,
        LastPositionResponse lastPosition,
        DeliveryProofResponse deliveryProof) {
}
