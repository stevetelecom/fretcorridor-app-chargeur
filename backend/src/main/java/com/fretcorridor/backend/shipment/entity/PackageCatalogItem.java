package com.fretcorridor.backend.shipment.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Entree du catalogue reduit (~15 items, plan §1). Lecture seule cote API
 * (pas de CRUD chargeur dessus) - alimente uniquement par la migration V4.
 */
@Entity
@Table(name = "package_catalog_items")
@Getter
@Setter
@NoArgsConstructor
public class PackageCatalogItem {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(nullable = false, unique = true, length = 50)
    private String code;

    @Column(nullable = false, length = 100)
    private String label;

    @Column(nullable = false, length = 50)
    private String category;

    @Column(name = "default_weight_kg", nullable = false, precision = 8, scale = 2)
    private BigDecimal defaultWeightKg;

    @Column(name = "default_volume_m3", nullable = false, precision = 8, scale = 3)
    private BigDecimal defaultVolumeM3;

    @Column(name = "fragile_by_default", nullable = false)
    private boolean fragileByDefault;

    @Column(name = "icon_name", nullable = false, length = 50)
    private String iconName;

    @Column(nullable = false)
    private boolean active;
}
