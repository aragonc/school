<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../src/ClassroomPlanManager.php';
require_once __DIR__ . '/../../src/AcademicManager.php';
require_once __DIR__ . '/../../src/MatriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$userId   = api_get_user_id();
$userInfo = api_get_user_info($userId);

$isAdmin       = api_is_platform_admin();
$isSecretary   = $userInfo && (int) $userInfo['status'] === SCHOOL_SECRETARY;
$isTeacher     = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;
$isStudent     = $userInfo && (int) $userInfo['status'] === STUDENT;

// Secretary cannot access Mi Aula
if ($isSecretary) {
    api_not_allowed(true);
}

// Only admin, teacher or student can access
if (!$isAdmin && !$isTeacher && !$isStudent) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('my-classroom');
$plugin->setSidebar('my-classroom');

// Active academic year
$activeYear = MatriculaManager::getActiveYear();
$yearId     = $activeYear ? (int) $activeYear['id'] : 0;

// Month navigation
$currentYear  = isset($_GET['year'])  ? (int) $_GET['year']  : (int) date('Y');
$currentMonth = isset($_GET['month']) ? (int) $_GET['month'] : (int) date('n');
if ($currentMonth < 1)  { $currentMonth = 1; }
if ($currentMonth > 12) { $currentMonth = 12; }

// Determine which classroom to show
$classroomId = isset($_GET['classroom_id']) ? (int) $_GET['classroom_id'] : 0;
$classroom   = null;
$isTutor     = false;
$classroomsList = [];

if ($isAdmin || $isSecretary) {
    // Admin/Secretary: list all classrooms for selection
    if ($yearId > 0) {
        $classroomsList = AcademicManager::getClassrooms($yearId);
    }
    if ($classroomId > 0) {
        $classroom = AcademicManager::getClassroom($classroomId);
        // Check if the selected classroom's tutor is the current user (edge case)
        $isTutor = $isAdmin; // admins have full control
    } elseif (!empty($classroomsList)) {
        $classroom   = $classroomsList[0];
        $classroomId = (int) $classroom['id'];
        $isTutor     = $isAdmin;
    }
} elseif ($isTeacher) {
    // All classrooms where this teacher is tutor OR assigned as course teacher
    $classroomsList = $yearId > 0 ? AcademicManager::getTeacherClassrooms($userId, $yearId) : [];

    if ($classroomId > 0) {
        $classroom = AcademicManager::getClassroom($classroomId);
    } elseif (!empty($classroomsList)) {
        $classroom   = $classroomsList[0];
        $classroomId = (int) $classroom['id'];
    }

    // Can edit only if tutor or supervisor of the selected classroom
    $isTutor = $classroom && (
        (int) ($classroom['tutor_id'] ?? 0) === $userId ||
        (int) ($classroom['supervisor_id'] ?? 0) === $userId
    );
} elseif ($isStudent) {
    // Student: find their classroom (read-only)
    $studentClassroom = $yearId > 0 ? AcademicManager::getStudentClassroom($yearId, $userId) : null;
    if ($studentClassroom) {
        $classroomId = (int) $studentClassroom['id'];
        $classroom   = AcademicManager::getClassroom($classroomId);
    }
    $isTutor = false;
}

// Enrich classroom with tutor name if not already set
if ($classroom && !empty($classroom['tutor_id']) && empty($classroom['tutor_name'])) {
    $tInfo = api_get_user_info((int) $classroom['tutor_id']);
    $classroom['tutor_name'] = $tInfo ? $tInfo['complete_name'] : '';
}

// Fetch plans for this classroom/month
$plansByDate = [];
if ($classroomId > 0) {
    $plansByDate = ClassroomPlanManager::getPlansByClassroomMonth($classroomId, $currentYear, $currentMonth);
}

// Load weekly schedule grouped by day_of_week (1=Mon … 5=Fri)
$scheduleByDay = [];
if ($classroomId > 0) {
    $schedTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_SCHEDULE);
    $schedResult = Database::query(
        "SELECT day_of_week, subject, time_start, style
         FROM $schedTable
         WHERE classroom_id = $classroomId
           AND day_of_week BETWEEN 1 AND 5
           AND style = ''
         ORDER BY sort_order ASC, time_start ASC"
    );
    while ($sr = Database::fetch_array($schedResult, 'ASSOC')) {
        $day  = (int) $sr['day_of_week'];
        $subj = $sr['subject'];
        if (!isset($scheduleByDay[$day]) || !in_array($subj, $scheduleByDay[$day], true)) {
            $scheduleByDay[$day][] = $subj;
        }
    }
}

