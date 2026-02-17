<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$isAdmin = api_is_platform_admin();
$userInfo = api_get_user_info();
$isSecretary = $userInfo && $userInfo['status'] == SCHOOL_SECRETARY;

if (!$isAdmin && !$isSecretary) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('payments');
$plugin->setSidebar('payments');

$periodId = isset($_GET['period_id']) ? (int) $_GET['period_id'] : 0;
$studentId = isset($_GET['user_id']) ? (int) $_GET['user_id'] : 0;

if (!$periodId || !$studentId) {
    header('Location: /payments');
    exit;
}

$studentInfo = api_get_user_info($studentId);
if (!$studentInfo) {
    header('Location: /payments');
    exit;
}

$paymentData = $plugin->getStudentPayments($periodId, $studentId);
if (empty($paymentData)) {
    header('Location: /payments');
    exit;
}

$monthNames = [
    1 => $plugin->get_lang('January'),
    2 => $plugin->get_lang('February'),
    3 => $plugin->get_lang('March'),
    4 => $plugin->get_lang('April'),
    5 => $plugin->get_lang('May'),
    6 => $plugin->get_lang('June'),
    7 => $plugin->get_lang('July'),
    8 => $plugin->get_lang('August'),
    9 => $plugin->get_lang('September'),
    10 => $plugin->get_lang('October'),
    11 => $plugin->get_lang('November'),
    12 => $plugin->get_lang('December'),
];

$plugin->assign('period', $paymentData['period']);
$plugin->assign('period_id', $periodId);
$plugin->assign('student', $studentInfo);
$plugin->assign('student_id', $studentId);
$plugin->assign('payment_data', $paymentData);
$plugin->assign('month_names', $monthNames);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_payments.php');

$plugin->setTitle($plugin->get_lang('RegisterPayment') . ' - ' . $studentInfo['complete_name']);

$content = $plugin->fetch('payments/register.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
