<?php

require_once __DIR__ . '/../config.php';
//api_block_anonymous_users();
$action = $_REQUEST['action'] ?? null;
$search = $_REQUEST['term'] ?? null;
$plugin = SchoolPlugin::create();

switch ($action) {
    case 'check_notifications':
        $userId = api_get_user_id();
        $messages = $plugin->getAjaxMessages($userId);
        $jsonResponse  = [
            'count_messages' => $messages['totalMessages'],
            'messages' => $messages['messages']
        ];

        header('Content-Type: application/json');
        echo json_encode($jsonResponse);
        break;

    case 'search':
        $userId = api_get_user_id();
        $sessions = $plugin->getSearchCourse($search);
        $jsonResponse  = [
            'sessions' => $sessions,
            'count' => count($sessions)
        ];
        header('Content-Type: application/json');
        echo json_encode($jsonResponse);
        break;

    case 'search_course':
        // Tu código aquí
        break;

    case 'update_password':
        // Cargar traducciones
        $language_file = __DIR__ . '/../lang/' . api_get_interface_language() . '.php';
        if (file_exists($language_file)) {
            include_once $language_file;
        }

        function get_plugin_lang($variable) {
            global $strings;
            return isset($strings[$variable]) ? $strings[$variable] : $variable;
        }

        $response = [
            'success' => false,
            'message' => ''
        ];

        try {
            // Verificar que sea método POST
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                throw new Exception(get_plugin_lang('InvalidRequest'));
            }

            // Obtener y validar token
            $token = isset($_POST['token']) ? trim($_POST['token']) : '';
            $validToken = isset($_SESSION['reset_password_token']) ? $_SESSION['reset_password_token'] : '';

            if (empty($token) || $token !== $validToken) {
                throw new Exception(get_plugin_lang('InvalidToken'));
            }

            // Obtener contraseñas
            $pass1 = isset($_POST['pass1']) ? trim($_POST['pass1']) : '';
            $pass2 = isset($_POST['pass2']) ? trim($_POST['pass2']) : '';

            // Validaciones
            if (empty($pass1) || empty($pass2)) {
                throw new Exception(get_plugin_lang('PasswordFieldsCannotBeEmpty'));
            }

            if (strlen($pass1) < 8) {
                throw new Exception(get_plugin_lang('PasswordMinLength'));
            }

            if ($pass1 !== $pass2) {
                throw new Exception(get_plugin_lang('PasswordsDoNotMatch'));
            }

            // Obtener ID de usuario desde la sesión
            $userId = isset($_SESSION['reset_user_id']) ? (int)$_SESSION['reset_user_id'] : 0;

            if ($userId <= 0) {
                throw new Exception(get_plugin_lang('InvalidSession'));
            }

            // Verificar que el usuario existe
            $userInfo = api_get_user_info($userId);

            if (empty($userInfo)) {
                throw new Exception(get_plugin_lang('UserNotFound'));
            }

            // Encriptar la nueva contraseña
            $hashedPassword = UserManager::encryptPassword($pass1);

            // Actualizar contraseña en la base de datos
            $tableName = Database::get_main_table(TABLE_MAIN_USER);
            $sql = "UPDATE " . $tableName . "
                    SET password = '" . Database::escape_string($hashedPassword) . "'
                    WHERE user_id = " . (int)$userId;

            $result = Database::query($sql);

            if (!$result) {
                throw new Exception(get_plugin_lang('PasswordUpdateFailed'));
            }

            // Actualización exitosa
            $response['success'] = true;
            $response['message'] = get_plugin_lang('PasswordSuccessfullyChanged');

            // Limpiar datos de sesión
            unset($_SESSION['reset_password_token']);
            unset($_SESSION['reset_user_id']);

            // Log de auditoría
            error_log("Password successfully changed for user ID: {$userId} (Username: {$userInfo['username']})");

            // Registrar en tabla de log si existe
            Event::addEvent(
                LOG_USER_PASSWORD_UPDATE,
                LOG_USER_ID,
                $userId,
                api_get_utc_datetime(),
                api_get_user_id(),
                null,
                null
            );

        } catch (Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();

            // Log del error
            error_log("Password update error: " . $e->getMessage());
        }

        // Enviar respuesta JSON
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
        break;

    default:
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => 'Invalid action'
        ]);
        break;
}
