<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

// Only admin and secretary
$isAdmin = api_is_platform_admin();
$userInfo = api_get_user_info();
$isSecretary = $userInfo && $userInfo['status'] == SCHOOL_SECRETARY;

if (!$isAdmin && !$isSecretary) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('payments');
$plugin->setSidebar('payments');

$periods = $plugin->getPaymentPeriods();

$plugin->assign('periods', $periods);
$plugin->assign('is_admin', $isAdmin);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_payments.php');

$plugin->setTitle($plugin->get_lang('PaymentControl'));

$content = $plugin->fetch('payments/periods.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
