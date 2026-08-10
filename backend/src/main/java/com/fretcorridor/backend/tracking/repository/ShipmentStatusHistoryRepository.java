package com.fretcorridor.backend.tracking.repository;

import com.fretcorridor.backend.tracking.entity.ShipmentStatusHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ShipmentStatusHistoryRepository extends JpaRepository<ShipmentStatusHistory, UUID> {
    List<ShipmentStatusHistory> findByShipmentRequestIdOrderByCreatedAtAsc(UUID shipmentRequestId);
}
