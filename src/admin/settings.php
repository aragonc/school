<?php

require_once __DIR__ . '/../../config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
api_block_anonymous_users();
if (!api_is_platform_admin()) {
    api_not_allowed(true);
}
$plugin->setSidebar('admin');
$content = null;
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

// Handle basic system configuration save
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_basic_settings'])) {
    $institution = Security::remove_XSS(trim($_POST['Institution'] ?? ''));
    $institutionUrl = Security::remove_XSS(trim($_POST['InstitutionUrl'] ?? ''));
    $siteName = Security::remove_XSS(trim($_POST['siteName'] ?? ''));
    $emailAdmin = Security::remove_XSS(trim($_POST['emailAdministrator'] ?? ''));
    api_set_setting('Institution', $institution);
    api_set_setting('InstitutionUrl', $institutionUrl);
    api_set_setting('siteName', $siteName);
    api_set_setting('emailAdministrator', $emailAdmin);
    header('Location: ' . api_get_self() . '?action=' . Security::remove_XSS($action) . '&' . api_get_cidreq() . '&saved=1');
    exit;
}

// Handle modules settings save
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_modules_settings'])) {
    $moduleKeys = ['courses', 'my_aula', 'attendance', 'payments', 'products', 'matricula', 'academic', 'support'];
    foreach ($moduleKeys as $key) {
        $value = !empty($_POST['module_' . $key]) ? '1' : '0';
        $plugin->setSchoolSetting('module_' . $key, $value);
    }
    header('Location: ' . api_get_self() . '?action=' . Security::remove_XSS($action) . '&' . api_get_cidreq() . '&saved=1');
    exit;
}

// Handle attendance settings save
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_attendance_settings'])) {
    $showCheckin = !empty($_POST['attendance_show_checkin_time']) ? '1' : '0';
    $plugin->setSchoolSetting('attendance_show_checkin_time', $showCheckin);
    $manualTutor = !empty($_POST['attendance_manual_tutor']) ? '1' : '0';
    $plugin->setSchoolSetting('attendance_manual_tutor', $manualTutor);
    header('Location: ' . api_get_self() . '?action=' . Security::remove_XSS($action) . '&' . api_get_cidreq() . '&saved=1');
    exit;
}

// Handle login settings save
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_login_settings'])) {
    $googleOnlyLogin = !empty($_POST['google_only_login']) ? '1' : '0';
    $plugin->setSchoolSetting('google_only_login', $googleOnlyLogin);
    $loginInfoMessage = Security::remove_XSS(trim($_POST['login_info_message'] ?? ''));
    $plugin->setSchoolSetting('login_info_message', $loginInfoMessage);
    header('Location: ' . api_get_self() . '?action=' . Security::remove_XSS($action) . '&' . api_get_cidreq() . '&saved=1');
    exit;
}

