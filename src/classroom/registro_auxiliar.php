<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../src/AcademicManager.php';
require_once __DIR__ . '/../../src/MatriculaManager.php';
require_once __DIR__ . '/../../src/CurriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();
$plugin->requireModule('my_aula');

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$userId   = api_get_user_id();
$userInfo = api_get_user_info($userId);
$isAdmin  = api_is_platform_admin();
$isTeacher = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;

if (!$isAdmin && !$isTeacher) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('my-classroom-registro');
$plugin->setSidebar('my-classroom-registro');

// Auto-migration: add status columns if not present
$_rTbl = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
$_cols = Database::query("SHOW COLUMNS FROM $_rTbl LIKE 'status'");
if (Database::num_rows($_cols) === 0) {
    Database::query("ALTER TABLE $_rTbl
        ADD COLUMN status       ENUM('draft','submitted','reviewed') NOT NULL DEFAULT 'draft' AFTER area_id,
        ADD COLUMN submitted_at DATETIME NULL DEFAULT NULL AFTER status,
        ADD COLUMN reviewed_at  DATETIME NULL DEFAULT NULL AFTER submitted_at,
        ADD COLUMN reviewed_by  INT NULL DEFAULT NULL AFTER reviewed_at,
        ADD INDEX idx_status (status)");
}

$activeYear = MatriculaManager::getActiveYear();
$yearId     = $activeYear ? (int) $activeYear['id'] : 0;

// Classroom selector (admin picks via GET; teacher uses their own classrooms)
$selectedClassroomId = isset($_GET['classroom_id']) ? (int) $_GET['classroom_id'] : 0;
$classroomsList      = [];

if ($isAdmin) {
    if ($yearId > 0) {
        $classroomsList = AcademicManager::getClassrooms($yearId);
    }
    // Default to first classroom if none selected
    if ($selectedClassroomId <= 0 && !empty($classroomsList)) {
        $selectedClassroomId = (int) $classroomsList[0]['id'];
    }
}

// Load teacher's classrooms/courses
$classrooms     = $isAdmin
    ? ($selectedClassroomId > 0 ? [AcademicManager::getClassroom($selectedClassroomId)] : [])
    : ($yearId > 0 ? AcademicManager::getTeacherClassrooms($userId, $yearId) : []);

$teacherCourses = [];
foreach ($classrooms as $cl) {
    if (empty($cl)) continue;
    $clCourses = AcademicManager::getClassroomCourses((int) $cl['id']);
    foreach ($clCourses as $c) {
        $isAssigned = $isAdmin;
        if (!$isAssigned) {
            foreach ($c['teachers'] as $t) {
                if ((int) $t['user_id'] === $userId) {
                    $isAssigned = true;
                    break;
                }
            }
        }
        if ($isAssigned) {
            $teacherCourses[] = [
                'classroom_course_id' => (int) $c['classroom_course_id'],
                'course_title'        => $c['title'],
                'course_code'         => $c['code'],
                'classroom_id'        => (int) $cl['id'],
                'level_name'          => $cl['level_name'],
                'grade_name'          => $cl['grade_name'],
                'section_name'        => $cl['section_name'],
                'classroom_label'     => $cl['level_name'] . ' — ' . $cl['grade_name'] .
                                         (!empty($cl['section_name']) ? ' Sec. ' . $cl['section_name'] : ''),
            ];
        }
    }
}

// Load existing registros
$rTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
$ccTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
$ctTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
$cTable    = Database::get_main_table(TABLE_MAIN_COURSE);
$clTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
$gTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
$sTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
$lTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
$areaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_AREA);

if ($isAdmin) {
    $clFilter = $selectedClassroomId > 0 ? "AND cc.classroom_id = $selectedClassroomId" : "AND 1=0";
    $registros_sql = "SELECT r.*, c.title AS course_title, c.code AS course_code,
                             l.name AS level_name, g.name AS grade_name, sec.name AS section_name,
                             a.name AS area_name
                      FROM $rTable r
                      INNER JOIN $ccTable cc ON cc.id = r.classroom_course_id
                      INNER JOIN $cTable c ON c.id = cc.course_id
                      INNER JOIN $clTable cl ON cl.id = cc.classroom_id
                      INNER JOIN $gTable g ON g.id = cl.grade_id
                      LEFT JOIN $sTable sec ON sec.id = cl.section_id
                      INNER JOIN $lTable l ON l.id = g.level_id
                      LEFT JOIN $areaTable a ON a.id = r.area_id
                      WHERE cl.academic_year_id = $yearId $clFilter
                      ORDER BY l.order_index ASC, g.order_index ASC, sec.name ASC, c.title ASC, r.period ASC";
} else {
    $uid = (int) $userId;
    $registros_sql = "SELECT r.*, c.title AS course_title, c.code AS course_code,
                             l.name AS level_name, g.name AS grade_name, sec.name AS section_name,
                             a.name AS area_name
                      FROM $rTable r
                      INNER JOIN $ccTable cc ON cc.id = r.classroom_course_id
                      INNER JOIN $ctTable ct ON ct.classroom_course_id = cc.id
                      INNER JOIN $cTable c ON c.id = cc.course_id
                      INNER JOIN $clTable cl ON cl.id = cc.classroom_id
                      INNER JOIN $gTable g ON g.id = cl.grade_id
                      LEFT JOIN $sTable sec ON sec.id = cl.section_id
                      INNER JOIN $lTable l ON l.id = g.level_id
                      LEFT JOIN $areaTable a ON a.id = r.area_id
                      WHERE ct.teacher_id = $uid AND cl.academic_year_id = $yearId
                      ORDER BY l.order_index ASC, g.order_index ASC, sec.name ASC, c.title ASC, r.period ASC";
}

