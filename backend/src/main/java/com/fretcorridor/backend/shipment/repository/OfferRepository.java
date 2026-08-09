package com.fretcorridor.backend.shipment.repository;

import com.fretcorridor.backend.shipment.entity.Offer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OfferRepository extends JpaRepository<Offer, UUID> {
    List<Offer> findByShipmentRequestIdOrderByPriceXafAsc(UUID shipmentRequestId);
    Optional<Offer> findByIdAndShipmentRequestId(UUID id, UUID shipmentRequestId);
}
