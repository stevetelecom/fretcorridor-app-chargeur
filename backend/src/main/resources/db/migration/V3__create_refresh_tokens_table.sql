-- V3 : refresh tokens opaques (pas des JWT), stockes hashes (SHA-256) pour
-- rester revocables individuellement - un JWT refresh ne peut pas etre
-- invalide avant son expiration naturelle, ce qui est inacceptable pour
-- un token longue duree (7 jours par defaut, JWT_REFRESH_EXPIRATION_MS).
CREATE TABLE refresh_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  VARCHAR(255) NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ NOT NULL,
    revoked     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens (user_id);
