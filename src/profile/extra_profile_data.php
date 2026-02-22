<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../MatriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setSidebar('dashboard');
api_block_anonymous_users();

$userId = api_get_user_id();

// Look up the matricula linked to this user
$matricula = MatriculaManager::getMatriculaByUserId($userId);

$madre     = [];
$padre     = [];
$contactos = [];
$info      = [];
$edad      = '';
$fotoUrl   = '';

if ($matricula) {
    $full      = MatriculaManager::getMatriculaCompleta($matricula['id']);
    $matricula = $full;
    $madre     = $full['padres']['MADRE'] ?? [];
    $padre     = $full['padres']['PADRE'] ?? [];
    $contactos = $full['contactos'];
    $info      = $full['info'];

    // Compute age
    if (!empty($matricula['fecha_nacimiento'])) {
        $dob  = new DateTime($matricula['fecha_nacimiento']);
        $diff = (new DateTime())->diff($dob);
        $edad = $diff->y . ' años, ' . $diff->m . ' meses';
    }

    // Resolve ubigeo codes to names
    $ubigeoBase = __DIR__ . '/../../ajax/ubigeo/';
    if (!empty($matricula['region'])) {
        $regions = json_decode(file_get_contents($ubigeoBase . 'ubigeo_peru_2016_region.json'), true) ?: [];
        foreach ($regions as $r) {
            if ($r['id'] === $matricula['region']) { $matricula['region_name'] = $r['name']; break; }
        }
    }
    if (!empty($matricula['provincia'])) {
        $provincias = json_decode(file_get_contents($ubigeoBase . 'ubigeo_peru_2016_provincias.json'), true) ?: [];
        foreach ($provincias as $p) {
            if ($p['id'] === $matricula['provincia']) { $matricula['provincia_name'] = $p['name']; break; }
        }
    }
    if (!empty($matricula['distrito'])) {
        $distritos = json_decode(file_get_contents($ubigeoBase . 'ubigeo_peru_2016_distritos.json'), true) ?: [];
        foreach ($distritos as $d) {
            if ($d['id'] === $matricula['distrito']) { $matricula['distrito_name'] = $d['name']; break; }
        }
    }

    // Photo URL
    if (!empty($matricula['foto'])) {
        $fotoUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/uploads/matricula/' . $matricula['foto'];
    }
}

$plugin->setTitle('Ficha de Matrícula');
$plugin->assign('matricula', $matricula);
$plugin->assign('madre', $madre);
$plugin->assign('padre', $padre);
$plugin->assign('contactos', $contactos);
$plugin->assign('info', $info);
$plugin->assign('edad', $edad);
$plugin->assign('foto_url', $fotoUrl);
$content = $plugin->fetch('profile/extra.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
