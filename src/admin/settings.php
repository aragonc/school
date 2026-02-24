<?php

require_once __DIR__ . '/../../config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$plugin->setSidebar('');
$content = null;
api_block_anonymous_users();
$userId = api_get_user_id();
$action = $_REQUEST['action'] ?? '';

$plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');

$faviconUploadDir = __DIR__ . '/../../uploads/';
$faviconPath = $faviconUploadDir . 'favicon.png';
$faviconWebUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/uploads/favicon.png';

$faviconMsg = '';

// Handle favicon upload
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['favicon_png'])) {
    $file = $_FILES['favicon_png'];
    if ($file['error'] === UPLOAD_ERR_OK) {
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime = $finfo->file($file['tmp_name']);
        if ($mime === 'image/png') {
            if (!is_dir($faviconUploadDir)) {
                mkdir($faviconUploadDir, api_get_permissions_for_new_directories(), true);
            }
            move_uploaded_file($file['tmp_name'], $faviconPath);
            $faviconMsg = 'success';
        } else {
            $faviconMsg = 'invalid';
        }
    } elseif ($file['error'] !== UPLOAD_ERR_NO_FILE) {
        $faviconMsg = 'error';
    }
}

// Handle matricula settings save
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_matricula_settings'])) {
    $reniecVisible = !empty($_POST['reniec_visible']) ? '1' : '0';
    $plugin->setSchoolSetting('reniec_visible', $reniecVisible);
    header('Location: ' . api_get_self() . '?action=' . Security::remove_XSS($action) . '&' . api_get_cidreq() . '&saved=1');
    exit;
}

// Handle favicon delete
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete_favicon'])) {
    if (file_exists($faviconPath)) {
        unlink($faviconPath);
    }
    $faviconMsg = 'deleted';
}

if ($enable) {
    $form = new FormValidator(
        'settings',
        'post',
        api_get_self().'?action='.Security::remove_XSS($action).'&'.api_get_cidreq()
    );
    $form->addText('Institution',[$plugin->get_lang('InstitutionTitle'), $plugin->get_lang('InstitutionComment')]);
    $form->addText('InstitutionUrl',[$plugin->get_lang('InstitutionUrlTitle'), $plugin->get_lang('InstitutionUrlComment')]);
    $form->addText('siteName',[$plugin->get_lang('SiteNameTitle'), $plugin->get_lang('SiteNameComment')]);
    $form->addText('emailAdministrator',[$plugin->get_lang('emailAdministratorTitle'), $plugin->get_lang('emailAdministratorComment')]);
    $plugin->setTitle($plugin->get_lang('BasicSystemConfiguration'));
    $plugin->assign('form', $form->returnForm());

    $plugin->assign('favicon_exists', file_exists($faviconPath));
    $plugin->assign('favicon_web_url', $faviconWebUrl);
    $plugin->assign('favicon_msg', $faviconMsg);
    $plugin->assign('reniec_visible', $plugin->getSchoolSetting('reniec_visible') !== '0');
    $plugin->assign('settings_saved', isset($_GET['saved']));
    $plugin->assign('settings_url', api_get_self() . '?action=' . Security::remove_XSS($action) . '&' . api_get_cidreq());

    $content = $plugin->fetch('admin/settings.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
