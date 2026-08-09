package com.fretcorridor.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Point d'entree de l'API backend FretCorridor (application chargeur).
 *
 * Sprint 0 : squelette minimal, securise par defaut (voir SecurityConfig).
 * Les modules metier (auth, shipment, payment, tracking, notification, admin)
 * sont ajoutes progressivement, sprint par sprint, conformement au plan
 * d'execution.
 */
@SpringBootApplication
public class FretcorridorBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(FretcorridorBackendApplication.class, args);
    }
}
