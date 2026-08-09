-- V2 : table des comptes chargeurs (particulier ou entreprise).
-- account_level suit le KYC gradue a 3 niveaux du CDC (RG-011).
-- pin_hash : jamais le PIN en clair, uniquement son hachage BCrypt.
CREATE TABLE users (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_type           VARCHAR(20) NOT NULL,
    first_name             VARCHAR(100) NOT NULL,
    last_name              VARCHAR(100) NOT NULL,
    phone_number           VARCHAR(20) NOT NULL UNIQUE,
    pin_hash               VARCHAR(100) NOT NULL,
    account_level          VARCHAR(20) NOT NULL DEFAULT 'NIVEAU_0',
    phone_verified         BOOLEAN NOT NULL DEFAULT FALSE,
    failed_login_attempts  SMALLINT NOT NULL DEFAULT 0,
    locked_until           TIMESTAMPTZ,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_phone_number ON users (phone_number);
