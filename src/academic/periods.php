<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../AcademicManager.php';
require_once __DIR__ . '/../MatriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();
$plugin->requireModule('academic');

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

if (!api_is_platform_admin()) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('academic-periods');
$plugin->setSidebar('academic-periods');

// Load all academic years with their periods
$yearTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
$periodTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_PERIOD);

$yearsRes = Database::query("SELECT * FROM $yearTable ORDER BY year DESC");
$academicYears = [];
while ($yr = Database::fetch_array($yearsRes, 'ASSOC')) {
    $yearId = (int) $yr['id'];
    $perRes = Database::query(
        "SELECT * FROM $periodTable WHERE academic_year_id = $yearId ORDER BY order_index ASC, date_start ASC"
    );
    $periods = [];
    while ($pr = Database::fetch_array($perRes, 'ASSOC')) {
        $periods[] = $pr;
    }
    $yr['periods'] = $periods;
    $academicYears[] = $yr;
}

$ajaxUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_academic_periods.php';

$plugin->assign('academic_years', $academicYears);
$plugin->assign('ajax_url', $ajaxUrl);
$plugin->setTitle('Períodos / Bimestres');

$content = $plugin->fetch('academic/periods.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
