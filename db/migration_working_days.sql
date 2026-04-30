-- =============================================
-- School Plugin - Migration: Días que labora
-- =============================================
-- Agrega la columna working_days a la tabla
-- plugin_school_extra_profile para registrar
-- los días de la semana en que cada usuario
-- asiste a laborar (lunes,martes,...,viernes).
-- Solo se generará ausencia automática en los
-- días configurados. Si el campo está vacío se
-- considera que labora todos los días hábiles.
-- Seguro de ejecutar en instalaciones existentes.
-- =============================================

-- NOTA: MySQL < 8.0 no soporta ADD COLUMN IF NOT EXISTS.
-- Verificar antes con: DESCRIBE plugin_school_extra_profile;

ALTER TABLE plugin_school_extra_profile
    ADD COLUMN working_days VARCHAR(50) NULL AFTER niveles_docente;
