<?php
require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
api_protect_admin_script();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setSidebar('admin');

$targetUserId = isset($_GET['user_id']) ? (int) $_GET['user_id'] : 0;
if (!$targetUserId) {
    header('Location: ' . api_get_path(WEB_PATH) . 'admin/usuarios');
    exit;
}

$userInfo = api_get_user_info($targetUserId);
if (!$userInfo) {
    api_not_allowed(true);
}

// POST — save ficha
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $postUserId = (int) ($_POST['user_id'] ?? 0);
    if ($postUserId !== $targetUserId) {
        api_not_allowed(true);
    }
    $plugin->saveExtraProfileData($targetUserId, $_POST);
    Display::addFlash(Display::return_message('Ficha guardada correctamente.', 'success'));
    header('Location: ' . api_get_path(WEB_PATH) . 'admin/ficha?user_id=' . $targetUserId);
    exit;
}

$ficha = $plugin->getExtraProfileData($targetUserId);

$tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

// Load regions for ubigeo
$ubigeoBase = __DIR__ . '/../../ajax/ubigeo/';
$regions = json_decode(file_get_contents($ubigeoBase . 'ubigeo_peru_2016_region.json'), true) ?: [];

$plugin->setTitle('Ficha de Usuario');
$plugin->assign('target_user', $userInfo);
$plugin->assign('ficha', $ficha);
$plugin->assign('tipos_sangre', $tiposSangre);
$plugin->assign('regions', $regions);
$plugin->assign('ubigeo_path', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ubigeo/');
$plugin->assign('select_option_text', '-- Seleccionar --');
$plugin->assign('saved_region', $ficha['region'] ?? '');
$plugin->assign('saved_province', $ficha['province'] ?? '');
$plugin->assign('saved_district', $ficha['district'] ?? '');

$content = $plugin->fetch('admin/ficha_usuario.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
