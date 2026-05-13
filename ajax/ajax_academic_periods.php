<?php

require_once __DIR__ . '/../config.php';

header('Content-Type: application/json');

$plugin = SchoolPlugin::create();

$userId = api_get_user_id();
if (!$userId || !api_is_platform_admin()) {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$action = $_POST['action'] ?? ($_GET['action'] ?? '');
$periodTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_PERIOD);

switch ($action) {

    case 'save_period':
        $id            = (int) ($_POST['id'] ?? 0);
        $academicYearId = (int) ($_POST['academic_year_id'] ?? 0);
        $name          = trim($_POST['name'] ?? '');
        $dateStart     = trim($_POST['date_start'] ?? '');
        $dateEnd       = trim($_POST['date_end'] ?? '');
        $orderIndex    = (int) ($_POST['order_index'] ?? 0);

        if (!$academicYearId || empty($name) || empty($dateStart) || empty($dateEnd)) {
            echo json_encode(['success' => false, 'message' => 'Todos los campos son obligatorios']);
            exit;
        }

        if ($dateStart >= $dateEnd) {
            echo json_encode(['success' => false, 'message' => 'La fecha de inicio debe ser anterior a la fecha de fin']);
            exit;
        }

        $name_e      = Database::escape_string($name);
        $dateStart_e = Database::escape_string($dateStart);
        $dateEnd_e   = Database::escape_string($dateEnd);

        if ($id > 0) {
            Database::query(
                "UPDATE $periodTable
                 SET name='$name_e', date_start='$dateStart_e', date_end='$dateEnd_e', order_index=$orderIndex
                 WHERE id=$id AND academic_year_id=$academicYearId"
            );
        } else {
            Database::query(
                "INSERT INTO $periodTable (academic_year_id, name, date_start, date_end, active, order_index)
                 VALUES ($academicYearId, '$name_e', '$dateStart_e', '$dateEnd_e', 1, $orderIndex)"
            );
            $id = Database::insert_id();
        }
        echo json_encode(['success' => true, 'id' => $id]);
        break;

    case 'delete_period':
        $id = (int) ($_POST['id'] ?? 0);
        if ($id <= 0) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            exit;
        }
        Database::query("DELETE FROM $periodTable WHERE id = $id");
        echo json_encode(['success' => true]);
        break;

    case 'toggle_active':
        $id     = (int) ($_POST['id'] ?? 0);
        $active = (int) ($_POST['active'] ?? 1);
        if ($id <= 0) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            exit;
        }
        Database::query("UPDATE $periodTable SET active = $active WHERE id = $id");
        echo json_encode(['success' => true]);
        break;

    case 'get_periods_for_year':
        $yearId = (int) ($_GET['year_id'] ?? 0);
        if ($yearId <= 0) {
            echo json_encode(['success' => false, 'message' => 'year_id requerido']);
            exit;
        }
        $res = Database::query(
            "SELECT * FROM $periodTable WHERE academic_year_id = $yearId AND active = 1
             ORDER BY order_index ASC, date_start ASC"
        );
        $periods = [];
        while ($row = Database::fetch_array($res, 'ASSOC')) {
            $periods[] = $row;
        }
        echo json_encode(['success' => true, 'periods' => $periods]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Unknown action']);
        break;
}
