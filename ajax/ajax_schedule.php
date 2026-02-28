<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../src/AcademicManager.php';
require_once __DIR__ . '/../src/MatriculaManager.php';
require_once __DIR__ . '/../src/ClassroomPlanManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

header('Content-Type: application/json');

$userId   = api_get_user_id();
$userInfo = api_get_user_info($userId);
$isAdmin  = api_is_platform_admin();
$isTeacher = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;

if (!$userId) {
    echo json_encode(['success' => false, 'error' => 'Not authenticated']);
    exit;
}

// Only admin or teacher can modify
$canEdit = $isAdmin || $isTeacher;

$schedTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CLASSROOM_SCHEDULE);
$action     = $_REQUEST['action'] ?? '';

/**
 * Verify the requesting user has edit rights on the given classroom.
 * Admin: always yes. Teacher: only if they are the tutor of that classroom.
 */
function canEditClassroom(int $classroomId, int $userId, bool $isAdmin): bool
{
    if ($isAdmin) return true;
    $activeYear = MatriculaManager::getActiveYear();
    $yearId = $activeYear ? (int) $activeYear['id'] : 0;
    if ($yearId === 0) return false;
    $tutorClassroom = ClassroomPlanManager::getTutorClassroom($userId, $yearId);
    return $tutorClassroom && (int) $tutorClassroom['id'] === $classroomId;
}

switch ($action) {

    // -------------------------------------------------------------------------
    // save_schedule_entry: insert or update one or multiple day entries
    // -------------------------------------------------------------------------
    case 'save_schedule_entry':
        if (!$canEdit) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos']);
            exit;
        }

        $entryId     = (int) ($_POST['entry_id']    ?? 0);
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $timeStart   = trim($_POST['time_start']   ?? '');
        $timeEnd     = trim($_POST['time_end']      ?? '');
        $style       = trim($_POST['style']         ?? '');
        $subject     = trim($_POST['subject']       ?? '');
        $teacherId   = (int) ($_POST['teacher_id']  ?? 0);
        $sortOrder   = (int) ($_POST['sort_order']  ?? 0);
        $days        = $_POST['days'] ?? [];

        if (!$classroomId || !$timeStart || !$timeEnd) {
            echo json_encode(['success' => false, 'error' => 'Datos incompletos']);
            exit;
        }

        if (!canEditClassroom($classroomId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos para este aula']);
            exit;
        }

        // Validate time format HH:MM or HH:MM:SS
        if (!preg_match('/^\d{2}:\d{2}(:\d{2})?$/', $timeStart) ||
            !preg_match('/^\d{2}:\d{2}(:\d{2})?$/', $timeEnd)) {
            echo json_encode(['success' => false, 'error' => 'Formato de hora inválido']);
            exit;
        }

        $tsEsc  = Database::escape_string($timeStart);
        $teEsc  = Database::escape_string($timeEnd);
        $subjEs = Database::escape_string($subject);
        $styleE = Database::escape_string($style);
        $tName  = '';
        if ($teacherId > 0) {
            $tInfo = api_get_user_info($teacherId);
            $tName = $tInfo ? ($tInfo['lastname'] . ', ' . $tInfo['firstname']) : '';
        }
        $tNameE = Database::escape_string($tName);
        $tidVal = $teacherId > 0 ? $teacherId : 'NULL';

        if ($entryId > 0) {
            // Update existing single entry
            Database::query("UPDATE $schedTable SET
                time_start   = '$tsEsc',
                time_end     = '$teEsc',
                subject      = '$subjEs',
                teacher_id   = $tidVal,
                teacher_name = '$tNameE',
                style        = '$styleE',
                sort_order   = $sortOrder
                WHERE id = $entryId AND classroom_id = $classroomId");
            echo json_encode(['success' => true]);
            break;
        }

        // Insert new entries: one per selected day (or day_of_week=0 for special rows)
        if ($style && in_array($style, ['break', 'pause', 'exit'])) {
            // Special rows apply to all days (day_of_week = 0)
            Database::query("INSERT INTO $schedTable
                (classroom_id, day_of_week, time_start, time_end, subject, teacher_id, teacher_name, style, sort_order)
                VALUES ($classroomId, 0, '$tsEsc', '$teEsc', '$subjEs', $tidVal, '$tNameE', '$styleE', $sortOrder)");
        } else {
            if (empty($days)) {
                echo json_encode(['success' => false, 'error' => 'Selecciona al menos un día']);
                exit;
            }
            foreach ($days as $day) {
                $dayInt = (int) $day;
                if ($dayInt < 0 || $dayInt > 5) continue;
                // Check for duplicate (same classroom, day, time range)
                $check = Database::fetch_array(
                    Database::query("SELECT id FROM $schedTable
                                     WHERE classroom_id=$classroomId AND day_of_week=$dayInt
                                       AND time_start='$tsEsc' AND time_end='$teEsc' LIMIT 1"),
                    'ASSOC'
                );
                if ($check) {
                    // Update existing
                    Database::query("UPDATE $schedTable SET
                        subject='$subjEs', teacher_id=$tidVal, teacher_name='$tNameE',
                        style='$styleE', sort_order=$sortOrder
                        WHERE id={$check['id']}");
                } else {
                    Database::query("INSERT INTO $schedTable
                        (classroom_id, day_of_week, time_start, time_end, subject, teacher_id, teacher_name, style, sort_order)
                        VALUES ($classroomId, $dayInt, '$tsEsc', '$teEsc', '$subjEs', $tidVal, '$tNameE', '$styleE', $sortOrder)");
                }
            }
        }

        echo json_encode(['success' => true]);
        break;

    // -------------------------------------------------------------------------
    // delete_schedule_entry: remove a single entry by id
    // -------------------------------------------------------------------------
    case 'delete_schedule_entry':
        if (!$canEdit) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos']);
            exit;
        }

        $entryId = (int) ($_POST['entry_id'] ?? 0);
        if (!$entryId) {
            echo json_encode(['success' => false, 'error' => 'ID inválido']);
            exit;
        }

        // Get classroom_id of the entry to verify permission
        $row = Database::fetch_array(
            Database::query("SELECT classroom_id FROM $schedTable WHERE id=$entryId LIMIT 1"),
            'ASSOC'
        );
        if (!$row) {
            echo json_encode(['success' => false, 'error' => 'Entrada no encontrada']);
            exit;
        }
        if (!canEditClassroom((int) $row['classroom_id'], $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos para este aula']);
            exit;
        }

        Database::query("DELETE FROM $schedTable WHERE id=$entryId");
        echo json_encode(['success' => true]);
        break;

    // -------------------------------------------------------------------------
    // delete_schedule_slot: remove all entries for a given time slot in a classroom
    // -------------------------------------------------------------------------
    case 'delete_schedule_slot':
        if (!$canEdit) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos']);
            exit;
        }

        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $timeStart   = trim($_POST['time_start'] ?? '');
        $timeEnd     = trim($_POST['time_end']   ?? '');

        if (!$classroomId || !$timeStart || !$timeEnd) {
            echo json_encode(['success' => false, 'error' => 'Datos incompletos']);
            exit;
        }

        if (!canEditClassroom($classroomId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos para este aula']);
            exit;
        }

        $tsEsc = Database::escape_string($timeStart);
        $teEsc = Database::escape_string($timeEnd);
        Database::query("DELETE FROM $schedTable
                         WHERE classroom_id=$classroomId AND time_start='$tsEsc' AND time_end='$teEsc'");
        echo json_encode(['success' => true]);
        break;

    default:
        echo json_encode(['success' => false, 'error' => 'Acción desconocida']);
        break;
}
