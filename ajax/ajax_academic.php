<?php

require_once __DIR__.'/../config.php';
require_once __DIR__.'/../src/AcademicManager.php';

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

if (!$isAdminOrSecretary) {
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

switch ($action) {
    // =========================================================================
    // ACADEMIC YEARS
    // =========================================================================
    case 'save_year':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $data = [
            'id' => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'name' => $_POST['name'] ?? '',
            'year' => $_POST['year'] ?? date('Y'),
            'active' => isset($_POST['active']) ? (int) $_POST['active'] : 1,
        ];
        $result = AcademicManager::saveAcademicYear($data);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_year':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = AcademicManager::deleteAcademicYear($id);
        echo json_encode(['success' => $result, 'message' => $result ? '' : 'No se puede eliminar: tiene aulas asociadas']);
        break;

    // =========================================================================
    // LEVELS
    // =========================================================================
    case 'save_level':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $data = [
            'id' => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'name' => $_POST['name'] ?? '',
            'order_index' => $_POST['order_index'] ?? 0,
            'active' => isset($_POST['active']) ? (int) $_POST['active'] : 1,
        ];
        $result = AcademicManager::saveLevel($data);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_level':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = AcademicManager::deleteLevel($id);
        echo json_encode(['success' => $result, 'message' => $result ? '' : 'No se puede eliminar: tiene grados asociados']);
        break;

    // =========================================================================
    // GRADES
    // =========================================================================
    case 'save_grade':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $data = [
            'id' => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'level_id' => $_POST['level_id'] ?? 0,
            'name' => $_POST['name'] ?? '',
            'order_index' => $_POST['order_index'] ?? 0,
            'active' => isset($_POST['active']) ? (int) $_POST['active'] : 1,
        ];
        $result = AcademicManager::saveGrade($data);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_grade':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = AcademicManager::deleteGrade($id);
        echo json_encode(['success' => $result, 'message' => $result ? '' : 'No se puede eliminar: tiene aulas asociadas']);
        break;

    // =========================================================================
    // SECTIONS
    // =========================================================================
    case 'save_section':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $data = [
            'id' => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'name' => $_POST['name'] ?? '',
            'active' => isset($_POST['active']) ? (int) $_POST['active'] : 1,
        ];
        $result = AcademicManager::saveSection($data);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_section':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = AcademicManager::deleteSection($id);
        echo json_encode(['success' => $result, 'message' => $result ? '' : 'No se puede eliminar: tiene aulas asociadas']);
        break;

    // =========================================================================
    // CLASSROOMS
    // =========================================================================
    case 'save_classroom':
        $data = [
            'id' => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'academic_year_id' => $_POST['academic_year_id'] ?? 0,
            'grade_id' => $_POST['grade_id'] ?? 0,
            'section_id' => $_POST['section_id'] ?? 0,
            'tutor_id' => $_POST['tutor_id'] ?? null,
            'capacity' => $_POST['capacity'] ?? 30,
            'active' => isset($_POST['active']) ? (int) $_POST['active'] : 1,
        ];
        $result = AcademicManager::saveClassroom($data);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_classroom':
        $id = (int) ($_POST['id'] ?? 0);
        $result = AcademicManager::deleteClassroom($id);
        echo json_encode(['success' => $result]);
        break;

    case 'update_tutor':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $tutorId = (int) ($_POST['tutor_id'] ?? 0);
        if ($classroomId > 0) {
            $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
            Database::update($table, ['tutor_id' => $tutorId ?: null], ['id = ?' => $classroomId]);
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false]);
        }
        break;

    // =========================================================================
    // CLASSROOM STUDENTS
    // =========================================================================
    case 'add_student':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $studentId = (int) ($_POST['user_id'] ?? 0);
        $result = AcademicManager::addStudentToClassroom($classroomId, $studentId);
        echo json_encode(['success' => $result, 'message' => $result ? '' : 'El alumno ya está en esta aula']);
        break;

    case 'remove_student':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $studentId = (int) ($_POST['user_id'] ?? 0);
        $result = AcademicManager::removeStudentFromClassroom($classroomId, $studentId);
        echo json_encode(['success' => $result]);
        break;

    // =========================================================================
    // SEARCH
    // =========================================================================
    case 'search_students':
        $query = $_GET['q'] ?? '';
        $students = AcademicManager::searchStudents($query);
        echo json_encode(['success' => true, 'data' => $students]);
        break;

    case 'search_teachers':
        $query = $_GET['q'] ?? '';
        $teachers = AcademicManager::searchTeachers($query);
        echo json_encode(['success' => true, 'data' => $teachers]);
        break;

    // =========================================================================
    // PERIOD PRICING
    // =========================================================================
    case 'get_period_prices':
        $periodId = (int) ($_GET['period_id'] ?? 0);
        $prices = AcademicManager::getPeriodPriceList($periodId);
        echo json_encode(['success' => true, 'data' => $prices]);
        break;

    case 'save_period_price':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = isset($_POST['id']) ? (int) $_POST['id'] : 0;
        $base = [
            'period_id'        => $_POST['period_id'] ?? 0,
            'level_id'         => $_POST['level_id'] ?? 0,
            'admission_amount' => $_POST['admission_amount'] ?? 0,
            'enrollment_amount'=> $_POST['enrollment_amount'] ?? 0,
            'monthly_amount'   => $_POST['monthly_amount'] ?? 0,
        ];

        if ($id > 0) {
            // Edit existing: single record
            $base['id']       = $id;
            $base['grade_id'] = $_POST['grade_id'] ?? null;
            AcademicManager::savePeriodPrice($base);
        } else {
            // New: one record per selected grade (or one level-wide if none selected)
            $gradeIds = isset($_POST['grade_ids']) ? (array) $_POST['grade_ids'] : [''];
            foreach ($gradeIds as $gid) {
                $entry = $base;
                $entry['id']       = 0;
                $entry['grade_id'] = ($gid !== '' && $gid !== null) ? $gid : null;
                AcademicManager::savePeriodPrice($entry);
            }
        }
        echo json_encode(['success' => true]);
        break;

    case 'delete_period_price':
        if (!$isAdmin) {
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            exit;
        }
        $id = (int) ($_POST['id'] ?? 0);
        $result = AcademicManager::deletePeriodPrice($id);
        echo json_encode(['success' => $result]);
        break;

    case 'resolve_student_price':
        $periodId = (int) ($_GET['period_id'] ?? 0);
        $userId = (int) ($_GET['user_id'] ?? 0);
        $price = AcademicManager::resolveStudentPrice($periodId, $userId);
        echo json_encode(['success' => true, 'data' => $price]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        break;
}
