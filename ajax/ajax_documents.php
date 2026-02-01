<?php
/* For licensing terms, see /license.txt */

/**
 * AJAX Helper for Student Documents
 * Handles asynchronous operations for the student document view
 *
 * @package chamilo.plugin.school
 * @author Alex
 */

require_once __DIR__ . '/../config.php';

$action = $_REQUEST['a'] ?? '';

switch ($action) {
    case 'get_folder_size':
        getFolderSize();
        break;

    case 'check_document_visibility':
        checkDocumentVisibility();
        break;

    case 'get_document_preview':
        getDocumentPreview();
        break;

    default:
        echo json_encode(['error' => 'Invalid action']);
        break;
}

/**
 * Obtener tamaño de una carpeta
 */
function getFolderSize()
{
    $path = isset($_REQUEST['path']) ? Security::remove_XSS($_REQUEST['path']) : '';
    $courseInfo = api_get_course_info();

    if (empty($path) || empty($courseInfo)) {
        echo '-';
        return;
    }

    $baseWorkDir = api_get_path(SYS_COURSE_PATH) . $courseInfo['directory'] . '/document';
    $fullPath = $baseWorkDir . $path;

    if (!is_dir($fullPath)) {
        echo '-';
        return;
    }

    $size = 0;
    try {
        $iterator = new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($fullPath, RecursiveDirectoryIterator::SKIP_DOTS),
            RecursiveIteratorIterator::SELF_FIRST
        );

        foreach ($iterator as $file) {
            if ($file->isFile()) {
                $size += $file->getSize();
            }
        }
    } catch (Exception $e) {
        echo '-';
        return;
    }

    echo format_file_size($size);
}

/**
 * Verificar visibilidad de un documento
 */
function checkDocumentVisibility()
{
    $documentId = isset($_REQUEST['id']) ? (int) $_REQUEST['id'] : 0;
    $courseInfo = api_get_course_info();
    $sessionId = api_get_session_id();
    $userId = api_get_user_id();

    if (empty($documentId) || empty($courseInfo)) {
        echo json_encode(['visible' => false]);
        return;
    }

    $isVisible = DocumentManager::is_visible_by_id(
        $documentId,
        $courseInfo,
        $sessionId,
        $userId
    );

    echo json_encode(['visible' => $isVisible]);
}

/**
 * Obtener preview de documento (para implementación futura)
 */
function getDocumentPreview()
{
    $documentId = isset($_REQUEST['id']) ? (int) $_REQUEST['id'] : 0;
    $courseInfo = api_get_course_info();
    $sessionId = api_get_session_id();
    $userId = api_get_user_id();

    if (empty($documentId) || empty($courseInfo)) {
        echo json_encode(['error' => 'Invalid parameters']);
        return;
    }

    // Verificar permisos
    if (!DocumentManager::is_visible_by_id($documentId, $courseInfo, $sessionId, $userId)) {
        echo json_encode(['error' => 'Access denied']);
        return;
    }

    // Obtener datos del documento
    $documentData = DocumentManager::get_document_data_by_id(
        $documentId,
        $courseInfo['code'],
        false,
        $sessionId
    );

    if (empty($documentData)) {
        echo json_encode(['error' => 'Document not found']);
        return;
    }

    // Preparar preview según tipo
    $extension = strtolower(pathinfo($documentData['path'], PATHINFO_EXTENSION));
    $previewData = [
        'id' => $documentData['id'],
        'title' => $documentData['title'],
        'type' => $extension,
        'url' => api_get_path(WEB_COURSE_PATH) . $courseInfo['path'] . '/document' . $documentData['path'],
    ];

    // Agregar preview específico por tipo
    if (in_array($extension, ['jpg', 'jpeg', 'png', 'gif'])) {
        $previewData['preview_type'] = 'image';
    } elseif (in_array($extension, ['mp4', 'webm', 'ogg'])) {
        $previewData['preview_type'] = 'video';
    } elseif (in_array($extension, ['mp3', 'wav', 'ogg'])) {
        $previewData['preview_type'] = 'audio';
    } elseif ($extension === 'pdf') {
        $previewData['preview_type'] = 'pdf';
    } else {
        $previewData['preview_type'] = 'download';
    }

    echo json_encode($previewData);
}
