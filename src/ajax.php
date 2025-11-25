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

        $response = [
            'success' => false,
            'message' => ''
        ];

        try {
            // Verificar que sea método POST
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                throw new Exception($plugin->get_lang('InvalidRequest'));
            }

            // Obtener token y contraseñas
            $token = isset($_POST['token']) ? trim($_POST['token']) : '';
            $pass1 = isset($_POST['pass1']) ? trim($_POST['pass1']) : '';
            $pass2 = isset($_POST['pass2']) ? trim($_POST['pass2']) : '';

            // Validaciones básicas
            if (empty($token)) {
                throw new Exception($plugin->get_lang('InvalidToken'));
            }

            if (empty($pass1) || empty($pass2)) {
                throw new Exception($plugin->get_lang('PasswordFieldsCannotBeEmpty'));
            }

            if (strlen($pass1) <= 4) {
                throw new Exception($plugin->get_lang('PasswordMinLength'));
            }

            if ($pass1 !== $pass2) {
                throw new Exception($plugin->get_lang('PasswordsDoNotMatch'));
            }

            // Buscar usuario por token de confirmación
            /** @var \Chamilo\UserBundle\Entity\User $user */
            $user = UserManager::getManager()->findUserByConfirmationToken($token);

            if (!$user) {
                throw new Exception($plugin->get_lang('InvalidToken'));
            }

            // Verificar que el token no haya expirado (tiempo en segundos)
            $ttl = 86400; // 24 horas (puedes ajustar esto)

            if (!$user->isPasswordRequestNonExpired($ttl)) {
                throw new Exception($plugin->get_lang('LinkExpired'));
            }

            // Actualizar la contraseña
            $user->setPlainPassword($pass1);

            // Obtener el UserManager
            $userManager = UserManager::getManager();
            $userManager->updateUser($user, true);

            // Limpiar el token de confirmación y la fecha de solicitud
            $user->setConfirmationToken(null);
            $user->setPasswordRequestedAt(null);

            // Persistir cambios con Doctrine
            $em = Database::getManager();
            $em->persist($user);
            $em->flush();
            $updated = $plugin->updateUserAuthSource($user->getUserId(), 'platform');
            // Respuesta exitosa
            $response['success'] = true;
            $response['message'] = $plugin->get_lang('PasswordSuccessfullyChanged');

            // Log de auditoría
            error_log(sprintf(
                "Password successfully changed for user ID: %d (Username: %s, Email: %s)",
                $user->getId(),
                $user->getUsername(),
                $user->getEmail()
            ));

            // Registrar evento en Chamilo (si existe la función)
            if (function_exists('Event::addEvent')) {
                Event::addEvent(
                    LOG_USER_PASSWORD_UPDATE,
                    LOG_USER_ID,
                    $user->getId(),
                    api_get_utc_datetime(),
                    null,
                    null,
                    null
                );
            }

        } catch (Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();

            // Log del error
            error_log("Password update error: " . $e->getMessage());
        }

        // Enviar respuesta JSON
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        break;

    default:
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => 'Invalid action'
        ]);
        break;
}
