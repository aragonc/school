-- =============================================
-- School Plugin - Migration: Support Guest Fields
-- =============================================
-- Agrega campos para tickets enviados desde el
-- login (sin sesión iniciada).
-- Seguro de ejecutar en instalaciones existentes:
-- usar el script PHP adjunto para MySQL < 8.
-- =============================================

-- NOTA: MySQL < 8.0 no soporta ADD COLUMN IF NOT EXISTS.
-- Ejecutar el siguiente bloque solo si las columnas NO existen:

-- Verificar antes con: DESCRIBE plugin_school_support_ticket;

ALTER TABLE plugin_school_support_ticket
    ADD COLUMN guest_name     VARCHAR(150) NULL AFTER user_id,
    ADD COLUMN guest_email    VARCHAR(150) NULL AFTER guest_name,
    ADD COLUMN guest_whatsapp VARCHAR(30)  NULL AFTER guest_email;
