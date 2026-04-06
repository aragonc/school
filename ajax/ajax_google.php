<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../src/GoogleAdminService.php';
require_once __DIR__ . '/../src/MatriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

header('Content-Type: application/json');

if (!api_is_platform_admin()) {
    echo json_encode(['success' => false, 'error' => 'Sin permisos']);
    exit;
}

$action = $_POST['action'] ?? $_GET['action'] ?? '';

$googleService = GoogleAdminService::fromPluginSettings($plugin);
if (!$googleService && $action !== 'check_config') {
    echo json_encode(['success' => false, 'error' => 'Google Workspace no está configurado. Configure las credenciales en Configuración.']);
    exit;
}

switch ($action) {

    // ---- Verificar si la configuración es válida ----
    case 'check_config':
        if (!$googleService) {
            echo json_encode(['success' => false, 'configured' => false,
                'error' => 'Faltan credenciales de Google Workspace en la configuración.']);
            break;
        }
        // Try a simple API call to verify credentials work
        try {
            // Just check a dummy email to test auth
            $googleService->getUser('_test_connectivity_@' . $googleService->getDomain());
            echo json_encode(['success' => true, 'configured' => true]);
        } catch (\Exception $e) {
            echo json_encode(['success' => false, 'configured' => true,
                'error' => 'Error al conectar con Google API: ' . $e->getMessage()]);
        }
        break;

    // ---- Verificar cuentas de un lote de alumnos ----
    case 'check_accounts':
        $yearId    = (int) ($_POST['year_id']    ?? $_GET['year_id']    ?? 0);
        $levelId   = (int) ($_POST['level_id']   ?? $_GET['level_id']   ?? 0);
        $gradeId   = (int) ($_POST['grade_id']   ?? $_GET['grade_id']   ?? 0);
        $sectionId = (int) ($_POST['section_id'] ?? $_GET['section_id'] ?? 0);

        $filters = ['estado' => 'activo'];
        if ($yearId    > 0) $filters['academic_year_id'] = $yearId;
        if ($levelId   > 0) $filters['level_id']         = $levelId;
        if ($gradeId   > 0) $filters['grade_id']         = $gradeId;
        if ($sectionId > 0) $filters['section_id']       = $sectionId;

        $matriculas = MatriculaManager::getMatriculas($filters);

        // Collect emails from Chamilo user accounts
        $userTable  = Database::get_main_table(TABLE_MAIN_USER);
        $fichaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $items = [];
        $emailsToCheck = [];

        foreach ($matriculas as $m) {
            if (empty($m['user_id'])) continue;
            $uid = (int) $m['user_id'];
            $uRow = Database::fetch_array(
                Database::query("SELECT user_id, email, username, firstname, lastname FROM $userTable WHERE user_id = $uid LIMIT 1"),
                'ASSOC'
            );
            if (!$uRow || empty($uRow['email'])) continue;

            $fRow = Database::fetch_array(
                Database::query("SELECT dni FROM $fichaTable WHERE user_id = $uid LIMIT 1"),
                'ASSOC'
            );

            $items[] = [
                'user_id'   => $uid,
                'email'     => $uRow['email'],
                'username'  => $uRow['username'],
                'firstname' => $uRow['firstname'],
                'lastname'  => $uRow['lastname'],
                'dni'       => trim($fRow['dni'] ?? ''),
                'full_name' => trim(($m['apellido_paterno'] ?? $uRow['lastname']) . ' ' .
                                    ($m['apellido_materno'] ?? '') . ', ' .
                                    ($m['nombres'] ?? $uRow['firstname'])),
                'grade'     => trim(($m['level_name'] ?? '') . ' ' . ($m['grade_name'] ?? '')),
                'section'   => $m['section_name'] ?? '',
            ];
            $emailsToCheck[] = $uRow['email'];
        }

        if (empty($emailsToCheck)) {
            echo json_encode(['success' => true, 'items' => []]);
            break;
        }

        // Test connectivity first with one email to get a clear error
        $testError = null;
        try {
            $googleService->getUser($emailsToCheck[0]);
        } catch (\Exception $e) {
            $testError = $e->getMessage();
        }

        if ($testError !== null) {
            echo json_encode(['success' => false, 'error' => 'Error al conectar con Google API: ' . $testError]);
            break;
        }

        // Check in batches to avoid timeout
        $googleStatuses = $googleService->checkMultipleUsers($emailsToCheck);

        foreach ($items as &$item) {
            $status = $googleStatuses[$item['email']] ?? null;
            $item['google_exists'] = $status === true  ? 'yes' :
                                    ($status === false ? 'no'  : 'error');
        }
        unset($item);

        echo json_encode(['success' => true, 'items' => $items]);
        break;

    // ---- Crear cuenta Google Workspace para un alumno ----
    case 'create_account':
        $userId             = (int) ($_POST['user_id'] ?? 0);
        $changeAtNextLogin  = !empty($_POST['change_at_next_login']);

        if ($userId <= 0) {
            echo json_encode(['success' => false, 'error' => 'ID de usuario inválido']);
            break;
        }

        $userTable  = Database::get_main_table(TABLE_MAIN_USER);
        $fichaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);

        $uRow = Database::fetch_array(
            Database::query("SELECT user_id, email, firstname, lastname FROM $userTable WHERE user_id = $userId LIMIT 1"),
            'ASSOC'
        );
        if (!$uRow || empty($uRow['email'])) {
            echo json_encode(['success' => false, 'error' => 'Usuario no encontrado o sin correo']);
            break;
        }

        // Password: use override if provided, else play@DNI
        $passwordOverride = trim($_POST['password_override'] ?? '');
        if ($passwordOverride !== '') {
            $password = $passwordOverride;
        } else {
            $fichaRow = Database::fetch_array(
                Database::query("SELECT dni FROM $fichaTable WHERE user_id = $userId LIMIT 1"),
                'ASSOC'
            );
            $dni = trim($fichaRow['dni'] ?? '');
            $password = 'play@' . ($dni ?: $userId);
        }

        // Check if already exists
        try {
            $existing = $googleService->getUser($uRow['email']);
            if ($existing !== null) {
                echo json_encode(['success' => true, 'created' => false,
                    'message' => 'La cuenta ya existe en Google Workspace.',
                    'email'   => $uRow['email']]);
                break;
            }
        } catch (\Exception $e) {
            echo json_encode(['success' => false, 'error' => 'Error al verificar: ' . $e->getMessage()]);
            break;
        }

        try {
            $googleService->createUser(
                $uRow['email'],
                $uRow['firstname'],
                $uRow['lastname'],
                $password,
                $changeAtNextLogin
            );
            echo json_encode([
                'success'              => true,
                'created'              => true,
                'email'                => $uRow['email'],
                'password'             => $password,
                'change_at_next_login' => $changeAtNextLogin,
            ]);
        } catch (\Exception $e) {
            echo json_encode(['success' => false, 'error' => 'Error al crear cuenta: ' . $e->getMessage()]);
        }
        break;

    // ---- Cambiar contraseña de una cuenta Google Workspace ----
    case 'change_password':
        $userId            = (int) ($_POST['user_id'] ?? 0);
        $newPassword       = trim($_POST['new_password'] ?? '');
        $changeAtNextLogin = !empty($_POST['change_at_next_login']);

        if ($userId <= 0 || strlen($newPassword) < 6) {
            echo json_encode(['success' => false, 'error' => 'Parámetros inválidos (mínimo 6 caracteres)']);
            break;
        }

        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $uRow = Database::fetch_array(
            Database::query("SELECT email FROM $userTable WHERE user_id = $userId LIMIT 1"),
            'ASSOC'
        );
        if (!$uRow || empty($uRow['email'])) {
            echo json_encode(['success' => false, 'error' => 'Usuario no encontrado']);
            break;
        }

        try {
            $googleService->updateUserPassword($uRow['email'], $newPassword, $changeAtNextLogin);
            echo json_encode(['success' => true, 'message' => 'Contraseña actualizada correctamente.']);
        } catch (\Exception $e) {
            echo json_encode(['success' => false, 'error' => 'Error al cambiar contraseña: ' . $e->getMessage()]);
        }
        break;

    default:
        echo json_encode(['success' => false, 'error' => 'Acción no reconocida']);
        break;
}
