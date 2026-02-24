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

    case 'save_matricula_anual':
        $fichaId     = (int) ($_POST['ficha_id'] ?? 0);
        $matId       = (int) ($_POST['mat_id'] ?? 0);
        $yearId      = (int) ($_POST['academic_year_id'] ?? 0);
        $gradeId     = (int) ($_POST['grade_id'] ?? 0);
        $tipoIngreso = $_POST['tipo_ingreso'] ?? 'NUEVO_INGRESO';
        $estado      = $_POST['estado'] ?? 'ACTIVO';

        if (!$fichaId) {
            echo json_encode(['success' => false, 'message' => 'ficha_id requerido']);
            break;
        }

        $savedId = MatriculaManager::saveMatricula([
            'id'               => $matId,
            'ficha_id'         => $fichaId,
            'academic_year_id' => $yearId ?: null,
            'grade_id'         => $gradeId ?: null,
            'tipo_ingreso'     => $tipoIngreso,
            'estado'           => $estado,
        ]);

        echo json_encode(['success' => $savedId > 0, 'id' => $savedId]);
        break;

    case 'crear_usuario_chamilo':
        // Accept ficha_id directly (new) or fall back to matricula_id (legacy)
        $fichaId     = (int) ($_POST['ficha_id'] ?? 0);
        $matriculaId = (int) ($_POST['matricula_id'] ?? 0);

        if ($fichaId > 0) {
            $mat = MatriculaManager::getFichaById($fichaId);
        } elseif ($matriculaId > 0) {
            $matRow  = MatriculaManager::getMatriculaById($matriculaId);
            $fichaId = $matRow ? (int) $matRow['ficha_id'] : 0;
            $mat     = $fichaId > 0 ? MatriculaManager::getFichaById($fichaId) : null;
        } else {
            $mat = null;
        }

        if (!$mat) {
            echo json_encode(['success' => false, 'message' => 'Ficha no encontrada']);
            break;
        }
        if (!empty($mat['user_id'])) {
            echo json_encode(['success' => false, 'message' => 'Esta ficha ya tiene un usuario vinculado']);
            break;
        }

        // Build user fields from ficha data
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

        // Email: generate a placeholder if DNI available
        $email = !empty($mat['dni']) ? $mat['dni'] . '@alumno.local' : '';

        $newUserId = UserManager::create_user(
            $firstName,
            $lastName,
            STUDENT,
            $email,
            $username,
            $password,
            (string) $fichaId,   // official_code = ficha id
            '',
            '',
            '',
            PLATFORM_AUTH_SOURCE,
            null,
            0   // inactive
        );

        if (!$newUserId || $newUserId < 0) {
            echo json_encode(['success' => false, 'message' => 'Error al crear el usuario. Verifique que el username o email no esté duplicado.']);
            break;
        }

        // Link the new user to the ficha
        Database::update(
            Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA),
            ['user_id' => $newUserId],
            ['id = ?' => $fichaId]
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

    case 'get_tarjeta_data':
        $matriculaId   = (int) ($_GET['matricula_id'] ?? 0);
        $tarjetaUserId = (int) ($_GET['user_id'] ?? 0);
        $currentUserId = api_get_user_id();
        $isSelf        = ($tarjetaUserId > 0 && $tarjetaUserId === $currentUserId);
        // Also allow if the matricula belongs to the current user
        if (!$isSelf && $matriculaId > 0) {
            $tempMat = MatriculaManager::getMatriculaById($matriculaId);
            $isSelf  = ($tempMat && (int) ($tempMat['user_id'] ?? 0) === $currentUserId);
        }
        if (!$isAdmin && !$isSecretary && !$isSelf) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos']);
            break;
        }
        $gradeName = ''; $levelName = ''; $sectionName = '';

        if ($matriculaId > 0) {
            // Alumno con ficha de matrícula
            $mat = MatriculaManager::getMatriculaById($matriculaId);
            if (!$mat) {
                echo json_encode(['success' => false, 'error' => 'Matrícula no encontrada']);
                break;
            }
            $gradeTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
            $levelTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
            $gradeId = (int) ($mat['grade_id'] ?? 0);
            if ($gradeId > 0) {
                $gRes = Database::query("SELECT g.name AS grade_name, g.section, l.name AS level_name
                    FROM $gradeTable g LEFT JOIN $levelTable l ON g.level_id = l.id
                    WHERE g.id = $gradeId LIMIT 1");
                if ($gRow = Database::fetch_array($gRes, 'ASSOC')) {
                    $gradeName   = $gRow['grade_name'];
                    $sectionName = $gRow['section'] ?? '';
                    $levelName   = $gRow['level_name'];
                }
            }
            $fotoUrl = '';
            if (!empty($mat['foto'])) {
                $fotoUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/uploads/matricula/' . $mat['foto'];
            } elseif (!empty($mat['user_id'])) {
                $uInfoCard = api_get_user_info((int) $mat['user_id']);
                $fotoUrl   = $uInfoCard['avatar'] ?? '';
            }
            $email = '';
            if (!empty($mat['user_id'])) {
                $uInfoCard = api_get_user_info((int) $mat['user_id']);
                $email     = $uInfoCard['email'] ?? '';
            }
            echo json_encode([
                'success'   => true,
                'nombres'   => trim($mat['nombres'] ?? ''),
                'apellidos' => trim(($mat['apellido_paterno'] ?? '') . ' ' . ($mat['apellido_materno'] ?? '')),
                'dni'       => $mat['dni'] ?? '',
                'grade'     => $gradeName,
                'section'   => $sectionName,
                'level'     => $levelName,
                'foto_url'  => $fotoUrl,
                'email'     => $email,
            ]);
        } elseif ($tarjetaUserId > 0) {
            // Alumno solo con cuenta Chamilo (sin ficha de matrícula)
            $uInfoCard = api_get_user_info($tarjetaUserId);
            if (!$uInfoCard) {
                echo json_encode(['success' => false, 'error' => 'Usuario no encontrado']);
                break;
            }
            $apellidos = trim($uInfoCard['lastname'] ?? '');
            $nombres   = trim($uInfoCard['firstname'] ?? '');
            echo json_encode([
                'success'   => true,
                'nombres'   => $nombres,
                'apellidos' => $apellidos,
                'dni'       => '',
                'grade'     => '',
                'section'   => '',
                'level'     => '',
                'foto_url'  => $uInfoCard['avatar'] ?? '',
                'email'     => $uInfoCard['email'] ?? '',
            ]);
        } else {
            echo json_encode(['success' => false, 'error' => 'ID inválido']);
        }
        break;

    case 'toggle_user_active':
        if (!api_is_platform_admin() && !($userInfo && $userInfo['status'] == SCHOOL_SECRETARY)) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos']);
            break;
        }
        $toggleUserId = (int) ($_POST['user_id'] ?? 0);
        $newActive    = (int) ($_POST['active'] ?? 0);
        $newActive    = $newActive ? 1 : 0;
        if ($toggleUserId <= 0) {
            echo json_encode(['success' => false, 'error' => 'ID inválido']);
            break;
        }
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        Database::update($userTable, ['active' => $newActive], ['user_id = ?' => $toggleUserId]);
        echo json_encode([
            'success' => true,
            'message' => $newActive ? 'Usuario activado.' : 'Usuario desactivado.',
        ]);
        break;

    case 'crear_alumno_nuevo':
        $apellidos = Database::escape_string(mb_convert_case(trim($_POST['apellidos'] ?? ''), MB_CASE_TITLE, 'UTF-8'));
        $nombres   = Database::escape_string(mb_convert_case(trim($_POST['nombres']   ?? ''), MB_CASE_TITLE, 'UTF-8'));
        $dni       = Database::escape_string(preg_replace('/[^0-9]/', '', trim($_POST['dni'] ?? '')));
        $active    = isset($_POST['active']) && (int) $_POST['active'] === 1 ? 1 : 0;

        if (!$apellidos || !$nombres || !$dni) {
            echo json_encode(['success' => false, 'error' => 'Apellidos, nombres y DNI son obligatorios.']);
            break;
        }

        $domain   = 'playschool.edu.pe';
        $username = $dni . '@' . $domain;
        $email    = $username;
        $password = $dni;

        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        // Check username not taken
        $chkUser = Database::query("SELECT user_id FROM $userTable WHERE username = '" . Database::escape_string($username) . "' LIMIT 1");
        if (Database::num_rows($chkUser) > 0) {
            echo json_encode(['success' => false, 'error' => 'Ya existe un usuario con el DNI ' . $dni . '.']);
            break;
        }

        $newUserId = UserManager::create_user(
            $nombres,           // firstname
            $apellidos,         // lastname
            STUDENT,            // status
            $email,
            $username,
            $password,
            $dni,               // official_code
            '',                 // language
            '',                 // phone
            '',                 // picture_uri
            'platform',         // auth_source
            '',                 // expiration_date
            $active,            // active
            0,                  // creator_id (0 = current admin)
            0,                  // hr_dept_id
            null,               // extra
            '',                 // encrypt_method
            false,              // send_mail
            false               // dry_run
        );

        if ($newUserId > 0) {
            echo json_encode([
                'success'     => true,
                'user_id'     => $newUserId,
                'form_url'    => api_get_path(WEB_PATH) . 'matricula/nueva?user_id=' . $newUserId,
                'message'     => 'Alumno creado correctamente.',
            ]);
        } else {
            echo json_encode(['success' => false, 'error' => 'No se pudo crear el usuario. Verifique los datos.']);
        }
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Acción no reconocida']);
        break;
}
