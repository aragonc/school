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

$plugin->setCurrentSection('products');
$plugin->setSidebar('products');

$filters = [];
if (!empty($_GET['product_id'])) {
    $filters['product_id'] = (int) $_GET['product_id'];
}
if (!empty($_GET['date_from'])) {
    $filters['date_from'] = $_GET['date_from'];
}
if (!empty($_GET['date_to'])) {
    $filters['date_to'] = $_GET['date_to'];
}

$sales = $plugin->getProductSales($filters);
$products = $plugin->getProducts();

// Calculate totals
$totalSales = 0;
$totalDiscount = 0;
foreach ($sales as $sale) {
    $totalSales += (float) $sale['total_amount'];
    $totalDiscount += (float) $sale['discount'];
}

$plugin->assign('sales', $sales);
$plugin->assign('products', $products);
$plugin->assign('filters', $filters);
$plugin->assign('total_sales', $totalSales);
$plugin->assign('total_discount', $totalDiscount);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_products.php');

$plugin->setTitle($plugin->get_lang('SalesHistory'));

$content = $plugin->fetch('products/sales.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
