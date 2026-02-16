<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$token = isset($_GET['token']) ? trim($_GET['token']) : '';

if (empty($token)) {
    api_not_allowed(true);
}

// If user is not logged in, save scan URL and redirect to login
if (!api_get_user_id()) {
    $_SESSION['school_plugin_redirect'] = api_get_path(WEB_PATH) . 'attendance/scan?token=' . urlencode($token);
    $loginUrl = api_get_path(WEB_PATH) . 'index.php';
    header('Location: ' . $loginUrl);
    exit;
}

api_block_anonymous_users();

$plugin->setCurrentSection('attendance');
$plugin->setSidebar('attendance');

$userId = api_get_user_id();

// Validate token
$qrToken = $plugin->validateQRToken($token);

if (!$qrToken) {
    Display::addFlash(
        Display::return_message($plugin->get_lang('InvalidQRToken'), 'error')
    );
    header('Location: ' . api_get_path(WEB_PATH) . 'attendance');
    exit;
}

// Mark attendance via QR
$result = $plugin->markAttendance($userId, 'qr');

if ($result['success']) {
    $statusLabel = $plugin->get_lang(ucfirst(str_replace('_', '', $result['status'] === 'on_time' ? 'OnTime' : ($result['status'] === 'late' ? 'Late' : 'Absent'))));
    Display::addFlash(
        Display::return_message(
            $plugin->get_lang('AttendanceRegistered') . ' - ' . $statusLabel,
            $result['status'] === 'on_time' ? 'success' : 'warning'
        )
    );
} else {
    $messageType = $result['message'] === 'AttendanceAlreadyRegistered' ? 'warning' : 'error';
    Display::addFlash(
        Display::return_message($plugin->get_lang($result['message']), $messageType)
    );
}

header('Location: ' . api_get_path(WEB_PATH) . 'attendance?tab=my');
exit;
