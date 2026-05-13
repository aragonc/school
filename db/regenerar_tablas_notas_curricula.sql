-- ================================================================
-- REGENERAR TABLAS: Registro Auxiliar + Curricula Enfoques Valores
-- School Plugin - Play School
-- ================================================================
-- Elimina y recrea las tablas indicadas.
-- Los datos existentes en estas tablas se perderán.
-- ================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------
-- 1. PERÍODOS ACADÉMICOS
-- ----------------------------------------------------------------
DROP TABLE IF EXISTS plugin_school_academic_period;
CREATE TABLE plugin_school_academic_period (
    id               INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    academic_year_id INT UNSIGNED NOT NULL,
    name             VARCHAR(100) NOT NULL,
    date_start       DATE NOT NULL,
    date_end         DATE NOT NULL,
    active           TINYINT(1) NOT NULL DEFAULT 1,
    order_index      INT NOT NULL DEFAULT 0,
    KEY idx_year (academic_year_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------
-- 2. VALORES DE ENFOQUES TRANSVERSALES
-- ----------------------------------------------------------------
DROP TABLE IF EXISTS plugin_school_curricula_enfoque_valor;
CREATE TABLE plugin_school_curricula_enfoque_valor (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    enfoque_id  INT UNSIGNED NOT NULL,
    name        VARCHAR(300) NOT NULL,
    active      TINYINT(1) NOT NULL DEFAULT 1,
    order_index INT NOT NULL DEFAULT 0,
    KEY idx_enfoque (enfoque_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- SEED EBR (nombres: "Enfoque de derechos", "Inclusivo o de
-- atención a la diversidad", "Intercultural", "Igualdad de
-- género", "Ambiental", "Orientación al bien común",
-- "Búsqueda de la excelencia")
-- ================================================================

-- 1. Enfoque de Derechos EBR
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Conciencia de derechos', 1
FROM plugin_school_curricula_enfoque WHERE name = 'Enfoque de derechos' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Libertad y responsabilidad', 2
FROM plugin_school_curricula_enfoque WHERE name = 'Enfoque de derechos' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Diálogo y concertación', 3
FROM plugin_school_curricula_enfoque WHERE name = 'Enfoque de derechos' AND level = 'ebr';

-- 2. Inclusivo o de Atención a la Diversidad EBR
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Respeto por las diferencias', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%nclusi%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Equidad en la enseñanza', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%nclusi%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Confianza en la persona', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%nclusi%' AND level = 'ebr';

-- 3. Intercultural EBR
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Respeto a la identidad cultural', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ntercultural%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Justicia', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ntercultural%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Diálogo intercultural', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ntercultural%' AND level = 'ebr';

-- 4. Igualdad de Género EBR
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Igualdad y dignidad', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%gualdad%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Justicia', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%gualdad%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Empatía', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%gualdad%' AND level = 'ebr';

-- 5. Ambiental EBR
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Solidaridad planetaria y equidad intergeneracional', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%mbiental%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Justicia y solidaridad', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%mbiental%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Respeto a toda forma de vida', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%mbiental%' AND level = 'ebr';

-- 6. Orientación al Bien Común EBR
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Equidad y justicia', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ien com%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Solidaridad', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ien com%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Empatía', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ien com%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Responsabilidad', 4
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ien com%' AND level = 'ebr';

-- 7. Búsqueda de la Excelencia EBR
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Flexibilidad y apertura', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%xcelencia%' AND level = 'ebr';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Superación personal', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%xcelencia%' AND level = 'ebr';

-- ================================================================
-- SEED INICIAL (nombres: "Enfoque de derechos", "Inclusión y
-- diversidad", "Interculturalidad", "Igualdad de género",
-- "Ambiental", "Bien común", "Excelencia")
-- ================================================================

-- 1. Enfoque de Derechos Inicial
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Conciencia de derechos', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%erechos%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Libertad y responsabilidad', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%erechos%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Diálogo y concertación', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%erechos%' AND level = 'inicial';

-- 2. Inclusión y Diversidad Inicial
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Respeto por las diferencias', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%nclusi%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Equidad', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%nclusi%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Confianza en la persona', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%nclusi%' AND level = 'inicial';

-- 3. Interculturalidad Inicial
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Respeto a la identidad cultural', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ntercultural%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Justicia', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ntercultural%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Diálogo intercultural', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ntercultural%' AND level = 'inicial';

-- 4. Igualdad de Género Inicial
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Igualdad y dignidad', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%gualdad%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Justicia', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%gualdad%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Empatía', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%gualdad%' AND level = 'inicial';

-- 5. Ambiental Inicial
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Solidaridad planetaria', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%mbiental%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Justicia y solidaridad', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%mbiental%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Respeto a toda forma de vida', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%mbiental%' AND level = 'inicial';

-- 6. Bien Común Inicial
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Equidad y justicia', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ien com%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Solidaridad', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ien com%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Empatía', 3
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ien com%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Responsabilidad', 4
FROM plugin_school_curricula_enfoque WHERE name LIKE '%ien com%' AND level = 'inicial';

-- 7. Excelencia Inicial
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Superación personal', 1
FROM plugin_school_curricula_enfoque WHERE name LIKE '%xcelencia%' AND level = 'inicial';
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT id, 'Flexibilidad y apertura', 2
FROM plugin_school_curricula_enfoque WHERE name LIKE '%xcelencia%' AND level = 'inicial';

-- ================================================================
-- FALLBACK: si los enfoques no tienen level asignado ('ambos')
-- inserta para los que aún no tienen valores
-- ================================================================
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Conciencia de derechos', 1
FROM plugin_school_curricula_enfoque e
WHERE e.name LIKE '%erechos%' AND e.level = 'ambos'
AND NOT EXISTS (SELECT 1 FROM plugin_school_curricula_enfoque_valor v WHERE v.enfoque_id = e.id);

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Libertad y responsabilidad', 2
FROM plugin_school_curricula_enfoque e
WHERE e.name LIKE '%erechos%' AND e.level = 'ambos'
AND NOT EXISTS (SELECT 1 FROM plugin_school_curricula_enfoque_valor v WHERE v.enfoque_id = e.id AND v.order_index = 2);

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Diálogo y concertación', 3
FROM plugin_school_curricula_enfoque e
WHERE e.name LIKE '%erechos%' AND e.level = 'ambos'
AND NOT EXISTS (SELECT 1 FROM plugin_school_curricula_enfoque_valor v WHERE v.enfoque_id = e.id AND v.order_index = 3);

-- ================================================================
-- 3. REGISTRO AUXILIAR Y TABLAS RELACIONADAS
-- ================================================================
DROP TABLE IF EXISTS plugin_school_registro_aux_nota;
DROP TABLE IF EXISTS plugin_school_registro_aux_capacidad;
DROP TABLE IF EXISTS plugin_school_registro_aux_competencia;
DROP TABLE IF EXISTS plugin_school_registro_aux_enfoque;
DROP TABLE IF EXISTS plugin_school_registro_auxiliar;

CREATE TABLE plugin_school_registro_auxiliar (
    id                  INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    classroom_course_id INT UNSIGNED NOT NULL,
    period              VARCHAR(50) NOT NULL DEFAULT 'I BIMESTRE',
    grade_type          ENUM('numeric','letter','combined') NOT NULL DEFAULT 'letter',
    area_id             INT UNSIGNED NOT NULL DEFAULT 0,
    created_by          INT NOT NULL,
    created_at          DATETIME NOT NULL,
    updated_at          DATETIME NOT NULL,
    UNIQUE KEY unique_register (classroom_course_id, period),
    KEY idx_classroom_course (classroom_course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plugin_school_registro_aux_competencia (
    id              INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    registro_id     INT UNSIGNED NOT NULL,
    competencia_id  INT UNSIGNED NOT NULL,
    is_transversal  TINYINT(1) NOT NULL DEFAULT 0,
    order_index     INT NOT NULL DEFAULT 0,
    UNIQUE KEY unique_comp (registro_id, competencia_id, is_transversal),
    KEY idx_registro (registro_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plugin_school_registro_aux_capacidad (
    id               INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    registro_comp_id INT UNSIGNED NOT NULL,
    capacidad_id     INT UNSIGNED NOT NULL,
    is_transversal   TINYINT(1) NOT NULL DEFAULT 0,
    order_index      INT NOT NULL DEFAULT 0,
    criterio         VARCHAR(300) NOT NULL DEFAULT '',
    UNIQUE KEY unique_cap (registro_comp_id, capacidad_id, is_transversal),
    KEY idx_comp (registro_comp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plugin_school_registro_aux_nota (
    id               INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    registro_id      INT UNSIGNED NOT NULL,
    aux_capacidad_id INT UNSIGNED NOT NULL,
    student_id       INT NOT NULL,
    nota             VARCHAR(10) NOT NULL DEFAULT '',
    updated_at       DATETIME NOT NULL,
    UNIQUE KEY unique_nota (registro_id, aux_capacidad_id, student_id),
    KEY idx_registro (registro_id),
    KEY idx_student (student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plugin_school_registro_aux_enfoque (
    id           INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    registro_id  INT UNSIGNED NOT NULL,
    enfoque_id   INT UNSIGNED NOT NULL DEFAULT 0,
    nombre       VARCHAR(300) NOT NULL DEFAULT '',
    valores      TEXT NOT NULL,
    actitudes    TEXT NOT NULL,
    order_index  INT NOT NULL DEFAULT 0,
    KEY idx_registro (registro_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- FIN — Ejecutar en el VPS:
-- mysql -u USUARIO -p BASEDEDATOS < regenerar_tablas_notas_curricula.sql
-- ================================================================
