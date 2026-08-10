package com.fretcorridor.backend.tracking.dto;

import java.time.Instant;

public record DeliveryProofResponse(String photoUrl, Instant deliveredAt) {
}
