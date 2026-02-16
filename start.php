<?php

require_once __DIR__.'/config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
$enableCompleteProfile = $plugin->get('enable_complete_profile') == 'true';
$plugin->setCurrentSection('dashboard');
$plugin->setSidebar('dashboard');
api_block_anonymous_users();
$showProfileCompletionModal = false;
$currentProfileData = [];

if ($enable) {
    $userId = api_get_user_id();
    $userInfo = api_get_user_info($userId);

    if ($userId && $enableCompleteProfile) {
        $profileCompletionFile = __DIR__.'/../../main/auth/external_login/check_profile_completion.php';
        if (file_exists($profileCompletionFile)) {
            require_once $profileCompletionFile;
        }
        if (function_exists('checkProfileCompletion')) {
            $profileCheck = checkProfileCompletion($userId);
            if ($profileCheck['needs_completion']) {
                $showProfileCompletionModal = true;
                $currentProfileData = $profileCheck['current_values'];
            }
        }
    }

    // Cursos activos
    $sessionsCategories = $plugin->getSessionsByCategory($userId);
    $countCourses = $sessionsCategories['total'];

    // Cursos base
    $showBaseCourses = $plugin->get('show_base_courses') == 'true';
    $totalBaseCourses = 0;
    if ($showBaseCourses) {
        $baseCoursesData = $plugin->getBaseCoursesByUser($userId);
        $totalBaseCourses = $baseCoursesData['total'];
    }

    // Cursos anteriores
    $countHistory = $plugin->getSessionsByCategoryCount($userId, true);

    // Asistencia de hoy
    $todayDate = date('Y-m-d');
    $todayAttendance = $plugin->getAttendanceByUser($userId, $todayDate, $todayDate);

    $plugin->assign('user_info', $userInfo);
    $plugin->assign('total_courses', $countCourses + $totalBaseCourses);
    $plugin->assign('total_history', $countHistory);
    $plugin->assign('today_attendance', $todayAttendance);
    $plugin->assign('show_certificates', $plugin->get('show_certificates') == 'true');

    if ($enableCompleteProfile) {
        $plugin->assign('show_profile_completion_modal', $showProfileCompletionModal);
        $plugin->assign('current_profile_data', $currentProfileData);
    }

    $plugin->setTitle($plugin->get_lang('Dashboard'));
    $content = $plugin->fetch('school_start.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