// Build calendar weeks (Mon–Fri only)
$firstDay    = mktime(0, 0, 0, $currentMonth, 1, $currentYear);
$daysInMonth = (int) date('t', $firstDay);
$calendarWeeks = [];
$week = [];

for ($d = 1; $d <= $daysInMonth; $d++) {
    $ts      = mktime(0, 0, 0, $currentMonth, $d, $currentYear);
    $dayOfWeek = (int) date('N', $ts); // 1=Mon … 7=Sun
    if ($dayOfWeek >= 6) {
        continue; // Skip Sat/Sun
    }
    $dateStr = date('Y-m-d', $ts);
    $week[$dayOfWeek] = [
        'date'       => $dateStr,
        'day_num'    => $d,
        'day_name'   => ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'][$dayOfWeek],
        'plans'      => $plansByDate[$dateStr] ?? [],
        'schedule'   => $scheduleByDay[$dayOfWeek] ?? [],
    ];
    // When we reach Friday or the last weekday of the month, close the week
    if ($dayOfWeek === 5 || $d === $daysInMonth) {
        $calendarWeeks[] = $week;
        $week = [];
    }
}

// Load non-working periods (holidays/vacations) that overlap with current month
$nonworkingTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ATTENDANCE_NONWORKING);
$monthStart = sprintf('%d-%02d-01', $currentYear, $currentMonth);
$monthEnd   = sprintf('%d-%02d-%02d', $currentYear, $currentMonth, $daysInMonth);
$nwResult   = Database::query(
    "SELECT * FROM $nonworkingTable
     WHERE start_date <= '$monthEnd' AND end_date >= '$monthStart'
     ORDER BY start_date ASC"
);
$nonworkingPeriods = [];
while ($nwRow = Database::fetch_array($nwResult, 'ASSOC')) {
    $nonworkingPeriods[] = $nwRow;
}

// Annotate each calendar day with its non-working period (if any)
for ($wi = 0; $wi < count($calendarWeeks); $wi++) {
    foreach ($calendarWeeks[$wi] as $col => $dayData) {
        $nw = null;
        foreach ($nonworkingPeriods as $period) {
            if ($dayData['date'] >= $period['start_date'] && $dayData['date'] <= $period['end_date']) {
                $nw = $period;
                break;
            }
        }
        $calendarWeeks[$wi][$col]['nonworking'] = $nw;
    }
}

// Prev / next month navigation
$prevM = $currentMonth - 1;
$prevY = $currentYear;
if ($prevM < 1) { $prevM = 12; $prevY--; }
$nextM = $currentMonth + 1;
$nextY = $currentYear;
if ($nextM > 12) { $nextM = 1; $nextY++; }

$baseUrl   = api_get_path(WEB_PATH) . 'my-aula?';
$prevParam = ($classroomId ? "classroom_id={$classroomId}&" : '') . "year={$prevY}&month={$prevM}";
$nextParam = ($classroomId ? "classroom_id={$classroomId}&" : '') . "year={$nextY}&month={$nextM}";

$monthNames = [
    1 => 'Enero', 2 => 'Febrero', 3 => 'Marzo', 4 => 'Abril',
    5 => 'Mayo', 6 => 'Junio', 7 => 'Julio', 8 => 'Agosto',
    9 => 'Septiembre', 10 => 'Octubre', 11 => 'Noviembre', 12 => 'Diciembre',
];

$logo = $plugin->getCustomLogo();

$plugin->assign('classroom',           $classroom);
$plugin->assign('classroom_id',        $classroomId);
$plugin->assign('classrooms_list',     $classroomsList);
$plugin->assign('is_tutor',            $isTutor);
$plugin->assign('is_admin_or_secretary', $isAdmin || $isSecretary);
$plugin->assign('is_student',          $isStudent);
$plugin->assign('can_edit',            !$isStudent);
$plugin->assign('current_user_id',     $userId);
$plugin->assign('calendar_weeks',      $calendarWeeks);
$plugin->assign('current_year',        $currentYear);
$plugin->assign('current_month',       $currentMonth);
$plugin->assign('month_name',          $monthNames[$currentMonth]);
$plugin->assign('prev_month_url',      $baseUrl . $prevParam);
$plugin->assign('next_month_url',      $baseUrl . $nextParam);
$plugin->assign('active_year',         $activeYear);
$plugin->assign('logo',                $logo);
$plugin->assign('institution_name',    api_get_setting('Institution'));
$plugin->assign('ajax_url',            api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_classroom_plan.php');

$plugin->setTitle('Mi Aula');
$content = $plugin->fetch('classroom/my_classroom.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
