<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

date_default_timezone_set(api_get_timezone());
$serverTime = date('Y-m-d H:i:s');

$plugin->assign('server_time', $serverTime);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_attendance.php');
$plugin->assign('web_path', api_get_path(WEB_PATH));

// Logo
$customLogo = $plugin->getCustomLogo();
$plugin->assign('kiosk_logo', $customLogo ?? '');
$plugin->assign('institution_name', api_get_setting('Institution'));
$plugin->assign('site_name', api_get_setting('siteName'));

// FontAwesome path
$plugin->assign('fa_css', api_get_path(WEB_PATH).'web/assets/fontawesome-free/css/all.min.css');

echo $plugin->fetch('attendance/kiosk.tpl');
