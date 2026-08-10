package com.fretcorridor.backend.tracking.dto;

import com.fretcorridor.backend.shipment.entity.ShipmentStatus;

import java.time.Instant;

/** Une ligne de la chronologie affichee au chargeur (UC-MKT-03). */
public record ShipmentStatusHistoryEntry(ShipmentStatus status, Instant occurredAt) {
}
