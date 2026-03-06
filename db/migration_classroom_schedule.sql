-- =============================================
-- School Plugin - Migration: Classroom Schedule table
-- =============================================
-- Crea la tabla de horario de aula si no existe.
-- Seguro de re-ejecutar (usa IF NOT EXISTS).
-- =============================================

CREATE TABLE IF NOT EXISTS plugin_school_classroom_schedule (
    id           INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    classroom_id INT          NOT NULL,
    day_of_week  TINYINT      NOT NULL DEFAULT 0,
    time_start   TIME         NOT NULL,
    time_end     TIME         NOT NULL,
    subject      VARCHAR(255) NOT NULL DEFAULT '',
    teacher_id   INT          NULL DEFAULT NULL,
    teacher_name VARCHAR(255) NULL DEFAULT NULL,
    style        VARCHAR(30)  NOT NULL DEFAULT '',
    sort_order   SMALLINT     NOT NULL DEFAULT 0,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_classroom     (classroom_id),
    INDEX idx_classroom_day (classroom_id, day_of_week)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
