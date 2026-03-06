-- =============================================
-- School Plugin - Migration: Schedule teacher_name backfill
-- =============================================
-- Rellena teacher_id y teacher_name en registros de horario que tienen
-- el subject como texto libre coincidente con el título del curso del aula.
-- Seguro de re-ejecutar (solo actualiza filas con teacher_id vacío).
-- Para cursos con múltiples docentes, toma el de menor id.
-- =============================================

UPDATE plugin_school_classroom_schedule s
INNER JOIN (
    SELECT cc.classroom_id, c.title AS course_title,
           MIN(ct.teacher_id) AS teacher_id
    FROM plugin_school_academic_classroom_course cc
    INNER JOIN course c ON c.id = cc.course_id
    INNER JOIN plugin_school_academic_course_teacher ct ON ct.classroom_course_id = cc.id
    GROUP BY cc.classroom_id, c.title
) AS cm ON cm.classroom_id = s.classroom_id AND cm.course_title = s.subject
INNER JOIN user u ON u.id = cm.teacher_id
SET s.teacher_id   = cm.teacher_id,
    s.teacher_name = CONCAT(u.lastname, ', ', u.firstname)
WHERE s.teacher_id IS NULL
  AND (s.teacher_name IS NULL OR s.teacher_name = '');
