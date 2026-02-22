<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../src/MatriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

header('Content-Type: application/json');

$isAdmin     = api_is_platform_admin();
$userInfo    = api_get_user_info();
$isSecretary = $userInfo && $userInfo['status'] == SCHOOL_SECRETARY;

if (!$isAdmin && !$isSecretary) {
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

$action = $_POST['action'] ?? $_GET['action'] ?? '';

switch ($action) {

    case 'delete_matricula':
        $id = (int) ($_POST['id'] ?? 0);
        if (!$id) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            break;
        }
        $result = MatriculaManager::deleteMatricula($id);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_contacto':
        $id = (int) ($_POST['id'] ?? 0);
        if (!$id) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            break;
        }
        $result = MatriculaManager::deleteContacto($id);
        echo json_encode(['success' => $result]);
        break;

    case 'retire_matricula':
        $id = (int) ($_POST['id'] ?? 0);
        if (!$id) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            break;
        }
        $result = MatriculaManager::retireMatricula($id);
        echo json_encode(['success' => $result]);
        break;

    case 'promote_year':
        $fromYearId = (int) ($_POST['from_year_id'] ?? 0);
        $toYearId   = (int) ($_POST['to_year_id'] ?? 0);
        if (!$fromYearId || !$toYearId) {
            echo json_encode(['success' => false, 'message' => 'Se requieren los IDs de ambos años académicos']);
            break;
        }
        $count = MatriculaManager::promoteToNextYear($fromYearId, $toYearId);
        echo json_encode(['success' => true, 'count' => $count]);
        break;

    case 'crear_usuario_chamilo':
        $matriculaId = (int) ($_POST['matricula_id'] ?? 0);
        if (!$matriculaId) {
            echo json_encode(['success' => false, 'message' => 'ID de matrícula requerido']);
            break;
        }
        $mat = MatriculaManager::getMatriculaById($matriculaId);
        if (!$mat) {
            echo json_encode(['success' => false, 'message' => 'Matrícula no encontrada']);
            break;
        }
        if (!empty($mat['user_id'])) {
            echo json_encode(['success' => false, 'message' => 'Esta matrícula ya tiene un usuario vinculado']);
            break;
        }

        // Build user fields from matricula data
        $firstName = ucwords(mb_strtolower(trim($mat['nombres'] ?? '')));
        $lastName  = trim(($mat['apellido_paterno'] ?? '') . ' ' . ($mat['apellido_materno'] ?? ''));
        $lastName  = ucwords(mb_strtolower($lastName));

        // Username: use DNI if available, otherwise generate from name
        if (!empty($mat['dni'])) {
            $username = $mat['dni'];
        } else {
            $username = UserManager::create_username($firstName, $lastName);
        }

        // Ensure username is unique
        $base = $username;
        $i = 1;
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        while (Database::num_rows(Database::query("SELECT id FROM $userTable WHERE username = '" . Database::escape_string($username) . "'")) > 0) {
            $username = $base . $i++;
        }

        // Generate initial password (same as DNI or random)
        $password = !empty($mat['dni']) ? $mat['dni'] : api_generate_password(8);

        // Email: generate a placeholder if DNI available, otherwise empty
        $email = !empty($mat['dni']) ? $mat['dni'] . '@alumno.local' : '';

        $newUserId = UserManager::create_user(
            $firstName,
            $lastName,
            STUDENT,          // status = 5
            $email,
            $username,
            $password,
            (string) $mat['id'], // official_code = matricula id
            '',               // language (default)
            '',               // phone
            '',               // picture_uri
            PLATFORM_AUTH_SOURCE,
            null,             // expiration date
            0                 // active = 0 (inactive)
        );

        if (!$newUserId || $newUserId < 0) {
            echo json_encode(['success' => false, 'message' => 'Error al crear el usuario. Verifique que el username o email no esté duplicado.']);
            break;
        }

        // Link the new user to the matricula
        Database::update(
            Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA),
            ['user_id' => $newUserId],
            ['id = ?' => $matriculaId]
        );

        echo json_encode([
            'success'  => true,
            'user_id'  => $newUserId,
            'username' => $username,
            'password' => $password,
        ]);
        break;

    case 'buscar_usuario':
        $term = trim($_POST['term'] ?? '');
        if (strlen($term) < 2) {
            echo json_encode(['success' => false, 'users' => []]);
            break;
        }
        $escaped = Database::escape_string($term);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $res = Database::query(
            "SELECT id, username, firstname, lastname
             FROM $userTable
             WHERE status != 6
               AND (username LIKE '%$escaped%' OR firstname LIKE '%$escaped%' OR lastname LIKE '%$escaped%')
             ORDER BY lastname, firstname
             LIMIT 10"
        );
        $users = [];
        while ($u = Database::fetch_array($res, 'ASSOC')) {
            $users[] = [
                'id'    => (int) $u['id'],
                'label' => $u['lastname'] . ' ' . $u['firstname'] . ' (' . $u['username'] . ')',
            ];
        }
        echo json_encode(['success' => true, 'users' => $users]);
        break;

    case 'consultar_reniec':
        $dni = trim($_POST['dni'] ?? '');
        if (!preg_match('/^\d{8}$/', $dni)) {
            echo json_encode(['success' => false, 'message' => 'DNI inválido: debe tener exactamente 8 dígitos']);
            break;
        }
        $url = 'https://api.apis.net.pe/v2/reniec/dni?numero=' . $dni;
        $ch  = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT        => 10,
            CURLOPT_HTTPHEADER     => ['Accept: application/json'],
        ]);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if ($httpCode === 200 && $response) {
            $data = json_decode($response, true);
            echo json_encode([
                'success'          => true,
                'apellido_paterno' => $data['apellidoPaterno'] ?? '',
                'apellido_materno' => $data['apellidoMaterno'] ?? '',
                'nombres'          => $data['nombre'] ?? '',
            ]);
        } else {
            echo json_encode(['success' => false, 'message' => 'No se encontró el DNI en RENIEC']);
        }
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Acción no reconocida']);
        break;
}
