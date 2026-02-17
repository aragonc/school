<?php

require_once __DIR__.'/../config.php';

$plugin = SchoolPlugin::create();

$action = isset($_REQUEST['action']) ? $_REQUEST['action'] : '';

header('Content-Type: application/json');

// Require login
$userId = api_get_user_id();
if (!$userId) {
    echo json_encode(['success' => false, 'message' => 'Not authenticated']);
    exit;
}

$isAdmin = api_is_platform_admin();
$userInfo = api_get_user_info();
$isSecretary = $userInfo && $userInfo['status'] == SCHOOL_SECRETARY;
$isAdminOrSecretary = $isAdmin || $isSecretary;

switch ($action) {
    case 'save_period':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $data = [
            'id' => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'name' => $_POST['name'] ?? '',
            'year' => $_POST['year'] ?? date('Y'),
            'admission_amount' => $_POST['admission_amount'] ?? 0,
            'enrollment_amount' => $_POST['enrollment_amount'] ?? 0,
            'monthly_amount' => $_POST['monthly_amount'] ?? 0,
            'months' => $_POST['months'] ?? '',
            'active' => isset($_POST['active']) ? (int) $_POST['active'] : 1,
        ];
        $result = $plugin->savePeriod($data);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_period':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = $plugin->deletePeriod($id);
        echo json_encode(['success' => $result]);
        break;

    case 'save_payment':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $data = [
            'period_id' => $_POST['period_id'] ?? 0,
            'user_id' => $_POST['user_id'] ?? 0,
            'type' => $_POST['type'] ?? '',
            'month' => $_POST['month'] ?? null,
            'amount' => $_POST['amount'] ?? null,
            'payment_date' => $_POST['payment_date'] ?? '',
            'payment_method' => $_POST['payment_method'] ?? 'cash',
            'reference' => $_POST['reference'] ?? '',
            'notes' => $_POST['notes'] ?? '',
        ];

        // Handle voucher upload
        if (!empty($_FILES['voucher']) && $_FILES['voucher']['error'] === UPLOAD_ERR_OK) {
            $allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
            $fileType = $_FILES['voucher']['type'];
            if (in_array($fileType, $allowed)) {
                $ext = pathinfo($_FILES['voucher']['name'], PATHINFO_EXTENSION);
                $studentId = (int) ($data['user_id'] ?? 0);
                $fileName = $studentId . '_' . date('Y-m-d_His') . '.' . $ext;
                $uploadDir = __DIR__ . '/../uploads/';
                if (move_uploaded_file($_FILES['voucher']['tmp_name'], $uploadDir . $fileName)) {
                    $data['voucher'] = $fileName;
                }
            }
        }

        $paymentId = $plugin->savePayment($data);
        echo json_encode(['success' => $paymentId > 0, 'payment_id' => $paymentId]);
        break;

    case 'delete_payment':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = $plugin->deletePayment($id);
        echo json_encode(['success' => $result]);
        break;

    case 'save_discount':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $data = [
            'id' => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'period_id' => $_POST['period_id'] ?? 0,
            'user_id' => $_POST['user_id'] ?? 0,
            'discount_type' => $_POST['discount_type'] ?? 'fixed',
            'discount_value' => $_POST['discount_value'] ?? 0,
            'applies_to' => $_POST['applies_to'] ?? 'all',
            'reason' => $_POST['reason'] ?? '',
        ];
        $result = $plugin->saveDiscount($data);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_discount':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = $plugin->deleteDiscount($id);
        echo json_encode(['success' => $result]);
        break;

    case 'get_student_payments':
        $periodId = (int) ($_GET['period_id'] ?? 0);
        $studentId = (int) ($_GET['user_id'] ?? 0);

        // Students can only see their own payments
        if (!$isAdminOrSecretary && $studentId != $userId) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }

        $payments = $plugin->getStudentPayments($periodId, $studentId);
        echo json_encode(['success' => true, 'data' => $payments]);
        break;

    case 'export_report':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $periodId = (int) ($_GET['period_id'] ?? 0);
        $month = isset($_GET['month']) && $_GET['month'] !== '' ? (int) $_GET['month'] : null;
        $filter = $_GET['filter'] ?? 'all';
        $plugin->exportPaymentReportCSV($periodId, $month, $filter);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        break;
}
