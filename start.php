<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
//$htmlHeadXtra[] = api_get_css(api_get_path(WEB_PLUGIN_PATH) . 'school/css/style.css');
$plugin->setCurrentSection('dashboard');
$plugin->setSidebar('dashboard');
api_block_anonymous_users();

if ($enable) {
    $userId = api_get_user_id();
    $sessionsCategories = $plugin->getSessionsByCategory($userId);
    var_dump($sessionsCategories['categories']);
    $countCourses = $sessionsCategories['total'];
    $countHistory = $plugin->getSessionsByCategoryCount($userId, true);
    $total = $countCourses + $countHistory;
    $imgSection = $plugin->get_svg_icon('girl',$plugin->get_lang('CurrentCourses'), 500);
    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $plugin->assign('categories', $sessionsCategories['categories']);
    $plugin->assign('img_section', $imgSection);
    $plugin->assign('total', $countHistory);
    $plugin->setTitle($plugin->get_lang('MyTrainings'));
    if($total > 0){
        $plugin->assign('total_courses', $countCourses);
        $plugin->assign('total_history', $countHistory);
        $content = $plugin->fetch('school_dashboard.tpl');
    } else {
        $content = $plugin->fetch('school_none.tpl');
    }
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
