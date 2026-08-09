package com.fretcorridor.backend.payment.service;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Contrat que devra respecter tout futur provider reel (MTN MoMo, Orange
 * Money - Phase 2, cf. plan §1). SimulatedPaymentProvider est la seule
 * implementation en V1 ; changer de provider ne touchera que
 * l'implementation, jamais PaymentService ni le contrat d'API.
 */
public interface PaymentProvider {

    PaymentResult charge(UUID shipmentRequestId, BigDecimal amountXaf);

    record PaymentResult(boolean success, String providerReference) {}
}
