<?php
require_once __DIR__ . '/../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

header('Content-Type: application/json');

$isAdmin = api_is_platform_admin();
if (!$isAdmin) {
    echo json_encode(['success' => false, 'error' => 'Sin permisos']);
    exit;
}

$action = $_POST['action'] ?? $_GET['action'] ?? '';

switch ($action) {

    case 'get_staff_card_data':
        $staffUserId = (int) ($_GET['user_id'] ?? 0);
        if ($staffUserId <= 0) {
            echo json_encode(['success' => false, 'error' => 'ID inválido']);
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

        // Nivel: only for teachers (COURSEMANAGER) via classrooms
        $nivel = '';
        if ((int)($uRow['status'] ?? 0) === COURSEMANAGER && empty($uRow['is_admin'])) {
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

    default:
        echo json_encode(['success' => false, 'error' => 'Acción no reconocida']);
        break;
}
