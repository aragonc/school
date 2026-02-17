<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$paymentId = isset($_GET['id']) ? (int) $_GET['id'] : 0;
if (!$paymentId) {
    header('Location: /payments');
    exit;
}

$payment = $plugin->getPaymentById($paymentId);
if (!$payment) {
    header('Location: /payments');
    exit;
}

// Access control: admin/secretary can see all, students only their own
$userId = api_get_user_id();
$isAdmin = api_is_platform_admin();
$userInfo = api_get_user_info();
$isSecretary = $userInfo && $userInfo['status'] == SCHOOL_SECRETARY;

if (!$isAdmin && !$isSecretary && (int) $payment['user_id'] !== $userId) {
    api_not_allowed(true);
}

$plugin->show_sidebar = false;
$plugin->show_header = false;

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

$paymentMethodLabels = [
    'cash' => $plugin->get_lang('Cash'),
    'transfer' => $plugin->get_lang('Transfer'),
    'yape' => 'Yape',
    'plin' => 'Plin',
];

$conceptLabel = $payment['type'] === 'enrollment'
    ? $plugin->get_lang('Enrollment')
    : $plugin->get_lang('Monthly') . ' - ' . ($monthNames[(int) $payment['month']] ?? '');

$statusLabel = $payment['status'] === 'paid'
    ? $plugin->get_lang('Paid')
    : ($payment['status'] === 'partial' ? $plugin->get_lang('Partial') : $plugin->get_lang('Pending'));

$logo = $plugin->getCustomLogo();

$plugin->assign('payment', $payment);
$plugin->assign('concept_label', $conceptLabel);
$plugin->assign('status_label', $statusLabel);
$plugin->assign('method_label', $paymentMethodLabels[$payment['payment_method']] ?? $payment['payment_method']);
$plugin->assign('logo', $logo);

$content = $plugin->fetch('payments/receipt.tpl');
echo $content;
