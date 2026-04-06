<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../src/GoogleAdminService.php';
require_once __DIR__ . '/../../src/MatriculaManager.php';
require_once __DIR__ . '/../../src/AcademicManager.php';

$plugin = SchoolPlugin::create();
api_protect_admin_script();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setSidebar('admin');
$plugin->setTitle('Sincronización Google Workspace');

$activeYear = MatriculaManager::getActiveYear();
$yearId     = $activeYear ? (int) $activeYear['id'] : 0;

// Check if Google Workspace is configured
$googleConfigured = false;
$saFileName = $plugin->getSchoolSetting('google_sa_json') ?: '';
$saUploadPath = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/' . $saFileName;
if ($saFileName && file_exists($saUploadPath) &&
    $plugin->getSchoolSetting('google_admin_email') &&
    $plugin->getSchoolSetting('google_domain')) {
    $googleConfigured = true;
}

// Load filter data
$levels  = AcademicManager::getLevels(true);
$grades  = AcademicManager::getGrades(null, true);
$sections = AcademicManager::getSections(true);

$plugin->assign('google_configured',    $googleConfigured);
$plugin->assign('google_admin_email',   $plugin->getSchoolSetting('google_admin_email') ?: '');
$plugin->assign('google_domain',        $plugin->getSchoolSetting('google_domain') ?: '');
$plugin->assign('active_year',          $activeYear);
$plugin->assign('year_id',              $yearId);
$plugin->assign('levels',               $levels);
$plugin->assign('grades',               $grades);
$plugin->assign('sections',             $sections);
$plugin->assign('settings_url',         api_get_path(WEB_PATH) . 'school-admin/settings');
$plugin->assign('ajax_google_url',      api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_google.php');

$content = $plugin->fetch('admin/google_sync.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
