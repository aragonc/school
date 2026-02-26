-- =============================================
-- School Plugin - Migration: Enrollment Documents
-- =============================================
-- Adds document checklist support to the enrollment form.
-- Safe to run on existing installations (IF NOT EXISTS).
-- =============================================

CREATE TABLE IF NOT EXISTS plugin_school_matricula_docs (
    id                          INT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ficha_id                    INT unsigned NOT NULL,
    doc_partida_nacimiento      TINYINT(1) NOT NULL DEFAULT 0,
    doc_copia_dni               TINYINT(1) NOT NULL DEFAULT 0,
    doc_libreta_calificaciones  TINYINT(1) NOT NULL DEFAULT 0,
    doc_ficha_matricula         TINYINT(1) NOT NULL DEFAULT 0,
    doc_certificado_estudios    TINYINT(1) NOT NULL DEFAULT 0,
    doc_constancia_conducta     TINYINT(1) NOT NULL DEFAULT 0,
    doc_foto_carnet             TINYINT(1) NOT NULL DEFAULT 0,
    doc_copia_dni_padres        TINYINT(1) NOT NULL DEFAULT 0,
    observaciones_docs          TEXT NULL,
    updated_at                  DATETIME NULL,
    UNIQUE KEY unique_ficha (ficha_id)
);
