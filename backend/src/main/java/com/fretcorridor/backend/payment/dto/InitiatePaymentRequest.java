package com.fretcorridor.backend.payment.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/**
 * Demande de paiement pour une offre acceptee. Le montant n'est PAS saisi
 * ici (regle securite : jamais faire confiance a un prix envoye par le
 * client) - il est relu depuis l'offre acceptee en base, cote service.
 */
public record InitiatePaymentRequest(
        @NotNull(message = "L'identifiant de l'offre est requis")
        UUID offerId
) {}
