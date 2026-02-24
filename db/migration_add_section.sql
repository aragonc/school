-- Migration: Agregar section_id a plugin_school_matricula
-- Ejecutar una sola vez en instancias existentes del plugin School.

ALTER TABLE plugin_school_matricula
    ADD COLUMN section_id INT unsigned NULL AFTER grade_id;
