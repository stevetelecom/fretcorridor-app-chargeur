package com.fretcorridor.backend.shipment.controller;

import com.fretcorridor.backend.shipment.dto.*;
import com.fretcorridor.backend.shipment.service.ShipmentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ShipmentController {

    private final ShipmentService shipmentService;

    @GetMapping("/package-catalog")
    public List<PackageCatalogItemResponse> listCatalog() {
        return shipmentService.listCatalog();
    }

    @PostMapping("/shipment-requests")
    @ResponseStatus(HttpStatus.CREATED)
    public ShipmentRequestResponse create(
            Principal principal,
            @Valid @RequestBody ShipmentRequestCreateRequest request) {
        return shipmentService.create(UUID.fromString(principal.getName()), request);
    }

    @GetMapping("/shipment-requests")
    public List<ShipmentRequestResponse> listMine(Principal principal) {
        return shipmentService.listMine(UUID.fromString(principal.getName()));
    }

    @GetMapping("/shipment-requests/{id}")
    public ShipmentRequestResponse getOne(Principal principal, @PathVariable UUID id) {
        return shipmentService.getOne(UUID.fromString(principal.getName()), id);
    }
}
