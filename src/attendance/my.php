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

$userId = api_get_user_id();
$isAdmin = api_is_platform_admin();

$today = date('Y-m-d');
$startDate30 = date('Y-m-d', strtotime('-30 days'));
$myAttendance = $plugin->getAttendanceByUser($userId, $startDate30, $today);
foreach ($myAttendance as &$record) {
    if (!empty($record['check_in'])) {
        $record['check_in'] = api_get_local_time($record['check_in']);
    }
}
unset($record);

$plugin->assign('is_admin', $isAdmin);
$plugin->assign('active_tab', 'my');
$plugin->assign('my_attendance', $myAttendance);

$plugin->setTitle($plugin->get_lang('AttendanceControl'));

$content = $plugin->fetch('attendance/my.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
