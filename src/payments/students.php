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
$search = isset($_GET['search']) ? trim($_GET['search']) : '';

if (!$periodId) {
    header('Location: /payments');
    exit;
}

// Get period info
$periods = $plugin->getPaymentPeriods();
$currentPeriod = null;
foreach ($periods as $p) {
    if ((int) $p['id'] === $periodId) {
        $currentPeriod = $p;
        break;
    }
}

if (!$currentPeriod) {
    header('Location: /payments');
    exit;
}

$months = !empty($currentPeriod['months']) ? explode(',', $currentPeriod['months']) : [];
$students = $plugin->getStudentsByPeriod($periodId, $search ?: null);
$summary = $plugin->getPaymentSummary($periodId);

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

$plugin->assign('period', $currentPeriod);
$plugin->assign('period_id', $periodId);
$plugin->assign('months', $months);
$plugin->assign('month_names', $monthNames);
$plugin->assign('students', $students);
$plugin->assign('summary', $summary);
$plugin->assign('search', $search);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_payments.php');

$plugin->setTitle($plugin->get_lang('PaymentControl') . ' - ' . $currentPeriod['name']);

$content = $plugin->fetch('payments/students.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
