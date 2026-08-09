package com.fretcorridor.backend.auth.dto;

public record TokenPairResponse(
        String accessToken,
        String refreshToken,
        long expiresInMs,
        UserProfileResponse user
) {}
