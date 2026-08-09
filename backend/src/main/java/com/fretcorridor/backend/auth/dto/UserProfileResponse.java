package com.fretcorridor.backend.auth.dto;

import com.fretcorridor.backend.auth.entity.AccountLevel;
import com.fretcorridor.backend.auth.entity.AccountType;

import java.util.UUID;

/** DTO expose au client - l'entite JPA User n'est jamais renvoyee telle quelle (pas de pinHash, etc.). */
public record UserProfileResponse(
        UUID id,
        AccountType accountType,
        String firstName,
        String lastName,
        String phoneNumber,
        AccountLevel accountLevel
) {}
