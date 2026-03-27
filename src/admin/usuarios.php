<?php
require_once __DIR__ . '/../../config.php';
$plugin = SchoolPlugin::create();
api_protect_admin_script();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setSidebar('admin');
$plugin->setTitle('Usuarios');

$userTable  = Database::get_main_table(TABLE_MAIN_USER);
$adminTable = Database::get_main_table(TABLE_MAIN_ADMIN);

$search = trim($_GET['search'] ?? '');
$searchCond = '';
if ($search !== '') {
    $s = Database::escape_string($search);
    $searchCond = "AND (u.firstname LIKE '%$s%' OR u.lastname LIKE '%$s%' OR u.username LIKE '%$s%' OR u.email LIKE '%$s%')";
}

$nonStudentStatuses = implode(',', [COURSEMANAGER, DRH, SCHOOL_SECRETARY, SCHOOL_AUXILIARY, SCHOOL_PARENT, SCHOOL_GUARDIAN]);

$sql = "SELECT u.user_id, u.firstname, u.lastname, u.username, u.email,
               u.active, u.picture_uri, u.status,
               CASE
                   WHEN adm.user_id IS NOT NULL THEN 'Administrador'
                   WHEN u.status = ".COURSEMANAGER." THEN 'Docente'
                   WHEN u.status = ".DRH."           THEN 'Administrativo'
                   WHEN u.status = ".SCHOOL_SECRETARY." THEN 'Secretaria'
                   WHEN u.status = ".SCHOOL_AUXILIARY." THEN 'Auxiliar'
                   WHEN u.status = ".SCHOOL_PARENT."    THEN 'Padre de familia'
                   WHEN u.status = ".SCHOOL_GUARDIAN."  THEN 'Apoderado'
                   ELSE 'Otro'
               END AS role_label
        FROM $userTable u
        LEFT JOIN $adminTable adm ON adm.user_id = u.user_id
        WHERE (u.status IN ($nonStudentStatuses) OR adm.user_id IS NOT NULL)
          $searchCond
        ORDER BY u.lastname, u.firstname";

$extraTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_EXTRA_PROFILE);

// Migración lazy: agregar columna si no existe
$chk = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$extraTable' AND COLUMN_NAME = 'niveles_docente'");
if (Database::num_rows($chk) === 0) {
    Database::query("ALTER TABLE $extraTable ADD COLUMN niveles_docente VARCHAR(100) NULL");
}

$nivelesLabels = ['inicial' => 'Inicial', 'primaria' => 'Primaria', 'secundaria' => 'Secundaria'];

$result = Database::query($sql);
$users = [];
while ($row = Database::fetch_array($result, 'ASSOC')) {
    $uInfo = api_get_user_info($row['user_id']);
    $row['avatar'] = $uInfo['avatar_small'] ?? '';
    // Check if extra profile (ficha) exists and get niveles_docente
    $uid = (int) $row['user_id'];
    $epRes = Database::query("SELECT id, niveles_docente FROM $extraTable WHERE user_id = $uid LIMIT 1");
    $epRow = Database::fetch_array($epRes, 'ASSOC');
    $row['has_ficha'] = !empty($epRow);
    // Format teacher levels
    $row['niveles_docente'] = '';
    if ((int)$row['status'] === COURSEMANAGER && !empty($epRow['niveles_docente'])) {
        $partes = array_filter(array_map('trim', explode(',', $epRow['niveles_docente'])));
        $row['niveles_docente'] = implode(', ', array_map(fn($v) => $nivelesLabels[$v] ?? ucfirst($v), $partes));
    }
    $users[] = $row;
}

// Institution logo for ID card
$customLogo = $plugin->getCustomLogo();
if (!$customLogo) {
    $theme    = api_get_visual_theme();
    $themeDir = Template::getThemeDir($theme);
    $customLogo = api_get_path(WEB_CSS_PATH) . $themeDir . 'images/header-logo-vector.svg';
}

$plugin->assign('users', $users);
$plugin->assign('ficha_url', api_get_path(WEB_PATH) . 'admin/ficha');
$plugin->assign('search', $search);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_matricula.php');
$plugin->assign('ajax_admin_url', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_admin.php');
$plugin->assign('logo_url', $customLogo);
$plugin->assign('institution_name', api_get_setting('Institution'));
$plugin->assign('qrcode_js', api_get_path(WEB_PLUGIN_PATH) . 'school/js/qrcode.min.js');

$content = $plugin->fetch('admin/usuarios.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
