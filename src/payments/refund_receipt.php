<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$refundId = isset($_GET['id']) ? (int) $_GET['id'] : 0;
if (!$refundId) {
    header('Location: /payments/refunds');
    exit;
}

$refund = $plugin->getRefundById($refundId);
if (!$refund) {
    header('Location: /payments/refunds');
    exit;
}

// Solo admin/secretario puede imprimir devoluciones
$isAdmin     = api_is_platform_admin();
$userInfo    = api_get_user_info();
$isSecretary = $userInfo && $userInfo['status'] == SCHOOL_SECRETARY;

if (!$isAdmin && !$isSecretary) {
    api_not_allowed(true);
}

$plugin->show_sidebar = false;
$plugin->show_header  = false;

$logo = $plugin->getCustomLogo();

// Número de constancia formateado: DEV-YYYYMMDD-ID
$refundNumber = 'DEV-' . date('Ymd', strtotime($refund['created_at'])) . '-' . str_pad($refund['id'], 4, '0', STR_PAD_LEFT);

// Cálculo de la fórmula para mostrar
$contracted   = (int) $refund['years_contracted'];
$attended     = (int) $refund['years_attended'];
$remaining    = (int) $refund['years_remaining'];
$admissionPaid = (float) $refund['admission_paid'];
$refundAmount  = (float) $refund['refund_amount'];

$plugin->assign('refund',        $refund);
$plugin->assign('refund_number', $refundNumber);
$plugin->assign('logo',          $logo);
$plugin->assign('contracted',    $contracted);
$plugin->assign('attended',      $attended);
$plugin->assign('remaining',     $remaining);
$plugin->assign('admission_paid', $admissionPaid);
$plugin->assign('refund_amount',  $refundAmount);

$content = $plugin->fetch('payments/refund_receipt.tpl');
echo $content;
