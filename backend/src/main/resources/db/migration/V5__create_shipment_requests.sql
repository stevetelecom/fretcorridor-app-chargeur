-- V5 : demandes de transport publiees par un chargeur (UC-MKT-01).
-- pickup/destination restent de simples colonnes latitude/longitude
-- (DOUBLE PRECISION) - pas de service GEO dedie ni de type geography
-- PostGIS complexe, conformement au plan §2.1 (besoin hors perimetre pour
-- une app chargeur seule ; l'extension PostGIS reste activee pour un futur
-- usage sans etre exploitee ici).
CREATE TABLE shipment_requests (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status                  VARCHAR(20) NOT NULL DEFAULT 'BROUILLON',

    pickup_address          VARCHAR(255) NOT NULL,
    pickup_lat              DOUBLE PRECISION NOT NULL,
    pickup_lng              DOUBLE PRECISION NOT NULL,

    destination_address     VARCHAR(255) NOT NULL,
    destination_lat         DOUBLE PRECISION NOT NULL,
    destination_lng         DOUBLE PRECISION NOT NULL,

    package_catalog_item_id UUID NOT NULL REFERENCES package_catalog_items(id),
    quantity                INTEGER NOT NULL,
    fragile                 BOOLEAN NOT NULL DEFAULT FALSE,
    total_weight_kg         NUMERIC(10,2) NOT NULL,
    total_volume_m3         NUMERIC(10,3) NOT NULL,
    taxable_weight_kg       NUMERIC(10,2) NOT NULL,

    requested_pickup_date   DATE NOT NULL,
    delivery_mode           VARCHAR(20) NOT NULL,
    recipient_name          VARCHAR(150) NOT NULL,
    recipient_phone         VARCHAR(20) NOT NULL,

    estimated_price_min     NUMERIC(12,2) NOT NULL,
    estimated_price_max     NUMERIC(12,2) NOT NULL,

    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_shipment_requests_user_id ON shipment_requests (user_id);
CREATE INDEX idx_shipment_requests_status ON shipment_requests (status);
