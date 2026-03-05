<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../src/ClassroomPlanManager.php';
require_once __DIR__ . '/../../src/MatriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$userId   = api_get_user_id();
$userInfo = api_get_user_info($userId);

$isAdmin     = api_is_platform_admin();
$isTeacher   = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;

if (!$isAdmin && !$isTeacher) {
    api_not_allowed(true);
}

$activeYear = MatriculaManager::getActiveYear();
$yearId     = $activeYear ? (int) $activeYear['id'] : 0;

// Non-admin: only supervisors can access this page
if (!$isAdmin && !ClassroomPlanManager::isSupervisor($userId, $yearId)) {
    api_not_allowed(true);
}

// Get all classrooms supervised by this user (admin sees all via param)
if ($isAdmin && isset($_GET['user_id'])) {
    $targetUserId = (int) $_GET['user_id'];
    $classrooms   = $targetUserId > 0
        ? ClassroomPlanManager::getSupervisorClassrooms($targetUserId, $yearId)
        : [];
} else {
    $classrooms = ClassroomPlanManager::getSupervisorClassrooms($userId, $yearId);
}

$plugin->setCurrentSection('supervision');
$plugin->setSidebar('supervision');
$plugin->setTitle('Supervisión');

$plugin->assign('classrooms',      $classrooms);
$plugin->assign('year_name',       $activeYear ? $activeYear['name'] : '');
$plugin->assign('web_course_path', api_get_path(WEB_COURSE_PATH));

$content = $plugin->fetch('supervision/index.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
