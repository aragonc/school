<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('attendance');
$plugin->setSidebar('attendance');
api_block_anonymous_users();

$isAdmin = api_is_platform_admin();
if (!$isAdmin) {
    api_not_allowed(true);
}

$schedules = $plugin->getSchedules();

$plugin->assign('is_admin', $isAdmin);
$plugin->assign('active_tab', 'schedules');
$plugin->assign('schedules', $schedules);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_attendance.php');

$plugin->setTitle($plugin->get_lang('AttendanceControl'));

$content = $plugin->fetch('attendance/schedules.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
