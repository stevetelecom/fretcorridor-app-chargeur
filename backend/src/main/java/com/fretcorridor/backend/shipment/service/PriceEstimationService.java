package com.fretcorridor.backend.shipment.service;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Estimation de prix par bareme simple (plan §1 : "affichee en fourchette,
 * jamais ferme", RG-037). Ce n'est PAS un calcul par distance reelle : sans
 * service GEO dedie (hors perimetre, cf. plan §1.1), la distance n'est pas
 * disponible ici. Le bareme se base uniquement sur le poids taxable et le
 * mode de livraison - a affiner des qu'une vraie donnee de distance existe,
 * sans changer la forme de la reponse (une fourchette min/max).
 */
@Service
public class PriceEstimationService {

    private static final BigDecimal BASE_FEE_XAF = BigDecimal.valueOf(1500);
    private static final BigDecimal RATE_PER_KG_XAF = BigDecimal.valueOf(150);
    private static final BigDecimal EXPRESS_MULTIPLIER = BigDecimal.valueOf(1.4);
    private static final BigDecimal RANGE_MARGIN = BigDecimal.valueOf(0.15); // +/- 15%

    /** Facteur volumetrique standard route (kg equivalents par m3). */
    private static final BigDecimal VOLUMETRIC_FACTOR_KG_PER_M3 = BigDecimal.valueOf(200);

    public BigDecimal computeTaxableWeightKg(BigDecimal totalWeightKg, BigDecimal totalVolumeM3) {
        BigDecimal volumetricWeight = totalVolumeM3.multiply(VOLUMETRIC_FACTOR_KG_PER_M3);
        return totalWeightKg.max(volumetricWeight).setScale(2, RoundingMode.HALF_UP);
    }

    public record PriceRange(BigDecimal min, BigDecimal max) {}

    public PriceRange estimate(BigDecimal taxableWeightKg, boolean express) {
        BigDecimal base = BASE_FEE_XAF.add(taxableWeightKg.multiply(RATE_PER_KG_XAF));
        if (express) {
            base = base.multiply(EXPRESS_MULTIPLIER);
        }

        BigDecimal margin = base.multiply(RANGE_MARGIN);
        BigDecimal min = base.subtract(margin).setScale(0, RoundingMode.HALF_UP);
        BigDecimal max = base.add(margin).setScale(0, RoundingMode.HALF_UP);
        return new PriceRange(min, max);
    }
}
