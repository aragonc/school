-- =============================================
-- School Plugin - Migration: DNI VARCHAR(20)
-- =============================================
-- Amplía la columna dni de CHAR(8) a VARCHAR(20)
-- en las tablas plugin_school_ficha y
-- plugin_school_matricula_padre, para soportar
-- Carnet de Extranjería (12-16 chars), Pasaporte
-- y otros documentos de más de 8 caracteres.
--
-- Seguro de ejecutar en instalaciones existentes.
-- No elimina ni modifica datos existentes.
-- =============================================

ALTER TABLE plugin_school_ficha
    MODIFY COLUMN dni VARCHAR(20) NULL;

ALTER TABLE plugin_school_matricula_padre
    MODIFY COLUMN dni VARCHAR(20) NULL;
