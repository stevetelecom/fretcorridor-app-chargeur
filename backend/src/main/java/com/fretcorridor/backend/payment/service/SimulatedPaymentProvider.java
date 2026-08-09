package com.fretcorridor.backend.payment.service;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.util.UUID;

/**
 * SIMPLIFICATION ASSUMEE ET DOCUMENTEE (cf. plan §1) : aucune passerelle
 * MTN MoMo/Orange Money integree en V1. Ce provider simule un paiement
 * reussi dans 95% des cas (les 5% restants simulent un echec operateur
 * realiste, pour que l'UI de gestion d'erreur soit reellement testee et
 * pas juste le chemin heureux). A remplacer par une vraie implementation
 * PaymentProvider des qu'un contrat operateur est signe, sans toucher a
 * PaymentService ni aux endpoints.
 */
@Service
public class SimulatedPaymentProvider implements PaymentProvider {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final double SUCCESS_RATE = 0.95;

    @Override
    public PaymentResult charge(UUID shipmentRequestId, BigDecimal amountXaf) {
        boolean success = RANDOM.nextDouble() < SUCCESS_RATE;
        String reference = success ? "SIM-" + UUID.randomUUID().toString().substring(0, 12).toUpperCase() : null;
        return new PaymentResult(success, reference);
    }
}
