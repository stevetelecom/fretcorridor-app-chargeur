package com.fretcorridor.backend.shipment.service;

import com.fretcorridor.backend.common.exception.ApiException;
import com.fretcorridor.backend.shipment.dto.*;
import com.fretcorridor.backend.shipment.entity.PackageCatalogItem;
import com.fretcorridor.backend.shipment.entity.ShipmentRequest;
import com.fretcorridor.backend.shipment.entity.ShipmentStatus;
import com.fretcorridor.backend.shipment.repository.PackageCatalogItemRepository;
import com.fretcorridor.backend.shipment.repository.ShipmentRequestRepository;
import com.fretcorridor.backend.tracking.service.ShipmentTrackingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ShipmentService {

    private final PackageCatalogItemRepository catalogRepository;
    private final ShipmentRequestRepository shipmentRepository;
    private final PriceEstimationService priceEstimationService;
    private final ShipmentTrackingService trackingService;

    @Transactional(readOnly = true)
    public List<PackageCatalogItemResponse> listCatalog() {
        return catalogRepository.findByActiveTrueOrderByCategoryAscLabelAsc().stream()
                .map(this::toCatalogResponse)
                .toList();
    }

    @Transactional
    public ShipmentRequestResponse create(UUID userId, ShipmentRequestCreateRequest request) {
        PackageCatalogItem item = catalogRepository.findById(request.packageCatalogItemId())
                .filter(PackageCatalogItem::isActive)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Type de colis invalide"));

        BigDecimal totalWeightKg = item.getDefaultWeightKg()
                .multiply(BigDecimal.valueOf(request.quantity()));
        BigDecimal totalVolumeM3 = item.getDefaultVolumeM3()
                .multiply(BigDecimal.valueOf(request.quantity()));

        BigDecimal taxableWeightKg = priceEstimationService.computeTaxableWeightKg(totalWeightKg, totalVolumeM3);

        boolean express = request.deliveryMode().name().equals("EXPRESS");
        var priceRange = priceEstimationService.estimate(taxableWeightKg, express);

        // fragile : force a true si le catalogue le marque par defaut, meme
        // si le chargeur a laisse la case decochee par erreur - securite
        // metier plutot que confiance aveugle dans l'input.
        boolean fragile = request.fragile() || item.isFragileByDefault();

        // Statut initial pose via trackingService juste apres l'insert (et non
        // dans le builder) afin que la creation de la demande genere aussi la
        // toute premiere ligne de la chronologie d'etats.
        ShipmentRequest entity = ShipmentRequest.builder()
                .userId(userId)
                .pickupAddress(request.pickupAddress().trim())
                .pickupLat(request.pickupLat())
                .pickupLng(request.pickupLng())
                .destinationAddress(request.destinationAddress().trim())
                .destinationLat(request.destinationLat())
                .destinationLng(request.destinationLng())
                .packageCatalogItemId(item.getId())
                .quantity(request.quantity())
                .fragile(fragile)
                .totalWeightKg(totalWeightKg)
                .totalVolumeM3(totalVolumeM3)
                .taxableWeightKg(taxableWeightKg)
                .requestedPickupDate(request.requestedPickupDate())
                .deliveryMode(request.deliveryMode())
                .recipientName(request.recipientName().trim())
                .recipientPhone(request.recipientPhone())
                .estimatedPriceMin(priceRange.min())
                .estimatedPriceMax(priceRange.max())
                .build();

        entity = shipmentRepository.save(entity);
        trackingService.changeStatus(entity, ShipmentStatus.PUBLIEE);
        return toResponse(entity, item);
    }

    @Transactional(readOnly = true)
    public List<ShipmentRequestResponse> listMine(UUID userId) {
        return shipmentRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(sr -> toResponse(sr, requireCatalogItem(sr.getPackageCatalogItemId())))
                .toList();
    }

    /**
     * Republication (Sprint 6, UC historique). Reconstruit une
     * ShipmentRequestCreateRequest a partir de la demande source et
     * delegue a create() - garantit que la republication passe exactement
     * par la meme validation (catalogue toujours actif, etc.) et le meme
     * calcul de prix que toute nouvelle demande, sans dupliquer cette
     * logique ici.
     */
    @Transactional
    public ShipmentRequestResponse republish(UUID userId, UUID sourceId, LocalDate newPickupDate) {
        ShipmentRequest source = shipmentRepository.findByIdAndUserId(sourceId, userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Demande introuvable"));

        ShipmentRequestCreateRequest request = new ShipmentRequestCreateRequest(
                source.getPickupAddress(), source.getPickupLat(), source.getPickupLng(),
                source.getDestinationAddress(), source.getDestinationLat(), source.getDestinationLng(),
                source.getPackageCatalogItemId(), source.getQuantity(), source.isFragile(),
                newPickupDate, source.getDeliveryMode(),
                source.getRecipientName(), source.getRecipientPhone());

        return create(userId, request);
    }

    @Transactional(readOnly = true)
    public ShipmentRequestResponse getOne(UUID userId, UUID shipmentRequestId) {
        ShipmentRequest entity = shipmentRepository.findByIdAndUserId(shipmentRequestId, userId)
                // 404 (pas 403) volontairement : ne pas confirmer a un tiers
                // qu'une demande d'un autre utilisateur existe.
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Demande introuvable"));
        return toResponse(entity, requireCatalogItem(entity.getPackageCatalogItemId()));
    }

    private PackageCatalogItem requireCatalogItem(UUID id) {
        return catalogRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Catalogue incoherent"));
    }

    private PackageCatalogItemResponse toCatalogResponse(PackageCatalogItem item) {
        return new PackageCatalogItemResponse(
                item.getId(), item.getCode(), item.getLabel(), item.getCategory(),
                item.getDefaultWeightKg(), item.getDefaultVolumeM3(),
                item.isFragileByDefault(), item.getIconName());
    }

    private ShipmentRequestResponse toResponse(ShipmentRequest sr, PackageCatalogItem item) {
        return new ShipmentRequestResponse(
                sr.getId(), sr.getStatus(),
                sr.getPickupAddress(), sr.getPickupLat(), sr.getPickupLng(),
                sr.getDestinationAddress(), sr.getDestinationLat(), sr.getDestinationLng(),
                toCatalogResponse(item), sr.getQuantity(), sr.isFragile(),
                sr.getTotalWeightKg(), sr.getTotalVolumeM3(),
                sr.getRequestedPickupDate(), sr.getDeliveryMode(),
                sr.getRecipientName(), sr.getRecipientPhone(),
                sr.getEstimatedPriceMin(), sr.getEstimatedPriceMax(), sr.getCreatedAt());
    }
}
