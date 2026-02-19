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

    default:
        echo json_encode(['success' => false, 'message' => 'Acción no reconocida']);
        break;
}
