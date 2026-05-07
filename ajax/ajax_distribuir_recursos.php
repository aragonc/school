<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../src/AcademicManager.php';
require_once __DIR__ . '/../src/MatriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

header('Content-Type: application/json');

$userId   = api_get_user_id();
$userInfo = api_get_user_info($userId);
$isAdmin  = api_is_platform_admin();
$isTeacher = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;

if (!$userId || (!$isAdmin && !$isTeacher)) {
    echo json_encode(['success' => false, 'error' => 'Sin permisos']);
    exit;
}

$resTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_RESOURCE);
$distTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_RESOURCE_DIST);

$action = $_REQUEST['action'] ?? '';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Returns true if the user is admin or tutor/supervisor of the classroom.
 */
function isTutorOfClassroom(int $classroomId, int $userId, bool $isAdmin): bool
{
    if ($isAdmin) return true;
    if ($classroomId <= 0 || $userId <= 0) return false;
    $cTable     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
    $activeYear = MatriculaManager::getActiveYear();
    $yearId     = $activeYear ? (int) $activeYear['id'] : 0;
    if ($yearId === 0) return false;
    $row = Database::fetch_array(
        Database::query("SELECT id FROM $cTable
                         WHERE id = $classroomId
                           AND academic_year_id = $yearId
                           AND (tutor_id = $userId OR supervisor_id = $userId)
                         LIMIT 1"),
        'ASSOC'
    );
    return !empty($row);
}

/**
 * Upload: only admin or tutor of the classroom.
 */
function canUploadToClassroom(int $classroomId, int $userId, bool $isAdmin): bool
{
    return isTutorOfClassroom($classroomId, $userId, $isAdmin);
}

/**
 * Distribute/create-folder: admin and tutor can use any course;
 * a plain docente can only use courses they are personally assigned to.
 */
function canDistributeToCourse(int $classroomId, string $courseCode, int $userId, bool $isAdmin): bool
{
    if (isTutorOfClassroom($classroomId, $userId, $isAdmin)) return true;
    if ($classroomId <= 0 || $userId <= 0 || empty($courseCode)) return false;

    $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
    $ctTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
    $cTable  = Database::get_main_table(TABLE_MAIN_COURSE);

    $code = Database::escape_string($courseCode);
    $row  = Database::fetch_array(
        Database::query("SELECT cc.id
                         FROM $ccTable cc
                         INNER JOIN $ctTable ct ON ct.classroom_course_id = cc.id
                         INNER JOIN $cTable c ON c.id = cc.course_id
                         WHERE cc.classroom_id = $classroomId
                           AND c.code = '$code'
                           AND ct.teacher_id = $userId
                         LIMIT 1"),
        'ASSOC'
    );
    return !empty($row);
}

/** Legacy alias — any access to this classroom (tutor or assigned teacher). */
function canEditClassroomRes(int $classroomId, int $userId, bool $isAdmin): bool
{
    if (isTutorOfClassroom($classroomId, $userId, $isAdmin)) return true;
    if ($classroomId <= 0 || $userId <= 0) return false;
    $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
    $ctTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
    $row = Database::fetch_array(
        Database::query("SELECT cc.id FROM $ccTable cc
                         INNER JOIN $ctTable ct ON ct.classroom_course_id = cc.id
                         WHERE cc.classroom_id = $classroomId AND ct.teacher_id = $userId
                         LIMIT 1"),
        'ASSOC'
    );
    return !empty($row);
}

function formatFileSizeAjax(int $bytes): string
{
    if ($bytes >= 1048576) return round($bytes / 1048576, 1) . ' MB';
    if ($bytes >= 1024)    return round($bytes / 1024, 1)    . ' KB';
    return $bytes . ' B';
}

// Allowed MIME types
$allowedMimes = [
    // Images
    'image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml',
    // Documents
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    // Audio
    'audio/mpeg', 'audio/mp3', 'audio/ogg', 'audio/wav', 'audio/x-wav',
    // Video
    'video/mp4', 'video/mpeg', 'video/quicktime', 'video/x-msvideo', 'video/webm',
];

// ---------------------------------------------------------------------------
switch ($action) {

    // -----------------------------------------------------------------------
    case 'rename_resource':
        $resourceId  = isset($_POST['resource_id'])  ? (int) $_POST['resource_id']  : 0;
        $classroomId = isset($_POST['classroom_id']) ? (int) $_POST['classroom_id'] : 0;
        $newTitle    = isset($_POST['title'])         ? trim($_POST['title'])         : '';

        if ($resourceId <= 0 || empty($newTitle)) {
            echo json_encode(['success' => false, 'error' => 'Datos incompletos']);
            exit;
        }
        if (!canEditClassroomRes($classroomId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos en esta aula']);
            exit;
        }

        $row = Database::fetch_array(
            Database::query("SELECT id, uploaded_by FROM $resTable WHERE id = $resourceId AND classroom_id = $classroomId LIMIT 1"),
            'ASSOC'
        );
        if (!$row) {
            echo json_encode(['success' => false, 'error' => 'Recurso no encontrado']);
            exit;
        }
        if (!isTutorOfClassroom($classroomId, $userId, $isAdmin) && (int)$row['uploaded_by'] !== $userId) {
            echo json_encode(['success' => false, 'error' => 'Solo puedes renombrar tus propios archivos']);
            exit;
        }

        // Re-fetch full row to get stored_name
        $row = Database::fetch_array(
            Database::query("SELECT * FROM $resTable WHERE id = $resourceId LIMIT 1"),
            'ASSOC'
        );

        $uploadDir   = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/recursos/';
        $srcFile     = $uploadDir . $row['stored_name'];
        $origExt     = strtolower(pathinfo($row['stored_name'], PATHINFO_EXTENSION));

        // Sanitize the new name: spaces → underscore, keep the original extension
        $newBase     = preg_replace('/[^\w\-\.áéíóúÁÉÍÓÚñÑüÜ ]/u', '_', $newTitle);
        $newBase     = str_replace(' ', '_', trim($newBase));
        $newBase     = preg_replace('/_+/', '_', $newBase); // collapse multiple underscores
        $newFilename = $newBase . ($origExt ? '.' . $origExt : '');

        // Resolve collision in the upload directory
        $newStoredName = $newFilename;
        $destFile      = $uploadDir . $newStoredName;
        $counter       = 1;
        while (file_exists($destFile) && realpath($destFile) !== realpath($srcFile)) {
            $newStoredName = $newBase . '_' . $counter . ($origExt ? '.' . $origExt : '');
            $destFile      = $uploadDir . $newStoredName;
            $counter++;
        }

        // Rename physical file (only if name actually changes)
        if (realpath($srcFile) !== realpath($destFile)) {
            if (!is_file($srcFile) || !rename($srcFile, $destFile)) {
                echo json_encode(['success' => false, 'error' => 'No se pudo renombrar el archivo en el servidor']);
                exit;
            }
        }

        $safeTitle      = Database::escape_string($newTitle);
        $safeFilename   = Database::escape_string($newFilename);
        $safeStoredName = Database::escape_string($newStoredName);
        Database::query("UPDATE $resTable SET title = '$safeTitle', filename = '$safeFilename', stored_name = '$safeStoredName' WHERE id = $resourceId");

        echo json_encode([
            'success'     => true,
            'title'       => $newTitle,
            'filename'    => $newFilename,
            'stored_name' => $newStoredName,
            'web_url'     => api_get_path(WEB_UPLOAD_PATH) . 'plugins/school/recursos/' . urlencode($newStoredName),
        ]);
        break;

    // -----------------------------------------------------------------------
    case 'upload_resource':
        $classroomId = isset($_POST['classroom_id']) ? (int) $_POST['classroom_id'] : 0;
        if ($classroomId <= 0 || !canEditClassroomRes($classroomId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos para subir archivos en esta aula']);
            exit;
        }

        if (empty($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
            $err = $_FILES['file']['error'] ?? 'desconocido';
            echo json_encode(['success' => false, 'error' => "Error en la subida ($err)"]);
            exit;
        }

        $file     = $_FILES['file'];
        $origName = basename($file['name']);
        $mimeType = mime_content_type($file['tmp_name']);

        if (!in_array($mimeType, $allowedMimes)) {
            echo json_encode(['success' => false, 'error' => "Tipo de archivo no permitido: $mimeType"]);
            exit;
        }

        $maxSize = 100 * 1024 * 1024; // 100 MB
        if ($file['size'] > $maxSize) {
            echo json_encode(['success' => false, 'error' => 'El archivo supera el límite de 100 MB']);
            exit;
        }

        // Build upload directory
        $uploadDir = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/recursos/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }

        // Unique stored filename
        $ext        = strtolower(pathinfo($origName, PATHINFO_EXTENSION));
        $storedName = 'res_' . $classroomId . '_' . uniqid() . ($ext ? '.' . $ext : '');
        $destPath   = $uploadDir . $storedName;

        if (!move_uploaded_file($file['tmp_name'], $destPath)) {
            echo json_encode(['success' => false, 'error' => 'No se pudo guardar el archivo']);
            exit;
        }

        // Classify file type
        $fileType = 'file';
        if (str_starts_with($mimeType, 'image/'))      $fileType = 'image';
        elseif ($mimeType === 'application/pdf')       $fileType = 'pdf';
        elseif (str_contains($mimeType, 'word'))       $fileType = 'word';
        elseif (str_contains($mimeType, 'powerpoint') || str_contains($mimeType, 'presentation')) $fileType = 'ppt';
        elseif (str_contains($mimeType, 'excel') || str_contains($mimeType, 'spreadsheet'))       $fileType = 'excel';
        elseif (str_starts_with($mimeType, 'audio/'))  $fileType = 'audio';
        elseif (str_starts_with($mimeType, 'video/'))  $fileType = 'video';

        $title = pathinfo($origName, PATHINFO_FILENAME);

        $docId = Database::insert($resTable, [
            'classroom_id' => $classroomId,
            'filename'     => Database::escape_string($origName),
            'stored_name'  => Database::escape_string($storedName),
            'title'        => Database::escape_string($title),
            'file_type'    => $fileType,
            'file_size'    => (int) $file['size'],
            'mime_type'    => Database::escape_string($mimeType),
            'uploaded_by'  => $userId,
            'created_at'   => date('Y-m-d H:i:s'),
        ]);

        echo json_encode([
            'success'      => true,
            'id'           => $docId,
            'filename'     => $origName,
            'stored_name'  => $storedName,
            'title'        => $title,
            'file_type'    => $fileType,
            'file_size'    => $file['size'],
            'file_size_fmt'=> formatFileSizeAjax((int) $file['size']),
            'mime_type'    => $mimeType,
            'web_url'      => api_get_path(WEB_UPLOAD_PATH) . 'plugins/school/recursos/' . urlencode($storedName),
            'dist_count'   => 0,
            'created_at'   => date('d/m/Y H:i'),
        ]);
        break;

    // -----------------------------------------------------------------------
    case 'delete_resource':
        $resourceId  = isset($_POST['resource_id']) ? (int) $_POST['resource_id'] : 0;
        $classroomId = isset($_POST['classroom_id']) ? (int) $_POST['classroom_id'] : 0;

        if ($resourceId <= 0 || !canEditClassroomRes($classroomId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos en esta aula']);
            exit;
        }

        $row = Database::fetch_array(
            Database::query("SELECT * FROM $resTable WHERE id = $resourceId AND classroom_id = $classroomId LIMIT 1"),
            'ASSOC'
        );

        if (!$row) {
            echo json_encode(['success' => false, 'error' => 'Recurso no encontrado']);
            exit;
        }
        if (!isTutorOfClassroom($classroomId, $userId, $isAdmin) && (int)$row['uploaded_by'] !== $userId) {
            echo json_encode(['success' => false, 'error' => 'Solo puedes eliminar tus propios archivos']);
            exit;
        }

        // Delete physical file
        $filePath = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/recursos/' . $row['stored_name'];
        if (is_file($filePath)) {
            unlink($filePath);
        }

        // Delete distribution records
        Database::query("DELETE FROM $distTable WHERE resource_id = $resourceId");
        // Delete resource record
        Database::query("DELETE FROM $resTable WHERE id = $resourceId");

        echo json_encode(['success' => true]);
        break;

    // -----------------------------------------------------------------------
    case 'get_courses':
        $classroomId = isset($_GET['classroom_id']) ? (int) $_GET['classroom_id'] : 0;
        if ($classroomId <= 0) {
            echo json_encode(['success' => false, 'courses' => []]);
            exit;
        }

        $courses = AcademicManager::getClassroomCourses($classroomId);
        $result  = [];
        foreach ($courses as $c) {
            $result[] = [
                'id'    => $c['id'],
                'code'  => $c['code'],
                'title' => $c['title'],
            ];
        }
        echo json_encode(['success' => true, 'courses' => $result]);
        break;

    // -----------------------------------------------------------------------
    case 'get_folders':
        $courseCode = isset($_GET['course_code']) ? trim($_GET['course_code']) : '';
        $sessionId  = isset($_GET['session_id'])  ? (int) $_GET['session_id']  : 0;

        if (empty($courseCode)) {
            echo json_encode(['success' => false, 'folders' => []]);
            exit;
        }

        $courseInfo = api_get_course_info($courseCode);
        if (!$courseInfo) {
            echo json_encode(['success' => false, 'error' => 'Curso no encontrado']);
            exit;
        }

        require_once api_get_path(LIBRARY_PATH) . 'document.lib.php';

        $courseId  = (int) $courseInfo['real_id'];
        $docTable  = Database::get_course_table(TABLE_DOCUMENT);
        $propTable = Database::get_course_table(TABLE_ITEM_PROPERTY);

        $sql = "SELECT d.id, d.path, d.title
                FROM $docTable d
                INNER JOIN $propTable p
                    ON p.ref = d.id AND p.tool = 'document' AND p.c_id = $courseId
                WHERE d.c_id = $courseId
                  AND d.filetype = 'folder'
                  AND p.visibility != 2
                  AND (d.session_id = 0 OR d.session_id = $sessionId)
                ORDER BY d.path ASC";

        $res     = Database::query($sql);
        $folders = [['path' => '/', 'label' => '/ (raíz)']];
        while ($f = Database::fetch_array($res, 'ASSOC')) {
            $folders[] = [
                'path'  => $f['path'],
                'label' => $f['path'] . ' — ' . $f['title'],
            ];
        }

        echo json_encode(['success' => true, 'folders' => $folders]);
        break;

    // -----------------------------------------------------------------------
    case 'create_folder':
        $courseCode  = isset($_POST['course_code'])  ? trim($_POST['course_code'])  : '';
        $sessionId   = isset($_POST['session_id'])   ? (int) $_POST['session_id']   : 0;
        $folderName  = isset($_POST['folder_name'])  ? trim($_POST['folder_name'])  : '';
        $parentPath  = isset($_POST['parent_path'])  ? trim($_POST['parent_path'])  : '/';
        $classroomId = isset($_POST['classroom_id']) ? (int) $_POST['classroom_id'] : 0;

        if (empty($courseCode) || empty($folderName)) {
            echo json_encode(['success' => false, 'error' => 'Datos incompletos']);
            exit;
        }
        if (!canDistributeToCourse($classroomId, $courseCode, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'error' => 'No tienes permiso para crear carpetas en ese curso']);
            exit;
        }

        $courseInfo = api_get_course_info($courseCode);
        if (!$courseInfo) {
            echo json_encode(['success' => false, 'error' => 'Curso no encontrado']);
            exit;
        }

        require_once api_get_path(LIBRARY_PATH) . 'document.lib.php';
        require_once api_get_path(LIBRARY_PATH) . 'fileUpload.lib.php';

        $folderName  = api_replace_dangerous_char($folderName);
        $parentPath  = rtrim($parentPath, '/');
        $newPath     = $parentPath . '/' . $folderName;
        $baseWorkDir = api_get_path(SYS_COURSE_PATH) . $courseInfo['path'] . '/document';

        $result = create_unexisting_directory(
            $courseInfo,
            $userId,
            $sessionId,
            0,  // group
            null,
            $baseWorkDir,
            $newPath,
            $folderName,
            1,  // visible
            true
        );

        if ($result === false) {
            echo json_encode(['success' => false, 'error' => 'La carpeta ya existe o no se pudo crear']);
            exit;
        }

        echo json_encode(['success' => true, 'path' => $newPath, 'title' => $folderName]);
        break;

    // -----------------------------------------------------------------------
    case 'distribute_resource':
        $resourceId  = isset($_POST['resource_id'])  ? (int) $_POST['resource_id']  : 0;
        $classroomId = isset($_POST['classroom_id']) ? (int) $_POST['classroom_id'] : 0;
        $courseCode  = isset($_POST['course_code'])  ? trim($_POST['course_code'])  : '';
        $sessionId   = isset($_POST['session_id'])   ? (int) $_POST['session_id']   : 0;
        $folderPath  = isset($_POST['folder_path'])  ? trim($_POST['folder_path'])  : '/';

        if ($resourceId <= 0 || empty($courseCode)) {
            echo json_encode(['success' => false, 'error' => 'Datos incompletos']);
            exit;
        }
        if (!canDistributeToCourse($classroomId, $courseCode, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'error' => 'No tienes permiso para distribuir a ese curso']);
            exit;
        }

        // Load resource
        $resource = Database::fetch_array(
            Database::query("SELECT * FROM $resTable WHERE id = $resourceId AND classroom_id = $classroomId LIMIT 1"),
            'ASSOC'
        );
        if (!$resource) {
            echo json_encode(['success' => false, 'error' => 'Recurso no encontrado']);
            exit;
        }

        $courseInfo = api_get_course_info($courseCode);
        if (!$courseInfo) {
            echo json_encode(['success' => false, 'error' => 'Curso no encontrado']);
            exit;
        }

        require_once api_get_path(LIBRARY_PATH) . 'document.lib.php';
        require_once api_get_path(LIBRARY_PATH) . 'fileUpload.lib.php';

        $srcFile  = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/recursos/' . $resource['stored_name'];
        if (!is_file($srcFile)) {
            echo json_encode(['success' => false, 'error' => 'Archivo fuente no encontrado en el servidor']);
            exit;
        }

        $baseWorkDir = api_get_path(SYS_COURSE_PATH) . $courseInfo['path'] . '/document';
        $folderPath  = '/' . ltrim($folderPath, '/');
        $folderPath  = rtrim($folderPath, '/');
        if (empty($folderPath)) $folderPath = '/';

        // Ensure the destination folder is created on disk
        $destDir = $baseWorkDir . ($folderPath === '/' ? '' : $folderPath);
        if (!is_dir($destDir)) {
            mkdir($destDir, api_get_permissions_for_new_directories(), true);
        }

        // Build destination filename using the resource's current filename (already renamed by user if needed)
        $ext      = strtolower(pathinfo($resource['filename'], PATHINFO_EXTENSION));
        $baseName = pathinfo($resource['filename'], PATHINFO_FILENAME);
        $baseName = api_replace_dangerous_char($baseName);
        $destFile = $destDir . '/' . $baseName . ($ext ? '.' . $ext : '');
        $docPath  = ($folderPath === '/' ? '' : $folderPath) . '/' . $baseName . ($ext ? '.' . $ext : '');

        // Handle collision at destination
        $counter = 1;
        while (file_exists($destFile)) {
            $destFile = $destDir . '/' . $baseName . '_' . $counter . ($ext ? '.' . $ext : '');
            $docPath  = ($folderPath === '/' ? '' : $folderPath) . '/' . $baseName . '_' . $counter . ($ext ? '.' . $ext : '');
            $counter++;
        }

        // MOVE (not copy) the file to its final location in the course
        if (!rename($srcFile, $destFile)) {
            echo json_encode(['success' => false, 'error' => 'No se pudo mover el archivo al curso']);
            exit;
        }

        $title = pathinfo($docPath, PATHINFO_BASENAME);
        $docId = add_document(
            $courseInfo,
            $docPath,
            'file',
            filesize($destFile),
            $title,
            null,
            0,
            true,
            0,
            $sessionId,
            $userId
        );

        if (!$docId) {
            // Move succeeded but DB insert failed — put the file back
            rename($destFile, $srcFile);
            echo json_encode(['success' => false, 'error' => 'No se pudo registrar el documento en el curso']);
            exit;
        }

        // Get session name
        $sessionName = '';
        if ($sessionId > 0) {
            $sInfo = api_get_session_info($sessionId);
            $sessionName = $sInfo ? $sInfo['name'] : '';
        }

        // Remove resource record (file has been moved to its final destination)
        Database::query("DELETE FROM $distTable WHERE resource_id = $resourceId");
        Database::query("DELETE FROM $resTable  WHERE id = $resourceId");

        echo json_encode([
            'success'          => true,
            'resource_removed' => true,
            'resource_id'      => $resourceId,
            'course_title'     => $courseInfo['title'],
            'session_name'     => $sessionName,
            'folder_path'      => $folderPath,
        ]);
        break;

    // -----------------------------------------------------------------------
    case 'get_distributions':
        $resourceId  = isset($_GET['resource_id'])  ? (int) $_GET['resource_id']  : 0;
        $classroomId = isset($_GET['classroom_id']) ? (int) $_GET['classroom_id'] : 0;

        if ($resourceId <= 0) {
            echo json_encode(['success' => false, 'distributions' => []]);
            exit;
        }

        // Verify resource belongs to classroom
        $res = Database::fetch_array(
            Database::query("SELECT id FROM $resTable WHERE id = $resourceId AND classroom_id = $classroomId LIMIT 1"),
            'ASSOC'
        );
        if (!$res) {
            echo json_encode(['success' => false, 'error' => 'Recurso no encontrado']);
            exit;
        }

        $dRes  = Database::query(
            "SELECT d.*, u.firstname, u.lastname
             FROM $distTable d
             LEFT JOIN " . Database::get_main_table(TABLE_MAIN_USER) . " u ON u.id = d.distributed_by
             WHERE d.resource_id = $resourceId
             ORDER BY d.distributed_at DESC"
        );
        $dists = [];
        while ($d = Database::fetch_array($dRes, 'ASSOC')) {
            $dists[] = [
                'id'           => $d['id'],
                'course_title' => $d['course_title'],
                'session_name' => $d['session_name'],
                'folder_path'  => $d['folder_path'],
                'distributed_by'   => trim($d['firstname'] . ' ' . $d['lastname']),
                'distributed_at'   => date('d/m/Y H:i', strtotime($d['distributed_at'])),
            ];
        }

        echo json_encode(['success' => true, 'distributions' => $dists]);
        break;

    // -----------------------------------------------------------------------
    case 'set_destination':
        $resourceId  = isset($_POST['resource_id'])  ? (int) $_POST['resource_id']  : 0;
        $classroomId = isset($_POST['classroom_id']) ? (int) $_POST['classroom_id'] : 0;
        $courseCode  = isset($_POST['course_code'])  ? trim($_POST['course_code'])  : '';
        $sessionId   = isset($_POST['session_id'])   ? (int) $_POST['session_id']   : 0;
        $folderPath  = isset($_POST['folder_path'])  ? trim($_POST['folder_path'])  : '/';

        if ($resourceId <= 0 || empty($courseCode)) {
            echo json_encode(['success' => false, 'error' => 'Datos incompletos']);
            exit;
        }
        if (!canDistributeToCourse($classroomId, $courseCode, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'error' => 'No tienes permiso para distribuir a ese curso']);
            exit;
        }

        $resource = Database::fetch_array(
            Database::query("SELECT id FROM $resTable WHERE id = $resourceId AND classroom_id = $classroomId LIMIT 1"),
            'ASSOC'
        );
        if (!$resource) {
            echo json_encode(['success' => false, 'error' => 'Recurso no encontrado']);
            exit;
        }

        $courseInfo  = api_get_course_info($courseCode);
        $courseTitle = $courseInfo ? $courseInfo['title'] : $courseCode;

        $sessionName = '';
        if ($sessionId > 0) {
            $sInfo = api_get_session_info($sessionId);
            $sessionName = $sInfo ? $sInfo['name'] : '';
        }

        $folderPath = '/' . ltrim($folderPath, '/');

        Database::query("UPDATE $resTable SET
            dest_course_code  = '" . Database::escape_string($courseCode)  . "',
            dest_course_title = '" . Database::escape_string($courseTitle) . "',
            dest_session_id   = $sessionId,
            dest_session_name = '" . Database::escape_string($sessionName) . "',
            dest_folder_path  = '" . Database::escape_string($folderPath)  . "'
            WHERE id = $resourceId");

        echo json_encode([
            'success'      => true,
            'course_code'  => $courseCode,
            'course_title' => $courseTitle,
            'session_id'   => $sessionId,
            'session_name' => $sessionName,
            'folder_path'  => $folderPath,
        ]);
        break;

    // -----------------------------------------------------------------------
    case 'distribute_selected':
        $classroomId = isset($_POST['classroom_id']) ? (int) $_POST['classroom_id'] : 0;
        $idsRaw      = isset($_POST['resource_ids']) ? trim($_POST['resource_ids']) : '';

        if ($classroomId <= 0 || empty($idsRaw)) {
            echo json_encode(['success' => false, 'error' => 'Datos incompletos']);
            exit;
        }
        if (!canEditClassroomRes($classroomId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos en esta aula']);
            exit;
        }

        // Parse and sanitize IDs
        $ids = array_filter(array_map('intval', explode(',', $idsRaw)));
        if (empty($ids)) {
            echo json_encode(['success' => false, 'error' => 'No se recibieron IDs válidos']);
            exit;
        }

        require_once api_get_path(LIBRARY_PATH) . 'document.lib.php';
        require_once api_get_path(LIBRARY_PATH) . 'fileUpload.lib.php';

        $uploadDir = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/recursos/';
        $results   = [];

        foreach ($ids as $resourceId) {
            $resource = Database::fetch_array(
                Database::query("SELECT * FROM $resTable WHERE id = $resourceId AND classroom_id = $classroomId LIMIT 1"),
                'ASSOC'
            );

            if (!$resource) {
                $results[] = ['resource_id' => $resourceId, 'success' => false, 'error' => 'No encontrado'];
                continue;
            }
            if (empty($resource['dest_course_code'])) {
                $results[] = ['resource_id' => $resourceId, 'success' => false,
                              'title' => $resource['title'], 'error' => 'Sin destino configurado'];
                continue;
            }

            $courseCode = $resource['dest_course_code'];
            if (!canDistributeToCourse($classroomId, $courseCode, $userId, $isAdmin)) {
                $results[] = ['resource_id' => $resourceId, 'success' => false,
                              'title' => $resource['title'], 'error' => 'Sin permiso para ese curso'];
                continue;
            }

            $courseInfo = api_get_course_info($courseCode);
            if (!$courseInfo) {
                $results[] = ['resource_id' => $resourceId, 'success' => false,
                              'title' => $resource['title'], 'error' => 'Curso no encontrado'];
                continue;
            }

            $srcFile = $uploadDir . $resource['stored_name'];
            if (!is_file($srcFile)) {
                $results[] = ['resource_id' => $resourceId, 'success' => false,
                              'title' => $resource['title'], 'error' => 'Archivo no encontrado en servidor'];
                continue;
            }

            $sessionId  = (int) $resource['dest_session_id'];
            $folderPath = $resource['dest_folder_path'];
            $folderPath = '/' . ltrim($folderPath, '/');
            $folderPath = rtrim($folderPath, '/');
            if (empty($folderPath)) $folderPath = '/';

            $baseWorkDir = api_get_path(SYS_COURSE_PATH) . $courseInfo['path'] . '/document';
            $destDir     = $baseWorkDir . ($folderPath === '/' ? '' : $folderPath);
            if (!is_dir($destDir)) {
                mkdir($destDir, api_get_permissions_for_new_directories(), true);
            }

            $ext      = strtolower(pathinfo($resource['filename'], PATHINFO_EXTENSION));
            $baseName = api_replace_dangerous_char(pathinfo($resource['filename'], PATHINFO_FILENAME));
            $destFile = $destDir . '/' . $baseName . ($ext ? '.' . $ext : '');
            $docPath  = ($folderPath === '/' ? '' : $folderPath) . '/' . $baseName . ($ext ? '.' . $ext : '');

            $counter = 1;
            while (file_exists($destFile)) {
                $destFile = $destDir . '/' . $baseName . '_' . $counter . ($ext ? '.' . $ext : '');
                $docPath  = ($folderPath === '/' ? '' : $folderPath) . '/' . $baseName . '_' . $counter . ($ext ? '.' . $ext : '');
                $counter++;
            }

            if (!rename($srcFile, $destFile)) {
                $results[] = ['resource_id' => $resourceId, 'success' => false,
                              'title' => $resource['title'], 'error' => 'No se pudo mover el archivo'];
                continue;
            }

            $title = pathinfo($docPath, PATHINFO_BASENAME);
            $docId = add_document($courseInfo, $docPath, 'file', filesize($destFile),
                                  $title, null, 0, true, 0, $sessionId, $userId);

            if (!$docId) {
                rename($destFile, $srcFile); // rollback
                $results[] = ['resource_id' => $resourceId, 'success' => false,
                              'title' => $resource['title'], 'error' => 'Error al registrar en el curso'];
                continue;
            }

            // Remove resource record — file is now at its final destination
            Database::query("DELETE FROM $distTable WHERE resource_id = $resourceId");
            Database::query("DELETE FROM $resTable  WHERE id = $resourceId");

            $results[] = [
                'resource_id'  => $resourceId,
                'success'      => true,
                'title'        => $resource['title'],
                'course_title' => $courseInfo['title'],
                'session_name' => $resource['dest_session_name'],
                'folder_path'  => $folderPath,
            ];
        }

        $ok  = count(array_filter($results, fn($r) => $r['success']));
        $err = count($results) - $ok;
        echo json_encode(['success' => true, 'results' => $results, 'ok' => $ok, 'errors' => $err]);
        break;

    // -----------------------------------------------------------------------
    default:
        echo json_encode(['success' => false, 'error' => 'Acción desconocida']);
        break;
}
