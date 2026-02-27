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

$year = isset($_GET['year']) ? (int) $_GET['year'] : (int) date('Y');

$nonWorkingDays = $plugin->getNonWorkingDays($year);

$plugin->assign('is_admin', $isAdmin);
$plugin->assign('active_tab', 'calendar');
$plugin->assign('non_working_days', $nonWorkingDays);
$plugin->assign('current_year', $year);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_calendar.php');
$plugin->assign('cron_path', api_get_path(SYS_PATH).'plugin/school/cron/cron_attendance.php');

$plugin->setTitle($plugin->get_lang('AttendanceCalendar'));

$content = $plugin->fetch('attendance/calendar.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
