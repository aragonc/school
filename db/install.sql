-- =============================================
-- School Plugin - Database Schema
-- =============================================
-- Ejecutar este script para crear todas las tablas
-- necesarias del plugin School.
-- =============================================

-- 1. Solicitudes
CREATE TABLE IF NOT EXISTS plugin_school_request (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    title VARCHAR(250) NULL,
    board_id INT NOT NULL,
    phase_id INT NOT NULL,
    description MEDIUMTEXT NULL,
    session_id INT NOT NULL,
    start_time DATETIME NULL,
    end_time DATETIME NULL,
    activate INT
);

-- 2. Configuraciones
CREATE TABLE IF NOT EXISTS plugin_school_settings (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    variable VARCHAR(255) NOT NULL,
    value TEXT NULL,
    UNIQUE KEY unique_variable (variable)
);

-- 3. Horarios de asistencia
CREATE TABLE IF NOT EXISTS plugin_school_attendance_schedule (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    entry_time TIME NOT NULL,
    late_time TIME NOT NULL,
    applies_to VARCHAR(255) NOT NULL DEFAULT 'all',
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL
);

-- 4. Registro de asistencia
CREATE TABLE IF NOT EXISTS plugin_school_attendance_log (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    user_id INT NOT NULL,
    schedule_id INT unsigned NULL,
    check_in DATETIME NOT NULL,
    status ENUM('on_time','late','absent') NOT NULL DEFAULT 'on_time',
    method ENUM('qr','manual') NOT NULL DEFAULT 'manual',
    registered_by INT NULL,
    date DATE NOT NULL,
    notes TEXT NULL,
    created_at DATETIME NOT NULL,
    UNIQUE KEY unique_user_date (user_id, date)
);

-- 5. Tokens QR de asistencia
CREATE TABLE IF NOT EXISTS plugin_school_attendance_qr_token (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    token VARCHAR(64) NOT NULL,
    date DATE NOT NULL,
    created_by INT NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at DATETIME NOT NULL,
    UNIQUE KEY unique_token (token)
);

-- 6. Perfil extra (DNI, dirección, etc.)
CREATE TABLE IF NOT EXISTS plugin_school_extra_profile (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    user_id INT NOT NULL,
    document_type ENUM('DNI','CE','PASAPORTE','OTRO') NOT NULL DEFAULT 'DNI',
    document_number VARCHAR(50) NULL,
    birthdate DATE NULL,
    address VARCHAR(500) NULL,
    address_reference VARCHAR(255) NULL,
    phone VARCHAR(50) NULL,
    district VARCHAR(100) NULL,
    province VARCHAR(100) NULL,
    region VARCHAR(100) NULL,
    updated_at DATETIME NULL,
    UNIQUE KEY unique_user (user_id)
);

-- =============================================
-- PAGOS / PENSIONES
-- =============================================

-- 7. Periodos de pago
CREATE TABLE IF NOT EXISTS plugin_school_payment_period (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    year SMALLINT NOT NULL,
    admission_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    enrollment_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    monthly_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    months VARCHAR(100) NOT NULL DEFAULT '',
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL
);

-- 8. Pagos de alumnos
CREATE TABLE IF NOT EXISTS plugin_school_payment (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    period_id INT unsigned NOT NULL,
    user_id INT NOT NULL,
    type ENUM('admission','enrollment','monthly') NOT NULL,
    month TINYINT NULL,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount DECIMAL(10,2) NOT NULL DEFAULT 0,
    original_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    payment_date DATE NULL,
    payment_method VARCHAR(50) NULL,
    reference VARCHAR(255) NULL,
    receipt_number VARCHAR(20) NULL,
    voucher VARCHAR(255) NULL,
    notes TEXT NULL,
    status ENUM('paid','pending','partial') NOT NULL DEFAULT 'pending',
    registered_by INT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NULL,
    UNIQUE KEY unique_payment (period_id, user_id, type, month)
);

-- 9. Descuentos de pago
CREATE TABLE IF NOT EXISTS plugin_school_payment_discount (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    period_id INT unsigned NOT NULL,
    user_id INT NOT NULL,
    discount_type ENUM('percentage','fixed') NOT NULL DEFAULT 'fixed',
    discount_value DECIMAL(10,2) NOT NULL DEFAULT 0,
    applies_to ENUM('admission','enrollment','monthly','all') NOT NULL DEFAULT 'all',
    reason VARCHAR(255) NULL,
    created_by INT NOT NULL,
    created_at DATETIME NOT NULL
);

-- =============================================
-- PRODUCTOS / OTROS INGRESOS
-- =============================================

-- 10. Categorías de productos
CREATE TABLE IF NOT EXISTS plugin_school_product_category (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL
);

-- 11. Catálogo de productos
CREATE TABLE IF NOT EXISTS plugin_school_product (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    category_id INT unsigned NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL
);

-- 12. Ventas de productos
CREATE TABLE IF NOT EXISTS plugin_school_product_sale (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    product_id INT unsigned NOT NULL,
    user_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    payment_method VARCHAR(50) NULL,
    reference VARCHAR(255) NULL,
    receipt_number VARCHAR(20) NULL,
    notes TEXT NULL,
    status ENUM('paid','pending') NOT NULL DEFAULT 'paid',
    registered_by INT NULL,
    created_at DATETIME NOT NULL
);
