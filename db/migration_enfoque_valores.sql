-- =============================================
-- School Plugin - Migration: Valores por Enfoque Transversal
-- =============================================

CREATE TABLE IF NOT EXISTS plugin_school_curricula_enfoque_valor (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    enfoque_id  INT UNSIGNED NOT NULL,
    name        VARCHAR(300) NOT NULL,
    active      TINYINT(1) NOT NULL DEFAULT 1,
    order_index INT NOT NULL DEFAULT 0,
    KEY idx_enfoque (enfoque_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- SEED: Valores para Enfoques EBR (IDs 1-7)
-- =============================================

-- 1. Enfoque de Derechos (id=1)
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index) VALUES
(1, 'Conciencia de derechos',       1),
(1, 'Libertad y responsabilidad',   2),
(1, 'Diálogo y concertación',       3);

-- 2. Enfoque Inclusivo o de Atención a la Diversidad (id=2)
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index) VALUES
(2, 'Respeto por las diferencias',  1),
(2, 'Equidad en la enseñanza',      2),
(2, 'Confianza en la persona',      3);

-- 3. Enfoque Intercultural (id=3)
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index) VALUES
(3, 'Respeto a la identidad cultural', 1),
(3, 'Justicia',                        2),
(3, 'Diálogo intercultural',           3);

-- 4. Enfoque de Igualdad de Género (id=4)
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index) VALUES
(4, 'Igualdad y dignidad', 1),
(4, 'Justicia',            2),
(4, 'Empatía',             3);

-- 5. Enfoque Ambiental (id=5)
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index) VALUES
(5, 'Solidaridad planetaria y equidad intergeneracional', 1),
(5, 'Justicia y solidaridad',                             2),
(5, 'Respeto a toda forma de vida',                       3);

-- 6. Enfoque de Orientación al Bien Común (id=6)
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index) VALUES
(6, 'Equidad y justicia', 1),
(6, 'Solidaridad',        2),
(6, 'Empatía',            3),
(6, 'Responsabilidad',    4);

-- 7. Enfoque de Búsqueda de la Excelencia (id=7)
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index) VALUES
(7, 'Flexibilidad y apertura', 1),
(7, 'Superación personal',     2);
