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
        $csTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        $sql = "SELECT cs.*, u.firstname, u.lastname, u.username, u.email, u.picture_uri
                FROM $csTable cs
                INNER JOIN $userTable u ON cs.user_id = u.id
                WHERE cs.classroom_id = " . (int) $classroomId . "
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
        Database::delete($table, ['classroom_id = ?' => $classroomId, 'user_id = ?' => $userId]);
        return true;
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
}
