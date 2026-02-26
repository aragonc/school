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

    // Check if this coach is already assigned to this course+session
    $rExists = Database::query(
        "SELECT 1 FROM $tbl_scu
         WHERE session_id = $sessionId AND c_id = $courseId AND user_id = $coachUserId AND status = 2
         LIMIT 1"
    );
    if (Database::num_rows($rExists) > 0) {
        echo json_encode(['success' => false, 'message' => 'El docente ya está asignado a este curso']);
        exit;
    }

    // Insert new coach without removing existing ones
    Database::query(
        "INSERT INTO $tbl_scu (session_id, c_id, user_id, status)
         VALUES ($sessionId, $courseId, $coachUserId, 2)"
    );

    // Return all coaches for UI update
    $rCoaches = Database::query(
        "SELECT scu.user_id, CONCAT(u.firstname,' ',u.lastname) AS name
         FROM $tbl_scu scu
         INNER JOIN $tbl_usr u ON u.id = scu.user_id
         WHERE scu.session_id = $sessionId AND scu.c_id = $courseId AND scu.status = 2
         ORDER BY u.lastname ASC, u.firstname ASC"
    );
    $coaches = [];
    while ($row = Database::fetch_array($rCoaches, 'ASSOC')) {
        $coaches[] = ['id' => (int)$row['user_id'], 'name' => $row['name']];
    }

    echo json_encode(['success' => true, 'coaches' => $coaches]);
    exit;
}

// ── action: remove ────────────────────────────────────────────────────────────
if ($action === 'remove' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!$courseId) {
        echo json_encode(['success' => false, 'message' => 'course_id requerido']);
        exit;
    }

    $coachUserId = (int)($_POST['coach_user_id'] ?? 0);
    $tbl_scu = Database::get_main_table(TABLE_MAIN_SESSION_COURSE_USER);
    $tbl_usr = Database::get_main_table(TABLE_MAIN_USER);

    if ($coachUserId) {
        // Remove a specific coach
        Database::query(
            "DELETE FROM $tbl_scu
             WHERE session_id = $sessionId AND c_id = $courseId AND user_id = $coachUserId AND status = 2"
        );
    } else {
        // Remove all coaches (backward-compat)
        Database::query(
            "DELETE FROM $tbl_scu
             WHERE session_id = $sessionId AND c_id = $courseId AND status = 2"
        );
    }

    // Return remaining coaches for UI update
    $rCoaches = Database::query(
        "SELECT scu.user_id, CONCAT(u.firstname,' ',u.lastname) AS name
         FROM $tbl_scu scu
         INNER JOIN $tbl_usr u ON u.id = scu.user_id
         WHERE scu.session_id = $sessionId AND scu.c_id = $courseId AND scu.status = 2
         ORDER BY u.lastname ASC, u.firstname ASC"
    );
    $coaches = [];
    while ($row = Database::fetch_array($rCoaches, 'ASSOC')) {
        $coaches[] = ['id' => (int)$row['user_id'], 'name' => $row['name']];
    }

    echo json_encode(['success' => true, 'coaches' => $coaches]);
    exit;
}

echo json_encode(['success' => false, 'message' => 'Acción no válida']);
