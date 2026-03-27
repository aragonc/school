<?php

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../src/SupportManager.php';

$plugin = SchoolPlugin::create();

if (!api_get_user_id()) {
    echo json_encode(['success' => false, 'message' => 'No autenticado']);
    exit;
}

header('Content-Type: application/json');

$action  = isset($_REQUEST['action']) ? $_REQUEST['action'] : '';
$isAdmin = api_is_platform_admin();
$userId  = (int) api_get_user_id();

switch ($action) {

    // ------------------------------------------------------------------
    // Crear nuevo ticket (cualquier usuario)
    // ------------------------------------------------------------------
    case 'create_ticket':
        $subject  = trim($_POST['subject']  ?? '');
        $category = trim($_POST['category'] ?? 'general');
        $priority = trim($_POST['priority'] ?? 'medium');
        $body     = Security::remove_XSS(trim($_POST['body'] ?? ''));

        if ($subject === '' || $body === '') {
            echo json_encode(['success' => false, 'message' => 'Asunto y mensaje son obligatorios.']);
            exit;
        }

        // Procesar imagen adjunta (opcional)
        if (!empty($_FILES['attachment']['tmp_name'])) {
            $file    = $_FILES['attachment'];
            $allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
            $finfo   = finfo_open(FILEINFO_MIME_TYPE);
            $mime    = finfo_file($finfo, $file['tmp_name']);
            finfo_close($finfo);

            if (!in_array($mime, $allowed)) {
                echo json_encode(['success' => false, 'message' => 'Tipo de archivo no permitido.']);
                exit;
            }
            if ($file['size'] > 5 * 1024 * 1024) {
                echo json_encode(['success' => false, 'message' => 'La imagen supera el límite de 5 MB.']);
                exit;
            }

            $ext      = pathinfo($file['name'], PATHINFO_EXTENSION) ?: 'jpg';
            $filename = 'support_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
            $uploadDir = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/support/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0755, true);
            }
            if (move_uploaded_file($file['tmp_name'], $uploadDir . $filename)) {
                $imgUrl = api_get_path(WEB_UPLOAD_PATH) . 'plugins/school/support/' . $filename;
                $body  .= '<p><img src="' . htmlspecialchars($imgUrl) . '" style="max-width:100%;border-radius:6px;" alt="adjunto"></p>';
            }
        }

        $ticketId = SupportManager::createTicket([
            'subject'  => $subject,
            'category' => $category,
            'priority' => $priority,
        ]);

        if ($ticketId > 0) {
            SupportManager::addMessage($ticketId, $body);
            echo json_encode(['success' => true, 'ticket_id' => $ticketId]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Error al crear el ticket.']);
        }
        break;

    // ------------------------------------------------------------------
    // Agregar mensaje a un ticket existente
    // ------------------------------------------------------------------
    case 'add_message':
        $ticketId   = (int) ($_POST['ticket_id'] ?? 0);
        $body       = Security::remove_XSS(trim($_POST['body'] ?? ''));
        $isInternal = $isAdmin && !empty($_POST['is_internal']);

        if ($ticketId <= 0 || $body === '') {
            echo json_encode(['success' => false, 'message' => 'Datos incompletos.']);
            exit;
        }

        $ticket = SupportManager::getTicketById($ticketId);
        if (!$ticket || !SupportManager::canAccess($ticket, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'message' => 'Acceso denegado.']);
            exit;
        }

        $msgId = SupportManager::addMessage($ticketId, $body, $isInternal);
        echo json_encode(['success' => $msgId > 0]);
        break;

    // ------------------------------------------------------------------
    // Obtener lista de admins para selector (solo admin)
    // ------------------------------------------------------------------
    case 'get_admins':
        if (!$isAdmin) { echo json_encode(['success' => false]); exit; }
        echo json_encode(['success' => true, 'admins' => SupportManager::getPlatformAdmins()]);
        break;

    // ------------------------------------------------------------------
    // Asignar admin a ticket
    // ------------------------------------------------------------------
    case 'add_assignee':
        if (!$isAdmin) { echo json_encode(['success' => false, 'message' => 'Sin permisos.']); exit; }
        $ticketId  = (int) ($_POST['ticket_id']  ?? 0);
        $assigneeId = (int) ($_POST['assignee_id'] ?? 0);
        $ticket = SupportManager::getTicketById($ticketId);
        if (!$ticket) { echo json_encode(['success' => false, 'message' => 'Ticket no encontrado.']); exit; }
        $ok = SupportManager::addAssignee($ticketId, $assigneeId);
        echo json_encode(['success' => $ok]);
        break;

    // ------------------------------------------------------------------
    // Quitar admin de ticket
    // ------------------------------------------------------------------
    case 'remove_assignee':
        if (!$isAdmin) { echo json_encode(['success' => false, 'message' => 'Sin permisos.']); exit; }
        $ticketId   = (int) ($_POST['ticket_id']   ?? 0);
        $assigneeId = (int) ($_POST['assignee_id'] ?? 0);
        $ok = SupportManager::removeAssignee($ticketId, $assigneeId);
        echo json_encode(['success' => $ok]);
        break;

    // ------------------------------------------------------------------
    // Cambiar estado (solo admin)
    // ------------------------------------------------------------------
    case 'change_status':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos.']);
            exit;
        }

        $ticketId   = (int) ($_POST['ticket_id'] ?? 0);
        $status     = trim($_POST['status'] ?? '');
        $assignedTo = isset($_POST['assigned_to']) ? (int) $_POST['assigned_to'] : null;

        $allowed = ['open', 'in_progress', 'resolved', 'closed'];
        if ($ticketId <= 0 || !in_array($status, $allowed)) {
            echo json_encode(['success' => false, 'message' => 'Datos inválidos.']);
            exit;
        }

        $ok = SupportManager::updateTicketStatus($ticketId, $status, $assignedTo);
        echo json_encode(['success' => $ok]);
        break;

    // ------------------------------------------------------------------
    // Eliminar ticket (solo admin)
    // ------------------------------------------------------------------
    case 'delete_ticket':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos.']);
            exit;
        }
        $ticketId = (int) ($_POST['ticket_id'] ?? 0);
        if ($ticketId <= 0) {
            echo json_encode(['success' => false, 'message' => 'ID inválido.']);
            exit;
        }
        echo json_encode(['success' => SupportManager::deleteTicket($ticketId)]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Acción desconocida.']);
}