// Handle Google Workspace settings save
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_google_workspace_settings'])) {
    $googleAdminEmail = Security::remove_XSS(trim($_POST['google_admin_email'] ?? ''));
    $googleDomain     = Security::remove_XSS(trim($_POST['google_domain'] ?? ''));
    $plugin->setSchoolSetting('google_admin_email', $googleAdminEmail);
    $plugin->setSchoolSetting('google_domain', $googleDomain);

    // Handle SA JSON textarea content
    $jsonContent = trim($_POST['google_sa_json_content'] ?? '');
    if ($jsonContent !== '') {
        $decoded = json_decode($jsonContent, true);
        if ($decoded && !empty($decoded['private_key']) && !empty($decoded['client_email'])
            && ($decoded['type'] ?? '') === 'service_account') {
            $saUploadDir = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/';
            if (!is_dir($saUploadDir)) {
                mkdir($saUploadDir, api_get_permissions_for_new_directories(), true);
            }
            // Remove old file if any
            $oldFile = $plugin->getSchoolSetting('google_sa_json') ?: '';
            if ($oldFile && file_exists($saUploadDir . $oldFile)) {
                unlink($saUploadDir . $oldFile);
            }
            $saFilename = 'google_sa_' . time() . '.json';
            file_put_contents($saUploadDir . $saFilename, $jsonContent);
            $plugin->setSchoolSetting('google_sa_json', $saFilename);
        } else {
            // Wrong type or missing fields — set error and skip redirect
            $gwsError = 'El JSON no es una Service Account válida. Debe contener "type": "service_account", "private_key" y "client_email".';
            $plugin->assign('gws_error', $gwsError);
            goto render_settings;
        }
    }
    header('Location: ' . api_get_self() . '?action=' . Security::remove_XSS($action) . '&' . api_get_cidreq() . '&saved=1');
    exit;
}
render_settings:

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
    $form->addHidden('save_basic_settings', '1');
    $form->addText('Institution', [$plugin->get_lang('InstitutionTitle'), $plugin->get_lang('InstitutionComment')]);
    $form->addText('InstitutionUrl', [$plugin->get_lang('InstitutionUrlTitle'), $plugin->get_lang('InstitutionUrlComment')]);
    $form->addText('siteName', [$plugin->get_lang('SiteNameTitle'), $plugin->get_lang('SiteNameComment')]);
    $form->addText('emailAdministrator', [$plugin->get_lang('emailAdministratorTitle'), $plugin->get_lang('emailAdministratorComment')]);
    $form->addButtonSave($plugin->get_lang('Save'));
    $form->setDefaults([
        'Institution'       => api_get_setting('Institution'),
        'InstitutionUrl'    => api_get_setting('InstitutionUrl'),
        'siteName'          => api_get_setting('siteName'),
        'emailAdministrator'=> api_get_setting('emailAdministrator'),
    ]);
    $plugin->setTitle($plugin->get_lang('BasicSystemConfiguration'));
    $plugin->assign('form', $form->returnForm());

    $plugin->assign('favicon_exists', file_exists($faviconPath));
    $plugin->assign('favicon_web_url', $faviconWebUrl);
    $plugin->assign('favicon_msg', $faviconMsg);
    // Modules active/inactive settings (default: active if not set)
    $moduleKeys = ['courses', 'my_aula', 'attendance', 'payments', 'products', 'matricula', 'academic', 'support'];
    $modulesEnabled = [];
    foreach ($moduleKeys as $key) {
        $modulesEnabled[$key] = $plugin->getSchoolSetting('module_' . $key) !== '0';
    }
    $plugin->assign('modules_enabled', $modulesEnabled);

    $plugin->assign('reniec_visible', $plugin->getSchoolSetting('reniec_visible') !== '0');
    $plugin->assign('attendance_show_checkin_time', $plugin->getSchoolSetting('attendance_show_checkin_time') === '1');
    $plugin->assign('attendance_manual_tutor', $plugin->getSchoolSetting('attendance_manual_tutor') === '1');
    $plugin->assign('google_only_login', $plugin->getSchoolSetting('google_only_login') === '1');
    $plugin->assign('login_info_message', $plugin->getSchoolSetting('login_info_message') ?: '');
    $plugin->assign('settings_saved', isset($_GET['saved']));
    $plugin->assign('settings_url', api_get_self() . '?action=' . Security::remove_XSS($action) . '&' . api_get_cidreq());

    // Google Workspace settings
    $saFileName = $plugin->getSchoolSetting('google_sa_json') ?: '';
    $saUploadPath = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/' . $saFileName;
    $plugin->assign('google_sa_json_name', $saFileName ?: '');
    $plugin->assign('google_sa_json_valid', $saFileName && file_exists($saUploadPath));
    $plugin->assign('google_admin_email', $plugin->getSchoolSetting('google_admin_email') ?: '');
    $plugin->assign('google_domain', $plugin->getSchoolSetting('google_domain') ?: '');
    $plugin->assign('google_sync_url', api_get_path(WEB_PATH) . 'admin/google-sync');

    $content = $plugin->fetch('admin/settings.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
