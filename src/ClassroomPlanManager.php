<?php
/* For licensing terms, see /license.txt */

/**
 * ClassroomPlanManager — School Plugin
 * Manages monthly class-topic planning per classroom.
 *
 * Each entry represents one subject's topic for a specific date in a classroom.
 * Multiple entries per day are allowed (one per subject/teacher).
 *
 * @package chamilo.plugin.school
 */
class ClassroomPlanManager
{
    /**
     * Returns the classroom tutored by $userId in $yearId, with grade/section/level names.
     * Returns null if the user is not a tutor of any classroom this year.
     */
    public static function getTutorClassroom(int $userId, int $yearId): ?array
    {
        if ($userId <= 0 || $yearId <= 0) {
            return null;
        }

        $cTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $gTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $sTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
        $lTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);

        $sql = "SELECT c.id, c.academic_year_id, c.grade_id, c.section_id, c.tutor_id, c.supervisor_id, c.capacity,
                       g.name AS grade_name, g.level_id,
                       s.name AS section_name,
                       l.name AS level_name
                FROM $cTable c
                INNER JOIN $gTable  g ON g.id  = c.grade_id
                INNER JOIN $sTable  s ON s.id  = c.section_id
                INNER JOIN $lTable  l ON l.id  = g.level_id
                WHERE (c.tutor_id = $userId OR c.supervisor_id = $userId)
                  AND c.academic_year_id = $yearId
                LIMIT 1";

