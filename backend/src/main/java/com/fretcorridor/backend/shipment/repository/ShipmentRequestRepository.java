package com.fretcorridor.backend.shipment.repository;

import com.fretcorridor.backend.shipment.entity.ShipmentRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ShipmentRequestRepository extends JpaRepository<ShipmentRequest, UUID> {

    // Isolation stricte : un chargeur ne doit jamais lire les demandes d'un
    // autre (regle de securite du plan, Sprint 7 anticipee des maintenant
    // en filtrant systematiquement par userId).
    List<ShipmentRequest> findByUserIdOrderByCreatedAtDesc(UUID userId);

    Optional<ShipmentRequest> findByIdAndUserId(UUID id, UUID userId);
}
