package com.fretcorridor.backend.auth.dto;

import com.fretcorridor.backend.auth.entity.AccountType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Requete d'inscription. Chaque champ est valide avant d'atteindre le
 * service - aucune donnee non filtree n'entre dans la couche metier
 * (regle securite du guide ultime : filtrer/valider tous les inputs,
 * prevenir injection SQL / XSS des la frontiere de l'API).
 */
public record RegisterRequest(

        @NotNull(message = "Le type de compte est requis")
        AccountType accountType,

        @NotBlank(message = "Le prenom est requis")
        @Size(min = 2, max = 100, message = "Le prenom doit contenir entre 2 et 100 caracteres")
        String firstName,

        @NotBlank(message = "Le nom est requis")
        @Size(min = 2, max = 100, message = "Le nom doit contenir entre 2 et 100 caracteres")
        String lastName,

        @NotBlank(message = "Le numero de telephone est requis")
        @Pattern(regexp = "^\\+[1-9]\\d{7,14}$",
                message = "Le numero doit etre au format international (ex: +237654862989)")
        String phoneNumber,

        @NotBlank(message = "Le code PIN est requis")
        @Pattern(regexp = "^\\d{4,6}$", message = "Le code PIN doit contenir entre 4 et 6 chiffres")
        String pin
) {}
