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

$userTable  = Database::get_main_table(TABLE_MAIN_USER);
$fichaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);

$search = trim($_GET['search'] ?? '');
$searchCond = '';
if ($search !== '') {
    $s = Database::escape_string($search);
    $searchCond = "AND (u.firstname LIKE '%$s%' OR u.lastname LIKE '%$s%' OR u.username LIKE '%$s%' OR u.email LIKE '%$s%')";
}

$sql = "SELECT u.user_id, u.firstname, u.lastname, u.username, u.email, u.registration_date
        FROM $userTable u
        WHERE u.status = " . STUDENT . "
          AND u.active = 1
          AND NOT EXISTS (
              SELECT 1 FROM $fichaTable f WHERE f.user_id = u.user_id
          )
          $searchCond
        ORDER BY u.lastname, u.firstname";

$result = Database::query($sql);
$students = [];
while ($row = Database::fetch_array($result, 'ASSOC')) {
    $students[] = $row;
}

$plugin->assign('students', $students);
$plugin->assign('search', $search);
$plugin->assign('form_url', api_get_path(WEB_PLUGIN_PATH) . 'school/matricula/nueva');
$plugin->setTitle($plugin->get_lang('StudentsWithoutEnrollment'));
$content = $plugin->fetch('matricula/sin_ficha.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
