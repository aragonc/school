<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');

api_block_anonymous_users();

if ($enable) {
    $userId = api_get_user_id();
    $sessionsCategories = $plugin->getSessionsByCategory($userId, true);
    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $plugin->assign('categories', $sessionsCategories);
    $plugin->setTitle($plugin->get_lang('MyTrainings'));
    $content = $plugin->fetch('school_previous.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
