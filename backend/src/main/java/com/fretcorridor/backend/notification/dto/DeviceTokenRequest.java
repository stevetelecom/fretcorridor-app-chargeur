package com.fretcorridor.backend.notification.dto;

import jakarta.validation.constraints.NotBlank;

public record DeviceTokenRequest(@NotBlank String fcmToken) {
}