        $result = Database::query($sql);
        $row    = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    /**
     * Returns all classrooms where $userId is assigned as supervisor for $yearId.
     */
    public static function getSupervisorClassrooms(int $userId, int $yearId): array
    {
        if ($userId <= 0 || $yearId <= 0) {
            return [];
        }

        $cTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $gTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $sTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
        $lTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $csTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        $uTable  = Database::get_main_table(TABLE_MAIN_USER);

        $sql = "SELECT c.id, c.academic_year_id, c.grade_id, c.section_id,
                       c.tutor_id, c.supervisor_id, c.session_id, c.capacity,
                       g.name AS grade_name, g.level_id, g.order_index AS grade_order,
                       s.name AS section_name,
                       l.name AS level_name, l.order_index AS level_order,
                       (SELECT COUNT(*) FROM $csTable cs WHERE cs.classroom_id = c.id) AS student_count,
                       CONCAT(u.firstname, ' ', u.lastname) AS tutor_full_name
                FROM $cTable c
                INNER JOIN $gTable g ON g.id = c.grade_id
                INNER JOIN $sTable s ON s.id = c.section_id
                INNER JOIN $lTable l ON l.id = g.level_id
                LEFT  JOIN $uTable u ON u.id = c.tutor_id
                WHERE c.supervisor_id = $userId
                  AND c.academic_year_id = $yearId
                ORDER BY l.order_index ASC, g.order_index ASC, s.name ASC";

        $result = Database::query($sql);
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            // Resolve session name
            if (!empty($row['session_id'])) {
                $sessionTable = Database::get_main_table(TABLE_MAIN_SESSION);
                $sid = (int) $row['session_id'];
                $sRes = Database::query("SELECT id, name FROM $sessionTable WHERE id = $sid LIMIT 1");
                $sRow = Database::fetch_array($sRes, 'ASSOC');
                $row['session_name'] = $sRow ? $sRow['name'] : '';

                // Get courses in the session
                $srcTable    = Database::get_main_table(TABLE_MAIN_SESSION_COURSE);
                $courseTable = Database::get_main_table(TABLE_MAIN_COURSE);
                $cRes = Database::query(
                    "SELECT c.id, c.code, c.title, c.visual_code
                     FROM $srcTable src
                     INNER JOIN $courseTable c ON c.id = src.c_id
                     WHERE src.session_id = $sid
                     ORDER BY c.title ASC"
                );
                $courses = [];
                while ($cRow = Database::fetch_array($cRes, 'ASSOC')) {
                    $courses[] = $cRow;
                }
                $row['session_courses'] = $courses;
            } else {
                $row['session_name']    = '';
                $row['session_courses'] = [];
            }
            $rows[] = $row;
        }
        return $rows;
    }

    /**
     * Returns true if $userId is supervisor of at least one classroom in $yearId.
     */
    public static function isSupervisor(int $userId, int $yearId): bool
    {
        if ($userId <= 0 || $yearId <= 0) {
            return false;
        }
        $cTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $res = Database::query(
            "SELECT id FROM $cTable WHERE supervisor_id = $userId AND academic_year_id = $yearId LIMIT 1"
        );
        return Database::num_rows($res) > 0;
    }

    /**
     * Returns all plan entries for a classroom in a given month, indexed by date.
     * Format: ['2026-03-03' => [['id'=>1,'subject'=>'...','topic'=>'...','teacher_name'=>'...'], ...]]
     */
    public static function getPlansByClassroomMonth(int $classroomId, int $year, int $month): array
    {
        if ($classroomId <= 0) {
            return [];
        }

        $table     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_PLAN);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $m         = str_pad($month, 2, '0', STR_PAD_LEFT);

        $sql = "SELECT p.id, p.classroom_id, p.plan_date, p.subject, p.topic, p.notes,
                       p.teacher_id, p.created_at, p.updated_at,
                       CONCAT(u.lastname, ' ', u.firstname) AS teacher_name
                FROM $table p
                LEFT JOIN $userTable u ON u.user_id = p.teacher_id
                WHERE p.classroom_id = $classroomId
                  AND p.plan_date BETWEEN '{$year}-{$m}-01' AND LAST_DAY('{$year}-{$m}-01')
                ORDER BY p.plan_date ASC, p.id ASC";

        $result = Database::query($sql);
        $plans  = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $date = $row['plan_date'];
            $plans[$date][] = $row;
        }
        return $plans;
    }

    /**
     * Insert or update a plan entry.
     * If $data['id'] > 0, updates the existing record (only the owner or tutor should call this).
     * Returns the saved record ID (> 0 on success, 0 on failure).
     */
    public static function savePlan(array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_PLAN);
        $id    = isset($data['id']) ? (int) $data['id'] : 0;

        $params = [
            'classroom_id' => (int) ($data['classroom_id'] ?? 0),
            'plan_date'    => Database::escape_string($data['plan_date'] ?? date('Y-m-d')),
            'subject'      => Database::escape_string(trim($data['subject'] ?? '')),
            'topic'        => Database::escape_string(trim($data['topic'] ?? '')),
            'notes'        => !empty($data['notes']) ? Database::escape_string(trim($data['notes'])) : null,
            'teacher_id'   => (int) ($data['teacher_id'] ?? api_get_user_id()),
        ];

        if (!$params['classroom_id'] || !$params['subject'] || !$params['topic']) {
            return 0;
        }

        if ($id > 0) {
            $params['updated_at'] = api_get_utc_datetime();
            Database::update($table, $params, ['id = ?' => $id]);
            return $id;
        }

        $params['created_at'] = api_get_utc_datetime();
        return (int) Database::insert($table, $params);
    }

    /**
     * Deletes a plan entry.
     * $isTutorOrAdmin: if true, can delete any entry; otherwise only if teacher_id matches.
     */
    public static function deletePlan(int $id, int $requestingUserId, bool $isTutorOrAdmin): bool
    {
        if ($id <= 0) {
            return false;
        }

        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_PLAN);

        if (!$isTutorOrAdmin) {
            // Non-tutor: can only delete own entries
            $check = Database::query(
                "SELECT id FROM $table WHERE id = $id AND teacher_id = $requestingUserId LIMIT 1"
            );
            if (Database::num_rows($check) === 0) {
                return false;
            }
        }

        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    /**
     * Returns a single plan entry by ID (with teacher name).
     */
    public static function getPlanById(int $id): ?array
    {
        if ($id <= 0) {
            return null;
        }

        $table     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_PLAN);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        $sql    = "SELECT p.*, CONCAT(u.lastname, ' ', u.firstname) AS teacher_name
                   FROM $table p
                   LEFT JOIN $userTable u ON u.user_id = p.teacher_id
                   WHERE p.id = $id LIMIT 1";
        $result = Database::query($sql);
        $row    = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }
}
