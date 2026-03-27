-- =============================================
-- School Plugin - Migration: Support Tickets
-- =============================================
-- Crea el módulo de tickets de soporte técnico
-- entre usuarios/alumnos y administradores.
-- Seguro de ejecutar en instalaciones existentes.
-- =============================================

CREATE TABLE IF NOT EXISTS plugin_school_support_ticket (
    id          INT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL,
    subject     VARCHAR(255) NOT NULL,
    category    VARCHAR(100) NOT NULL DEFAULT 'general',
    priority    ENUM('low','medium','high','critical') NOT NULL DEFAULT 'medium',
    status      ENUM('open','in_progress','resolved','closed') NOT NULL DEFAULT 'open',
    assigned_to INT NULL,
    closed_at   DATETIME NULL,
    created_at  DATETIME NOT NULL,
    updated_at  DATETIME NOT NULL,
    INDEX idx_user   (user_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS plugin_school_support_message (
    id          INT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ticket_id   INT unsigned NOT NULL,
    user_id     INT NOT NULL,
    body        TEXT NOT NULL,
    is_internal TINYINT(1) NOT NULL DEFAULT 0,
    created_at  DATETIME NOT NULL,
    INDEX idx_ticket (ticket_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
