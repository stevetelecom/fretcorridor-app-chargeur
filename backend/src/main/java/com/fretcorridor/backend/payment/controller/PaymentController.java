package com.fretcorridor.backend.payment.controller;

import com.fretcorridor.backend.payment.dto.InitiatePaymentRequest;
import com.fretcorridor.backend.payment.dto.PaymentResponse;
import com.fretcorridor.backend.payment.service.PaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.UUID;

@RestController
@RequestMapping("/api/shipment-requests/{shipmentRequestId}/payment")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping
    public PaymentResponse initiate(
            Principal principal,
            @PathVariable UUID shipmentRequestId,
            @Valid @RequestBody InitiatePaymentRequest request) {
        return paymentService.initiate(UUID.fromString(principal.getName()), shipmentRequestId, request.offerId());
    }

    @GetMapping
    public PaymentResponse get(Principal principal, @PathVariable UUID shipmentRequestId) {
        return paymentService.getForShipment(UUID.fromString(principal.getName()), shipmentRequestId);
    }
}
