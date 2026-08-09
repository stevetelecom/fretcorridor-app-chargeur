package com.fretcorridor.backend.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record LoginRequest(

        @NotBlank(message = "Le numero de telephone est requis")
        @Pattern(regexp = "^\\+[1-9]\\d{7,14}$", message = "Format de telephone invalide")
        String phoneNumber,

        @NotBlank(message = "Le code PIN est requis")
        @Pattern(regexp = "^\\d{4,6}$", message = "Le code PIN doit contenir entre 4 et 6 chiffres")
        String pin
) {}
