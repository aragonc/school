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
    sexo ENUM('F','M') NULL,
    nacionalidad VARCHAR(50) NULL DEFAULT 'Peruana',
    tipo_sangre VARCHAR(5) NULL,
    peso DECIMAL(5,2) NULL,
    estatura DECIMAL(4,2) NULL,
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

-- =============================================
-- ACADÉMICO
-- =============================================

-- 13. Años académicos
CREATE TABLE IF NOT EXISTS plugin_school_academic_year (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    year SMALLINT NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL
);

-- 14. Niveles educativos
CREATE TABLE IF NOT EXISTS plugin_school_academic_level (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    order_index TINYINT NOT NULL DEFAULT 0,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL
);

-- 15. Grados
CREATE TABLE IF NOT EXISTS plugin_school_academic_grade (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    level_id INT unsigned NOT NULL,
    name VARCHAR(100) NOT NULL,
    order_index TINYINT NOT NULL DEFAULT 0,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL
);

-- 16. Secciones
CREATE TABLE IF NOT EXISTS plugin_school_academic_section (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL
);

-- 17. Aulas (grado + sección + año)
CREATE TABLE IF NOT EXISTS plugin_school_academic_classroom (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    academic_year_id INT unsigned NOT NULL,
    grade_id INT unsigned NOT NULL,
    section_id INT unsigned NOT NULL,
    tutor_id INT NULL,
    capacity INT NOT NULL DEFAULT 30,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL,
    UNIQUE KEY unique_classroom (academic_year_id, grade_id, section_id)
);

-- 18. Alumnos en aulas
CREATE TABLE IF NOT EXISTS plugin_school_academic_classroom_student (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    classroom_id INT unsigned NOT NULL,
    user_id INT NOT NULL,
    enrolled_at DATETIME NOT NULL,
    UNIQUE KEY unique_student (classroom_id, user_id)
);

-- 19. Precios por nivel/grado por periodo
CREATE TABLE IF NOT EXISTS plugin_school_payment_period_price (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    period_id INT unsigned NOT NULL,
    level_id INT unsigned NOT NULL,
    grade_id INT unsigned NULL,
    admission_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    enrollment_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    monthly_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    UNIQUE KEY unique_price (period_id, level_id, grade_id)
);

-- =============================================
-- MATRÍCULAS
-- =============================================

-- 20. Ficha del alumno (datos personales permanentes — 1 por alumno)
CREATE TABLE IF NOT EXISTS plugin_school_ficha (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    user_id INT NULL,
    apellido_paterno VARCHAR(100) NULL,
    apellido_materno VARCHAR(100) NULL,
    nombres VARCHAR(100) NOT NULL DEFAULT '',
    sexo ENUM('F','M') NULL,
    dni CHAR(8) NULL,
    tipo_documento VARCHAR(20) NULL,
    tipo_sangre VARCHAR(5) NULL,
    fecha_nacimiento DATE NULL,
    nacionalidad VARCHAR(50) NULL DEFAULT 'Peruana',
    peso DECIMAL(5,2) NULL,
    estatura DECIMAL(4,2) NULL,
    domicilio VARCHAR(255) NULL,
    region VARCHAR(10) NULL,
    provincia VARCHAR(10) NULL,
    distrito VARCHAR(10) NULL,
    tiene_alergias TINYINT(1) NOT NULL DEFAULT 0,
    alergias_detalle VARCHAR(255) NULL,
    usa_lentes TINYINT(1) NOT NULL DEFAULT 0,
    tiene_discapacidad TINYINT(1) NOT NULL DEFAULT 0,
    discapacidad_detalle VARCHAR(255) NULL,
    ie_procedencia VARCHAR(150) NULL,
    motivo_traslado TEXT NULL,
    foto VARCHAR(255) NULL,
    created_by INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NULL,
    UNIQUE KEY unique_ficha_user (user_id)
);

-- 21. Matrícula anual (datos variables por año — 1 por alumno por año)
CREATE TABLE IF NOT EXISTS plugin_school_matricula (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    ficha_id INT unsigned NOT NULL,
    academic_year_id INT unsigned NULL,
    grade_id INT unsigned NULL,
    estado ENUM('ACTIVO','RETIRADO') NOT NULL DEFAULT 'ACTIVO',
    tipo_ingreso ENUM('NUEVO_INGRESO','REINGRESO','CONTINUACION') NOT NULL DEFAULT 'NUEVO_INGRESO',
    created_by INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NULL,
    UNIQUE KEY unique_ficha_year (ficha_id, academic_year_id)
);

-- 22. Datos de padres/tutores (vinculados a la ficha, no a la matrícula anual)
CREATE TABLE IF NOT EXISTS plugin_school_matricula_padre (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    ficha_id INT unsigned NOT NULL,
    matricula_id INT unsigned NULL,
    parentesco ENUM('MADRE','PADRE','APODERADO') NOT NULL,
    apellidos VARCHAR(100) NULL,
    nombres VARCHAR(100) NULL,
    celular VARCHAR(15) NULL,
    ocupacion VARCHAR(100) NULL,
    dni CHAR(8) NULL,
    edad TINYINT unsigned NULL,
    religion VARCHAR(50) NULL,
    tipo_parto ENUM('CESAREA','NORMAL') NULL,
    vive_con_menor TINYINT(1) NULL
);

-- 23. Contactos de emergencia (vinculados a la ficha)
CREATE TABLE IF NOT EXISTS plugin_school_matricula_contacto (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    ficha_id INT unsigned NOT NULL,
    matricula_id INT unsigned NULL,
    nombre_contacto VARCHAR(150) NULL,
    telefono VARCHAR(15) NULL,
    direccion VARCHAR(255) NULL
);

-- 24. Información adicional (vinculada a la ficha)
CREATE TABLE IF NOT EXISTS plugin_school_matricula_info (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    ficha_id INT unsigned NOT NULL,
    matricula_id INT unsigned NULL,
    encargados_cuidado VARCHAR(255) NULL,
    familiar_en_institucion VARCHAR(150) NULL,
    observaciones TEXT NULL,
    UNIQUE KEY unique_mat_info (ficha_id)
);

-- 25. Hermanos (relación entre fichas de alumnos vía usuario Chamilo)
CREATE TABLE IF NOT EXISTS plugin_school_ficha_hermano (
    id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    ficha_id INT unsigned NOT NULL,
    hermano_user_id INT unsigned NOT NULL,
    UNIQUE KEY uk_ficha_hermano (ficha_id, hermano_user_id)
);
