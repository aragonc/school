<?php

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../src/CurriculaManager.php';

header('Content-Type: application/json');

$plugin = SchoolPlugin::create();

if (!$plugin->isUserLoggedIn() || !api_is_platform_admin()) {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$action = $_POST['action'] ?? '';

switch ($action) {

    // ---- ÁREAS ----
    case 'save_area':
        $name = trim($_POST['name'] ?? '');
        if (empty($name)) {
            echo json_encode(['success' => false, 'message' => 'Name required']);
            exit;
        }
        $id = CurriculaManager::saveArea([
            'id'    => (int) ($_POST['id'] ?? 0),
            'name'  => $name,
            'level' => $_POST['level'] ?? 'ambos',
        ]);
        echo json_encode(['success' => true, 'id' => $id]);
        break;

    case 'delete_area':
        $id = (int) ($_POST['id'] ?? 0);
        CurriculaManager::deleteArea($id);
        echo json_encode(['success' => true]);
        break;

    // ---- COMPETENCIAS ----
    case 'save_competencia':
        $name = trim($_POST['name'] ?? '');
        if (empty($name)) {
            echo json_encode(['success' => false, 'message' => 'Name required']);
            exit;
        }
        $id = CurriculaManager::saveCompetencia([
            'id'      => (int) ($_POST['id'] ?? 0),
            'area_id' => (int) ($_POST['area_id'] ?? 0),
            'name'    => $name,
        ]);
        echo json_encode(['success' => true, 'id' => $id]);
        break;

    case 'delete_competencia':
        CurriculaManager::deleteCompetencia((int) ($_POST['id'] ?? 0));
        echo json_encode(['success' => true]);
        break;

    // ---- CAPACIDADES ----
    case 'save_capacidad':
        $name = trim($_POST['name'] ?? '');
        if (empty($name)) {
            echo json_encode(['success' => false, 'message' => 'Name required']);
            exit;
        }
        $id = CurriculaManager::saveCapacidad([
            'id'      => (int) ($_POST['id'] ?? 0),
            'area_id' => (int) ($_POST['area_id'] ?? 0),
            'name'    => $name,
        ]);
        echo json_encode(['success' => true, 'id' => $id]);
        break;

    case 'delete_capacidad':
        CurriculaManager::deleteCapacidad((int) ($_POST['id'] ?? 0));
        echo json_encode(['success' => true]);
        break;

    // ---- COMPETENCIAS TRANSVERSALES ----
    case 'save_transversal':
        $name = trim($_POST['name'] ?? '');
        if (empty($name)) {
            echo json_encode(['success' => false, 'message' => 'Name required']);
            exit;
        }
        $id = CurriculaManager::saveTransversal([
            'id'    => (int) ($_POST['id'] ?? 0),
            'name'  => $name,
            'level' => $_POST['level'] ?? 'ebr',
        ]);
        echo json_encode(['success' => true, 'id' => $id]);
        break;

    case 'delete_transversal':
        CurriculaManager::deleteTransversal((int) ($_POST['id'] ?? 0));
        echo json_encode(['success' => true]);
        break;

    // ---- CAPACIDADES DE COMPETENCIAS TRANSVERSALES ----
    case 'save_transversal_cap':
        $name = trim($_POST['name'] ?? '');
        if (empty($name)) {
            echo json_encode(['success' => false, 'message' => 'Name required']);
            exit;
        }
        $id = CurriculaManager::saveTransversalCap([
            'id'             => (int) ($_POST['id'] ?? 0),
            'transversal_id' => (int) ($_POST['transversal_id'] ?? 0),
            'name'           => $name,
        ]);
        echo json_encode(['success' => true, 'id' => $id]);
        break;

    case 'delete_transversal_cap':
        CurriculaManager::deleteTransversalCap((int) ($_POST['id'] ?? 0));
        echo json_encode(['success' => true]);
        break;

    // ---- ENFOQUES ----
    case 'save_enfoque':
        $name = trim($_POST['name'] ?? '');
        if (empty($name)) {
            echo json_encode(['success' => false, 'message' => 'Name required']);
            exit;
        }
        $id = CurriculaManager::saveEnfoque([
            'id'    => (int) ($_POST['id'] ?? 0),
            'name'  => $name,
            'level' => $_POST['level'] ?? 'ebr',
        ]);
        echo json_encode(['success' => true, 'id' => $id]);
        break;

    case 'delete_enfoque':
        CurriculaManager::deleteEnfoque((int) ($_POST['id'] ?? 0));
        echo json_encode(['success' => true]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Unknown action']);
        break;
}
