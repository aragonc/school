<?php

require_once __DIR__.'/config.php';

// Aplicar reglas de visibilidad del plugin toolscourses automáticamente al cargar el curso
$_tcPluginPath = api_get_path(SYS_PLUGIN_PATH).'toolscourses/ToolsCourses.php';
if (file_exists($_tcPluginPath)) {
    $_tcTable = 'plugin_toolscourses_schedule';
    $_tcCheck = Database::query("SHOW TABLES LIKE '$_tcTable'");
    if (Database::num_rows($_tcCheck) > 0) {
        require_once $_tcPluginPath;
        if (ToolsCourses::create()->isEnabled()) {
            ToolsCourses::create()->applyVisibilityRules();
            ToolsCourses::create()->applyLessonVisibilityRules();
        }
    }
}
unset($_tcPluginPath, $_tcTable, $_tcCheck);

$plugin = SchoolPlugin::create();
// Simplemente llama la función
$plugin->requireLogin();

$buyCourse = BuyCoursesPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');

$user_id = api_get_user_id();
$course_code = api_get_course_id();
$courseId = api_get_course_int_id();
$sessionId = api_get_session_id();

$iconCourse = $plugin->get_svg_icon('course_white','' ,32);
$action = !empty($_GET['action']) ? Security::remove_XSS($_GET['action']) : '';
$plugin->setSidebar('course');
api_protect_course_script(true);

$session = $plugin->getInfoSession($sessionId);
$courseInfo = api_get_course_info_by_id($courseId);

$words = explode(' ', $courseInfo['title']);
$first_four = array_slice($words, 0, 4);
$rest = array_slice($words, 4);
$title = '<span>' . implode(' ', $first_four) . '</span> ' . implode(' ', $rest);
$courseInfo['title'] = $title;

$logInfo = [
    'tool' => 'course-main',
    'tool_id' => 0,
    'tool_id_detail' => 0,
    'action' => $action,
    'info' => '',
];
Event::registerLog($logInfo);
$content = '';
$checkIcon = $plugin->get_svg_icon('smile', $plugin->get_lang('Welcome'), 64);
$tools = $plugin->getToolsCourseHome($sessionId, $courseId);
$plugin->setTitle('');

$modalSence = '';
//check enabled plugin sence
if(class_exists('SencePlugin')){
    $sencePlugin = SencePlugin::create();
    $enable = $sencePlugin->get('sence_enabled') == 'true';
    if($enable){
        $modalSence = $sencePlugin->loadLoginSence();
    }
}

$plugin->assign('session', $session);
$plugin->assign('course', $courseInfo);
$plugin->assign('icon_course', $iconCourse);
$plugin->assign('icon_smile', $checkIcon);
$plugin->assign('tools_one', $tools['home']);
$plugin->assign('tools_two', $tools['scorm']);
$plugin->assign('tools_tree', $tools['tools']);
$content = $plugin->fetch('school_course_home.tpl');
$plugin->assign('content', $content.$modalSence);
$plugin->display_blank_template();
