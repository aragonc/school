<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../src/ClassroomPlanManager.php';
require_once __DIR__ . '/../../src/AcademicManager.php';
require_once __DIR__ . '/../../src/MatriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$userId   = api_get_user_id();
$userInfo = api_get_user_info($userId);

$isAdmin   = api_is_platform_admin();
$isTeacher = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;

// Only admin or teacher can access (secretary excluded)
if (!$isAdmin && !$isTeacher) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('my-classroom-alumnos');
$plugin->setSidebar('my-classroom-alumnos');

// Active academic year
$activeYear = MatriculaManager::getActiveYear();
$yearId     = $activeYear ? (int) $activeYear['id'] : 0;

// Selected date (default: today)
$selectedDate = date('Y-m-d');
if (isset($_GET['date']) && preg_match('/^\d{4}-\d{2}-\d{2}$/', $_GET['date'])) {
    $selectedDate = $_GET['date'];
}

// Determine which classroom to show
$classroomId    = isset($_GET['classroom_id']) ? (int) $_GET['classroom_id'] : 0;
$classroom      = null;
$classroomsList = [];

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
} elseif ($isTeacher) {
    $tutorClassroom = $yearId > 0 ? ClassroomPlanManager::getTutorClassroom($userId, $yearId) : null;
    if ($tutorClassroom) {
        $classroom   = $tutorClassroom;
        $classroomId = (int) $tutorClassroom['id'];
    }
}

// Enrich classroom with tutor name if needed
if ($classroom && !empty($classroom['tutor_id']) && empty($classroom['tutor_name'])) {
    $tInfo = api_get_user_info((int) $classroom['tutor_id']);
    $classroom['tutor_name'] = $tInfo ? $tInfo['complete_name'] : '';
}

// ---- Fetch students + attendance for the selected date ----
$students = [];
$countPuntual    = 0;
$countTardanza   = 0;
$countAusente    = 0;
$countSinRegistro = 0;

if ($classroomId > 0) {
    $csTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
    $userTable  = Database::get_main_table(TABLE_MAIN_USER);
    $fichaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
    $attTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ATTENDANCE_LOG);
    $dateEsc    = Database::escape_string($selectedDate);

    $sql = "SELECT
                cs.user_id,
                u.firstname, u.lastname, u.official_code, u.picture_uri,
                COALESCE(NULLIF(TRIM(f.dni), ''), u.official_code) AS dni,
                f.apellido_paterno, f.apellido_materno,
                f.nombres     AS ficha_nombres,
                f.foto        AS ficha_foto,
                al.status     AS att_status,
                al.check_in   AS att_check_in,
                al.method     AS att_method
            FROM $csTable cs
            INNER JOIN $userTable  u  ON u.id       = cs.user_id
            LEFT  JOIN $fichaTable f  ON f.user_id  = cs.user_id
            LEFT  JOIN $attTable   al ON al.user_id = cs.user_id AND al.date = '$dateEsc'
            WHERE cs.classroom_id = $classroomId
            ORDER BY
                COALESCE(NULLIF(TRIM(f.apellido_paterno), ''), u.lastname)  ASC,
                COALESCE(NULLIF(TRIM(f.apellido_materno), ''), '') ASC,
                COALESCE(NULLIF(TRIM(f.nombres), ''), u.firstname) ASC";

    $result = Database::query($sql);
    while ($row = Database::fetch_array($result, 'ASSOC')) {
        // Photo URL
        if (!empty($row['ficha_foto'])) {
            $row['foto_url'] = api_get_path(WEB_PLUGIN_PATH) . 'school/uploads/matricula/' . $row['ficha_foto'];
        } else {
            $uInfoSmall     = api_get_user_info((int) $row['user_id']);
            $row['foto_url'] = $uInfoSmall ? ($uInfoSmall['avatar_small'] ?? '') : '';
        }

        // Display name: prefer ficha data over Chamilo user data
        if (!empty(trim($row['apellido_paterno']))) {
            $row['display_apellidos'] = trim($row['apellido_paterno'] . ' ' . $row['apellido_materno']);
            $row['display_nombres']   = trim($row['ficha_nombres'] ?? '');
        } else {
            $row['display_apellidos'] = trim($row['lastname']);
            $row['display_nombres']   = trim($row['firstname']);
        }

        // Format check-in time (stored UTC → local)
        if (!empty($row['att_check_in'])) {
            try {
                $dt = new DateTime($row['att_check_in'], new DateTimeZone('UTC'));
                $tz = date_default_timezone_get() ?: 'America/Lima';
                $dt->setTimezone(new DateTimeZone($tz));
                $row['att_time'] = $dt->format('H:i');
            } catch (Exception $e) {
                $row['att_time'] = '';
            }
        } else {
            $row['att_time'] = '';
        }

        // Attendance counts
        switch ($row['att_status']) {
            case 'on_time': $countPuntual++;   break;
            case 'late':    $countTardanza++;  break;
            case 'absent':  $countAusente++;   break;
            default:        $countSinRegistro++; break;
        }

        $students[] = $row;
    }
}

$plugin->assign('classroom',              $classroom);
$plugin->assign('classroom_id',           $classroomId);
$plugin->assign('classrooms_list',        $classroomsList);
$plugin->assign('is_admin_or_secretary',  $isAdmin);
$plugin->assign('students',               $students);
$plugin->assign('selected_date',          $selectedDate);
$plugin->assign('count_puntual',          $countPuntual);
$plugin->assign('count_tardanza',         $countTardanza);
$plugin->assign('count_ausente',          $countAusente);
$plugin->assign('count_sin_registro',     $countSinRegistro);
$plugin->assign('total_students',         count($students));
$plugin->assign('is_today',               $selectedDate === date('Y-m-d'));

$plugin->setTitle('Mis Alumnos');
$content = $plugin->fetch('classroom/mis_alumnos.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
