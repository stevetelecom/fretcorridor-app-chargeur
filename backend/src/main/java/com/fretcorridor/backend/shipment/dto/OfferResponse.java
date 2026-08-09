package com.fretcorridor.backend.shipment.dto;

import com.fretcorridor.backend.shipment.entity.OfferStatus;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record OfferResponse(
        UUID id,
        UUID shipmentRequestId,
        String carrierDisplayName,
        BigDecimal carrierRating,
        BigDecimal priceXaf,
        Instant estimatedPickupAt,
        Instant estimatedDeliveryAt,
        OfferStatus status,
        Instant createdAt
) {}
