-- V7 : paiement associe a une offre acceptee (UC-PAY-01). Un seul paiement
-- reussi possible par shipment_request (contrainte metier, comme pour les
-- offres). SimulatedPaymentProvider en V1 - pas de vrai MTN MoMo/Orange
-- Money (repousse en Phase 2, cf. plan §1) : le champ provider_reference
-- existe deja pour accueillir une vraie reference operateur plus tard,
-- sans migration supplementaire.
CREATE TABLE payments (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_request_id   UUID NOT NULL REFERENCES shipment_requests(id) ON DELETE CASCADE,
    offer_id              UUID NOT NULL REFERENCES offers(id),
    user_id               UUID NOT NULL REFERENCES users(id),
    amount_xaf            NUMERIC(12,2) NOT NULL,
    provider              VARCHAR(30) NOT NULL DEFAULT 'SIMULATED',
    provider_reference    VARCHAR(100),
    status                VARCHAR(20) NOT NULL DEFAULT 'EN_ATTENTE',
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_payments_shipment_request_id ON payments (shipment_request_id);
CREATE INDEX idx_payments_user_id ON payments (user_id);

-- Un seul paiement reussi par demande.
CREATE UNIQUE INDEX idx_payments_succeeded_unique
    ON payments (shipment_request_id)
    WHERE status = 'REUSSI';
