<?php

require_once __DIR__.'/../config.php';

$plugin = SchoolPlugin::create();

date_default_timezone_set(api_get_timezone());

$action = isset($_REQUEST['action']) ? $_REQUEST['action'] : '';

header('Content-Type: application/json');

// Kiosk mode: public endpoint, no login required
if ($action === 'scan_qr_kiosk') {
    $username = isset($_POST['username']) ? trim($_POST['username']) : '';

    if (empty($username)) {
        echo json_encode(['success' => false, 'message' => 'Username is required']);
        exit;
    }

    $userInfo = api_get_user_info_from_username(Database::escape_string($username));

    // Fallback: buscar por número de documento (DNI / carnet / pasaporte) en la ficha
    if (!$userInfo) {
        $fichaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $dniEsc     = Database::escape_string($username);
        $fichaRes   = Database::query(
            "SELECT user_id FROM $fichaTable
             WHERE dni = '$dniEsc' AND user_id IS NOT NULL LIMIT 1"
        );
        $fichaRow = Database::fetch_assoc($fichaRes);
        if ($fichaRow && !empty($fichaRow['user_id'])) {
            $userInfo = api_get_user_info((int) $fichaRow['user_id']);
        }
    }

    if (!$userInfo) {
        echo json_encode(['success' => false, 'message' => 'UserNotFound']);
        exit;
    }

    $userId = (int) $userInfo['user_id'];
    $result = $plugin->markAttendance($userId, 'qr');

    // Get avatar URL
    $avatarUrl = $userInfo['avatar'] ?? '';

    // Get last 10 records for today, converting UTC times to local
    $todayRecords = $plugin->getAttendanceByDate(date('Y-m-d'));
    foreach ($todayRecords as &$record) {
        if (!empty($record['check_in'])) {
            $record['check_in'] = api_get_local_time($record['check_in']);
        }
        if (!empty($record['created_at'])) {
            $record['created_at'] = api_get_local_time($record['created_at']);
        }
    }
    unset($record);
    $lastRecords = array_slice(array_reverse($todayRecords), 0, 10);

    echo json_encode([
        'success' => $result['success'],
        'message' => $result['message'],
        'status' => $result['status'] ?? '',
        'user_info' => [
            'firstname' => $userInfo['firstname'],
            'lastname' => $userInfo['lastname'],
            'username' => $userInfo['username'],
            'avatar_url' => $avatarUrl,
        ],
        'check_in_time' => date('H:i:s'),
        'server_time' => date('Y-m-d H:i:s'),
        'today_records' => $lastRecords,
    ]);
    exit;
}

// All other actions require authentication
if (!api_get_user_id()) {
    echo json_encode(['success' => false, 'message' => 'Not authenticated']);
    exit;
}

$isAdmin = api_is_platform_admin();

