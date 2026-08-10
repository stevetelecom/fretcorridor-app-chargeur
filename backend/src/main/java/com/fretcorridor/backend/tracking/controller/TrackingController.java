package com.fretcorridor.backend.tracking.controller;

import com.fretcorridor.backend.tracking.dto.ShipmentTrackingResponse;
import com.fretcorridor.backend.tracking.service.ShipmentTrackingService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.UUID;

// Meme pattern que ShipmentController : Principal.getName() = UUID de
// l'utilisateur authentifie (pose par JwtAuthenticationFilter).
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class TrackingController {

    private final ShipmentTrackingService trackingService;

    @GetMapping("/shipment-requests/{id}/tracking")
    public ShipmentTrackingResponse getTracking(Principal principal, @PathVariable UUID id) {
        return trackingService.getTracking(UUID.fromString(principal.getName()), id);
    }
}
