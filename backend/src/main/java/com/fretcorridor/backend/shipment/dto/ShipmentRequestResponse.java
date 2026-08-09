package com.fretcorridor.backend.shipment.dto;

import com.fretcorridor.backend.shipment.entity.DeliveryMode;
import com.fretcorridor.backend.shipment.entity.ShipmentStatus;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record ShipmentRequestResponse(
        UUID id,
        ShipmentStatus status,
        String pickupAddress,
        double pickupLat,
        double pickupLng,
        String destinationAddress,
        double destinationLat,
        double destinationLng,
        PackageCatalogItemResponse packageItem,
        int quantity,
        boolean fragile,
        BigDecimal totalWeightKg,
        BigDecimal totalVolumeM3,
        LocalDate requestedPickupDate,
        DeliveryMode deliveryMode,
        String recipientName,
        String recipientPhone,
        BigDecimal estimatedPriceMin,
        BigDecimal estimatedPriceMax,
        Instant createdAt
) {}
