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

    // Documentos de Reglamento Interno
    $uploadDir = api_get_path(SYS_UPLOAD_PATH).'plugins/school/reglamento/';
    $meses = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
    $reglamentoDocs = [];
    $docsConfig = [
        'reglamento_interno'  => ['label' => $plugin->get_lang('DocReglamentoInterno'),  'icon' => 'fa-file-contract',  'color' => 'primary'],
        'boletin_informativo' => ['label' => $plugin->get_lang('DocBoletinInformativo'),  'icon' => 'fa-newspaper',       'color' => 'info'],
        'reglas_generales'    => ['label' => $plugin->get_lang('DocReglasGenerales'),     'icon' => 'fa-list-alt',        'color' => 'warning'],
    ];
    foreach ($docsConfig as $key => $cfg) {
        $filename = $plugin->getSchoolSetting('reglamento_file_'.$key);
        if ($filename && file_exists($uploadDir.$filename)) {
            $rawDate = $plugin->getSchoolSetting('reglamento_date_'.$key) ?: '';
            $friendlyDate = '';
            if ($rawDate) {
                $parts = explode('-', $rawDate);
                if (count($parts) === 3) {
                    $friendlyDate = (int)$parts[2].' de '.$meses[(int)$parts[1] - 1].' de '.$parts[0];
                }
            }
            $reglamentoDocs[] = [
                'label'   => $cfg['label'],
                'icon'    => $cfg['icon'],
                'color'   => $cfg['color'],
                'url'     => api_get_path(WEB_UPLOAD_PATH).'plugins/school/reglamento/'.$filename,
                'date'    => $friendlyDate,
            ];
        }
    }
    $plugin->assign('reglamento_docs', $reglamentoDocs);

    if ($enableCompleteProfile) {
        $plugin->assign('show_profile_completion_modal', $showProfileCompletionModal);
        $plugin->assign('current_profile_data', $currentProfileData);
    }

    $plugin->setTitle($plugin->get_lang('Dashboard'));
    $content = $plugin->fetch('dashboard/start.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
