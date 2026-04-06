<?php
require_once __DIR__ . '/../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

header('Content-Type: application/json');

$isAdmin      = api_is_platform_admin();
$currentUserId = api_get_user_id();

$action = $_POST['action'] ?? $_GET['action'] ?? '';

switch ($action) {

    case 'get_staff_card_data':
        $staffUserId = (int) ($_GET['user_id'] ?? 0);
        if ($staffUserId <= 0) {
            echo json_encode(['success' => false, 'error' => 'ID inválido']);
            break;
        }
        // Allow admin OR the user requesting their own card
        if (!$isAdmin && $staffUserId !== $currentUserId) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos']);
            break;
        }

        $uInfo = api_get_user_info($staffUserId);
        if (!$uInfo) {
            echo json_encode(['success' => false, 'error' => 'Usuario no encontrado']);
            break;
        }

        $userTable  = Database::get_main_table(TABLE_MAIN_USER);
        $adminTable = Database::get_main_table(TABLE_MAIN_ADMIN);

        $uRow = Database::fetch_array(
            Database::query("SELECT u.status, adm.user_id AS is_admin
                FROM $userTable u
                LEFT JOIN $adminTable adm ON adm.user_id = u.user_id
                WHERE u.user_id = $staffUserId LIMIT 1"),
            'ASSOC'
        );

        // Determine cargo label
        $cargo = '';
        if (!empty($uRow['is_admin'])) {
            $cargo = 'Administrador';
        } elseif ((int)($uRow['status'] ?? 0) === COURSEMANAGER) {
            $cargo = 'Docente';
        } elseif ((int)($uRow['status'] ?? 0) === DRH) {
            $cargo = 'Administrativo';
        } elseif ((int)($uRow['status'] ?? 0) === SCHOOL_SECRETARY) {
            $cargo = 'Secretaria';
        } elseif ((int)($uRow['status'] ?? 0) === SCHOOL_AUXILIARY) {
            $cargo = 'Auxiliar';
        } elseif ((int)($uRow['status'] ?? 0) === SCHOOL_PARENT) {
            $cargo = 'Padre de familia';
        } elseif ((int)($uRow['status'] ?? 0) === SCHOOL_GUARDIAN) {
            $cargo = 'Apoderado';
        }

        // Nivel: solo para docentes — primero desde ficha, si no desde aulas asignadas
        $nivel = '';
        if ((int)($uRow['status'] ?? 0) === COURSEMANAGER && empty($uRow['is_admin'])) {
            // Fuente 1: niveles_docente guardados en la ficha
            $extraProfile = $plugin->getExtraProfileData($staffUserId);
            $nivelesRaw   = trim($extraProfile['niveles_docente'] ?? '');
            if ($nivelesRaw !== '') {
                $labels = [
                    'inicial'    => 'Inicial',
                    'primaria'   => 'Primaria',
                    'secundaria' => 'Secundaria',
                ];
                $partes = array_filter(array_map('trim', explode(',', $nivelesRaw)));
                $nivel  = implode(', ', array_map(fn($v) => $labels[$v] ?? ucfirst($v), $partes));
            }

            // Fuente 2: aulas asignadas (si la ficha no tiene niveles)
            if ($nivel === '') {
                $levelTable     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
                $gradeTable     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
                $classroomTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);

                $lvlRes = Database::query(
                    "SELECT GROUP_CONCAT(DISTINCT l.name ORDER BY l.order_index SEPARATOR ', ') AS niveles
                     FROM $levelTable l
                     INNER JOIN $gradeTable g ON l.id = g.level_id
                     INNER JOIN $classroomTable c ON g.id = c.grade_id
                     WHERE c.tutor_id = $staffUserId"
                );
                $lvlRow = Database::fetch_array($lvlRes, 'ASSOC');
                $nivel  = $lvlRow['niveles'] ?? '';
            }
        }

        echo json_encode([
            'success'   => true,
            'nombres'   => trim($uInfo['firstname'] ?? ''),
            'apellidos' => trim($uInfo['lastname'] ?? ''),
            'cargo'     => $cargo,
            'nivel'     => $nivel,
            'foto_url'  => $uInfo['avatar'] ?? '',
            'email'     => $uInfo['email'] ?? '',
        ]);
        break;

    case 'get_login_history':
        $targetUserId = (int) ($_POST['user_id'] ?? 0);
        if ($targetUserId <= 0) {
            echo json_encode(['success' => false, 'error' => 'ID inválido']);
            break;
        }

        // Only admin or teacher (tutor) can view — teacher can only view students from their classroom
        $isTeacher = (int) api_get_user_info($currentUserId)['status'] === COURSEMANAGER;
        if (!$isAdmin && !$isTeacher) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos']);
            break;
        }

        $loginTable = Database::get_main_table(TABLE_STATISTIC_TRACK_E_LOGIN);
        $result = Database::query(
            "SELECT login_date, logout_date, user_ip
             FROM $loginTable
             WHERE login_user_id = $targetUserId
             ORDER BY login_date DESC
             LIMIT 30"
        );

        $records = [];
        while ($row = Database::fetch_assoc($result)) {
            $records[] = [
                'login_date'  => !empty($row['login_date'])  ? api_get_local_time($row['login_date'])  : null,
                'logout_date' => !empty($row['logout_date']) ? api_get_local_time($row['logout_date']) : null,
                'user_ip'     => $row['user_ip'] ?? '',
            ];
        }

        echo json_encode(['success' => true, 'records' => $records]);
        break;

    default:
        echo json_encode(['success' => false, 'error' => 'Acción no reconocida']);
        break;
}
