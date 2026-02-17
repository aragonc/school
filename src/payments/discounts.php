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

$discounts = $periodId ? $plugin->getDiscounts($periodId) : [];

// Get students for the select dropdown
$userTable = Database::get_main_table(TABLE_MAIN_USER);
$sql = "SELECT user_id, firstname, lastname, username FROM $userTable WHERE status = ".STUDENT." AND active = 1 ORDER BY lastname, firstname";
$result = Database::query($sql);
$studentsList = [];
while ($row = Database::fetch_array($result, 'ASSOC')) {
    $studentsList[] = $row;
}

$plugin->assign('periods', $periods);
$plugin->assign('period_id', $periodId);
$plugin->assign('discounts', $discounts);
$plugin->assign('students_list', $studentsList);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ajax_payments.php');

$plugin->setTitle($plugin->get_lang('Discounts'));

$content = $plugin->fetch('payments/discounts.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
