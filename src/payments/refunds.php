<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$isAdmin     = api_is_platform_admin();
$userInfo    = api_get_user_info();
$isSecretary = $userInfo && $userInfo['status'] == SCHOOL_SECRETARY;

if (!$isAdmin && !$isSecretary) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('payments');
$plugin->setSidebar('payments');

$statusFilter = isset($_GET['status']) && in_array($_GET['status'], ['pending', 'processed']) ? $_GET['status'] : null;
$refunds      = $plugin->getRefunds($statusFilter);

$plugin->assign('refunds',       $refunds);
$plugin->assign('status_filter', $statusFilter ?? '');
$plugin->assign('is_admin',      $isAdmin);
$plugin->assign('active_tab',    'refunds');
$plugin->assign('ajax_url',      api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_payments.php');

$plugin->setTitle('Devoluciones de Cuota de Ingreso');

$content = $plugin->fetch('payments/refunds.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
