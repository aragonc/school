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

$matriculaId = isset($_GET['id']) ? (int) $_GET['id'] : 0;
$matricula   = null;
$madre       = [];
$padre       = [];
$contactos   = [];
$info        = [];

if ($matriculaId > 0) {
    $full = MatriculaManager::getMatriculaCompleta($matriculaId);
    if (!$full) {
        header('Location: ' . api_get_path(WEB_PATH) . 'matricula');
        exit;
    }
    $matricula = $full;
    $madre     = $full['padres']['MADRE'] ?? [];
    $padre     = $full['padres']['PADRE'] ?? [];
    $contactos = $full['contactos'];
    $info      = $full['info'];
}

// POST handling
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $postId = isset($_POST['matricula_id']) ? (int) $_POST['matricula_id'] : 0;

    // Save main record
    $savedId = MatriculaManager::saveMatricula(array_merge($_POST, ['id' => $postId]));

    // Save madre
    if (!empty($_POST['madre'])) {
        MatriculaManager::savePadre($savedId, 'MADRE', $_POST['madre']);
    }

    // Save padre
    if (!empty($_POST['padre'])) {
        MatriculaManager::savePadre($savedId, 'PADRE', $_POST['padre']);
    }

    // Save contacto (single for simplicity)
    if (!empty($_POST['contacto'])) {
        $contactoData = $_POST['contacto'];
        $contactoData['id'] = isset($_POST['contacto_id']) ? (int) $_POST['contacto_id'] : 0;
        MatriculaManager::saveContacto($savedId, $contactoData);
    }

    // Save info adicional
    if (isset($_POST['info'])) {
        MatriculaManager::saveInfo($savedId, $_POST['info']);
    }

    Display::addFlash(Display::return_message($plugin->get_lang('EnrollmentSaved'), 'success'));
    header('Location: ' . api_get_path(WEB_PATH) . 'matricula/ver?id=' . $savedId);
    exit;
}

// Levels & grades for dropdown
$levelTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
$gradeTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
$levels = [];
$res = Database::query("SELECT * FROM $levelTable WHERE active = 1 ORDER BY order_index, name");
while ($row = Database::fetch_array($res, 'ASSOC')) {
    $row['grades'] = [];
    $levels[$row['id']] = $row;
}
$res2 = Database::query("SELECT * FROM $gradeTable WHERE active = 1 ORDER BY order_index, name");
$allGrades = [];
while ($row = Database::fetch_array($res2, 'ASSOC')) {
    $allGrades[] = $row;
    if (isset($levels[$row['level_id']])) {
        $levels[$row['level_id']]['grades'][] = $row;
    }
}

$tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

// Academic years
$activeYear = MatriculaManager::getActiveYear();
$allYears   = MatriculaManager::getAllYears();

// Load regions for ubigeo
$regionsJson = file_get_contents(__DIR__ . '/../../ajax/ubigeo/ubigeo_peru_2016_region.json');
$regions = json_decode($regionsJson, true) ?: [];

$plugin->assign('matricula', $matricula);
$plugin->assign('madre', $madre);
$plugin->assign('padre', $padre);
$plugin->assign('contactos', $contactos);
$plugin->assign('info', $info);
$plugin->assign('levels', array_values($levels));
$plugin->assign('all_grades', $allGrades);
$plugin->assign('tipos_sangre', $tiposSangre);
$plugin->assign('matricula_id', $matriculaId);
$plugin->assign('regions', $regions);
$plugin->assign('ubigeo_path', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ubigeo/');
$plugin->assign('select_option_text', '-- ' . $plugin->get_lang('SelectOption') . ' --');
$plugin->assign('saved_region', $matricula['region'] ?? '');
$plugin->assign('saved_province', $matricula['provincia'] ?? '');
$plugin->assign('saved_district', $matricula['distrito'] ?? '');
$plugin->assign('all_years', $allYears);
$plugin->assign('active_year', $activeYear);
$plugin->assign('default_year_id', $matricula['academic_year_id'] ?? ($activeYear['id'] ?? 0));

$title = $matriculaId > 0 ? $plugin->get_lang('EditEnrollment') : $plugin->get_lang('NewEnrollment');
$plugin->setTitle($title);
$content = $plugin->fetch('matricula/form.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
