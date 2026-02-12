<?php

require_once __DIR__.'/config.php';

$plugin = SchoolPlugin::create();
// Simplemente llama la función
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
$enableCompleteProfile = $plugin->get('enable_complete_profile') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
//$htmlHeadXtra[] = api_get_css(api_get_path(WEB_PLUGIN_PATH) . 'school/css/style.css');
$plugin->setCurrentSection('dashboard');
$plugin->setSidebar('dashboard');
api_block_anonymous_users();
$showProfileCompletionModal = false;
$currentProfileData = [];

if ($enable) {
    $userId = api_get_user_id();
    if ($userId) {
        if($enableCompleteProfile){
            $profileCompletionFile = __DIR__.'/../../main/auth/external_login/check_profile_completion.php';
            if (file_exists($profileCompletionFile)) {
                require_once $profileCompletionFile;
            }
            // Verificar directamente en la BD si los campos están completos
            if (function_exists('checkProfileCompletion')) {
                $profileCheck = checkProfileCompletion($userId);
                if ($profileCheck['needs_completion']) {
                    $showProfileCompletionModal = true;
                    $currentProfileData = $profileCheck['current_values'];

                    error_log("Mostrando modal de completar perfil para usuario $userId. Campos faltantes: " .
                        implode(', ', $profileCheck['missing_fields']));
                } else {
                    error_log("Perfil completo para usuario $userId");
                }
            }
        }

    }
    $countries = $plugin->getCountriesData();
    $sessionsCategories = $plugin->getSessionsByCategory($userId);
    $countCourses = $sessionsCategories['total'];
    $countHistory = $plugin->getSessionsByCategoryCount($userId, true);

    // Cursos base (sin sesión)
    $showBaseCourses = $plugin->get('show_base_courses') == 'true';
    $baseCourses = [];
    $totalBaseCourses = 0;
    if ($showBaseCourses) {
        $baseCoursesData = $plugin->getBaseCoursesByUser($userId);
        $baseCourses = $baseCoursesData['courses'];
        $totalBaseCourses = $baseCoursesData['total'];
    }

    $total = $countCourses + $countHistory + $totalBaseCourses;
    $imgSection = $plugin->get_svg_icon('girl',$plugin->get_lang('CurrentCourses'), 500);
    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $plugin->assign('categories', $sessionsCategories['categories']);
    $plugin->assign('img_section', $imgSection);
    $plugin->assign('total', $countHistory);
    $plugin->assign('show_base_courses', $showBaseCourses);
    $plugin->assign('base_courses', $baseCourses);
    $plugin->assign('total_base_courses', $totalBaseCourses);
    if($enableCompleteProfile){
        $plugin->assign('show_profile_completion_modal', $showProfileCompletionModal);
        $plugin->assign('current_profile_data', $currentProfileData);
    }
    $plugin->setTitle($plugin->get_lang('MyTrainings'));
    if($total > 0){
        $plugin->assign('total_courses', $countCourses);
        $plugin->assign('total_history', $countHistory);
        $plugin->assign('countries', $countries);
        $content = $plugin->fetch('school_dashboard.tpl');
    } else {
        $plugin->assign('countries', $countries);
        $content = $plugin->fetch('school_none.tpl');
    }
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
