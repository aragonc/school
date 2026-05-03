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

        // Admin/tutor can assign a specific teacher (from the course schedule);
        // regular teachers always save as themselves.
        $postTeacherId = (int) ($_POST['teacher_id'] ?? 0);
        $effectiveTeacherId = ($isAdmin || $isSecretary) && $postTeacherId > 0
            ? $postTeacherId
            : ($postTeacherId > 0 ? $postTeacherId : $userId);

        $savedId = ClassroomPlanManager::savePlan([
            'id'           => $planId,
            'classroom_id' => $classroomId,
            'plan_date'    => $planDate,
            'subject'      => $subject,
            'topic'        => $topic,
            'notes'        => $notes ?: null,
            'teacher_id'   => $effectiveTeacherId,
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

    // -------------------------------------------------------------------------
    // POST: save cropped image for a calendar day
    // -------------------------------------------------------------------------
    case 'save_day_image':
        if (!$isAdmin && !$isSecretary && !$isTeacher) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            break;
        }

        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $dayDate     = trim($_POST['day_date'] ?? '');

        if (!$classroomId || !$dayDate) {
            echo json_encode(['success' => false, 'message' => 'Faltan datos']);
            break;
        }

        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $dayDate)) {
            echo json_encode(['success' => false, 'message' => 'Fecha inválida']);
            break;
        }

        if (empty($_FILES['file']['tmp_name'])) {
            echo json_encode(['success' => false, 'message' => 'No se recibió ningún archivo']);
            break;
        }

        $tmpFile = $_FILES['file']['tmp_name'];
        if (!is_uploaded_file($tmpFile)) {
            echo json_encode(['success' => false, 'message' => 'Archivo inválido']);
            break;
        }

        $uploadDir = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/day_images/';
        $filename  = 'day_' . $classroomId . '_' . $dayDate . '.jpg';
        $filepath  = $uploadDir . $filename;

        if (!move_uploaded_file($tmpFile, $filepath)) {
            echo json_encode(['success' => false, 'message' => 'Error al guardar imagen']);
            break;
        }

        $webUrl = api_get_path(WEB_UPLOAD_PATH) . 'plugins/school/day_images/' . $filename . '?t=' . time();
        echo json_encode(['success' => true, 'url' => $webUrl]);
        break;

    // -------------------------------------------------------------------------
    // POST: delete image for a calendar day
    // -------------------------------------------------------------------------
    case 'delete_day_image':
        if (!$isAdmin && !$isSecretary && !$isTeacher) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            break;
        }

        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $dayDate     = trim($_POST['day_date'] ?? '');

        if (!$classroomId || !$dayDate) {
            echo json_encode(['success' => false, 'message' => 'Faltan datos']);
            break;
        }

        $uploadDir = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/day_images/';
        $filename  = 'day_' . $classroomId . '_' . $dayDate . '.jpg';
        $filepath  = $uploadDir . $filename;

        if (file_exists($filepath)) {
            unlink($filepath);
        }
        echo json_encode(['success' => true]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Acción no reconocida']);
        break;
}
