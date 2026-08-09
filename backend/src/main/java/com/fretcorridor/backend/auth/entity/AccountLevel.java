package com.fretcorridor.backend.auth.entity;

/**
 * KYC gradue a 3 niveaux (CDC, RG-011).
 * NIVEAU_0 : telephone possede, consultation seule.
 * NIVEAU_1 : identite declaree, pieces deposees ; consultation + declaration, pas d'acceptation.
 * NIVEAU_2 : pieces verifiees ; acceptation d'offres et paiement.
 * Aucune fonction financiere n'est accessible en-deca de NIVEAU_2.
 */
public enum AccountLevel {
    NIVEAU_0,
    NIVEAU_1,
    NIVEAU_2
}
