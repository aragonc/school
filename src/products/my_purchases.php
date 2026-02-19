<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$_userInfo = api_get_user_info();
$_isAdmin = api_is_platform_admin();
$_isSecretary = $_userInfo && $_userInfo['status'] == SCHOOL_SECRETARY;
$_isStudent = $_userInfo && (int) $_userInfo['status'] === STUDENT;
if (!$_isAdmin && !$_isSecretary && !$_isStudent) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('products');
$plugin->setSidebar('products');

$userId = api_get_user_id();
$sales = $plugin->getMyProductSales($userId);

$totalSpent = 0;
foreach ($sales as $sale) {
    $totalSpent += (float) $sale['total_amount'];
}

$plugin->assign('sales', $sales);
$plugin->assign('total_spent', $totalSpent);

$plugin->setTitle($plugin->get_lang('MyPurchases'));

$content = $plugin->fetch('products/my_purchases.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
