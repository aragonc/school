<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$plugin->setSidebar('notifications');
api_block_anonymous_users();

if ($enable) {
    $userId = api_get_user_id();
    $messages = $plugin->getMessages();
    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $plugin->setTitle($plugin->get_lang('MyNotifications'));
    $plugin->assign('messages', $messages);
    $content = $plugin->fetch('school_notifications.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}
