<?php
/* For licensing terms, see /license.txt */

/**
 * AcademicManager - School Plugin
 * Manages academic structure: years, levels, grades, sections, classrooms and students.
 *
 * @package chamilo.plugin.school
 */
class AcademicManager
{
    // =========================================================================
    // ACADEMIC YEARS
    // =========================================================================

    public static function getAcademicYears(bool $activeOnly = false): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
        $sql = "SELECT * FROM $table";
        if ($activeOnly) {
            $sql .= " WHERE active = 1";
        }
        $sql .= " ORDER BY year DESC, name ASC";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveAcademicYear(array $data): bool
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
        $id = isset($data['id']) ? (int) $data['id'] : 0;
        $params = [
            'name' => Database::escape_string($data['name'] ?? ''),
            'year' => (int) ($data['year'] ?? date('Y')),
            'active' => isset($data['active']) ? (int) $data['active'] : 1,
        ];

        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            $params['created_at'] = date('Y-m-d H:i:s');
            Database::insert($table, $params);
        }
        return true;
    }

    public static function deleteAcademicYear(int $id): bool
    {
        if ($id <= 0) return false;
        // Check for classrooms using this year
        $classroomTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $sql = "SELECT COUNT(*) as c FROM $classroomTable WHERE academic_year_id = $id";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        if ((int) $row['c'] > 0) {
            return false;
        }
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // LEVELS
    // =========================================================================

    public static function getLevels(bool $activeOnly = false): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $sql = "SELECT * FROM $table";
        if ($activeOnly) {
            $sql .= " WHERE active = 1";
        }
        $sql .= " ORDER BY order_index ASC, name ASC";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveLevel(array $data): bool
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $id = isset($data['id']) ? (int) $data['id'] : 0;
        $params = [
            'name'          => Database::escape_string($data['name'] ?? ''),
            'order_index'   => (int) ($data['order_index'] ?? 0),
            'years_duration'=> isset($data['years_duration']) ? max(1, (int) $data['years_duration']) : 1,
            'active'        => isset($data['active']) ? (int) $data['active'] : 1,
        ];

        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            $params['created_at'] = date('Y-m-d H:i:s');
            Database::insert($table, $params);
        }
        return true;
    }

    /**
     * Returns data needed to pre-populate the retirement refund modal.
     * Calculates years_attended by counting distinct academic years this student
     * has been enrolled in the same educational level.
     */
    public static function getRetirementInfo(int $matriculaId): array
    {
        if ($matriculaId <= 0) {
            return [];
        }

        $matTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $fichaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $gradeTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $levelTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);

        // Load matricula + ficha + grade + level
        $sql = "SELECT m.id AS matricula_id, m.ficha_id, m.grade_id, m.academic_year_id,
                       f.user_id, f.apellido_paterno, f.apellido_materno, f.nombres,
                       g.level_id, g.name AS grade_name,
                       lv.name AS level_name, lv.years_duration
                FROM $matTable m
                JOIN $fichaTable f ON f.id = m.ficha_id
                LEFT JOIN $gradeTable g  ON g.id  = m.grade_id
                LEFT JOIN $levelTable lv ON lv.id = g.level_id
                WHERE m.id = $matriculaId
                LIMIT 1";
        $result = Database::query($sql);
        $row    = Database::fetch_array($result, 'ASSOC');
        if (!$row) {
            return [];
        }

        $fichaId = (int) $row['ficha_id'];
        $levelId = (int) ($row['level_id'] ?? 0);

        // Count years attended in this level
        $yearsAttended = 0;
        if ($fichaId > 0 && $levelId > 0) {
            $countSql = "SELECT COUNT(DISTINCT m2.academic_year_id) AS total
                         FROM $matTable m2
                         JOIN $gradeTable g2 ON g2.id = m2.grade_id
                         WHERE m2.ficha_id = $fichaId AND g2.level_id = $levelId";
            $countResult   = Database::query($countSql);
            $countRow      = Database::fetch_array($countResult, 'ASSOC');
            $yearsAttended = (int) ($countRow['total'] ?? 0);
        }

        $ap = trim($row['apellido_paterno'] ?? '');
        $am = trim($row['apellido_materno'] ?? '');
        $n  = trim($row['nombres'] ?? '');
        $fullName = trim("$ap $am") ? trim("$ap $am") . ($n ? ", $n" : '') : $n;

        return [
            'matricula_id'    => $matriculaId,
            'ficha_id'        => $fichaId,
            'user_id'         => $row['user_id'],
            'full_name'       => $fullName,
            'level_id'        => $levelId,
            'level_name'      => $row['level_name'] ?? '',
            'grade_name'      => $row['grade_name'] ?? '',
            'years_contracted'=> max(1, (int) ($row['years_duration'] ?? 1)),
            'years_attended'  => $yearsAttended,
        ];
    }

    public static function deleteLevel(int $id): bool
    {
        if ($id <= 0) return false;
        $gradeTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $sql = "SELECT COUNT(*) as c FROM $gradeTable WHERE level_id = $id";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        if ((int) $row['c'] > 0) {
            return false;
        }
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // GRADES
    // =========================================================================

    public static function getGrades(?int $levelId = null, bool $activeOnly = false): array
    {
        $gradeTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $levelTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $sql = "SELECT g.*, l.name as level_name
                FROM $gradeTable g
                LEFT JOIN $levelTable l ON g.level_id = l.id";
        $where = [];
        if ($levelId) {
            $where[] = "g.level_id = " . (int) $levelId;
        }
        if ($activeOnly) {
            $where[] = "g.active = 1";
        }
        if (!empty($where)) {
            $sql .= " WHERE " . implode(' AND ', $where);
        }
        $sql .= " ORDER BY l.order_index ASC, g.order_index ASC, g.name ASC";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveGrade(array $data): bool
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $id = isset($data['id']) ? (int) $data['id'] : 0;
        $params = [
            'level_id' => (int) ($data['level_id'] ?? 0),
            'name' => Database::escape_string($data['name'] ?? ''),
            'order_index' => (int) ($data['order_index'] ?? 0),
            'active' => isset($data['active']) ? (int) $data['active'] : 1,
        ];

        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            $params['created_at'] = date('Y-m-d H:i:s');
            Database::insert($table, $params);
        }
        return true;
    }

    public static function deleteGrade(int $id): bool
    {
        if ($id <= 0) return false;
        $classroomTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $sql = "SELECT COUNT(*) as c FROM $classroomTable WHERE grade_id = $id";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        if ((int) $row['c'] > 0) {
            return false;
        }
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // SECTIONS
    // =========================================================================

    public static function getSections(bool $activeOnly = false): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
        $sql = "SELECT * FROM $table";
        if ($activeOnly) {
            $sql .= " WHERE active = 1";
        }
        $sql .= " ORDER BY name ASC";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveSection(array $data): bool
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
        $id = isset($data['id']) ? (int) $data['id'] : 0;
        $params = [
            'name' => Database::escape_string($data['name'] ?? ''),
            'active' => isset($data['active']) ? (int) $data['active'] : 1,
        ];

        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            $params['created_at'] = date('Y-m-d H:i:s');
            Database::insert($table, $params);
        }
        return true;
    }

    public static function deleteSection(int $id): bool
    {
        if ($id <= 0) return false;
        $classroomTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $sql = "SELECT COUNT(*) as c FROM $classroomTable WHERE section_id = $id";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        if ((int) $row['c'] > 0) {
            return false;
        }
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // CLASSROOMS
    // =========================================================================

    public static function getClassrooms(int $yearId, ?int $levelId = null): array
    {
        $cTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $gTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $sTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
        $lTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $csTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);

        $sql = "SELECT c.*, g.name as grade_name, g.level_id, s.name as section_name,
                       l.name as level_name, l.order_index as level_order, g.order_index as grade_order,
                       (SELECT COUNT(*) FROM $csTable cs WHERE cs.classroom_id = c.id) as student_count
                FROM $cTable c
                INNER JOIN $gTable g ON c.grade_id = g.id
                INNER JOIN $sTable s ON c.section_id = s.id
                INNER JOIN $lTable l ON g.level_id = l.id
                WHERE c.academic_year_id = " . (int) $yearId;

        if ($levelId) {
            $sql .= " AND g.level_id = " . (int) $levelId;
        }

        $sql .= " ORDER BY l.order_index ASC, g.order_index ASC, s.name ASC";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            // Get tutor info
            if (!empty($row['tutor_id'])) {
                $tutorInfo = api_get_user_info($row['tutor_id']);
                $row['tutor_name'] = $tutorInfo ? $tutorInfo['complete_name'] : '';
                $row['tutor_avatar'] = $tutorInfo ? $tutorInfo['avatar_small'] : '';
            } else {
                $row['tutor_name'] = '';
                $row['tutor_avatar'] = '';
            }
            $rows[] = $row;
        }
        return $rows;
    }

    public static function getClassroom(int $id): ?array
    {
        $cTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $gTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $sTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
        $lTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $yTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);

        $sql = "SELECT c.*, g.name as grade_name, g.level_id, s.name as section_name,
                       l.name as level_name, y.name as year_name
                FROM $cTable c
                INNER JOIN $gTable g ON c.grade_id = g.id
                INNER JOIN $sTable s ON c.section_id = s.id
                INNER JOIN $lTable l ON g.level_id = l.id
                INNER JOIN $yTable y ON c.academic_year_id = y.id
                WHERE c.id = " . (int) $id;

        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        if (!$row) return null;

        if (!empty($row['tutor_id'])) {
            $tutorInfo = api_get_user_info($row['tutor_id']);
            $row['tutor_name'] = $tutorInfo ? $tutorInfo['complete_name'] : '';
            $row['tutor_avatar'] = $tutorInfo ? $tutorInfo['avatar'] : '';
        } else {
            $row['tutor_name'] = '';
            $row['tutor_avatar'] = '';
        }

        return $row;
    }

    public static function saveClassroom(array $data): bool
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $id = isset($data['id']) ? (int) $data['id'] : 0;
        $params = [
            'academic_year_id' => (int) ($data['academic_year_id'] ?? 0),
            'grade_id' => (int) ($data['grade_id'] ?? 0),
            'section_id' => (int) ($data['section_id'] ?? 0),
            'tutor_id' => !empty($data['tutor_id']) ? (int) $data['tutor_id'] : null,
            'capacity' => (int) ($data['capacity'] ?? 30),
            'active' => isset($data['active']) ? (int) $data['active'] : 1,
        ];

        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            $params['created_at'] = date('Y-m-d H:i:s');
            Database::insert($table, $params);
        }
        return true;
    }

    public static function deleteClassroom(int $id): bool
    {
        if ($id <= 0) return false;
        // Delete students first
        $csTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        Database::delete($csTable, ['classroom_id = ?' => $id]);
        // Delete classroom
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // CLASSROOM STUDENTS
    // =========================================================================

    public static function getClassroomStudents(int $classroomId): array
    {
        $csTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        $cTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $mTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $fTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $gTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $sTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        $sql = "SELECT
                    cs.id, cs.user_id, cs.classroom_id, cs.enrolled_at,
                    u.firstname, u.lastname, u.username, u.email, u.picture_uri,
                    -- current active matrícula for this academic year
                    m.id         AS mat_id,
                    m.grade_id   AS mat_grade_id,
                    m.section_id AS mat_section_id,
                    m.estado     AS mat_estado,
                    -- classroom reference
                    c.grade_id   AS cls_grade_id,
                    c.section_id AS cls_section_id,
                    -- human-readable names for the matrícula destination
                    gm.name  AS mat_grade_name,
                    sm.name  AS mat_section_name,
                    -- mismatch flag
                    CASE
                        WHEN m.id IS NULL                                                          THEN 'no_matricula'
                        WHEN m.estado = 'RETIRADO'                                                 THEN 'retirado'
                        WHEN m.grade_id != c.grade_id OR m.section_id != c.section_id             THEN 'moved'
                        ELSE NULL
                    END AS matricula_alert
                FROM $csTable cs
                INNER JOIN $userTable u  ON u.id  = cs.user_id
                INNER JOIN $cTable   c  ON c.id  = cs.classroom_id
                LEFT  JOIN $fTable   f  ON f.user_id = cs.user_id
                LEFT  JOIN (
                    SELECT ficha_id, MAX(id) AS last_id
                    FROM $mTable
                    WHERE academic_year_id = (SELECT academic_year_id FROM $cTable WHERE id = $classroomId LIMIT 1)
                    GROUP BY ficha_id
                ) latest ON latest.ficha_id = f.id
                LEFT  JOIN $mTable   m  ON m.id  = latest.last_id
                LEFT  JOIN $gTable   gm ON gm.id = m.grade_id
                LEFT  JOIN $sTable   sm ON sm.id = m.section_id
                WHERE cs.classroom_id = $classroomId
                ORDER BY u.lastname ASC, u.firstname ASC";

        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $userInfo = api_get_user_info($row['user_id']);
            $row['avatar'] = $userInfo ? $userInfo['avatar_small'] : '';
            $rows[] = $row;
        }
        return $rows;
    }

    public static function addStudentToClassroom(int $classroomId, int $userId): bool
    {
        if ($classroomId <= 0 || $userId <= 0) return false;

        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);

        // Check if already exists
        $sql = "SELECT id FROM $table WHERE classroom_id = $classroomId AND user_id = $userId";
        $result = Database::query($sql);
        if (Database::num_rows($result) > 0) {
            return false;
        }

        Database::insert($table, [
            'classroom_id' => $classroomId,
            'user_id' => $userId,
            'enrolled_at' => date('Y-m-d H:i:s'),
        ]);
        return true;
    }

    public static function removeStudentFromClassroom(int $classroomId, int $userId): bool
    {
        if ($classroomId <= 0 || $userId <= 0) return false;
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        Database::delete($table, ['classroom_id = ? AND user_id = ?' => [$classroomId, $userId]]);
        return true;
    }

    /**
     * Returns students with an active matrícula for the classroom's year/grade/section
     * that are NOT yet assigned to any classroom in that academic year.
     */
    public static function getClassroomCandidates(int $classroomId): array
    {
        if ($classroomId <= 0) return [];

        $cTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $csTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        $mTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $fTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $uTable  = Database::get_main_table(TABLE_MAIN_USER);

        // Get classroom data
        $sql = "SELECT academic_year_id, grade_id, section_id FROM $cTable WHERE id = $classroomId LIMIT 1";
        $row = Database::fetch_array(Database::query($sql), 'ASSOC');
        if (!$row) return [];

        $yearId    = (int) $row['academic_year_id'];
        $gradeId   = (int) $row['grade_id'];
        $sectionId = (int) $row['section_id'];

        // Students already in any classroom of this academic year
        $sql = "SELECT DISTINCT cs.user_id
                FROM $csTable cs
                INNER JOIN $cTable c ON c.id = cs.classroom_id
                WHERE c.academic_year_id = $yearId";
        $assigned = [];
        $res = Database::query($sql);
        while ($r = Database::fetch_array($res, 'ASSOC')) {
            $assigned[] = (int) $r['user_id'];
        }
        $excludeClause = !empty($assigned)
            ? 'AND f.user_id NOT IN (' . implode(',', $assigned) . ')'
            : '';

        $sql = "SELECT
                    f.user_id,
                    f.nombres,
                    f.apellido_paterno,
                    f.apellido_materno,
                    u.username,
                    u.email,
                    u.picture_uri,
                    u.id AS chamilo_user_id
                FROM $mTable m
                INNER JOIN $fTable f ON f.id = m.ficha_id
                INNER JOIN $uTable u ON u.id = f.user_id
                WHERE m.academic_year_id = $yearId
                  AND m.grade_id = $gradeId
                  AND m.section_id = $sectionId
                  AND m.estado = 'ACTIVO'
                  AND f.user_id IS NOT NULL
                  $excludeClause
                ORDER BY f.apellido_paterno ASC, f.apellido_materno ASC, f.nombres ASC";

        $rows = [];
        $res = Database::query($sql);
        while ($r = Database::fetch_array($res, 'ASSOC')) {
            $rows[] = $r;
        }
        return $rows;
    }

    /**
     * Bulk-add multiple students to a classroom. Returns counts of added/skipped.
     */
    public static function addStudentsBulk(int $classroomId, array $userIds): array
    {
        $added   = 0;
        $skipped = 0;
        $table   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        $now     = date('Y-m-d H:i:s');

        foreach ($userIds as $userId) {
            $userId = (int) $userId;
            if ($userId <= 0) continue;
            $sql = "SELECT id FROM $table WHERE classroom_id = $classroomId AND user_id = $userId";
            if (Database::num_rows(Database::query($sql)) > 0) {
                $skipped++;
                continue;
            }
            Database::insert($table, [
                'classroom_id' => $classroomId,
                'user_id'      => $userId,
                'enrolled_at'  => $now,
            ]);
            $added++;
        }
        return ['added' => $added, 'skipped' => $skipped];
    }

    public static function getStudentClassroom(int $yearId, int $userId): ?array
    {
        $csTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        $cTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);

        $sql = "SELECT c.* FROM $csTable cs
                INNER JOIN $cTable c ON cs.classroom_id = c.id
                WHERE c.academic_year_id = " . (int) $yearId . "
                AND cs.user_id = " . (int) $userId . "
                LIMIT 1";

        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    // =========================================================================
    // TEACHERS / STUDENT SEARCH
    // =========================================================================

    public static function getTeachers(): array
    {
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $sql = "SELECT id as user_id, firstname, lastname, username, email
                FROM $userTable
                WHERE status = " . COURSEMANAGER . " AND active = 1
                ORDER BY lastname ASC, firstname ASC";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function searchStudents(string $query): array
    {
        if (empty(trim($query))) return [];
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $q = Database::escape_string(trim($query));
        $sql = "SELECT id as user_id, firstname, lastname, username, email
                FROM $userTable
                WHERE status = " . STUDENT . " AND active = 1
                AND (firstname LIKE '%$q%' OR lastname LIKE '%$q%' OR username LIKE '%$q%')
                ORDER BY lastname ASC, firstname ASC
                LIMIT 20";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function searchTeachers(string $query): array
    {
        if (empty(trim($query))) return [];
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $q = Database::escape_string(trim($query));
        $sql = "SELECT id as user_id, firstname, lastname, username, email
                FROM $userTable
                WHERE status = " . COURSEMANAGER . " AND active = 1
                AND (firstname LIKE '%$q%' OR lastname LIKE '%$q%' OR username LIKE '%$q%')
                ORDER BY lastname ASC, firstname ASC
                LIMIT 20";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    // =========================================================================
    // CLASSROOM AUXILIARIES
    // =========================================================================

    public static function getClassroomAuxiliaries(int $classroomId): array
    {
        $auxTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_AUXILIARY);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $sql = "SELECT a.id, a.user_id, a.created_at,
                       u.firstname, u.lastname, u.username, u.picture_uri
                FROM $auxTable a
                INNER JOIN $userTable u ON u.id = a.user_id
                WHERE a.classroom_id = $classroomId
                ORDER BY u.lastname ASC, u.firstname ASC";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $row['avatar'] = !empty($row['picture_uri'])
                ? api_get_path(WEB_UPLOAD_PATH) . 'users/' . $row['user_id'] . '/' . $row['picture_uri']
                : '';
            $rows[] = $row;
        }
        return $rows;
    }

    public static function addAuxiliary(int $classroomId, int $userId): bool
    {
        if ($classroomId <= 0 || $userId <= 0) return false;
        // Enforce max 3 auxiliaries per classroom
        $auxTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_AUXILIARY);
        $count = Database::fetch_array(
            Database::query("SELECT COUNT(*) as c FROM $auxTable WHERE classroom_id = $classroomId"),
            'ASSOC'
        );
        if ((int) $count['c'] >= 3) return false;
        // Prevent duplicate (UNIQUE KEY will also catch it, but let's return gracefully)
        $exists = Database::fetch_array(
            Database::query("SELECT id FROM $auxTable WHERE classroom_id = $classroomId AND user_id = $userId LIMIT 1"),
            'ASSOC'
        );
        if ($exists) return false;
        Database::insert($auxTable, [
            'classroom_id' => $classroomId,
            'user_id'      => $userId,
            'created_at'   => date('Y-m-d H:i:s'),
        ]);
        return true;
    }

    public static function removeAuxiliary(int $classroomId, int $userId): bool
    {
        if ($classroomId <= 0 || $userId <= 0) return false;
        $auxTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_AUXILIARY);
        Database::delete($auxTable, ['classroom_id = ? AND user_id = ?' => [$classroomId, $userId]]);
        return true;
    }

    public static function searchAuxiliaries(string $query): array
    {
        if (empty(trim($query))) return [];
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $q = Database::escape_string(trim($query));
        $sql = "SELECT id as user_id, firstname, lastname, username, email, status
                FROM $userTable
                WHERE status IN (" . COURSEMANAGER . ", " . SCHOOL_AUXILIARY . ") AND active = 1
                AND (firstname LIKE '%$q%' OR lastname LIKE '%$q%' OR username LIKE '%$q%')
                ORDER BY lastname ASC, firstname ASC
                LIMIT 20";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    // =========================================================================
    // PERIOD PRICING (by level, with optional grade override)
    // =========================================================================

    /**
     * Get prices for a period, grouped by level and grade.
     * Returns: [level_id => ['level' => [...], 'grades' => [grade_id => [...]]]]
     */
    public static function getPeriodPrices(int $periodId): array
    {
        $priceTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_PAYMENT_PERIOD_PRICE);
        $levelTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $gradeTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);

        $sql = "SELECT p.*, l.name as level_name, l.order_index as level_order, g.name as grade_name
                FROM $priceTable p
                INNER JOIN $levelTable l ON p.level_id = l.id
                LEFT JOIN $gradeTable g ON p.grade_id = g.id
                WHERE p.period_id = " . (int) $periodId . "
                ORDER BY l.order_index ASC, g.order_index ASC";

        $result = Database::query($sql);
        $prices = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $levelId = (int) $row['level_id'];
            if (!isset($prices[$levelId])) {
                $prices[$levelId] = [
                    'level_name' => $row['level_name'],
                    'level_price' => null,
                    'grades' => [],
                ];
            }
            if (empty($row['grade_id'])) {
                // Level-wide price
                $prices[$levelId]['level_price'] = $row;
            } else {
                // Grade-specific override
                $prices[$levelId]['grades'][(int) $row['grade_id']] = $row;
            }
        }
        return $prices;
    }

    /**
     * Get all price rows for a period (flat list for AJAX/editing).
     */
    public static function getPeriodPriceList(int $periodId): array
    {
        $priceTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_PAYMENT_PERIOD_PRICE);
        $levelTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $gradeTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);

        $sql = "SELECT p.*, l.name as level_name, g.name as grade_name
                FROM $priceTable p
                INNER JOIN $levelTable l ON p.level_id = l.id
                LEFT JOIN $gradeTable g ON p.grade_id = g.id
                WHERE p.period_id = " . (int) $periodId . "
                ORDER BY l.order_index ASC, p.grade_id ASC";

        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    /**
     * Save a price entry (level or grade override).
     */
    public static function savePeriodPrice(array $data): bool
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_PAYMENT_PERIOD_PRICE);
        $id = isset($data['id']) ? (int) $data['id'] : 0;
        $params = [
            'period_id' => (int) ($data['period_id'] ?? 0),
            'level_id' => (int) ($data['level_id'] ?? 0),
            'grade_id' => !empty($data['grade_id']) ? (int) $data['grade_id'] : null,
            'admission_amount' => (float) ($data['admission_amount'] ?? 0),
            'enrollment_amount' => (float) ($data['enrollment_amount'] ?? 0),
            'monthly_amount' => (float) ($data['monthly_amount'] ?? 0),
        ];

        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            $params['created_at'] = date('Y-m-d H:i:s');
            Database::insert($table, $params);
        }
        return true;
    }

    /**
     * Delete a price entry.
     */
    public static function deletePeriodPrice(int $id): bool
    {
        if ($id <= 0) return false;
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_PAYMENT_PERIOD_PRICE);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    /**
     * Resolve the effective price for a student based on their classroom.
     * Priority: 1) Grade override, 2) Level price, 3) Period default.
     *
     * @return array ['admission_amount' => float, 'enrollment_amount' => float, 'monthly_amount' => float, 'source' => string]
     */
    public static function resolveStudentPrice(int $periodId, int $userId): array
    {
        $priceTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_PAYMENT_PERIOD_PRICE);
        $periodTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_PAYMENT_PERIOD);
        $classroomTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $csTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        $gradeTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);

        // Get the period info for defaults and year
        $sql = "SELECT * FROM $periodTable WHERE id = " . (int) $periodId;
        $result = Database::query($sql);
        $period = Database::fetch_array($result, 'ASSOC');
        if (!$period) {
            return ['admission_amount' => 0, 'enrollment_amount' => 0, 'monthly_amount' => 0, 'source' => 'none'];
        }

        $defaults = [
            'admission_amount' => (float) $period['admission_amount'],
            'enrollment_amount' => (float) $period['enrollment_amount'],
            'monthly_amount' => (float) $period['monthly_amount'],
            'source' => 'period_default',
        ];

        // Find student's classroom for this period's year
        // Match by academic year that corresponds to the payment period year
        $yearTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
        $sql = "SELECT c.grade_id, g.level_id
                FROM $csTable cs
                INNER JOIN $classroomTable c ON cs.classroom_id = c.id
                INNER JOIN $yearTable y ON c.academic_year_id = y.id
                INNER JOIN $gradeTable g ON c.grade_id = g.id
                WHERE cs.user_id = " . (int) $userId . "
                AND y.year = " . (int) $period['year'] . "
                LIMIT 1";
        $result = Database::query($sql);
        $classroom = Database::fetch_array($result, 'ASSOC');

        if (!$classroom) {
            return $defaults;
        }

        $gradeId = (int) $classroom['grade_id'];
        $levelId = (int) $classroom['level_id'];

        // 1) Try grade-specific price
        $sql = "SELECT * FROM $priceTable
                WHERE period_id = " . (int) $periodId . "
                AND level_id = $levelId AND grade_id = $gradeId
                LIMIT 1";
        $result = Database::query($sql);
        $gradePrice = Database::fetch_array($result, 'ASSOC');
        if ($gradePrice) {
            return [
                'admission_amount' => (float) $gradePrice['admission_amount'],
                'enrollment_amount' => (float) $gradePrice['enrollment_amount'],
                'monthly_amount' => (float) $gradePrice['monthly_amount'],
                'source' => 'grade',
            ];
        }

        // 2) Try level price
        $sql = "SELECT * FROM $priceTable
                WHERE period_id = " . (int) $periodId . "
                AND level_id = $levelId AND grade_id IS NULL
                LIMIT 1";
        $result = Database::query($sql);
        $levelPrice = Database::fetch_array($result, 'ASSOC');
        if ($levelPrice) {
            return [
                'admission_amount' => (float) $levelPrice['admission_amount'],
                'enrollment_amount' => (float) $levelPrice['enrollment_amount'],
                'monthly_amount' => (float) $levelPrice['monthly_amount'],
                'source' => 'level',
            ];
        }

        // 3) Fall back to period defaults
        return $defaults;
    }
}
