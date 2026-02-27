<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('attendance');
$plugin->setSidebar('attendance');
api_block_anonymous_users();

$isAdmin = api_is_platform_admin();
if (!$isAdmin) {
    api_not_allowed(true);
}

date_default_timezone_set(api_get_timezone());

$levelId   = isset($_GET['level_id'])   ? (int) $_GET['level_id']   : 0;
$gradeId   = isset($_GET['grade_id'])   ? (int) $_GET['grade_id']   : 0;
$sectionId = isset($_GET['section_id']) ? (int) $_GET['section_id'] : 0;

$students = $plugin->getStudentsForAttendance(
    $levelId   ?: null,
    $gradeId   ?: null,
    $sectionId ?: null
);

foreach ($students as &$student) {
    if (!empty($student['check_in'])) {
        $student['check_in'] = api_get_local_time($student['check_in']);
    }
}
unset($student);

$filters = $plugin->getAcademicFiltersForAttendance();

$plugin->assign('is_admin', $isAdmin);
$plugin->assign('active_tab', 'manual_students');
$plugin->assign('students', $students);
$plugin->assign('levels',   $filters['levels']);
$plugin->assign('grades',   $filters['grades']);
$plugin->assign('sections', $filters['sections']);
$plugin->assign('filter_level_id',   $levelId);
$plugin->assign('filter_grade_id',   $gradeId);
$plugin->assign('filter_section_id', $sectionId);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_attendance.php');

$plugin->setTitle($plugin->get_lang('AttendanceStudents'));

$content = $plugin->fetch('attendance/manual_students.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
