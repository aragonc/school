<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();

// Si ya está logueado, redirigir al dashboard
if (api_get_user_id()) {
    $plugin->handleLoginRedirect();
    $redirectUrl = api_get_path(WEB_PATH) . 'dashboard';
    header('Location: ' . $redirectUrl);
    exit;
}

// Procesar login
$errorMessage = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['login'], $_POST['password'])) {
    $login = trim($_POST['login']);
    $password = $_POST['password'];

    // Buscar usuario
    $userTable = Database::get_main_table(TABLE_MAIN_USER);
    $sql = "SELECT user_id, username, password, auth_source, active, expiration_date, status, salt, last_login
            FROM $userTable
            WHERE username = '".Database::escape_string($login)."'";
    $result = Database::query($sql);

    if (Database::num_rows($result) > 0) {
        $uData = Database::fetch_array($result, 'ASSOC');

        // Verificar que el usuario esté activo
        if ($uData['active'] != 1) {
            $errorMessage = $plugin->get_lang('AccountInactive');
        } elseif (
            !empty($uData['expiration_date']) &&
            $uData['expiration_date'] !== '0000-00-00 00:00:00' &&
            strtotime($uData['expiration_date']) < time()
        ) {
            $errorMessage = $plugin->get_lang('AccountExpired');
        } else {
            // Validar contraseña usando el método de Chamilo
            $validPassword = UserManager::checkPassword(
                $uData['password'],
                $password,
                $uData['salt'],
                (int) $uData['user_id']
            );

            if ($validPassword) {
                $userId = (int) $uData['user_id'];

                // Iniciar sesión en Chamilo
                ChamiloSession::write('_uid', $userId);
                $_SESSION['_uid'] = $userId;
                $_SESSION['_user'] = [
                    'user_id' => $userId,
                    'status'  => $uData['status'],
                    'uidReset' => true,
                ];

                // Registrar evento de login
                Event::eventLogin($userId);

                // Manejar redirección pendiente
                $plugin->handleLoginRedirect();

                // Por defecto ir al dashboard del plugin
                $redirectUrl = api_get_path(WEB_PATH) . 'dashboard';
                header('Location: ' . $redirectUrl);
                exit;
            } else {
                $errorMessage = $plugin->get_lang('LoginFailed');
            }
        }
    } else {
        $errorMessage = $plugin->get_lang('LoginFailed');
    }
}

// Obtener parámetros de error desde URL (si viene redirigido)
if (isset($_GET['error'])) {
    $errorMessage = $plugin->get_lang('LoginFailed');
}

$siteName = api_get_setting('siteName');
$institution = api_get_setting('Institution');
$pluginPath = api_get_path(WEB_PLUGIN_PATH) . 'school/';
$webPath = api_get_path(WEB_PATH);
$lostPasswordUrl = $webPath . 'main/auth/lostPassword.php';

// Logo personalizado
$customLogo = $plugin->getCustomLogo();
if ($customLogo) {
    $logoUrl = $customLogo;
} else {
    $theme = api_get_visual_theme();
    $themeDir = Template::getThemeDir($theme);
    $logoUrl = api_get_path(WEB_CSS_PATH).$themeDir.'images/header-logo-vector.svg';
}

// Login background settings
$loginBgColor = $plugin->getSchoolSetting('login_bg_color');
$loginBgImage = $plugin->getSchoolSetting('login_bg_image');
$loginBgImageUrl = '';
if ($loginBgImage) {
    $fullPath = api_get_path(SYS_UPLOAD_PATH).'plugins/school/'.$loginBgImage;
    if (file_exists($fullPath)) {
        $loginBgImageUrl = api_get_path(WEB_UPLOAD_PATH).'plugins/school/'.$loginBgImage;
    }
}

// Login card image
$loginCardImage = $plugin->getSchoolSetting('login_card_image');
$loginCardImageUrl = '';
if ($loginCardImage) {
    $fullPath = api_get_path(SYS_UPLOAD_PATH).'plugins/school/'.$loginCardImage;
    if (file_exists($fullPath)) {
        $loginCardImageUrl = api_get_path(WEB_UPLOAD_PATH).'plugins/school/'.$loginCardImage;
    }
}

$plugin->assign('logo_url', $logoUrl);
$plugin->assign('login_bg_color', $loginBgColor ?: '');
$plugin->assign('login_bg_image', $loginBgImageUrl);
$plugin->assign('login_card_image', $loginCardImageUrl);
$plugin->assign('error_message', $errorMessage);
$plugin->assign('site_name', $siteName);
$plugin->assign('institution', $institution);
$plugin->assign('plugin_path', $pluginPath);
$plugin->assign('web_path', $webPath);
$plugin->assign('lost_password_url', $lostPasswordUrl);

$googleLoginUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/src/auth/external_login/login_google.php';
$plugin->assign('google_login_url', $googleLoginUrl);

$content = $plugin->fetch('auth/login.tpl');
$plugin->assign('content', $content);
$plugin->display_login_template();
