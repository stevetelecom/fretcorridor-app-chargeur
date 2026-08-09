-- V6 : offres associees a une demande publiee (UC-MKT-02). Generees pour
-- l'instant par MockOfferGenerationService (pas de vrai moteur MAT/OPT dans
-- ce perimetre solo, cf. note Sprint 2/3) - le contrat de donnees est concu
-- pour rester identique quand un vrai moteur sera branche.
CREATE TABLE offers (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_request_id  UUID NOT NULL REFERENCES shipment_requests(id) ON DELETE CASCADE,
    carrier_display_name VARCHAR(150) NOT NULL,
    carrier_rating       NUMERIC(2,1) NOT NULL,
    price_xaf            NUMERIC(12,2) NOT NULL,
    estimated_pickup_at  TIMESTAMPTZ NOT NULL,
    estimated_delivery_at TIMESTAMPTZ NOT NULL,
    status               VARCHAR(20) NOT NULL DEFAULT 'PROPOSEE',
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_offers_shipment_request_id ON offers (shipment_request_id);

-- Une seule offre acceptee possible par demande (contrainte metier UC-MKT-03).
CREATE UNIQUE INDEX idx_offers_accepted_unique
    ON offers (shipment_request_id)
    WHERE status = 'ACCEPTEE';
