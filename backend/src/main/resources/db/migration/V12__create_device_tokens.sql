-- V9 : token FCM (Firebase Cloud Messaging) par utilisateur, pour les
-- notifications push (module notification, rattrape du Sprint 5). Un seul
-- token par utilisateur : simplification assumee pour ce perimetre solo
-- (hypothese un seul appareil actif ; un nouveau login ecrase l'ancien
-- token, ce qui est le comportement correct si l'utilisateur change de
-- telephone).
ALTER TABLE users
    ADD COLUMN fcm_token VARCHAR(255),
    ADD COLUMN fcm_token_updated_at TIMESTAMPTZ;
