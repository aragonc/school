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

$studentId = isset($_GET['user_id']) ? (int) $_GET['user_id'] : 0;
$studentInfo = null;

if ($studentId) {
    $studentInfo = api_get_user_info($studentId);
}

$products = $plugin->getProducts(true);

$plugin->assign('products', $products);
$plugin->assign('student', $studentInfo);
$plugin->assign('student_id', $studentId);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_products.php');

$plugin->setTitle($plugin->get_lang('SellProduct'));

$content = $plugin->fetch('products/sell.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
