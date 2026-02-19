<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../MatriculaManager.php';

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

$plugin->setCurrentSection('matricula');
$plugin->setSidebar('matricula');

// Academic year
$activeYear = MatriculaManager::getActiveYear();
$allYears   = MatriculaManager::getAllYears();
$yearId     = isset($_GET['academic_year_id']) && (int) $_GET['academic_year_id']
    ? (int) $_GET['academic_year_id']
    : ($activeYear ? (int) $activeYear['id'] : 0);

// Filters
$filters = [
    'academic_year_id' => $yearId,
    'tipo_ingreso'     => $_GET['tipo_ingreso'] ?? '',
    'estado'           => $_GET['estado'] ?? '',
    'grade_id'         => isset($_GET['grade_id']) ? (int) $_GET['grade_id'] : 0,
    'search'           => trim($_GET['search'] ?? ''),
];

$matriculas = MatriculaManager::getMatriculas(array_filter($filters, fn($v) => $v !== '' && $v !== 0));
$counts     = MatriculaManager::countByTipoIngreso($yearId ?: null);

// Levels & grades for filter dropdown
$levelTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
$gradeTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
$levels = [];
$res = Database::query("SELECT * FROM $levelTable WHERE active = 1 ORDER BY order_index, name");
while ($row = Database::fetch_array($res, 'ASSOC')) {
    $row['grades'] = [];
    $levels[$row['id']] = $row;
}
$res2 = Database::query("SELECT * FROM $gradeTable WHERE active = 1 ORDER BY order_index, name");
while ($row = Database::fetch_array($res2, 'ASSOC')) {
    if (isset($levels[$row['level_id']])) {
        $levels[$row['level_id']]['grades'][] = $row;
    }
}

$plugin->assign('matriculas', $matriculas);
$plugin->assign('counts', $counts);
$plugin->assign('filters', $filters);
$plugin->assign('levels', array_values($levels));
$plugin->assign('all_years', $allYears);
$plugin->assign('active_year', $activeYear);
$plugin->assign('selected_year_id', $yearId);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_matricula.php');

$plugin->setTitle($plugin->get_lang('EnrollmentList'));
$content = $plugin->fetch('matricula/list.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
