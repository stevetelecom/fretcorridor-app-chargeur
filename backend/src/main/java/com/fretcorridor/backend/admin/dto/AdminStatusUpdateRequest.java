package com.fretcorridor.backend.admin.dto;

import com.fretcorridor.backend.shipment.entity.ShipmentStatus;
import jakarta.validation.constraints.NotNull;

public record AdminStatusUpdateRequest(@NotNull ShipmentStatus status) {
}
