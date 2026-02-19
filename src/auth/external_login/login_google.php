<?php
/**
 * Google OAuth Login para Chamilo 1.11.12 con Custom Pages
 * Basado en el plugin OAuth2 oficial de Chamilo
 */

require_once __DIR__ . '/../../../config.php';

// ============================================
// CONFIGURACIÓN
// ============================================
$plugin = SchoolPlugin::create();
$GOOGLE_CLIENT_ID = $plugin->get('google_client_id');
$GOOGLE_CLIENT_SECRET = $plugin->get('google_client_secret');
$GOOGLE_REDIRECT_URI = api_get_path(WEB_PATH).'plugin/school/src/auth/external_login/login_google.php';

$GOOGLE_AUTH_URI = 'https://accounts.google.com/o/oauth2/v2/auth';
$GOOGLE_TOKEN_URI = 'https://oauth2.googleapis.com/token';
$GOOGLE_USERINFO_URI = 'https://www.googleapis.com/oauth2/v2/userinfo';


/**
 * Función para hacer peticiones HTTP con cURL
 */
function makeHttpRequest($url, $post_data = null, $headers = []) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);

    if ($post_data !== null) {
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($post_data));
    }

    if (!empty($headers)) {
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    }

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);

    if ($error) {
        throw new Exception('Error de conexión: ' . $error);
    }

    if ($http_code >= 400) {
        throw new Exception('Error HTTP ' . $http_code);
    }

    return json_decode($response, true);
}

// ============================================
// PASO 1: Redirigir a Google
// ============================================
if (!isset($_GET['code'])) {
    $securityToken = bin2hex(random_bytes(16));

    // Capturar parámetros antes de redirigir a Google
    $source = $_REQUEST['source'] ?? 'unknown';
    $item = isset($_REQUEST['item']) ? intval($_REQUEST['item']) : 0;
    $type = isset($_REQUEST['type']) ? intval($_REQUEST['type']) : 0;

    // Incluir todo en el state (Google lo preserva)
    $stateData = [
        'token' => $securityToken,
        'source' => $source,
        'item' => $item,
        'type' => $type
    ];

    $state = base64_encode(json_encode($stateData));

    // Guardar solo el token para validación
    ChamiloSession::write('google_oauth_token', $securityToken);

    $params = [
        'client_id' => $GOOGLE_CLIENT_ID,
        'redirect_uri' => $GOOGLE_REDIRECT_URI,
        'response_type' => 'code',
        'scope' => 'email profile',
        'access_type' => 'online',
        'state' => $state,
        'prompt' => 'select_account'
    ];

    $auth_url = $GOOGLE_AUTH_URI . '?' . http_build_query($params);
    header('Location: ' . $auth_url);
    exit;
}

// ============================================
// PASO 2: Validar state y extraer datos
// ============================================
$stateData = json_decode(base64_decode($_GET['state'] ?? ''), true);

if (!$stateData || !isset($stateData['token'])) {
    error_log('Google OAuth: State inválido');
    Display::addFlash(Display::return_message('Error de seguridad. Por favor, intenta nuevamente.', 'error'));
    header('Location: ' . api_get_path(WEB_PATH) . 'index.php');
    exit;
}

// Validar token de seguridad
$savedToken = ChamiloSession::read('google_oauth_token');
if (empty($savedToken) || $stateData['token'] !== $savedToken) {
    ChamiloSession::erase('google_oauth_token');
    error_log('Google OAuth: Token validation failed');
    Display::addFlash(Display::return_message('Error de seguridad. Por favor, intenta nuevamente.', 'error'));
    header('Location: ' . api_get_path(WEB_PATH) . 'index.php');
    exit;
}
ChamiloSession::erase('google_oauth_token');

// Extraer datos del state
$source = $stateData['source'] ?? 'unknown';
$item = $stateData['item'] ?? 0;
$type = $stateData['type'] ?? 0;

