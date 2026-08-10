package com.fretcorridor.backend.tracking.dto;

import java.time.Instant;

/**
 * ageSeconds calcule cote serveur (pas cote client) pour eviter tout
 * decalage d'horloge entre le telephone et le backend - RG-043 : le
 * chargeur doit voir "il y a X minutes", pas une heure absolue a interpreter.
 */
public record LastPositionResponse(double lat, double lng, Instant recordedAt, long ageSeconds) {
}
