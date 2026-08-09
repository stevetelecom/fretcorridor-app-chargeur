package com.fretcorridor.backend.shipment.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Offre proposee pour une demande (UC-MKT-02). Generee par
 * MockOfferGenerationService en V1 - voir sa Javadoc pour le detail de la
 * simplification assumee (pas de vrai moteur de matching dans ce perimetre).
 */
@Entity
@Table(name = "offers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Offer {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "shipment_request_id", nullable = false)
    private UUID shipmentRequestId;

    @Column(name = "carrier_display_name", nullable = false, length = 150)
    private String carrierDisplayName;

    @Column(name = "carrier_rating", nullable = false, precision = 2, scale = 1)
    private BigDecimal carrierRating;

    @Column(name = "price_xaf", nullable = false, precision = 12, scale = 2)
    private BigDecimal priceXaf;

    @Column(name = "estimated_pickup_at", nullable = false)
    private Instant estimatedPickupAt;

    @Column(name = "estimated_delivery_at", nullable = false)
    private Instant estimatedDeliveryAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private OfferStatus status = OfferStatus.PROPOSEE;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = Instant.now();
    }
}
