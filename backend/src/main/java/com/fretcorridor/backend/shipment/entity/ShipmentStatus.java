package com.fretcorridor.backend.shipment.entity;

/**
 * Machine a etats simplifiee d'une demande (UC-MKT-01/02/03). Les etats
 * au-dela de PUBLIEE sont ajoutes progressivement (Sprint 3 : OFFRE_RECUE/
 * ACCEPTEE, Sprint 5 : EN_COURS/LIVREE) - definis ici a l'avance pour eviter
 * une migration de colonne enum plus tard, mais pas encore tous atteignables
 * par l'API a ce stade du plan.
 */
public enum ShipmentStatus {
    BROUILLON,
    PUBLIEE,
    OFFRE_RECUE,
    ACCEPTEE,
    EN_COURS,
    LIVREE,
    ANNULEE
}
