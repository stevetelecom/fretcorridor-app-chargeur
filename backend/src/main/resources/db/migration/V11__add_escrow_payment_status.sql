-- V9 : introduction du sequestre logique (fonds bloques jusqu'a
-- confirmation de livraison, cf. plan §1). REUSSI devient SEQUESTRE
-- (paiement confirme, fonds retenus) puis LIBERE (verses au transporteur,
-- declenche par ShipmentTrackingService.recordDeliveryProof lors du
-- passage a LIVREE). Migration de donnees defensive au cas ou un
-- paiement REUSSI existerait deja en base de demo.
UPDATE payments SET status = 'SEQUESTRE' WHERE status = 'REUSSI';

DROP INDEX idx_payments_succeeded_unique;

-- Un seul paiement "actif" (fonds retenus ou deja verses) par demande.
CREATE UNIQUE INDEX idx_payments_succeeded_unique
    ON payments (shipment_request_id)
    WHERE status IN ('SEQUESTRE', 'LIBERE');
