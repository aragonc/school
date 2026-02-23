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

$userTable      = Database::get_main_table(TABLE_MAIN_USER);
$fichaTable     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
$matriculaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);

$search = trim($_GET['search'] ?? '');
$searchCond = '';
if ($search !== '') {
    $s = Database::escape_string($search);
    $searchCond = "AND (u.firstname LIKE '%$s%' OR u.lastname LIKE '%$s%' OR u.username LIKE '%$s%' OR u.email LIKE '%$s%')";
}

$sql = "SELECT u.user_id, u.firstname, u.lastname, u.username, u.email,
               u.active, u.picture_uri, u.registration_date,
               f.id AS ficha_id,
               (SELECT m.id FROM $matriculaTable m WHERE m.ficha_id = f.id ORDER BY m.id DESC LIMIT 1) AS matricula_id
        FROM $userTable u
        LEFT JOIN $fichaTable f ON f.user_id = u.user_id
        WHERE u.status = " . STUDENT . "
          $searchCond
        ORDER BY u.lastname, u.firstname";

$result = Database::query($sql);
$students = [];
while ($row = Database::fetch_array($result, 'ASSOC')) {
    $uInfo = api_get_user_info($row['user_id']);
    $row['avatar'] = $uInfo['avatar_small'] ?? '';
    $students[] = $row;
}

// Institution logo for ID card
$customLogo = $plugin->getCustomLogo();
if (!$customLogo) {
    $theme   = api_get_visual_theme();
    $themeDir = Template::getThemeDir($theme);
    $customLogo = api_get_path(WEB_CSS_PATH) . $themeDir . 'images/header-logo-vector.svg';
}
$institutionName = api_get_setting('Institution');

$plugin->assign('students', $students);
$plugin->assign('search', $search);
$plugin->assign('view_url', api_get_path(WEB_PATH) . 'matricula/ver');
$plugin->assign('form_url', api_get_path(WEB_PATH) . 'matricula/nueva');
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_matricula.php');
$plugin->assign('logo_url', $customLogo);
$plugin->assign('institution_name', $institutionName);
$plugin->assign('qrcode_js', api_get_path(WEB_PLUGIN_PATH) . 'school/js/qrcode.min.js');

$plugin->setTitle('Alumnos');
$content = $plugin->fetch('matricula/alumnos.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
