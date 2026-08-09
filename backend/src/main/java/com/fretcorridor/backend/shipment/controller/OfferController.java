package com.fretcorridor.backend.shipment.controller;

import com.fretcorridor.backend.shipment.dto.OfferResponse;
import com.fretcorridor.backend.shipment.service.OfferService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/shipment-requests/{shipmentRequestId}/offers")
@RequiredArgsConstructor
public class OfferController {

    private final OfferService offerService;

    @GetMapping
    public List<OfferResponse> list(Principal principal, @PathVariable UUID shipmentRequestId) {
        return offerService.listOrGenerate(UUID.fromString(principal.getName()), shipmentRequestId);
    }

    @PostMapping("/{offerId}/accept")
    public OfferResponse accept(
            Principal principal,
            @PathVariable UUID shipmentRequestId,
            @PathVariable UUID offerId) {
        return offerService.accept(UUID.fromString(principal.getName()), shipmentRequestId, offerId);
    }
}
