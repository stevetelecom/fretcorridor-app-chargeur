-- V8 : historique des etats + derniere position connue + preuve de
-- livraison, pour le suivi cote chargeur (UC-MKT-03, UC-EXE-03 partie
-- client). Alimente uniquement par le mini-outil admin (module admin),
-- qui remplace l'app chauffeur reelle hors perimetre pour ce solo.
CREATE TABLE shipment_status_history (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_request_id  UUID NOT NULL REFERENCES shipment_requests(id) ON DELETE CASCADE,
    status               VARCHAR(20) NOT NULL,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_shipment_status_history_request ON shipment_status_history (shipment_request_id);

-- Position simplifiee a un seul point "dernier connu" (pas d'historique de
-- trajet) : suffisant pour l'app chargeur seule (RG-043 : afficher l'age de
-- la position, pas un flux GPS continu).
ALTER TABLE shipment_requests
    ADD COLUMN last_position_lat DOUBLE PRECISION,
    ADD COLUMN last_position_lng DOUBLE PRECISION,
    ADD COLUMN last_position_recorded_at TIMESTAMPTZ,
    ADD COLUMN delivery_proof_photo_url VARCHAR(500),
    ADD COLUMN delivered_at TIMESTAMPTZ;
