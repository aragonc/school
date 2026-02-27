<?php

require_once __DIR__ . '/../config.php';

$plugin = SchoolPlugin::create();

date_default_timezone_set(api_get_timezone());

header('Content-Type: application/json');

api_block_anonymous_users();

if (!api_is_platform_admin()) {
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

$action = isset($_POST['action']) ? $_POST['action'] : '';

switch ($action) {

    case 'add':
        $type        = isset($_POST['type'])        ? trim($_POST['type'])        : 'holiday';
        $startDate   = isset($_POST['start_date'])  ? trim($_POST['start_date'])  : '';
        $endDate     = isset($_POST['end_date'])     ? trim($_POST['end_date'])    : '';
        $description = isset($_POST['description']) ? trim($_POST['description']) : '';

        if (empty($startDate) || empty($endDate) || empty($description)) {
            echo json_encode(['success' => false, 'message' => 'Missing required fields']);
            exit;
        }

        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $startDate) || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $endDate)) {
            echo json_encode(['success' => false, 'message' => 'Invalid date format']);
            exit;
        }

        if ($endDate < $startDate) {
            echo json_encode(['success' => false, 'message' => 'End date must be >= start date']);
            exit;
        }

        $id = $plugin->addNonWorkingDay($type, $startDate, $endDate, $description);
        echo json_encode(['success' => $id > 0, 'id' => $id]);
        break;

    case 'delete':
        $id = isset($_POST['id']) ? (int) $_POST['id'] : 0;
        if (!$id) {
            echo json_encode(['success' => false, 'message' => 'Invalid ID']);
            exit;
        }
        $ok = $plugin->deleteNonWorkingDay($id);
        echo json_encode(['success' => $ok]);
        break;

    case 'generate_absences':
        $date = isset($_POST['date']) ? trim($_POST['date']) : date('Y-m-d');
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            echo json_encode(['success' => false, 'message' => 'Invalid date']);
            exit;
        }
        $result = $plugin->generateDailyAbsences($date);

        if ($result['skipped']) {
            $labels = [
                'weekend'    => $plugin->get_lang('SkippedWeekend'),
                'nonworking' => $plugin->get_lang('SkippedNonWorking'),
            ];
            $result['reason_label'] = isset($labels[$result['reason']]) ? $labels[$result['reason']] : $result['reason'];
        }
        $result['success'] = true;
        echo json_encode($result);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Unknown action']);
        break;
}
