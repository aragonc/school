<?php
/**
 * AJAX endpoint: assign or update course coach within a session.
 * Actions:
 *   GET  action=search_users&q=...          → search teachers by name
 *   POST action=assign  session_id, course_id, coach_user_id  → assign coach
 *   POST action=remove  session_id, course_id                 → remove coach
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

$action    = $_REQUEST['action'] ?? '';
$sessionId = (int)($_REQUEST['session_id'] ?? 0);
$courseId  = (int)($_REQUEST['course_id']  ?? 0);

if (!$sessionId) {
    echo json_encode(['success' => false, 'message' => 'session_id requerido']);
    exit;
}

// ── Verify current user is a session-level coach (id_coach OR relation_type=1) ──
$tbl_session      = Database::get_main_table(TABLE_MAIN_SESSION);
$tbl_session_user = Database::get_main_table(TABLE_MAIN_SESSION_USER);

$isCoach = false;

$rCoach = Database::query(
    "SELECT id FROM $tbl_session WHERE id = $sessionId AND id_coach = $currentUserId LIMIT 1"
);
if (Database::num_rows($rCoach) > 0) {
    $isCoach = true;
}

if (!$isCoach) {
    $rRel = Database::query(
        "SELECT session_id FROM $tbl_session_user
         WHERE session_id = $sessionId AND user_id = $currentUserId AND relation_type = 1
         LIMIT 1"
    );
    if (Database::num_rows($rRel) > 0) {
        $isCoach = true;
    }
}

// Admins can always act
if (!$isCoach && api_is_platform_admin()) {
    $isCoach = true;
}

if (!$isCoach) {
    echo json_encode(['success' => false, 'message' => 'No autorizado']);
    exit;
}

// ── action: search_users ──────────────────────────────────────────────────────
if ($action === 'search_users') {
    $q       = Database::escape_string(trim($_GET['q'] ?? ''));
    $tbl_usr = Database::get_main_table(TABLE_MAIN_USER);

    // Teachers (status=1) and platform admins (status=3) are valid candidates
    $sql = "SELECT id, firstname, lastname, username
            FROM $tbl_usr
            WHERE status IN (1, 3)
              AND active = 1
              AND (
                  firstname LIKE '%$q%' OR
                  lastname  LIKE '%$q%' OR
                  username  LIKE '%$q%' OR
                  CONCAT(firstname,' ',lastname) LIKE '%$q%'
              )
            ORDER BY lastname, firstname
            LIMIT 20";

    $result = Database::query($sql);
    $users  = [];
    while ($row = Database::fetch_array($result, 'ASSOC')) {
        $users[] = [
            'id'   => (int)$row['id'],
            'name' => $row['firstname'] . ' ' . $row['lastname'],
            'username' => $row['username'],
        ];
    }
    echo json_encode(['success' => true, 'users' => $users]);
    exit;
}

// ── action: assign ────────────────────────────────────────────────────────────
if ($action === 'assign' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $coachUserId = (int)($_POST['coach_user_id'] ?? 0);

    if (!$coachUserId || !$courseId) {
        echo json_encode(['success' => false, 'message' => 'Datos incompletos']);
        exit;
    }

    $tbl_scu = Database::get_main_table(TABLE_MAIN_SESSION_COURSE_USER);
    $tbl_usr = Database::get_main_table(TABLE_MAIN_USER);

    // Remove any existing coach for this course+session
    Database::query(
        "DELETE FROM $tbl_scu
         WHERE session_id = $sessionId AND c_id = $courseId AND status = 2"
    );

    // Insert new coach
    Database::query(
        "INSERT INTO $tbl_scu (session_id, c_id, user_id, status)
         VALUES ($sessionId, $courseId, $coachUserId, 2)"
    );

    // Return coach name for UI update
    $rName = Database::query(
        "SELECT CONCAT(firstname,' ',lastname) AS name
         FROM $tbl_usr WHERE id = $coachUserId LIMIT 1"
    );
    $nameRow   = Database::fetch_array($rName, 'ASSOC');
    $coachName = $nameRow['name'] ?? '';

    echo json_encode(['success' => true, 'coach_name' => $coachName]);
    exit;
}

// ── action: remove ────────────────────────────────────────────────────────────
if ($action === 'remove' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!$courseId) {
        echo json_encode(['success' => false, 'message' => 'course_id requerido']);
        exit;
    }

    $tbl_scu = Database::get_main_table(TABLE_MAIN_SESSION_COURSE_USER);
    Database::query(
        "DELETE FROM $tbl_scu
         WHERE session_id = $sessionId AND c_id = $courseId AND status = 2"
    );

    echo json_encode(['success' => true]);
    exit;
}

echo json_encode(['success' => false, 'message' => 'Acción no válida']);
