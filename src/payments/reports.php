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

$plugin->setCurrentSection('payments');
$plugin->setSidebar('payments');

$periodId = isset($_GET['period_id']) ? (int) $_GET['period_id'] : 0;
$month = isset($_GET['month']) && $_GET['month'] !== '' ? (int) $_GET['month'] : null;
$filter = isset($_GET['filter']) ? $_GET['filter'] : 'all';

$periods = $plugin->getPaymentPeriods();

// If no period selected, use the first active one
if (!$periodId && !empty($periods)) {
    foreach ($periods as $p) {
        if ($p['active']) {
            $periodId = (int) $p['id'];
            break;
        }
    }
    if (!$periodId) {
        $periodId = (int) $periods[0]['id'];
    }
}

$report = $periodId ? $plugin->getPaymentReport($periodId, $month) : [];

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

$plugin->assign('periods', $periods);
$plugin->assign('period_id', $periodId);
$plugin->assign('selected_month', $month);
$plugin->assign('filter', $filter);
$plugin->assign('report', $report);
$plugin->assign('month_names', $monthNames);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_payments.php');

$plugin->setTitle($plugin->get_lang('PaymentReports'));

$content = $plugin->fetch('payments/reports.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