switch ($action) {
    case 'generate_qr':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $qrData = $plugin->generateDailyQRToken();
        echo json_encode(['success' => true, 'data' => $qrData]);
        break;

    case 'mark_attendance':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $userIds      = isset($_POST['user_ids']) ? $_POST['user_ids'] : [];
        $notes        = isset($_POST['notes']) ? trim($_POST['notes']) : null;
        $status       = isset($_POST['status']) ? $_POST['status'] : null;
        $checkInTime  = isset($_POST['check_in_time']) ? trim($_POST['check_in_time']) : null;
        $registeredBy = api_get_user_id();

        // Validate status if provided
        if ($status && !in_array($status, ['on_time', 'late', 'absent'])) {
            echo json_encode(['success' => false, 'message' => 'Invalid status']);
            exit;
        }

        // Validate check_in_time format HH:MM
        if ($checkInTime && !preg_match('/^\d{2}:\d{2}$/', $checkInTime)) {
            $checkInTime = null;
        }

        // Support single user_id or array of user_ids
        if (empty($userIds)) {
            $singleId = isset($_POST['user_id']) ? (int) $_POST['user_id'] : 0;
            if ($singleId > 0) {
                $userIds = [$singleId];
            }
        }

        if (empty($userIds) || !is_array($userIds)) {
            echo json_encode(['success' => false, 'message' => 'No users selected']);
            exit;
        }

        $results = [];
        foreach ($userIds as $uid) {
            $uid = (int) $uid;
            if ($uid > 0) {
                $results[] = $plugin->markAttendance($uid, 'manual', $registeredBy, $notes, $status, $checkInTime);
            }
        }
        echo json_encode(['success' => true, 'results' => $results]);
        break;

    case 'get_attendance_list':
        $date = isset($_GET['date']) ? $_GET['date'] : date('Y-m-d');
        $records = $plugin->getAttendanceByDate($date);
        echo json_encode(['success' => true, 'data' => $records]);
        break;

    case 'save_schedule':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $data = [
            'id'         => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'name'       => isset($_POST['name']) ? trim($_POST['name']) : '',
            'entry_time' => isset($_POST['entry_time']) ? $_POST['entry_time'] : '',
            'late_time'  => isset($_POST['late_time']) ? $_POST['late_time'] : '',
            'applies_to' => isset($_POST['applies_to']) ? $_POST['applies_to'] : ['all'],
            'level_id'   => isset($_POST['level_id']) && $_POST['level_id'] !== '' ? (int) $_POST['level_id'] : null,
            'grade_id'   => isset($_POST['grade_id']) && $_POST['grade_id'] !== '' ? (int) $_POST['grade_id'] : null,
            'active'     => isset($_POST['active']) ? (int) $_POST['active'] : 1,
        ];

        if (empty($data['name']) || empty($data['entry_time']) || empty($data['late_time'])) {
            echo json_encode(['success' => false, 'message' => 'Missing required fields']);
            exit;
        }

        $plugin->saveSchedule($data);
        echo json_encode(['success' => true, 'message' => 'Schedule saved']);
        break;

    case 'delete_schedule':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $id = isset($_POST['id']) ? (int) $_POST['id'] : 0;
        if ($id <= 0) {
            echo json_encode(['success' => false, 'message' => 'Invalid schedule']);
            exit;
        }
        $plugin->deleteSchedule($id);
        echo json_encode(['success' => true, 'message' => 'Schedule deleted']);
        break;

    case 'get_schedule_users':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $scheduleId = isset($_GET['schedule_id']) ? (int) $_GET['schedule_id'] : 0;
        if ($scheduleId <= 0) {
            echo json_encode(['success' => false, 'message' => 'Invalid schedule']);
            exit;
        }
        $users = $plugin->getScheduleUserAssignments($scheduleId);
        echo json_encode(['success' => true, 'data' => $users]);
        break;

    case 'search_users_for_schedule':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $query = isset($_GET['q']) ? trim($_GET['q']) : '';
        if (strlen($query) < 2) {
            echo json_encode(['success' => true, 'data' => []]);
            exit;
        }
        $users = $plugin->searchUsersForScheduleAssignment($query);
        echo json_encode(['success' => true, 'data' => $users]);
        break;

    case 'assign_user_schedule':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $userId     = isset($_POST['user_id'])     ? (int) $_POST['user_id']     : 0;
        $scheduleId = isset($_POST['schedule_id']) ? (int) $_POST['schedule_id'] : 0;
        if ($userId <= 0 || $scheduleId <= 0) {
            echo json_encode(['success' => false, 'message' => 'Invalid parameters']);
            exit;
        }
        $plugin->assignUserSchedule($userId, $scheduleId);
        echo json_encode(['success' => true, 'message' => 'User assigned']);
        break;

    case 'remove_user_schedule':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $userId = isset($_POST['user_id']) ? (int) $_POST['user_id'] : 0;
        if ($userId <= 0) {
            echo json_encode(['success' => false, 'message' => 'Invalid user']);
            exit;
        }
        $plugin->removeUserSchedule($userId);
        echo json_encode(['success' => true, 'message' => 'Assignment removed']);
        break;

    case 'export_excel':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $startDate = isset($_GET['start_date'])  ? $_GET['start_date']       : null;
        $endDate   = isset($_GET['end_date'])     ? $_GET['end_date']         : null;
        $userType  = isset($_GET['user_type'])    ? $_GET['user_type']        : null;
        $levelId   = isset($_GET['level_id'])     ? (int) $_GET['level_id']   : 0;
        $gradeId   = isset($_GET['grade_id'])     ? (int) $_GET['grade_id']   : 0;
        $sectionId = isset($_GET['section_id'])   ? (int) $_GET['section_id'] : 0;
        $plugin->exportAttendanceExcel($startDate, $endDate, $userType, $levelId, $gradeId, $sectionId);
        break;

    case 'export_pdf':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $startDate = isset($_GET['start_date'])  ? $_GET['start_date']       : null;
        $endDate   = isset($_GET['end_date'])     ? $_GET['end_date']         : null;
        $userType  = isset($_GET['user_type'])    ? $_GET['user_type']        : null;
        $levelId   = isset($_GET['level_id'])     ? (int) $_GET['level_id']   : 0;
        $gradeId   = isset($_GET['grade_id'])     ? (int) $_GET['grade_id']   : 0;
        $sectionId = isset($_GET['section_id'])   ? (int) $_GET['section_id'] : 0;
        $plugin->exportAttendancePDF($startDate, $endDate, $userType, $levelId, $gradeId, $sectionId);
        break;

    case 'delete_attendance':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $attendanceId = isset($_POST['attendance_id']) ? (int) $_POST['attendance_id'] : 0;
        if ($attendanceId <= 0) {
            echo json_encode(['success' => false, 'message' => 'Invalid record']);
            exit;
        }
        $table = Database::get_main_table('plugin_school_attendance_log');
        $sql = "DELETE FROM $table WHERE id = $attendanceId";
        Database::query($sql);
        echo json_encode(['success' => true, 'message' => 'AttendanceDeleted']);
        break;

    case 'report_register_manual':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $userId      = isset($_POST['user_id'])       ? (int) $_POST['user_id']                        : 0;
        $date        = isset($_POST['date'])          ? trim($_POST['date'])                            : '';
        $status      = isset($_POST['status'])        ? trim($_POST['status'])                         : '';
        $checkInTime = isset($_POST['check_in_time']) ? trim($_POST['check_in_time'])                  : '';
        $notes       = isset($_POST['notes'])         ? trim($_POST['notes'])                          : null;
        $registeredBy = api_get_user_id();

        if ($userId <= 0 || empty($date) || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)
            || !in_array($status, ['on_time', 'late', 'absent'])
        ) {
            echo json_encode(['success' => false, 'message' => 'Datos inválidos']);
            exit;
        }

        // Build check_in datetime (store as UTC)
        if ($status !== 'absent' && preg_match('/^\d{2}:\d{2}$/', $checkInTime)) {
            $localDatetime = $date . ' ' . $checkInTime . ':00';
            $checkIn = api_get_utc_datetime($localDatetime);
        } else {
            $checkIn = $date . ' 00:00:00';
        }

        $logTable = Database::get_main_table('plugin_school_attendance_log');
        $safeDate = Database::escape_string($date);

        $existingResult = Database::query(
            "SELECT id FROM $logTable WHERE user_id = $userId AND date = '$safeDate' LIMIT 1"
        );
        $existing = Database::fetch_array($existingResult, 'ASSOC');

        if ($existing) {
            Database::update($logTable, [
                'status'        => $status,
                'check_in'      => $checkIn,
                'method'        => 'manual',
                'registered_by' => $registeredBy,
                'notes'         => $notes ? Database::escape_string($notes) : null,
            ], ['id = ?' => (int) $existing['id']]);
        } else {
            Database::insert($logTable, [
                'user_id'       => $userId,
                'date'          => $date,
                'status'        => $status,
                'check_in'      => $checkIn,
                'method'        => 'manual',
                'registered_by' => $registeredBy,
                'notes'         => $notes ? Database::escape_string($notes) : null,
                'created_at'    => api_get_utc_datetime(),
            ]);
        }

        echo json_encode(['success' => true, 'status' => $status]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        break;
}
