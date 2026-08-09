package com.fretcorridor.backend.shipment.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record PackageCatalogItemResponse(
        UUID id,
        String code,
        String label,
        String category,
        BigDecimal defaultWeightKg,
        BigDecimal defaultVolumeM3,
        boolean fragileByDefault,
        String iconName
) {}
