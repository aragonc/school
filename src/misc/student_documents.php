<?php
/* For licensing terms, see /license.txt */

/**
 * Student Documents View - School Plugin
 * Optimized view for students to browse and download course documents
 *
 * @package chamilo.plugin.school
 * @author Alex
 */

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../lib/DocumentHelper.php';

$plugin = SchoolPlugin::create();
$plugin->setCurrentSection('dashboard');
$plugin->setSidebar('dashboard');
// Verificar acceso
api_protect_course_script(true);
api_protect_course_group(GroupManager::GROUP_TOOL_DOCUMENTS);

// Inicializar variables
$courseInfo = api_get_course_info();
$courseId = $courseInfo['real_id'];
$sessionId = api_get_session_id();
$userId = api_get_user_id();
$groupId = api_get_group_id();

// Verificar si es estudiante
$isStudent = !api_is_allowed_to_edit(null, true);

if (!$isStudent) {
    // Redirigir a profesores a la vista estándar
    header('Location: ' . api_get_path(WEB_CODE_PATH) . 'document/document.php?' . api_get_cidreq());
    exit;
}

// Configuración
$current_course_tool = TOOL_DOCUMENT;
$this_section = SECTION_COURSES;
$base_work_dir = api_get_path(SYS_COURSE_PATH) . $courseInfo['directory'] . '/document';
$http_www = api_get_path(WEB_COURSE_PATH) . $courseInfo['directory'] . '/document';

// URL base amigable para el plugin
$useRewriteUrl = api_get_configuration_value('use_friendly_document_urls');
if ($useRewriteUrl) {
    $baseUrl = api_get_path(WEB_PATH) . 'documents';
} else {
    $baseUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/src/misc/student_documents.php';
}
$currentUrlParams = api_get_cidreq();

// Obtener parámetros
$documentId = isset($_REQUEST['id']) ? (int) $_REQUEST['id'] : null;
$curdirpath = isset($_GET['curdirpath']) ? Security::remove_XSS($_GET['curdirpath']) : '/';
$action = isset($_REQUEST['action']) ? $_REQUEST['action'] : '';
$keyword = isset($_GET['keyword']) ? Security::remove_XSS($_GET['keyword']) : '';

// Manejar descarga de archivo
if ($action === 'download' && !empty($documentId)) {
    DocumentHelper::handleDownload($documentId, $courseInfo, $sessionId, $userId, $base_work_dir);
    exit;
}

// Manejar descarga de carpeta
if ($action === 'downloadfolder' && !empty($documentId)) {
    if (api_get_setting('students_download_folders') == 'true') {
        DocumentHelper::handleFolderDownload($documentId, $courseInfo, $sessionId, $userId);
        exit;
    }
}

// Obtener información del documento actual
$currentDocument = null;
$parentId = null;

if ($documentId) {
    $currentDocument = DocumentManager::get_document_data_by_id(
        $documentId,
        $courseInfo['code'],
        true,
        $sessionId
    );

    if ($currentDocument) {
        $parentId = $currentDocument['parent_id'];
        $curdirpath = $currentDocument['path'];
    }
}

// Si no hay documento, obtener ID desde el path
if (!$documentId && $curdirpath) {
    $documentId = DocumentManager::get_document_id($courseInfo, $curdirpath, $sessionId);
    if (!$documentId) {
        $documentId = DocumentManager::get_document_id($courseInfo, $curdirpath, 0);
    }
}

// Verificar visibilidad
$visibility = DocumentManager::check_visibility_tree(
    $documentId,
    $courseInfo,
    $sessionId,
    $userId,
    $groupId
);

if (!$visibility && $curdirpath != '/') {
    api_not_allowed(true);
}

// Obtener documentos y carpetas
$documentsData = DocumentHelper::getStudentDocuments(
    $courseInfo,
    $curdirpath,
    $groupId,
    $sessionId,
    $userId,
    $keyword
);

// Obtener breadcrumb
$breadcrumb = DocumentHelper::getBreadcrumb($currentDocument, $documentId, $groupId);

// Preparar datos para la vista
$templateData = [
    'course_info' => $courseInfo,
    'session_id' => $sessionId,
    'user_id' => $userId,
    'group_id' => $groupId,
    'current_path' => $curdirpath,
    'current_document_id' => $documentId,
    'parent_id' => $parentId,
    'breadcrumb' => $breadcrumb,
    'documents' => $documentsData['documents'],
    'can_download_folders' => api_get_setting('students_download_folders') == 'true',
    'keyword' => $keyword,
    'base_url' => $baseUrl . '?' . $currentUrlParams,
    'has_search' => !empty($keyword),
];

// Registrar acceso
Event::event_access_tool(TOOL_DOCUMENT);

// Agregar breadcrumb
$interbreadcrumb[] = [
    'url' => api_get_path(WEB_CODE_PATH) . 'document/document.php?' . api_get_cidreq(),
    'name' => $plugin->get_lang('ComplementaryMaterial'),
];

// Renderizar vista
$plugin->setTitle($plugin->get_lang('ComplementaryMaterial'));
$plugin->assign('data', $templateData);
$content = $plugin->fetch('misc/student_documents.tpl');

// Mostrar página
$plugin->assign('header', get_lang('Documents'));
$plugin->assign('content', $content);
$plugin->display_blank_template();
