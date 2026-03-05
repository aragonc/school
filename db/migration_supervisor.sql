-- Migration: add supervisor_id to classroom table
ALTER TABLE plugin_school_academic_classroom
    ADD COLUMN supervisor_id INT NULL DEFAULT NULL AFTER tutor_id;
