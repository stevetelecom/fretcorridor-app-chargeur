package com.fretcorridor.backend.admin.dto;

import jakarta.validation.constraints.NotBlank;

// Simplification assumee (perimetre solo) : la preuve est une URL de photo
// deja hebergee (pas d'upload de fichier ni de stockage objet a operer ici).
public record AdminDeliveryProofRequest(@NotBlank String photoUrl) {
}
