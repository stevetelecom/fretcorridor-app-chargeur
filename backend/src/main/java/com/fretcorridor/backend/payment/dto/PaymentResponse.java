package com.fretcorridor.backend.payment.dto;

import com.fretcorridor.backend.payment.entity.PaymentStatus;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record PaymentResponse(
        UUID id,
        UUID shipmentRequestId,
        UUID offerId,
        BigDecimal amountXaf,
        String provider,
        String providerReference,
        PaymentStatus status,
        Instant createdAt
) {}
