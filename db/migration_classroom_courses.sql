-- =============================================
-- School Plugin - Migration: Classroom Courses & Teacher Assignments
-- =============================================
-- Crea tablas permanentes del plugin para el vínculo curso-aula
-- y la asignación docente-curso. Son la fuente de verdad aunque
-- se borre la sesión de Chamilo.
-- Seguro de re-ejecutar (usa IF NOT EXISTS / INSERT IGNORE).
-- =============================================

-- 1. Vínculo permanente curso-aula por año académico
CREATE TABLE IF NOT EXISTS plugin_school_academic_classroom_course (
    id               INT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
    classroom_id     INT unsigned NOT NULL,
    course_id        INT NOT NULL,
    academic_year_id INT unsigned NOT NULL,
    session_id       INT NULL DEFAULT NULL,
    created_at       DATETIME NOT NULL,
    UNIQUE KEY unique_classroom_course (classroom_id, course_id),
    KEY idx_classroom (classroom_id),
    KEY idx_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Asignación permanente docente-curso-aula
CREATE TABLE IF NOT EXISTS plugin_school_academic_course_teacher (
    id                   INT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
    classroom_course_id  INT unsigned NOT NULL,
    teacher_id           INT NOT NULL,
    created_at           DATETIME NOT NULL,
    UNIQUE KEY unique_course_teacher (classroom_course_id, teacher_id),
    KEY idx_classroom_course (classroom_course_id),
    KEY idx_teacher (teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Backfill: poblar cursos de aulas que ya tienen sesión asignada
INSERT IGNORE INTO plugin_school_academic_classroom_course
    (classroom_id, course_id, academic_year_id, session_id, created_at)
SELECT cl.id, src.c_id, cl.academic_year_id, cl.session_id, NOW()
FROM plugin_school_academic_classroom cl
INNER JOIN session_rel_course src ON src.session_id = cl.session_id
WHERE cl.session_id IS NOT NULL;

-- 4. Backfill: poblar docentes asignados a esos cursos
INSERT IGNORE INTO plugin_school_academic_course_teacher
    (classroom_course_id, teacher_id, created_at)
SELECT cc.id, srcu.user_id, NOW()
FROM plugin_school_academic_classroom_course cc
INNER JOIN session_rel_course_rel_user srcu
    ON srcu.session_id = cc.session_id
   AND srcu.c_id = cc.course_id
   AND srcu.status = 2;
