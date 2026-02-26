-- =============================================
-- School Plugin - Migration: Classroom Session
-- =============================================
-- Adds optional Chamilo session link to classrooms.
-- Run only once; check column existence before running.
-- =============================================

-- Add session_id column (run only if it doesn't exist):
-- ALTER TABLE plugin_school_academic_classroom ADD COLUMN session_id INT NULL DEFAULT NULL AFTER tutor_id;
