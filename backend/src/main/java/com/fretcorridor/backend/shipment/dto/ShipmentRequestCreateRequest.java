package com.fretcorridor.backend.shipment.dto;

import com.fretcorridor.backend.shipment.entity.DeliveryMode;
import jakarta.validation.constraints.*;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Requete de publication d'une demande. Chaque champ est valide a la
 * frontiere de l'API (regle securite du guide ultime) - aucune coordonnee,
 * quantite ou texte libre n'atteint le service sans controle.
 */
public record ShipmentRequestCreateRequest(

        @NotBlank(message = "L'adresse de collecte est requise")
        @Size(max = 255, message = "Adresse de collecte trop longue")
        String pickupAddress,

        @NotNull @DecimalMin(value = "-90.0") @DecimalMax(value = "90.0")
        Double pickupLat,

        @NotNull @DecimalMin(value = "-180.0") @DecimalMax(value = "180.0")
        Double pickupLng,

        @NotBlank(message = "L'adresse de destination est requise")
        @Size(max = 255, message = "Adresse de destination trop longue")
        String destinationAddress,

        @NotNull @DecimalMin(value = "-90.0") @DecimalMax(value = "90.0")
        Double destinationLat,

        @NotNull @DecimalMin(value = "-180.0") @DecimalMax(value = "180.0")
        Double destinationLng,

        @NotNull(message = "Le type de colis est requis")
        UUID packageCatalogItemId,

        @NotNull @Min(value = 1, message = "La quantite doit etre au moins 1")
        @Max(value = 500, message = "Quantite maximale depassee")
        Integer quantity,

        boolean fragile,

        @NotNull(message = "La date d'enlevement souhaitee est requise")
        @FutureOrPresent(message = "La date d'enlevement ne peut pas etre dans le passe")
        LocalDate requestedPickupDate,

        @NotNull(message = "Le mode de livraison est requis")
        DeliveryMode deliveryMode,

        @NotBlank(message = "Le nom du destinataire est requis")
        @Size(min = 2, max = 150, message = "Le nom du destinataire doit contenir entre 2 et 150 caracteres")
        String recipientName,

        @NotBlank(message = "Le telephone du destinataire est requis")
        @Pattern(regexp = "^\\+[1-9]\\d{7,14}$", message = "Format de telephone invalide")
        String recipientPhone
) {}
