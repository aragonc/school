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
$userInfo = api_get_user_info($userId);
$isTeacher = $userInfo['status'] == COURSEMANAGER;

if (!$isAdmin) {
    header('Location: '.api_get_path(WEB_PATH).'attendance/my');
    exit;
}

$today = date('Y-m-d');

$todayRecords = $plugin->getAttendanceByDate($today);
foreach ($todayRecords as &$record) {
    if (!empty($record['check_in'])) {
        $record['check_in'] = api_get_local_time($record['check_in']);
    }
}
unset($record);

$todayStats = $plugin->getAttendanceStats($today, $today);

$plugin->assign('is_admin', $isAdmin);
$plugin->assign('active_tab', 'today');
$plugin->assign('today', $today);
$plugin->assign('today_records', $todayRecords);
$plugin->assign('today_stats', $todayStats);
$plugin->assign('kiosk_url', api_get_path(WEB_PATH).'attendance/kiosk');

$plugin->setTitle($plugin->get_lang('AttendanceControl'));

$content = $plugin->fetch('attendance/today.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
