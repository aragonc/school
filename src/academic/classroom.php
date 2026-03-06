<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../AcademicManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$isAdmin = api_is_platform_admin();

if (!$isAdmin) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('academic');
$plugin->setSidebar('academic');

$classroomId = isset($_GET['id']) ? (int) $_GET['id'] : 0;
if (!$classroomId) {
    header('Location: /academic');
    exit;
}

$classroom = AcademicManager::getClassroom($classroomId);
if (!$classroom) {
    header('Location: /academic');
    exit;
}

$students    = AcademicManager::getClassroomStudents($classroomId);
$candidates  = AcademicManager::getClassroomCandidates($classroomId);
$auxiliaries = AcademicManager::getClassroomAuxiliaries($classroomId);

$sessionCourses  = AcademicManager::getClassroomCourses($classroomId);
$unsyncedCourses = !empty($classroom['session_id'])
    ? AcademicManager::getUnsyncedSessionCourses($classroomId, (int) $classroom['session_id'])
    : [];

$plugin->assign('classroom',       $classroom);
$plugin->assign('students',        $students);
$plugin->assign('auxiliaries',     $auxiliaries);
$plugin->assign('session_courses',  $sessionCourses);
$plugin->assign('unsynced_courses', $unsyncedCourses);
$plugin->assign('pending_count',   count($candidates));
$plugin->assign('is_admin',        $isAdmin);
$plugin->assign('web_course_path', api_get_path(WEB_COURSE_PATH));
$plugin->assign('ajax_url',        api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_academic.php');

$title = $classroom['level_name'] . ' - ' . $classroom['grade_name'] . ' "' . $classroom['section_name'] . '"';
$plugin->setTitle($title);

$content = $plugin->fetch('academic/classroom.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
