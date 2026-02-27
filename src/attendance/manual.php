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

$users = $plugin->getUsersForAttendance('staff');
foreach ($users as &$user) {
    if (!empty($user['check_in'])) {
        $user['check_in'] = api_get_local_time($user['check_in']);
    }
}
unset($user);

$plugin->assign('is_admin', $isAdmin);
$plugin->assign('active_tab', 'manual');
$plugin->assign('users', $users);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_attendance.php');

$plugin->setTitle($plugin->get_lang('AttendanceControl'));

$content = $plugin->fetch('attendance/manual.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
