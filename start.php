<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
//$htmlHeadXtra[] = api_get_css(api_get_path(WEB_PLUGIN_PATH) . 'school/css/style.css');

api_block_anonymous_users();

if ($enable) {
    $userId = api_get_user_id();
    $sessionsCategories = $plugin->getSessionsByCategory($userId);
    $imgSection = $plugin->get_svg_icon('girl',$plugin->get_lang('CurrentCourses'), 500);
    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $plugin->assign('categories', $sessionsCategories);
    $plugin->assign('img_section', $imgSection);
    $plugin->setTitle($plugin->get_lang('MyTrainings'));
    $content = $plugin->fetch('school_dashboard.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
