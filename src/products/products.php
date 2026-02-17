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

$products = $plugin->getProducts();
$categories = $plugin->getProductCategories(true);

$plugin->assign('products', $products);
$plugin->assign('categories', $categories);
$plugin->assign('is_admin', $isAdmin);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_products.php');

$plugin->setTitle($plugin->get_lang('ProductCatalog'));

$content = $plugin->fetch('products/catalog.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
