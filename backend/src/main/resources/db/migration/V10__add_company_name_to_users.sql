-- Raison sociale, requise uniquement pour les comptes ENTREPRISE
-- (CDC UC-IDA-02 etape 1). Nullable en base : la contrainte "obligatoire
-- si ENTREPRISE" est une regle metier appliquee dans AuthService, pas une
-- contrainte de colonne (un compte PARTICULIER n'en a jamais).
ALTER TABLE users ADD COLUMN company_name VARCHAR(200);
