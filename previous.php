<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$plugin->setSidebar('dashboard');
api_block_anonymous_users();
if ($enable) {
    $userId = api_get_user_id();
    $sessionsCategories = $plugin->getSessionsByCategory($userId, true);
    $countHistory = $sessionsCategories['total'];
    $countCourses = $plugin->getSessionsByCategoryCount($userId);
    $total = $countCourses + $countHistory;
    $imgSection = $plugin->get_svg_icon('girl',$plugin->get_lang('PreviousCourses'), 500);
    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $plugin->assign('categories', $sessionsCategories['categories']);
    $plugin->assign('img_section', $imgSection);
    $plugin->assign('total', $countHistory);
    $plugin->setTitle($plugin->get_lang('MyTrainings'));
    if($total > 0){
        $plugin->assign('total_courses', $countCourses);
        $plugin->assign('total_history', $countHistory);
        $content = $plugin->fetch('school_previous.tpl');
    } else {
        $content = $plugin->fetch('school_none.tpl');
    }
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
