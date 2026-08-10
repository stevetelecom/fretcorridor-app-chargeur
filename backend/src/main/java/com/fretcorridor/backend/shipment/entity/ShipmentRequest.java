package com.fretcorridor.backend.shipment.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

/** Demande de transport publiee par un chargeur (UC-MKT-01). */
@Entity
@Table(name = "shipment_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShipmentRequest {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private ShipmentStatus status = ShipmentStatus.BROUILLON;

    @Column(name = "pickup_address", nullable = false, length = 255)
    private String pickupAddress;

    @Column(name = "pickup_lat", nullable = false)
    private double pickupLat;

    @Column(name = "pickup_lng", nullable = false)
    private double pickupLng;

    @Column(name = "destination_address", nullable = false, length = 255)
    private String destinationAddress;

    @Column(name = "destination_lat", nullable = false)
    private double destinationLat;

    @Column(name = "destination_lng", nullable = false)
    private double destinationLng;

    @Column(name = "package_catalog_item_id", nullable = false)
    private UUID packageCatalogItemId;

    @Column(nullable = false)
    private int quantity;

    @Column(nullable = false)
    private boolean fragile;

    @Column(name = "total_weight_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalWeightKg;

    @Column(name = "total_volume_m3", nullable = false, precision = 10, scale = 3)
    private BigDecimal totalVolumeM3;

    @Column(name = "taxable_weight_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal taxableWeightKg;

    @Column(name = "requested_pickup_date", nullable = false)
    private LocalDate requestedPickupDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "delivery_mode", nullable = false, length = 20)
    private DeliveryMode deliveryMode;

    @Column(name = "recipient_name", nullable = false, length = 150)
    private String recipientName;

    @Column(name = "recipient_phone", nullable = false, length = 20)
    private String recipientPhone;

    @Column(name = "estimated_price_min", nullable = false, precision = 12, scale = 2)
    private BigDecimal estimatedPriceMin;

    @Column(name = "estimated_price_max", nullable = false, precision = 12, scale = 2)
    private BigDecimal estimatedPriceMax;

    // Sprint 5 (tracking) : derniere position connue, simplifiee a un seul
    // point (pas d'historique de trajet) - voir ShipmentTrackingService.
    @Column(name = "last_position_lat")
    private Double lastPositionLat;

    @Column(name = "last_position_lng")
    private Double lastPositionLng;

    @Column(name = "last_position_recorded_at")
    private Instant lastPositionRecordedAt;

    @Column(name = "delivery_proof_photo_url", length = 500)
    private String deliveryProofPhotoUrl;

    @Column(name = "delivered_at")
    private Instant deliveredAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist
    protected void onCreate() {
        Instant now = Instant.now();
        this.createdAt = now;
        this.updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = Instant.now();
    }
}
