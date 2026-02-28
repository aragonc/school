<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../src/AcademicManager.php';
require_once __DIR__ . '/../../src/MatriculaManager.php';
require_once __DIR__ . '/../../src/ClassroomPlanManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$userId   = api_get_user_id();
$userInfo = api_get_user_info($userId);

$isAdmin     = api_is_platform_admin();
$isSecretary = $userInfo && (int) $userInfo['status'] === SCHOOL_SECRETARY;
$isTeacher   = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;
$isStudent   = $userInfo && (int) $userInfo['status'] === STUDENT;

// Secretary cannot access
if ($isSecretary) {
    api_not_allowed(true);
}

// Only admin, teacher, or student
if (!$isAdmin && !$isTeacher && !$isStudent) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('my-classroom-schedule');
$plugin->setSidebar('my-classroom-schedule');

// Ensure table exists (migration on first load)
$schedTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_SCHEDULE);
Database::query("CREATE TABLE IF NOT EXISTS $schedTable (
    id            INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    classroom_id  INT NOT NULL,
    day_of_week   TINYINT NOT NULL DEFAULT 0,
    time_start    TIME NOT NULL,
    time_end      TIME NOT NULL,
    subject       VARCHAR(255) NOT NULL DEFAULT '',
    teacher_id    INT NULL DEFAULT NULL,
    teacher_name  VARCHAR(255) NULL DEFAULT NULL,
    style         VARCHAR(30) NOT NULL DEFAULT '',
    sort_order    SMALLINT NOT NULL DEFAULT 0,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_classroom (classroom_id),
    INDEX idx_classroom_day (classroom_id, day_of_week)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

// Active academic year
$activeYear = MatriculaManager::getActiveYear();
$yearId     = $activeYear ? (int) $activeYear['id'] : 0;

// Determine which classroom to show
$classroomId    = isset($_GET['classroom_id']) ? (int) $_GET['classroom_id'] : 0;
$classroom      = null;
$classroomsList = [];
$isTutor        = false;

if ($isAdmin) {
    if ($yearId > 0) {
        $classroomsList = AcademicManager::getClassrooms($yearId);
    }
    if ($classroomId > 0) {
        $classroom = AcademicManager::getClassroom($classroomId);
    } elseif (!empty($classroomsList)) {
        $classroom   = $classroomsList[0];
        $classroomId = (int) $classroom['id'];
    }
    $isTutor = true; // admin can always edit
} elseif ($isTeacher) {
    $tutorClassroom = $yearId > 0 ? ClassroomPlanManager::getTutorClassroom($userId, $yearId) : null;
    if ($tutorClassroom) {
        $classroom   = $tutorClassroom;
        $classroomId = (int) $tutorClassroom['id'];
        $isTutor     = true;
    } else {
        // Non-tutor teacher: show all classrooms (read-only)
        if ($yearId > 0) {
            $classroomsList = AcademicManager::getClassrooms($yearId);
        }
        if ($classroomId > 0) {
            $classroom = AcademicManager::getClassroom($classroomId);
        } elseif (!empty($classroomsList)) {
            $classroom   = $classroomsList[0];
            $classroomId = (int) $classroom['id'];
        }
        $isTutor = false;
    }
} elseif ($isStudent) {
    $studentClassroom = $yearId > 0 ? AcademicManager::getStudentClassroom($yearId, $userId) : null;
    if ($studentClassroom) {
        $classroomId = (int) $studentClassroom['id'];
        $classroom   = AcademicManager::getClassroom($classroomId);
    }
    $isTutor = false;
}

// Enrich classroom with tutor name
if ($classroom && !empty($classroom['tutor_id']) && empty($classroom['tutor_name'])) {
    $tInfo = api_get_user_info((int) $classroom['tutor_id']);
    $classroom['tutor_name'] = $tInfo ? $tInfo['complete_name'] : '';
}

// Fetch schedule entries for this classroom
$scheduleEntries = [];
if ($classroomId > 0) {
    $sql = "SELECT * FROM $schedTable
            WHERE classroom_id = $classroomId
            ORDER BY sort_order ASC, time_start ASC, day_of_week ASC";
    $result = Database::query($sql);
    while ($row = Database::fetch_array($result, 'ASSOC')) {
        $scheduleEntries[] = $row;
    }
}

// Build schedule grid:
// Collect distinct time slots (day_of_week=0 entries apply to all days, day=1-5 are day-specific)
// We'll group by (time_start, time_end, style) for rows, then within each row get day columns

// Collect all unique time slots
$timeSlotsMap = [];
foreach ($scheduleEntries as $entry) {
    $key = $entry['time_start'] . '|' . $entry['time_end'] . '|' . (int)$entry['sort_order'];
    if (!isset($timeSlotsMap[$key])) {
        $timeSlotsMap[$key] = [
            'time_start' => $entry['time_start'],
            'time_end'   => $entry['time_end'],
            'sort_order' => (int) $entry['sort_order'],
            'style'      => $entry['style'],
            'days'       => [], // day => entry data
        ];
    }
    // Merge style (break/pause/exit/fullday entries may apply to all days)
    if (!empty($entry['style'])) {
        $timeSlotsMap[$key]['style'] = $entry['style'];
    }
    $day = (int) $entry['day_of_week'];
    $timeSlotsMap[$key]['days'][$day] = $entry;
}

// Sort by sort_order then time_start
uasort($timeSlotsMap, function ($a, $b) {
    if ($a['sort_order'] !== $b['sort_order']) {
        return $a['sort_order'] - $b['sort_order'];
    }
    return strcmp($a['time_start'], $b['time_start']);
});

$scheduleGrid = array_values($timeSlotsMap);

// Teachers list for edit modal
$teachersList = ($isAdmin || $isTutor) ? AcademicManager::getTeachers() : [];

// Day names
$dayNames = [1 => 'Lunes', 2 => 'Martes', 3 => 'Miércoles', 4 => 'Jueves', 5 => 'Viernes'];

$plugin->assign('classroom',           $classroom);
$plugin->assign('classroom_id',        $classroomId);
$plugin->assign('classrooms_list',     $classroomsList);
$plugin->assign('is_admin',            $isAdmin);
$plugin->assign('is_tutor',            $isTutor);
$plugin->assign('can_edit',            $isAdmin || $isTutor);
$plugin->assign('is_student',          $isStudent);
$plugin->assign('schedule_grid',       $scheduleGrid);
$plugin->assign('teachers_list',       $teachersList);
$plugin->assign('day_names',           $dayNames);
$plugin->assign('active_year',         $activeYear);
$plugin->assign('ajax_url',            api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_schedule.php');

$plugin->setTitle('Horario');
$content = $plugin->fetch('classroom/schedule.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
