package com.fretcorridor.backend.payment.repository;

import com.fretcorridor.backend.payment.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {
    Optional<Payment> findByShipmentRequestIdAndUserId(UUID shipmentRequestId, UUID userId);
}
