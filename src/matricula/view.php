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

// Accept ?ficha_id= ; also handle legacy ?id=MATRICULA_ID links
$fichaId = isset($_GET['ficha_id']) ? (int) $_GET['ficha_id'] : 0;
if (!$fichaId && isset($_GET['id']) && (int) $_GET['id'] > 0) {
    $mat = MatriculaManager::getMatriculaById((int) $_GET['id']);
    if ($mat) {
        $fichaId = (int) $mat['ficha_id'];
    }
}
if (!$fichaId) {
    header('Location: ' . api_get_path(WEB_PATH) . 'matricula');
    exit;
}

$fichaCompleta = MatriculaManager::getFichaCompleta($fichaId);
if (!$fichaCompleta) {
    header('Location: ' . api_get_path(WEB_PATH) . 'matricula');
    exit;
}

$plugin->setCurrentSection('matricula');
$plugin->setSidebar('matricula');

// Historial de matrículas (all annual enrollments for this ficha)
$historial = MatriculaManager::getMatriculasByFichaId($fichaId);
$lastMat   = $historial[0] ?? [];

// Merge ficha + last enrollment so the template can use matricula.apellido_paterno etc.
$matricula = array_merge($fichaCompleta, $lastMat);

$madre     = $fichaCompleta['padres']['MADRE'] ?? [];
$padre     = $fichaCompleta['padres']['PADRE'] ?? [];
$contactos = $fichaCompleta['contactos'] ?? [];
$info      = $fichaCompleta['info'] ?? [];

// Compute age
$edad = '';
if (!empty($matricula['fecha_nacimiento'])) {
    $dob  = new DateTime($matricula['fecha_nacimiento']);
    $now  = new DateTime();
    $diff = $now->diff($dob);
    $edad = $diff->y . ' años, ' . $diff->m . ' meses';
}

// Resolve ubigeo codes to names
$ubigeoBase = __DIR__ . '/../../ajax/ubigeo/';
if (!empty($matricula['region'])) {
    $regions = json_decode(file_get_contents($ubigeoBase . 'ubigeo_peru_2016_region.json'), true) ?: [];
    foreach ($regions as $r) {
        if ($r['id'] === $matricula['region']) {
            $matricula['region_name'] = $r['name'];
            break;
        }
    }
}
if (!empty($matricula['provincia'])) {
    $provincias = json_decode(file_get_contents($ubigeoBase . 'ubigeo_peru_2016_provincias.json'), true) ?: [];
    foreach ($provincias as $p) {
        if ($p['id'] === $matricula['provincia']) {
            $matricula['provincia_name'] = $p['name'];
            break;
        }
    }
}
if (!empty($matricula['distrito'])) {
    $distritos = json_decode(file_get_contents($ubigeoBase . 'ubigeo_peru_2016_distritos.json'), true) ?: [];
    foreach ($distritos as $d) {
        if ($d['id'] === $matricula['distrito']) {
            $matricula['distrito_name'] = $d['name'];
            break;
        }
    }
}

$fotoUrl = '';
if (!empty($matricula['foto'])) {
    $fotoUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/uploads/matricula/' . $matricula['foto'];
}

// Linked user name
$linkedUserName = '';
if (!empty($matricula['user_id'])) {
    $linkedUser = api_get_user_info($matricula['user_id']);
    if ($linkedUser) {
        $linkedUserName = $linkedUser['lastname'] . ' ' . $linkedUser['firstname'] . ' (' . $linkedUser['username'] . ')';
    }
}

// Levels & grades for the "Asignar Matrícula" modal
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

$allYears   = MatriculaManager::getAllYears();
$activeYear = MatriculaManager::getActiveYear();

$plugin->assign('matricula', $matricula);
$plugin->assign('ficha_id', $fichaId);
$plugin->assign('madre', $madre);
$plugin->assign('padre', $padre);
$plugin->assign('contactos', $contactos);
$plugin->assign('info', $info);
$plugin->assign('historial', $historial);
$plugin->assign('edad', $edad);
$plugin->assign('foto_url', $fotoUrl);
$plugin->assign('linked_user_name', $linkedUserName);
$plugin->assign('levels', array_values($levels));
$plugin->assign('all_years', $allYears);
$plugin->assign('active_year_id', $activeYear['id'] ?? 0);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_matricula.php');
$plugin->assign('is_admin', $isAdmin);
$plugin->assign('is_secretary', $isSecretary);

$plugin->setTitle($plugin->get_lang('EnrollmentView'));
$content = $plugin->fetch('matricula/view.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
