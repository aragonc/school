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

$activeYear = MatriculaManager::getActiveYear();
$yearId     = $activeYear ? (int) $activeYear['id'] : 0;

// Load teacher's classrooms/courses
$classrooms      = AcademicManager::getTeacherClassrooms($userId, $yearId);
$teacherCourses  = [];
foreach ($classrooms as $cl) {
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

// Load existing registros for this teacher
$rTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
$ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
$ctTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
$cTable  = Database::get_main_table(TABLE_MAIN_COURSE);
$clTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
$gTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
$sTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
$lTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
$areaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_AREA);

if ($isAdmin) {
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
                      WHERE cl.academic_year_id = $yearId
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

$plugin->assign('teacher_courses', $teacherCourses);
$plugin->assign('registros', $registros);
$plugin->assign('areas', $areas);
$plugin->assign('periods', $periods);
$plugin->assign('ajax_url', $ajaxUrl);
$plugin->assign('periods_ajax_url', $periodsAjaxUrl);
$plugin->assign('is_admin', $isAdmin);
$plugin->assign('active_year', $activeYear);

$content = $plugin->fetch('classroom/registro_auxiliar.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
