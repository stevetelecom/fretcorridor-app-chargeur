package com.fretcorridor.backend.shipment.dto;

import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

// Seul champ demande a la republication : tout le reste vient de la
// demande source (voir ShipmentService.republish). La date ne peut pas
// etre reutilisee telle quelle (ShipmentRequestCreateRequest exige
// @FutureOrPresent).
public record RepublishRequest(
        @NotNull(message = "La date d'enlevement souhaitee est requise")
        @FutureOrPresent(message = "La date d'enlevement ne peut pas etre dans le passe")
        LocalDate requestedPickupDate) {
}
