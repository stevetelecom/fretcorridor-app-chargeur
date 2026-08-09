-- V4 : catalogue d'emballages/marchandises reduit a ~15 entrees (plan §1,
-- simplification assumee vs le catalogue complet du CDC). icon_name
-- reference un nom d'icone Material Symbols cote Flutter (pas d'emoji,
-- regle du guide ultime).
CREATE TABLE package_catalog_items (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code               VARCHAR(50) NOT NULL UNIQUE,
    label              VARCHAR(100) NOT NULL,
    category           VARCHAR(50) NOT NULL,
    default_weight_kg  NUMERIC(8,2) NOT NULL,
    default_volume_m3  NUMERIC(8,3) NOT NULL,
    fragile_by_default BOOLEAN NOT NULL DEFAULT FALSE,
    icon_name          VARCHAR(50) NOT NULL,
    active             BOOLEAN NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO package_catalog_items (code, label, category, default_weight_kg, default_volume_m3, fragile_by_default, icon_name) VALUES
('CARTON_STD',      'Carton standard',            'COLIS',     10.00, 0.060, FALSE, 'inventory_2'),
('CARTON_RENFORCE', 'Carton renforce',             'COLIS',     18.00, 0.090, FALSE, 'inventory_2'),
('DOCUMENT_A4',     'Colis document A4',           'COLIS',      0.50, 0.002, FALSE, 'description'),
('PALETTE_BOIS',    'Palette bois charge',         'PALETTE',  350.00, 1.440, FALSE, 'pallet'),
('SAC_RIZ_50',      'Sac de riz 50kg',              'VIVRES',    50.00, 0.070, FALSE, 'grain'),
('SAC_CIMENT_50',   'Sac de ciment 50kg',           'MATERIAUX', 50.00, 0.035, FALSE, 'construction'),
('BIDON_20L',       'Bidon 20L (liquide)',          'LIQUIDE',   22.00, 0.025, TRUE,  'water_drop'),
('CASIER_BOISSONS', 'Casier de boissons',           'LIQUIDE',   18.00, 0.030, TRUE,  'liquor'),
('FRIGO',           'Refrigerateur',                'ELECTROMENAGER', 65.00, 0.700, TRUE, 'kitchen'),
('TELEVISION',      'Television / ecran',           'ELECTRONIQUE', 12.00, 0.120, TRUE, 'tv'),
('MEUBLE_CANAPE',   'Meuble (canape)',              'MOBILIER', 45.00, 1.800, FALSE, 'chair'),
('MATELAS',         'Matelas',                      'MOBILIER', 20.00, 0.400, FALSE, 'bed'),
('VELO',            'Velo',                         'VEHICULE_LEGER', 15.00, 0.500, FALSE, 'directions_bike'),
('MOTO',            'Moto',                         'VEHICULE_LEGER', 110.00, 1.200, FALSE, 'two_wheeler'),
('GROUPE_ELECTRO',  'Groupe electrogene',           'EQUIPEMENT', 80.00, 0.350, TRUE, 'bolt');
