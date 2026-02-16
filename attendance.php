<?php

require_once __DIR__.'/config.php';

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

$today = date('Y-m-d');
$activeTab = isset($_GET['tab']) ? $_GET['tab'] : 'today';

// Data for today's attendance tab
$todayRecords = $plugin->getAttendanceByDate($today);
// Convert UTC times to local
foreach ($todayRecords as &$record) {
    if (!empty($record['check_in'])) {
        $record['check_in'] = api_get_local_time($record['check_in']);
    }
}
unset($record);

$users = $plugin->getUsersForAttendance();
// Convert UTC times to local for users with attendance
foreach ($users as &$user) {
    if (!empty($user['check_in'])) {
        $user['check_in'] = api_get_local_time($user['check_in']);
    }
}
unset($user);

$schedules = $plugin->getSchedules();

// Stats for today
$todayStats = $plugin->getAttendanceStats($today, $today);

// My attendance (last 30 days for personal view)
$startDate30 = date('Y-m-d', strtotime('-30 days'));
$myAttendance = $plugin->getAttendanceByUser($userId, $startDate30, $today);
// Convert UTC times to local for my attendance
foreach ($myAttendance as &$record) {
    if (!empty($record['check_in'])) {
        $record['check_in'] = api_get_local_time($record['check_in']);
    }
}
unset($record);

// Report filters
$reportStartDate = isset($_GET['start_date']) ? $_GET['start_date'] : date('Y-m-01');
$reportEndDate = isset($_GET['end_date']) ? $_GET['end_date'] : $today;
$reportUserType = isset($_GET['user_type']) ? $_GET['user_type'] : null;

$reportRecords = [];
$reportStats = [];
if ($isAdmin && $activeTab === 'reports') {
    $reportRecords = $plugin->getAttendanceByDate($reportStartDate);
    $reportStats = $plugin->getAttendanceStats($reportStartDate, $reportEndDate, $reportUserType);
}

$plugin->assign('is_admin', $isAdmin);
$plugin->assign('is_teacher', $isTeacher);
$plugin->assign('active_tab', $activeTab);
$plugin->assign('today', $today);
$plugin->assign('today_records', $todayRecords);
$plugin->assign('today_stats', $todayStats);
$plugin->assign('users', $users);
$plugin->assign('schedules', $schedules);
$plugin->assign('my_attendance', $myAttendance);
$plugin->assign('report_start_date', $reportStartDate);
$plugin->assign('report_end_date', $reportEndDate);
$plugin->assign('report_user_type', $reportUserType);
$plugin->assign('report_stats', $reportStats);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_attendance.php');

$plugin->setTitle($plugin->get_lang('AttendanceControl'));

$content = $plugin->fetch('school_attendance.tpl');

$plugin->assign('content', $content);
$plugin->display_blank_template();
