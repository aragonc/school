-- =============================================
-- School Plugin - Migration: Support Assignees
-- =============================================
-- Permite asignar múltiples administradores
-- a un ticket de soporte.
-- =============================================

CREATE TABLE IF NOT EXISTS plugin_school_support_assignee (
    id          INT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ticket_id   INT unsigned NOT NULL,
    user_id     INT NOT NULL,
    assigned_at DATETIME NOT NULL,
    assigned_by INT NOT NULL,
    UNIQUE KEY unique_assignee (ticket_id, user_id),
    INDEX idx_ticket (ticket_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
