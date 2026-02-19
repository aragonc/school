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

$matriculaId = isset($_GET['id']) ? (int) $_GET['id'] : 0;
if (!$matriculaId) {
    header('Location: ' . api_get_path(WEB_PATH) . 'matricula');
    exit;
}

$matricula = MatriculaManager::getMatriculaCompleta($matriculaId);
if (!$matricula) {
    header('Location: ' . api_get_path(WEB_PATH) . 'matricula');
    exit;
}

$plugin->setCurrentSection('matricula');
$plugin->setSidebar('matricula');

$madre   = $matricula['padres']['MADRE'] ?? [];
$padre   = $matricula['padres']['PADRE'] ?? [];
$contactos = $matricula['contactos'];
$info    = $matricula['info'];

// Compute age from fecha_nacimiento
$edad = '';
if (!empty($matricula['fecha_nacimiento'])) {
    $dob = new DateTime($matricula['fecha_nacimiento']);
    $now = new DateTime();
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

$plugin->assign('matricula', $matricula);
$plugin->assign('madre', $madre);
$plugin->assign('padre', $padre);
$plugin->assign('contactos', $contactos);
$plugin->assign('info', $info);
$plugin->assign('edad', $edad);
$plugin->assign('is_admin', $isAdmin);
$plugin->assign('is_secretary', $isSecretary);

$plugin->setTitle($plugin->get_lang('EnrollmentView'));
$content = $plugin->fetch('matricula/view.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
