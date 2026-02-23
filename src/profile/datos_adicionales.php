<?php
require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setSidebar('dashboard');
api_block_anonymous_users();

$userId = api_get_user_id();

// Students should use /extra-profile instead
if ((int) api_get_user_status() === STUDENT) {
    header('Location: ' . api_get_path(WEB_PATH) . 'extra-profile');
    exit;
}

// POST — save extra profile data
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $plugin->saveExtraProfileData($userId, $_POST);
    Display::addFlash(Display::return_message('Datos adicionales guardados correctamente.', 'success'));
    header('Location: ' . api_get_path(WEB_PATH) . 'datos-adicionales');
    exit;
}

$ficha = $plugin->getExtraProfileData($userId);

$tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

// Resolve ubigeo codes to names for display
$ubigeoBase = __DIR__ . '/../../ajax/ubigeo/';
$regions = json_decode(file_get_contents($ubigeoBase . 'ubigeo_peru_2016_region.json'), true) ?: [];

$regionName   = '';
$provinceName = '';
$districtName = '';

if (!empty($ficha['region'])) {
    foreach ($regions as $r) {
        if ($r['id'] === $ficha['region']) { $regionName = $r['name']; break; }
    }
}
if (!empty($ficha['province'])) {
    $provincias = json_decode(file_get_contents($ubigeoBase . 'ubigeo_peru_2016_provincias.json'), true) ?: [];
    foreach ($provincias as $p) {
        if ($p['id'] === $ficha['province']) { $provinceName = $p['name']; break; }
    }
}
if (!empty($ficha['district'])) {
    $distritos = json_decode(file_get_contents($ubigeoBase . 'ubigeo_peru_2016_distritos.json'), true) ?: [];
    foreach ($distritos as $d) {
        if ($d['id'] === $ficha['district']) { $districtName = $d['name']; break; }
    }
}

$ficha['region_name']   = $regionName;
$ficha['province_name'] = $provinceName;
$ficha['district_name'] = $districtName;

$plugin->setTitle('Datos Adicionales');
$plugin->assign('is_student', false);
$plugin->assign('ficha', $ficha);
$plugin->assign('tipos_sangre', $tiposSangre);
$plugin->assign('regions', $regions);
$plugin->assign('ubigeo_path', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ubigeo/');
$plugin->assign('select_option_text', '-- Seleccionar --');
$plugin->assign('saved_region', $ficha['region'] ?? '');
$plugin->assign('saved_province', $ficha['province'] ?? '');
$plugin->assign('saved_district', $ficha['district'] ?? '');

$content = $plugin->fetch('profile/datos_adicionales.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
