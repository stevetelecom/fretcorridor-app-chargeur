package com.fretcorridor.backend.payment.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "payments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "shipment_request_id", nullable = false)
    private UUID shipmentRequestId;

    @Column(name = "offer_id", nullable = false)
    private UUID offerId;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "amount_xaf", nullable = false, precision = 12, scale = 2)
    private BigDecimal amountXaf;

    @Column(nullable = false, length = 30)
    @Builder.Default
    private String provider = "SIMULATED";

    @Column(name = "provider_reference", length = 100)
    private String providerReference;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private PaymentStatus status = PaymentStatus.EN_ATTENTE;

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
