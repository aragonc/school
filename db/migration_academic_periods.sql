-- =============================================
-- School Plugin - Migration: Academic Periods (Bimestres/Trimestres)
-- =============================================

CREATE TABLE IF NOT EXISTS plugin_school_academic_period (
    id               INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    academic_year_id INT UNSIGNED NOT NULL,
    name             VARCHAR(100) NOT NULL,
    date_start       DATE NOT NULL,
    date_end         DATE NOT NULL,
    active           TINYINT(1) NOT NULL DEFAULT 1,
    order_index      INT NOT NULL DEFAULT 0,
    KEY idx_year (academic_year_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
