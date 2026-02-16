<?php

require_once __DIR__.'/../config.php';

$plugin = SchoolPlugin::create();

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
        $userIds = isset($_POST['user_ids']) ? $_POST['user_ids'] : [];
        $notes = isset($_POST['notes']) ? trim($_POST['notes']) : null;
        $status = isset($_POST['status']) ? $_POST['status'] : null;
        $registeredBy = api_get_user_id();

        // Validate status if provided
        if ($status && !in_array($status, ['on_time', 'late', 'absent'])) {
            echo json_encode(['success' => false, 'message' => 'Invalid status']);
            exit;
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
                $results[] = $plugin->markAttendance($uid, 'manual', $registeredBy, $notes, $status);
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
            'id' => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'name' => isset($_POST['name']) ? trim($_POST['name']) : '',
            'entry_time' => isset($_POST['entry_time']) ? $_POST['entry_time'] : '',
            'late_time' => isset($_POST['late_time']) ? $_POST['late_time'] : '',
            'applies_to' => isset($_POST['applies_to']) ? $_POST['applies_to'] : ['all'],
            'active' => isset($_POST['active']) ? (int) $_POST['active'] : 1,
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

    case 'export_excel':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $startDate = isset($_GET['start_date']) ? $_GET['start_date'] : null;
        $endDate = isset($_GET['end_date']) ? $_GET['end_date'] : null;
        $userType = isset($_GET['user_type']) ? $_GET['user_type'] : null;
        $plugin->exportAttendanceCSV($startDate, $endDate, $userType);
        break;

    case 'export_pdf':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Not authorized']);
            exit;
        }
        $startDate = isset($_GET['start_date']) ? $_GET['start_date'] : null;
        $endDate = isset($_GET['end_date']) ? $_GET['end_date'] : null;
        $userType = isset($_GET['user_type']) ? $_GET['user_type'] : null;
        $plugin->exportAttendancePDF($startDate, $endDate, $userType);
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

    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        break;
}
