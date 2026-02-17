<?php

require_once __DIR__.'/../config.php';

$plugin = SchoolPlugin::create();

$action = isset($_REQUEST['action']) ? $_REQUEST['action'] : '';

header('Content-Type: application/json');

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
    case 'save_category':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $data = [
            'id' => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'name' => $_POST['name'] ?? '',
            'active' => isset($_POST['active']) ? (int) $_POST['active'] : 1,
        ];
        $result = $plugin->saveProductCategory($data);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_category':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = $plugin->deleteProductCategory($id);
        echo json_encode(['success' => $result]);
        break;

    case 'save_product':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $data = [
            'id' => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'name' => $_POST['name'] ?? '',
            'description' => $_POST['description'] ?? '',
            'price' => $_POST['price'] ?? 0,
            'category_id' => $_POST['category_id'] ?? '',
            'active' => isset($_POST['active']) ? (int) $_POST['active'] : 1,
        ];
        $result = $plugin->saveProduct($data);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_product':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = $plugin->deleteProduct($id);
        echo json_encode(['success' => $result]);
        break;

    case 'save_sale':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $data = [
            'product_id' => $_POST['product_id'] ?? 0,
            'user_id' => $_POST['user_id'] ?? 0,
            'quantity' => $_POST['quantity'] ?? 1,
            'unit_price' => $_POST['unit_price'] ?? 0,
            'discount' => $_POST['discount'] ?? 0,
            'payment_method' => $_POST['payment_method'] ?? 'cash',
            'reference' => $_POST['reference'] ?? '',
            'notes' => $_POST['notes'] ?? '',
        ];
        $saleId = $plugin->saveProductSale($data);
        echo json_encode(['success' => $saleId > 0, 'sale_id' => $saleId]);
        break;

    case 'delete_sale':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = $plugin->deleteProductSale($id);
        echo json_encode(['success' => $result]);
        break;

    case 'search_students':
        if (!$isAdminOrSecretary) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $query = isset($_REQUEST['q']) ? trim($_REQUEST['q']) : '';
        $results = [];
        if (strlen($query) >= 2) {
            $conditions = [
                'username' => $query,
                'firstname' => $query,
                'lastname' => $query,
            ];
            $users = UserManager::getUserListLike($conditions, [], false, 'OR');
            foreach ($users as $user) {
                $results[] = [
                    'id' => $user['id'],
                    'text' => $user['complete_name'] . ' (' . $user['username'] . ')',
                ];
            }
        }
        echo json_encode(['items' => $results]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        break;
}
