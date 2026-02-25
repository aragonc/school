<?php
/**
 * AJAX endpoint: upload course picture for a session course.
 * POST: session_id, course_id, course_code, file (image)
 *
 * Authorized users:
 *   - Session general coach (session.id_coach OR session_rel_user relation_type=1)
 *   - Course coach (session_course_user status=2 for this course)
 */
require_once __DIR__ . '/../../config.php';

header('Content-Type: application/json; charset=utf-8');

$plugin = SchoolPlugin::create();
api_block_anonymous_users();

$currentUserId = api_get_user_id();
if (!$currentUserId) {
    echo json_encode(['success' => false, 'message' => 'No autenticado']);
    exit;
}

$sessionId   = (int)($_POST['session_id']   ?? 0);
$courseId    = (int)($_POST['course_id']    ?? 0);
$courseCode  = preg_replace('/[^a-zA-Z0-9_-]/', '', $_POST['course_code'] ?? '');

if (!$sessionId || !$courseId || !$courseCode) {
    echo json_encode(['success' => false, 'message' => 'Parámetros incompletos']);
    exit;
}

// ── Authorization ────────────────────────────────────────────────────────────
$tbl_session      = Database::get_main_table(TABLE_MAIN_SESSION);
$tbl_session_user = Database::get_main_table(TABLE_MAIN_SESSION_USER);
$tbl_scu          = Database::get_main_table(TABLE_MAIN_SESSION_COURSE_USER);

$canUpload = false;

if (api_is_platform_admin()) {
    $canUpload = true;
}

if (!$canUpload) {
    // Session general coach
    $r = Database::query(
        "SELECT id FROM $tbl_session WHERE id = $sessionId AND id_coach = $currentUserId LIMIT 1"
    );
    if (Database::num_rows($r) > 0) $canUpload = true;
}

if (!$canUpload) {
    // Session tutor via relation_type=1
    $r = Database::query(
        "SELECT session_id FROM $tbl_session_user
         WHERE session_id = $sessionId AND user_id = $currentUserId AND relation_type = 1 LIMIT 1"
    );
    if (Database::num_rows($r) > 0) $canUpload = true;
}

if (!$canUpload) {
    // Course coach for this specific course
    $r = Database::query(
        "SELECT session_id FROM $tbl_scu
         WHERE session_id = $sessionId AND c_id = $courseId AND user_id = $currentUserId AND status = 2 LIMIT 1"
    );
    if (Database::num_rows($r) > 0) $canUpload = true;
}

if (!$canUpload) {
    echo json_encode(['success' => false, 'message' => 'No autorizado']);
    exit;
}

// ── File validation ───────────────────────────────────────────────────────────
if (empty($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
    $errMsg = [
        UPLOAD_ERR_INI_SIZE   => 'El archivo supera el límite del servidor',
        UPLOAD_ERR_FORM_SIZE  => 'El archivo supera el límite del formulario',
        UPLOAD_ERR_NO_FILE    => 'No se envió ningún archivo',
    ];
    $err = $_FILES['file']['error'] ?? UPLOAD_ERR_NO_FILE;
    echo json_encode(['success' => false, 'message' => $errMsg[$err] ?? 'Error al subir el archivo']);
    exit;
}

$allowedMime = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
$finfo       = new finfo(FILEINFO_MIME_TYPE);
$mime        = $finfo->file($_FILES['file']['tmp_name']);

if (!in_array($mime, $allowedMime)) {
    echo json_encode(['success' => false, 'message' => 'Formato no permitido. Use JPG, PNG, GIF o WebP.']);
    exit;
}

$maxSize = 5 * 1024 * 1024; // 5 MB
if ($_FILES['file']['size'] > $maxSize) {
    echo json_encode(['success' => false, 'message' => 'El archivo no debe superar 5 MB']);
    exit;
}

// ── Save image ────────────────────────────────────────────────────────────────
$courseDir = api_get_path(SYS_COURSE_PATH) . $courseCode . '/';

if (!is_dir($courseDir)) {
    echo json_encode(['success' => false, 'message' => 'Directorio del curso no encontrado']);
    exit;
}

$destPath = $courseDir . 'course-pic.png';
$tmpPath  = $_FILES['file']['tmp_name'];

// Convert/resize to PNG using GD (max 200x200 preserving aspect ratio)
$srcImg = null;
switch ($mime) {
    case 'image/jpeg': $srcImg = imagecreatefromjpeg($tmpPath); break;
    case 'image/png':  $srcImg = imagecreatefrompng($tmpPath);  break;
    case 'image/gif':  $srcImg = imagecreatefromgif($tmpPath);  break;
    case 'image/webp': $srcImg = imagecreatefromwebp($tmpPath); break;
}

if (!$srcImg) {
    echo json_encode(['success' => false, 'message' => 'No se pudo procesar la imagen']);
    exit;
}

$origW = imagesx($srcImg);
$origH = imagesy($srcImg);
$maxDim = 200;

if ($origW > $maxDim || $origH > $maxDim) {
    $ratio  = min($maxDim / $origW, $maxDim / $origH);
    $newW   = (int)round($origW * $ratio);
    $newH   = (int)round($origH * $ratio);
    $dstImg = imagecreatetruecolor($newW, $newH);
    imagealphablending($dstImg, false);
    imagesavealpha($dstImg, true);
    imagecopyresampled($dstImg, $srcImg, 0, 0, 0, 0, $newW, $newH, $origW, $origH);
    imagedestroy($srcImg);
    $srcImg = $dstImg;
}

$saved = imagepng($srcImg, $destPath);
imagedestroy($srcImg);

if (!$saved) {
    echo json_encode(['success' => false, 'message' => 'No se pudo guardar la imagen']);
    exit;
}

// Return new public URL with cache-buster
$imageUrl = api_get_path(WEB_COURSE_PATH) . $courseCode . '/course-pic.png?' . time();
echo json_encode(['success' => true, 'image_url' => $imageUrl]);
