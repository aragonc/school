<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../AcademicManager.php';

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

$plugin->setCurrentSection('payments');
$plugin->setSidebar('payments');

$periodId = isset($_GET['period_id']) ? (int) $_GET['period_id'] : 0;
$periods = $plugin->getPaymentPeriods();

if (!$periodId && !empty($periods)) {
    $periodId = (int) $periods[0]['id'];
}

$currentPeriod = null;
foreach ($periods as $p) {
    if ((int) $p['id'] === $periodId) {
        $currentPeriod = $p;
        break;
    }
}

$levels = AcademicManager::getLevels(true);
$grades = AcademicManager::getGrades(null, true);
$prices = $periodId ? AcademicManager::getPeriodPriceList($periodId) : [];

$plugin->assign('periods', $periods);
$plugin->assign('period_id', $periodId);
$plugin->assign('current_period', $currentPeriod);
$plugin->assign('levels', $levels);
$plugin->assign('grades', $grades);
$plugin->assign('prices', $prices);
$plugin->assign('is_admin', $isAdmin);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_academic.php');

$plugin->setTitle($plugin->get_lang('Pricing'));

$content = $plugin->fetch('payments/pricing.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
