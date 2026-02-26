-- =============================================
-- School Plugin - Migration: Auxiliary Teachers
-- =============================================
-- Run this migration to add auxiliary teacher support
-- to classrooms. Safe to run on existing installations.
-- =============================================

CREATE TABLE IF NOT EXISTS plugin_school_academic_classroom_auxiliary (
    id           INT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
    classroom_id INT unsigned NOT NULL,
    user_id      INT NOT NULL,
    created_at   DATETIME NOT NULL,
    UNIQUE KEY unique_classroom_user (classroom_id, user_id),
    KEY idx_classroom (classroom_id)
);