if (isset($_GET['error'])) {
    $error_description = isset($_GET['error_description']) ? $_GET['error_description'] : $_GET['error'];
    error_log('Google OAuth Error: ' . $error_description);
    Display::addFlash(Display::return_message('Error de autorización: ' . $error_description, 'error'));
    header('Location: ' . api_get_path(WEB_PATH) . 'index.php');
    exit;
}

try {
    // ============================================
    // PASO 3: Obtener access token
    // ============================================
    $token_params = [
        'code' => $_GET['code'],
        'client_id' => $GOOGLE_CLIENT_ID,
        'client_secret' => $GOOGLE_CLIENT_SECRET,
        'redirect_uri' => $GOOGLE_REDIRECT_URI,
        'grant_type' => 'authorization_code'
    ];

    error_log('Google OAuth: Solicitando access token...');
    $token_response = makeHttpRequest($GOOGLE_TOKEN_URI, $token_params);

    if (isset($token_response['error'])) {
        $error_msg = isset($token_response['error_description']) ? $token_response['error_description'] : $token_response['error'];
        throw new Exception('Error al obtener token: ' . $error_msg);
    }

    if (!isset($token_response['access_token'])) {
        throw new Exception('No se recibió el access token de Google');
    }

    $access_token = $token_response['access_token'];
    error_log('Google OAuth: Access token obtenido');

    // ============================================
    // PASO 4: Obtener información del usuario
    // ============================================
    $userinfo_url = $GOOGLE_USERINFO_URI . '?access_token=' . urlencode($access_token);
    $user_data = makeHttpRequest($userinfo_url);

    if (!isset($user_data['email'])) {
        throw new Exception('No se pudo obtener el email del usuario');
    }

    $email = $user_data['email'];
    $firstName = isset($user_data['given_name']) ? $user_data['given_name'] : '';
    $lastName = isset($user_data['family_name']) ? $user_data['family_name'] : '';
    $googleId = isset($user_data['id']) ? $user_data['id'] : '';
    $picture = isset($user_data['picture']) ? $user_data['picture'] : '';

    error_log('Google OAuth: Datos obtenidos - Email: ' . $email);

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new Exception('Email inválido');
    }

    // ============================================
    // PASO 5: Buscar o crear usuario
    // ============================================

    $userInfo = api_get_user_info_from_email($email);

    if ($userInfo !== false && !empty($userInfo) && isset($userInfo['user_id'])) {
        // ========================================
        // USUARIO EXISTE
        // ========================================
        error_log('Google OAuth: Usuario existente - ID: ' . $userInfo['user_id']);

        if (isset($userInfo['active']) && $userInfo['active'] != 1) {
            throw new Exception('Tu cuenta está inactiva. Contacta al administrador.');
        }

    } else {
        // ========================================
        // CREAR NUEVO USUARIO
        // ========================================
        error_log('Google OAuth: Creando nuevo usuario para email: ' . $email);

        // Generar username único
        $username = substr($email, 0, strpos($email, '@'));
        $username = preg_replace('/[^a-zA-Z0-9_]/', '', $username);

        if (empty($username) || strlen($username) < 3) {
            $username = 'user_' . substr(md5($email), 0, 8);
        }

        $username_base = $username;
        $counter = 1;

        while (UserManager::is_username_available($username) === false) {
            $username = $username_base . $counter;
            $counter++;
            if ($counter > 100) {
                throw new Exception('No se pudo generar un nombre de usuario único');
            }
        }

        // Si faltan nombres, usar valores por defecto
        if (empty($firstName)) {
            $firstName = $username;
        }
        if (empty($lastName)) {
            $lastName = 'Usuario';
        }

        error_log('Google OAuth: Intentando crear usuario con datos: ' . json_encode([
                'email' => $email,
                'username' => $username,
                'firstName' => $firstName,
                'lastName' => $lastName
            ]));

        // Crear el nuevo usuario con UserManager::create_user()
        $userId = UserManager::create_user(
            $firstName,
            $lastName,
            STUDENT,
            $email,
            $email,
            '',
            null,
            api_get_setting('platformLanguage'),
            '',
            $picture,
            'oauth2-google',
            null,
            1,
            0,
            [],
            ''
        );

        error_log('Google OAuth: Resultado create_user - UserID: ' . ($userId ? $userId : 'FALSE'));

        if (!$userId || $userId === false) {
            // Log de error detallado
            $lastError = error_get_last();
            if ($lastError) {
                error_log('Google OAuth: Error PHP al crear usuario: ' . print_r($lastError, true));
            }

            throw new Exception('No se pudo crear la cuenta de usuario. Por favor contacta al administrador.');
        }

        error_log('Google OAuth: Usuario creado exitosamente - ID: ' . $userId);

        // Marcar que es un usuario nuevo de OAuth que necesita completar perfil
        ChamiloSession::write('is_new_oauth_user', true);
        ChamiloSession::write('oauth_user_id', $userId);

        // Guardar Google ID como campo extra (opcional)
        if (!empty($googleId)) {
            try {
                UserManager::update_extra_field_value($userId, 'google_id', $googleId);
            } catch (Exception $e) {
                error_log('Google OAuth: No se pudo guardar google_id: ' . $e->getMessage());
            }
        }

        // Obtener info completa del usuario recién creado
        $userInfo = api_get_user_info($userId);

        if (!$userInfo || empty($userInfo)) {
            throw new Exception('Usuario creado pero no se pudo obtener su información');
        }
    }

    // ============================================
    // PASO 6: INICIAR SESIÓN (método oficial de Chamilo)
    // ============================================

    // Verificar condiciones de login (similar al plugin OAuth2)
    ConditionalLogin::check_conditions($userInfo);

    // IMPORTANTE: Usar el método correcto de Chamilo para iniciar sesión
    $userId = $userInfo['user_id'];

    // Método 1: Usar Login::init_user (más compatible con Chamilo)
    $_SESSION['_user'] = $userInfo;
    $_SESSION['_user']['user_id'] = $userId;
    $_SESSION['is_platformAdmin'] = $userInfo['status'] == 1;
    $_SESSION['is_allowedCreateCourse'] = $userInfo['status'] == 1 || $userInfo['status'] == 2;

    // Establecer variables globales que Chamilo necesita
    $_user = $userInfo;
    $_user['user_id'] = $userId;
    $_user['uidReset'] = true;

    // Guardar en sesión usando ChamiloSession
    ChamiloSession::write('_user', $userInfo);
    ChamiloSession::write('_uid', $userId);
    ChamiloSession::write('_user_auth_source', 'google_oauth');

    // Puedes guardarlo como extra field
    if (!empty($source) && $source !== 'unknown') {
        UserManager::update_extra_field_value($userInfo['user_id'], 'registration_source', $source);
    }
    // O usarlo para redirigir a diferentes lugares
    ChamiloSession::write('registration_source', $source);

    // Registrar el evento de login
    Event::eventLogin($userId);

    error_log('Google OAuth: Sesión establecida correctamente para user_id: ' . $userId . ', source: ' . $source);

    if ($source === 'payments') {
        // Redirigir al plugin de compras
        header('Location: '.api_get_path(WEB_PLUGIN_PATH).'payments/process-check.php?item='.$item.'&type='.$type);
        exit;
    } else {
        // Redirigir usando el método oficial de Chamilo
        Redirect::session_request_uri(true, $userId);
    }

} catch (Exception $e) {
    error_log('Google OAuth Error: ' . $e->getMessage());
    error_log('Google OAuth Stack: ' . $e->getTraceAsString());

    Display::addFlash(
        Display::return_message(
            'Error al iniciar sesión con Google: ' . $e->getMessage(),
            'error'
        )
    );

    header('Location: ' . api_get_path(WEB_PATH) . 'index.php');
    exit;
}
