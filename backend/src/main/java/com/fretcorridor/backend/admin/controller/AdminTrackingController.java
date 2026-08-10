package com.fretcorridor.backend.admin.controller;

import com.fretcorridor.backend.admin.dto.AdminDeliveryProofRequest;
import com.fretcorridor.backend.admin.dto.AdminPositionUpdateRequest;
import com.fretcorridor.backend.admin.dto.AdminStatusUpdateRequest;
import com.fretcorridor.backend.tracking.service.ShipmentTrackingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * Mini-outil interne (protege par AdminApiKeyInterceptor, pas par JWT) qui
 * injecte les mises a jour de statut/position/preuve normalement produites
 * par une app chauffeur - hors perimetre pour ce projet solo.
 */
@RestController
@RequestMapping("/api/admin/shipment-requests")
@RequiredArgsConstructor
public class AdminTrackingController {

    private final ShipmentTrackingService trackingService;

    @PostMapping("/{id}/status")
    public ResponseEntity<Void> updateStatus(@PathVariable UUID id, @Valid @RequestBody AdminStatusUpdateRequest request) {
        trackingService.changeStatusAsAdmin(id, request.status());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/position")
    public ResponseEntity<Void> updatePosition(@PathVariable UUID id, @Valid @RequestBody AdminPositionUpdateRequest request) {
        trackingService.recordPosition(id, request.lat(), request.lng());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/delivery-proof")
    public ResponseEntity<Void> deliveryProof(@PathVariable UUID id, @Valid @RequestBody AdminDeliveryProofRequest request) {
        trackingService.recordDeliveryProof(id, request.photoUrl());
        return ResponseEntity.noContent().build();
    }
}
