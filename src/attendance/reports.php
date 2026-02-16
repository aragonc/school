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

$today = date('Y-m-d');
$reportStartDate = isset($_GET['start_date']) ? $_GET['start_date'] : date('Y-m-01');
$reportEndDate = isset($_GET['end_date']) ? $_GET['end_date'] : $today;
$reportUserType = isset($_GET['user_type']) ? $_GET['user_type'] : null;

$reportStats = $plugin->getAttendanceStats($reportStartDate, $reportEndDate, $reportUserType);

$plugin->assign('is_admin', $isAdmin);
$plugin->assign('active_tab', 'reports');
$plugin->assign('report_start_date', $reportStartDate);
$plugin->assign('report_end_date', $reportEndDate);
$plugin->assign('report_user_type', $reportUserType);
$plugin->assign('report_stats', $reportStats);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_attendance.php');

$plugin->setTitle($plugin->get_lang('AttendanceControl'));

$content = $plugin->fetch('attendance/reports.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