$registros = [];
$res = Database::query($registros_sql);
while ($row = Database::fetch_array($res, 'ASSOC')) {
    $row['classroom_label'] = $row['level_name'] . ' — ' . $row['grade_name'] .
                              (!empty($row['section_name']) ? ' Sec. ' . $row['section_name'] : '');
    $registros[] = $row;
}

// Detect if current user is tutor of any classroom in the active year
// and load registros submitted to their classroom(s)
$isTutor          = false;
$tutorRegistros   = [];

if ($isTeacher && $yearId > 0) {
    $tutorCheck = Database::fetch_array(Database::query(
        "SELECT id FROM $clTable WHERE tutor_id = $userId AND academic_year_id = $yearId LIMIT 1"
    ), 'ASSOC');
    $isTutor = !empty($tutorCheck);
}

if ($isTutor && $yearId > 0) {
    $uid = (int) $userId;
    $uTable = Database::get_main_table(TABLE_MAIN_USER);
    $tutorRes = Database::query(
        "SELECT r.*, c.title AS course_title,
                l.name AS level_name, g.name AS grade_name, sec.name AS section_name,
                a.name AS area_name,
                u.firstname AS creator_firstname, u.lastname AS creator_lastname
         FROM $rTable r
         INNER JOIN $ccTable cc ON cc.id = r.classroom_course_id
         INNER JOIN $cTable c ON c.id = cc.course_id
         INNER JOIN $clTable cl ON cl.id = cc.classroom_id
         INNER JOIN $gTable g ON g.id = cl.grade_id
         LEFT JOIN $sTable sec ON sec.id = cl.section_id
         INNER JOIN $lTable l ON l.id = g.level_id
         LEFT JOIN $areaTable a ON a.id = r.area_id
         INNER JOIN $uTable u ON u.user_id = r.created_by
         WHERE cl.tutor_id = $uid AND cl.academic_year_id = $yearId
           AND r.status IN ('submitted','reviewed')
           AND r.created_by <> $uid
         ORDER BY r.submitted_at DESC"
    );
    while ($row = Database::fetch_array($tutorRes, 'ASSOC')) {
        $row['classroom_label'] = $row['level_name'] . ' — ' . $row['grade_name'] .
                                  (!empty($row['section_name']) ? ' Sec. ' . $row['section_name'] : '');
        $row['creator_name'] = $row['creator_lastname'] . ', ' . $row['creator_firstname'];
        $tutorRegistros[] = $row;
    }
}

// Load curricula areas for the create form
$areas = CurriculaManager::getAreas();

// Load periods from DB for active year; fallback to defaults if none defined
$periods = [];
if ($yearId > 0) {
    $periodTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_PERIOD);
    $perRes = Database::query(
        "SELECT id, name, date_start, date_end FROM $periodTable
         WHERE academic_year_id = $yearId AND active = 1
         ORDER BY order_index ASC, date_start ASC"
    );
    while ($pr = Database::fetch_array($perRes, 'ASSOC')) {
        $periods[] = $pr;
    }
}
if (empty($periods)) {
    // Default fallback if no periods defined yet
    $defaults = ['I BIMESTRE', 'II BIMESTRE', 'III BIMESTRE', 'IV BIMESTRE'];
    foreach ($defaults as $d) {
        $periods[] = ['id' => 0, 'name' => $d, 'date_start' => '', 'date_end' => ''];
    }
}

$ajaxUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_registro_auxiliar.php';
$periodsAjaxUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_academic_periods.php';

$plugin->assign('teacher_courses',       $teacherCourses);
$plugin->assign('registros',             $registros);
$plugin->assign('areas',                 $areas);
$plugin->assign('periods',               $periods);
$plugin->assign('ajax_url',              $ajaxUrl);
$plugin->assign('periods_ajax_url',      $periodsAjaxUrl);
$plugin->assign('is_admin',              $isAdmin);
$plugin->assign('is_tutor',              $isTutor);
$plugin->assign('tutor_registros',       $tutorRegistros);
$plugin->assign('active_year',           $activeYear);
$plugin->assign('classrooms_list',       $classroomsList);
$plugin->assign('selected_classroom_id', $selectedClassroomId);
$plugin->assign('current_user_id',       $userId);

$content = $plugin->fetch('classroom/registro_auxiliar.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
