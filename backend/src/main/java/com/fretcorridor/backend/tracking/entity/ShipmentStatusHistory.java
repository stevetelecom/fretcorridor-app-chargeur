package com.fretcorridor.backend.tracking.entity;

import com.fretcorridor.backend.shipment.entity.ShipmentStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Une ligne = un changement de statut d'une demande, horodate. Alimentee
 * uniquement par ShipmentTrackingService.changeStatus - jamais ecrite
 * directement ailleurs, pour garantir que la chronologie affichee au
 * chargeur ne peut pas manquer une transition.
 */
@Entity
@Table(name = "shipment_status_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShipmentStatusHistory {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "shipment_request_id", nullable = false)
    private UUID shipmentRequestId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ShipmentStatus status;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = Instant.now();
    }
}
