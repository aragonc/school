-- =============================================
-- School Plugin - Migration: Niveles Docente
-- =============================================
-- Agrega la columna niveles_docente a la tabla
-- plugin_school_extra_profile para registrar
-- los niveles de enseñanza de cada docente
-- (inicial, primaria, secundaria).
-- Seguro de ejecutar en instalaciones existentes.
-- =============================================

-- NOTA: MySQL < 8.0 no soporta ADD COLUMN IF NOT EXISTS.
-- Verificar antes con: DESCRIBE plugin_school_extra_profile;

ALTER TABLE plugin_school_extra_profile
    ADD COLUMN niveles_docente VARCHAR(100) NULL AFTER estatura;
