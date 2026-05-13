-- =============================================
-- School Plugin - Migration: Registro Auxiliar de Evaluación
-- =============================================

CREATE TABLE IF NOT EXISTS plugin_school_registro_auxiliar (
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

CREATE TABLE IF NOT EXISTS plugin_school_registro_aux_competencia (
    id              INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    registro_id     INT UNSIGNED NOT NULL,
    competencia_id  INT UNSIGNED NOT NULL,
    is_transversal  TINYINT(1) NOT NULL DEFAULT 0,
    order_index     INT NOT NULL DEFAULT 0,
    UNIQUE KEY unique_comp (registro_id, competencia_id, is_transversal),
    KEY idx_registro (registro_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS plugin_school_registro_aux_capacidad (
    id               INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    registro_comp_id INT UNSIGNED NOT NULL,
    capacidad_id     INT UNSIGNED NOT NULL,
    is_transversal   TINYINT(1) NOT NULL DEFAULT 0,
    order_index      INT NOT NULL DEFAULT 0,
    UNIQUE KEY unique_cap (registro_comp_id, capacidad_id, is_transversal),
    KEY idx_comp (registro_comp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS plugin_school_registro_aux_nota (
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
