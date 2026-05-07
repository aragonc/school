<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../src/AcademicManager.php';
require_once __DIR__ . '/../../src/MatriculaManager.php';
require_once __DIR__ . '/../../src/ClassroomPlanManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();
$plugin->requireModule('my_aula');

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$userId   = api_get_user_id();
$userInfo = api_get_user_info($userId);

$isAdmin     = api_is_platform_admin();
$isSecretary = $userInfo && (int) $userInfo['status'] === SCHOOL_SECRETARY;
$isTeacher   = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;
$isStudent   = $userInfo && (int) $userInfo['status'] === STUDENT;

// Secretary and student cannot access
if ($isSecretary || $isStudent) {
    api_not_allowed(true);
}

if (!$isAdmin && !$isTeacher) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('my-classroom-recursos');
$plugin->setSidebar('my-classroom-recursos');

// Ensure resource tables exist
$resTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_RESOURCE);
$distTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_RESOURCE_DIST);

Database::query("CREATE TABLE IF NOT EXISTS $resTable (
    id                INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    classroom_id      INT NOT NULL DEFAULT 0,
    filename          VARCHAR(255) NOT NULL DEFAULT '',
    stored_name       VARCHAR(255) NOT NULL DEFAULT '',
    title             VARCHAR(255) NOT NULL DEFAULT '',
    file_type         VARCHAR(30)  NOT NULL DEFAULT '',
    file_size         INT NOT NULL DEFAULT 0,
    mime_type         VARCHAR(120) NOT NULL DEFAULT '',
    uploaded_by       INT NOT NULL DEFAULT 0,
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dest_course_code  VARCHAR(40)  NOT NULL DEFAULT '',
    dest_course_title VARCHAR(255) NOT NULL DEFAULT '',
    dest_session_id   INT NOT NULL DEFAULT 0,
    dest_session_name VARCHAR(255) NOT NULL DEFAULT '',
    dest_folder_path  VARCHAR(500) NOT NULL DEFAULT '',
    INDEX idx_classroom (classroom_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

// Migrate: add destination columns to existing tables
$existingCols = Database::query("SHOW COLUMNS FROM $resTable LIKE 'dest_course_code'");
if (Database::num_rows($existingCols) === 0) {
    Database::query("ALTER TABLE $resTable
        ADD COLUMN dest_course_code  VARCHAR(40)  NOT NULL DEFAULT '',
        ADD COLUMN dest_course_title VARCHAR(255) NOT NULL DEFAULT '',
        ADD COLUMN dest_session_id   INT          NOT NULL DEFAULT 0,
        ADD COLUMN dest_session_name VARCHAR(255) NOT NULL DEFAULT '',
        ADD COLUMN dest_folder_path  VARCHAR(500) NOT NULL DEFAULT ''");
}

Database::query("CREATE TABLE IF NOT EXISTS $distTable (
    id              INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    resource_id     INT NOT NULL,
    course_code     VARCHAR(40) NOT NULL DEFAULT '',
    course_title    VARCHAR(255) NOT NULL DEFAULT '',
    session_id      INT NOT NULL DEFAULT 0,
    session_name    VARCHAR(255) NOT NULL DEFAULT '',
    folder_path     VARCHAR(500) NOT NULL DEFAULT '/',
    document_id     INT NOT NULL DEFAULT 0,
    distributed_by  INT NOT NULL DEFAULT 0,
    distributed_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_resource (resource_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

// Active academic year
$activeYear = MatriculaManager::getActiveYear();
$yearId     = $activeYear ? (int) $activeYear['id'] : 0;

// Determine classroom
$classroomId    = isset($_GET['classroom_id']) ? (int) $_GET['classroom_id'] : 0;
$classroom      = null;
$classroomsList = [];
$isTutor        = false;

if ($isAdmin) {
    if ($yearId > 0) {
        $classroomsList = AcademicManager::getClassrooms($yearId);
    }
    if ($classroomId > 0) {
        $classroom = AcademicManager::getClassroom($classroomId);
    } elseif (!empty($classroomsList)) {
        $classroom   = $classroomsList[0];
        $classroomId = (int) $classroom['id'];
    }
    $isTutor = true;
} elseif ($isTeacher) {
    $tutorClassroom = $yearId > 0 ? ClassroomPlanManager::getTutorClassroom($userId, $yearId) : null;
    $classroomsList = $yearId > 0 ? AcademicManager::getTeacherClassrooms($userId, $yearId) : [];

    if ($classroomId > 0) {
        $classroom = AcademicManager::getClassroom($classroomId);
    } elseif ($tutorClassroom) {
        $classroom   = $tutorClassroom;
        $classroomId = (int) $tutorClassroom['id'];
    } elseif (!empty($classroomsList)) {
        $classroom   = $classroomsList[0];
        $classroomId = (int) $classroom['id'];
    }

    $isTutor = $classroom && (
        (int) ($classroom['tutor_id'] ?? 0) === $userId ||
        (int) ($classroom['supervisor_id'] ?? 0) === $userId
    );
}

// Enrich classroom with tutor name
if ($classroom && !empty($classroom['tutor_id']) && empty($classroom['tutor_name'])) {
    $tInfo = api_get_user_info((int) $classroom['tutor_id']);
    $classroom['tutor_name'] = $tInfo ? $tInfo['complete_name'] : '';
}

// Load resources for this classroom
$resources = [];
if ($classroomId > 0) {
    $safeClassId = (int) $classroomId;
    $res = Database::query("SELECT r.*, u.firstname, u.lastname
        FROM $resTable r
        LEFT JOIN " . Database::get_main_table(TABLE_MAIN_USER) . " u ON u.id = r.uploaded_by
        WHERE r.classroom_id = $safeClassId
        ORDER BY r.created_at DESC");
    while ($row = Database::fetch_array($res, 'ASSOC')) {
        $row['uploader_name']    = trim($row['firstname'] . ' ' . $row['lastname']);
        $row['file_size_fmt']    = formatFileSize((int) $row['file_size']);
        $row['web_url']          = api_get_path(WEB_UPLOAD_PATH) . 'plugins/school/recursos/' . urlencode($row['stored_name']);
        $row['has_destination']  = !empty($row['dest_course_code']);
        $resources[] = $row;
    }
}

// ---- Permission rules ----
// Any teacher (including plain docentes) can upload, rename and delete their own files.
// Tutor and admin can manage all files in the classroom.
// Distribution: tutor/admin → any course; plain docente → only their assigned courses.
$canUpload = $isAdmin || $isTeacher; // all teachers can upload

// Get ALL courses linked to this classroom
$allClassroomCourses = $classroomId > 0 ? AcademicManager::getClassroomCourses($classroomId) : [];

// For a non-tutor teacher: filter to only their assigned courses
$classroomCourses = $allClassroomCourses;
$teacherCourseIds = []; // course IDs the current teacher can distribute to

if (!$isAdmin && !$isTutor && $isTeacher && $classroomId > 0) {
    $ccTable2 = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
    $ctTable2 = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
    $tcRes = Database::query(
        "SELECT cc.course_id
         FROM $ccTable2 cc
         INNER JOIN $ctTable2 ct ON ct.classroom_course_id = cc.id
         WHERE cc.classroom_id = $classroomId AND ct.teacher_id = $userId"
    );
    while ($tcRow = Database::fetch_array($tcRes, 'ASSOC')) {
        $teacherCourseIds[] = (int) $tcRow['course_id'];
    }
    // Restrict course list shown to teacher
    $classroomCourses = array_filter($allClassroomCourses, function($c) use ($teacherCourseIds) {
        return in_array((int)$c['id'], $teacherCourseIds, true);
    });
    $classroomCourses = array_values($classroomCourses);
}

// Get session for this classroom
$sessionId = 0;
if ($classroomId > 0) {
    $cTbl  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
    $sRow  = Database::fetch_array(
        Database::query("SELECT session_id FROM $cTbl WHERE id = $classroomId LIMIT 1"),
        'ASSOC'
    );
    $sessionId = $sRow ? (int) ($sRow['session_id'] ?? 0) : 0;
}

function formatFileSize(int $bytes): string
{
    if ($bytes >= 1048576) return round($bytes / 1048576, 1) . ' MB';
    if ($bytes >= 1024)    return round($bytes / 1024, 1)    . ' KB';
    return $bytes . ' B';
}

$plugin->assign('classroom',          $classroom);
$plugin->assign('classroom_id',       $classroomId);
$plugin->assign('classrooms_list',    $classroomsList);
$plugin->assign('is_admin',           $isAdmin);
$plugin->assign('is_tutor',           $isTutor);
$plugin->assign('can_upload',         $canUpload);
$plugin->assign('current_user_id',    $userId);
$plugin->assign('resources',          $resources);
$plugin->assign('classroom_courses',  $classroomCourses);
$plugin->assign('teacher_course_ids', $teacherCourseIds);
$plugin->assign('session_id',         $sessionId);
$plugin->assign('active_year',       $activeYear);
$plugin->assign('ajax_url',          api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_distribuir_recursos.php');
$plugin->assign('web_upload_path',   api_get_path(WEB_UPLOAD_PATH) . 'plugins/school/recursos/');

$plugin->setTitle('Distribuir recursos');
$content = $plugin->fetch('classroom/distribuir_recursos.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
