<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$saleId = isset($_GET['id']) ? (int) $_GET['id'] : 0;
if (!$saleId) {
    header('Location: /products');
    exit;
}

$sale = $plugin->getProductSaleById($saleId);
if (!$sale) {
    header('Location: /products');
    exit;
}

$userId = api_get_user_id();
$isAdmin = api_is_platform_admin();
$userInfo = api_get_user_info();
$isSecretary = $userInfo && $userInfo['status'] == SCHOOL_SECRETARY;

if (!$isAdmin && !$isSecretary && (int) $sale['user_id'] !== $userId) {
    api_not_allowed(true);
}

$plugin->show_sidebar = false;
$plugin->show_header = false;

$paymentMethodLabels = [
    'cash' => $plugin->get_lang('Cash'),
    'transfer' => $plugin->get_lang('Transfer'),
    'yape' => 'Yape',
    'plin' => 'Plin',
];

$logo = $plugin->getCustomLogo();

$plugin->assign('sale', $sale);
$plugin->assign('method_label', $paymentMethodLabels[$sale['payment_method']] ?? $sale['payment_method']);
$plugin->assign('logo', $logo);

$content = $plugin->fetch('products/receipt.tpl');
echo $content;
