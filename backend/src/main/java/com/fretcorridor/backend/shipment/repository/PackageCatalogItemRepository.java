package com.fretcorridor.backend.shipment.repository;

import com.fretcorridor.backend.shipment.entity.PackageCatalogItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PackageCatalogItemRepository extends JpaRepository<PackageCatalogItem, UUID> {
    List<PackageCatalogItem> findByActiveTrueOrderByCategoryAscLabelAsc();
}
