<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$certificateId = $_GET['id'] ?? 0;
$plugin->setSidebar('shopping');

api_block_anonymous_users();

if ($enable) {
    $userId = api_get_user_id();
    $plugin->setTitle($plugin->get_lang('BuyCourses'));
    $content = $plugin->fetch('school_shopping.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
