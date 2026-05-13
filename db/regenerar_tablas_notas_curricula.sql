-- ================================================================
-- REGENERAR TABLAS: Registro Auxiliar + Curricula Enfoques Valores
-- School Plugin - Play School
-- ================================================================
-- ADVERTENCIA: Este script elimina y recrea las tablas indicadas.
-- Los datos existentes en estas tablas se perderán.
-- Tablas que NO se tocan: matricula, pagos, asistencia, usuarios, etc.
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

-- Seed valores usando el nombre del enfoque (independiente del ID)
INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Conciencia de derechos', 1
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Derechos%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Libertad y responsabilidad', 2
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Derechos%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Diálogo y concertación', 3
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Derechos%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Respeto por las diferencias', 1
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Inclusiv%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Equidad en la enseñanza', 2
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Inclusiv%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Confianza en la persona', 3
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Inclusiv%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Respeto a la identidad cultural', 1
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Intercultural%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Justicia', 2
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Intercultural%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Diálogo intercultural', 3
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Intercultural%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Igualdad y dignidad', 1
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Género%' OR e.name LIKE '%Genero%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Justicia', 2
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Género%' OR e.name LIKE '%Genero%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Empatía', 3
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Género%' OR e.name LIKE '%Genero%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Solidaridad planetaria y equidad intergeneracional', 1
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Ambiental%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Justicia y solidaridad', 2
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Ambiental%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Respeto a toda forma de vida', 3
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Ambiental%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Equidad y justicia', 1
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Bien Com%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Solidaridad', 2
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Bien Com%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Empatía', 3
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Bien Com%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Responsabilidad', 4
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Bien Com%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Flexibilidad y apertura', 1
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Excelencia%' LIMIT 1;

INSERT INTO plugin_school_curricula_enfoque_valor (enfoque_id, name, order_index)
SELECT e.id, 'Superación personal', 2
FROM plugin_school_curricula_enfoque e WHERE e.name LIKE '%Excelencia%' LIMIT 1;

-- ----------------------------------------------------------------
-- 3. REGISTRO AUXILIAR (cabecera)
-- ----------------------------------------------------------------
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

-- ----------------------------------------------------------------
-- 4. COMPETENCIAS DEL REGISTRO
-- ----------------------------------------------------------------
CREATE TABLE plugin_school_registro_aux_competencia (
    id              INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    registro_id     INT UNSIGNED NOT NULL,
    competencia_id  INT UNSIGNED NOT NULL,
    is_transversal  TINYINT(1) NOT NULL DEFAULT 0,
    order_index     INT NOT NULL DEFAULT 0,
    UNIQUE KEY unique_comp (registro_id, competencia_id, is_transversal),
    KEY idx_registro (registro_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------
-- 5. CAPACIDADES DEL REGISTRO (con campo criterio)
-- ----------------------------------------------------------------
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

-- ----------------------------------------------------------------
-- 6. NOTAS POR ALUMNO
-- ----------------------------------------------------------------
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

-- ----------------------------------------------------------------
-- 7. ENFOQUES VINCULADOS AL REGISTRO
-- ----------------------------------------------------------------
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
-- FIN
-- ================================================================
