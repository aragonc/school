<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('payments');
$plugin->setSidebar('payments');

$userId = api_get_user_id();
$periodId = isset($_GET['period_id']) ? (int) $_GET['period_id'] : 0;

$periods = $plugin->getPaymentPeriods(true);

// If no period selected, use the first active one
if (!$periodId && !empty($periods)) {
    $periodId = (int) $periods[0]['id'];
}

$paymentData = $periodId ? $plugin->getStudentPayments($periodId, $userId) : [];

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

$plugin->assign('periods', $periods);
$plugin->assign('period_id', $periodId);
$plugin->assign('payment_data', $paymentData);
$plugin->assign('month_names', $monthNames);

$plugin->setTitle($plugin->get_lang('MyPayments'));

$content = $plugin->fetch('payments/my.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
