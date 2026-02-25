<?php

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../src/ClassroomPlanManager.php';
require_once __DIR__ . '/../src/AcademicManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

header('Content-Type: application/json');

$userId   = api_get_user_id();
$userInfo = api_get_user_info($userId);
$isAdmin  = api_is_platform_admin();
$isSecretary = $userInfo && (int) $userInfo['status'] === SCHOOL_SECRETARY;
$isTeacher   = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;

if (!$userId) {
    echo json_encode(['success' => false, 'message' => 'Not authenticated']);
    exit;
}

$action = $_REQUEST['action'] ?? '';

switch ($action) {

    // -------------------------------------------------------------------------
    // GET: fetch single entry (for edit modal)
    // -------------------------------------------------------------------------
    case 'get_plan':
        $id   = (int) ($_GET['id'] ?? 0);
        $plan = ClassroomPlanManager::getPlanById($id);
        if (!$plan) {
            echo json_encode(['success' => false, 'message' => 'Not found']);
            break;
        }
        echo json_encode(['success' => true, 'plan' => $plan]);
        break;

    // -------------------------------------------------------------------------
    // POST: create or update entry
    // -------------------------------------------------------------------------
    case 'save_plan':
        if (!$isAdmin && !$isSecretary && !$isTeacher) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            break;
        }

        $planId      = (int) ($_POST['id'] ?? 0);
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $planDate    = $_POST['plan_date'] ?? '';
        $subject     = trim($_POST['subject'] ?? '');
        $topic       = trim($_POST['topic'] ?? '');
        $notes       = trim($_POST['notes'] ?? '');

        if (!$classroomId || !$planDate || !$subject || !$topic) {
            echo json_encode(['success' => false, 'message' => 'Faltan datos requeridos']);
            break;
        }

        // Validate date format
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $planDate)) {
            echo json_encode(['success' => false, 'message' => 'Fecha inválida']);
            break;
        }

        // If editing, verify ownership or admin/tutor rights
        if ($planId > 0 && !$isAdmin && !$isSecretary) {
            $existing = ClassroomPlanManager::getPlanById($planId);
            if (!$existing) {
                echo json_encode(['success' => false, 'message' => 'Entrada no encontrada']);
                break;
            }
            // Check if user is tutor of this classroom
            $activeYear = \MatriculaManager::getActiveYear();
            $yearId     = $activeYear ? (int) $activeYear['id'] : 0;
            $tutorClassroom = ClassroomPlanManager::getTutorClassroom($userId, $yearId);
            $isTutor = $tutorClassroom && (int) $tutorClassroom['id'] === $classroomId;

            if (!$isTutor && (int) $existing['teacher_id'] !== $userId) {
                echo json_encode(['success' => false, 'message' => 'Solo puedes editar tus propias entradas']);
                break;
            }
        }

        $savedId = ClassroomPlanManager::savePlan([
            'id'           => $planId,
            'classroom_id' => $classroomId,
            'plan_date'    => $planDate,
            'subject'      => $subject,
            'topic'        => $topic,
            'notes'        => $notes ?: null,
            'teacher_id'   => $userId,
        ]);

        echo json_encode(['success' => $savedId > 0, 'id' => $savedId]);
        break;

    // -------------------------------------------------------------------------
    // POST: delete entry
    // -------------------------------------------------------------------------
    case 'delete_plan':
        if (!$isAdmin && !$isSecretary && !$isTeacher) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            break;
        }

        $planId = (int) ($_POST['id'] ?? 0);
        if (!$planId) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            break;
        }

        // Determine if user is tutor of the classroom this plan belongs to
        $plan = ClassroomPlanManager::getPlanById($planId);
        if (!$plan) {
            echo json_encode(['success' => false, 'message' => 'Entrada no encontrada']);
            break;
        }

        $isTutorOrAdmin = $isAdmin || $isSecretary;
        if (!$isTutorOrAdmin) {
            $activeYear = \MatriculaManager::getActiveYear();
            $yearId     = $activeYear ? (int) $activeYear['id'] : 0;
            $tutorClassroom = ClassroomPlanManager::getTutorClassroom($userId, $yearId);
            $isTutorOrAdmin = $tutorClassroom && (int) $tutorClassroom['id'] === (int) $plan['classroom_id'];
        }

        $result = ClassroomPlanManager::deletePlan($planId, $userId, $isTutorOrAdmin);
        echo json_encode(['success' => $result, 'message' => $result ? '' : 'Sin permisos para eliminar']);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Acción no reconocida']);
        break;
}
