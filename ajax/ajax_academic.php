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

if (!$isAdmin) {
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
            'id'             => isset($_POST['id']) ? (int) $_POST['id'] : 0,
            'name'           => $_POST['name'] ?? '',
            'order_index'    => $_POST['order_index'] ?? 0,
            'years_duration' => isset($_POST['years_duration']) ? max(1, (int) $_POST['years_duration']) : 1,
            'active'         => isset($_POST['active']) ? (int) $_POST['active'] : 1,
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

    // =========================================================================
    // CLASSROOM SESSION
    // =========================================================================
    case 'search_sessions':
        $query = $_GET['q'] ?? '';
        $sessions = AcademicManager::searchSessions($query);
        echo json_encode(['success' => true, 'data' => $sessions]);
        break;

    case 'assign_session':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $sessionId   = (int) ($_POST['session_id'] ?? 0);
        $result = AcademicManager::assignSessionToClassroom($classroomId, $sessionId);
        echo json_encode(['success' => $result]);
        break;

    case 'remove_session':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $result = AcademicManager::removeSessionFromClassroom($classroomId);
        echo json_encode([
            'success' => $result['error'] === null,
            'removed' => $result['removed'],
            'message' => $result['error'] ?? '',
        ]);
        break;

    case 'enroll_to_session':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $result = AcademicManager::enrollClassroomStudentsToSession($classroomId);
        echo json_encode([
            'success'  => $result['error'] === null,
            'enrolled' => $result['enrolled'],
            'skipped'  => $result['skipped'],
            'message'  => $result['error'] ?? '',
        ]);
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

    case 'update_supervisor':
        $classroomId  = (int) ($_POST['classroom_id'] ?? 0);
        $supervisorId = (int) ($_POST['supervisor_id'] ?? 0);
        if ($classroomId > 0) {
            $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
            Database::update($table, ['supervisor_id' => $supervisorId ?: null], ['id = ?' => $classroomId]);
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

    case 'get_classroom_candidates':
        $classroomId = (int) ($_GET['classroom_id'] ?? 0);
        $candidates = AcademicManager::getClassroomCandidates($classroomId);
        echo json_encode(['success' => true, 'data' => $candidates]);
        break;

    case 'add_students_bulk':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $userIds = isset($_POST['user_ids']) ? (array) $_POST['user_ids'] : [];
        if ($classroomId <= 0 || empty($userIds)) {
            echo json_encode(['success' => false, 'message' => 'Invalid parameters']);
            break;
        }
        $result = AcademicManager::addStudentsBulk($classroomId, $userIds);
        echo json_encode(['success' => true, 'added' => $result['added'], 'skipped' => $result['skipped']]);
        break;

    // =========================================================================
    // CLASSROOM AUXILIARIES
    // =========================================================================
    case 'get_auxiliaries':
        $classroomId = (int) ($_GET['classroom_id'] ?? 0);
        $aux = AcademicManager::getClassroomAuxiliaries($classroomId);
        echo json_encode(['success' => true, 'data' => $aux]);
        break;

    case 'add_auxiliary':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $userId = (int) ($_POST['user_id'] ?? 0);
        $result = AcademicManager::addAuxiliary($classroomId, $userId);
        echo json_encode([
            'success' => $result,
            'message' => $result ? '' : 'No se puede agregar: ya existe o se alcanzó el límite de 3 auxiliares',
        ]);
        break;

    case 'remove_auxiliary':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $userId = (int) ($_POST['user_id'] ?? 0);
        $result = AcademicManager::removeAuxiliary($classroomId, $userId);
        echo json_encode(['success' => $result]);
        break;

    case 'search_auxiliaries':
        $query = $_GET['q'] ?? '';
        $results = AcademicManager::searchAuxiliaries($query);
        echo json_encode(['success' => true, 'data' => $results]);
        break;

    // =========================================================================
    // SEARCH
    // =========================================================================
    case 'search_students':
        $query = $_GET['q'] ?? '';
        $students = AcademicManager::searchStudents($query);
        echo json_encode(['success' => true, 'data' => $students]);
        break;

    case 'assign_course_teacher':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $courseId    = (int) ($_POST['course_id']    ?? 0);
        $teacherId   = (int) ($_POST['teacher_id']   ?? 0);
        $sessionId   = (int) ($_POST['session_id']   ?? 0);
        if ($classroomId > 0 && $courseId > 0 && $teacherId > 0) {
            // 1. Guardar en tabla permanente del plugin
            $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
            $ctTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
            $ccRow   = Database::fetch_array(Database::query(
                "SELECT id FROM $ccTable
                 WHERE classroom_id = $classroomId AND course_id = $courseId
                 LIMIT 1"
            ), 'ASSOC');
            if ($ccRow) {
                $classroomCourseId = (int) $ccRow['id'];
                $exists = Database::fetch_array(Database::query(
                    "SELECT id FROM $ctTable
                     WHERE classroom_course_id = $classroomCourseId AND teacher_id = $teacherId
                     LIMIT 1"
                ), 'ASSOC');
                if (!$exists) {
                    Database::insert($ctTable, [
                        'classroom_course_id' => $classroomCourseId,
                        'teacher_id'          => $teacherId,
                        'created_at'          => date('Y-m-d H:i:s'),
                    ]);
                }
            }
            // 2. También guardar en tabla Chamilo si hay sesión activa
            if ($sessionId > 0) {
                $srcuTable = Database::get_main_table(TABLE_MAIN_SESSION_COURSE_USER);
                $exists    = Database::fetch_array(Database::query(
                    "SELECT id FROM $srcuTable
                     WHERE session_id=$sessionId AND c_id=$courseId
                       AND user_id=$teacherId AND status=2
                     LIMIT 1"
                ), 'ASSOC');
                if (!$exists) {
                    Database::insert($srcuTable, [
                        'session_id'      => $sessionId,
                        'c_id'            => $courseId,
                        'user_id'         => $teacherId,
                        'status'          => 2,
                        'visibility'      => 0,
                        'legal_agreement' => 0,
                    ]);
                }
            }
            $uInfo = api_get_user_info($teacherId);
            echo json_encode([
                'success'   => true,
                'user_id'   => $teacherId,
                'firstname' => $uInfo['firstname']    ?? '',
                'lastname'  => $uInfo['lastname']     ?? '',
                'email'     => $uInfo['email']        ?? '',
                'avatar'    => $uInfo['avatar_small'] ?? '',
            ]);
        } else {
            echo json_encode(['success' => false]);
        }
        break;

    case 'remove_course_teacher':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $courseId    = (int) ($_POST['course_id']    ?? 0);
        $teacherId   = (int) ($_POST['teacher_id']   ?? 0);
        $sessionId   = (int) ($_POST['session_id']   ?? 0);
        if ($classroomId > 0 && $courseId > 0 && $teacherId > 0) {
            // 1. Borrar de tabla permanente del plugin
            $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
            $ctTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
            $ccRow   = Database::fetch_array(Database::query(
                "SELECT id FROM $ccTable
                 WHERE classroom_id = $classroomId AND course_id = $courseId
                 LIMIT 1"
            ), 'ASSOC');
            if ($ccRow) {
                $classroomCourseId = (int) $ccRow['id'];
                Database::delete($ctTable, [
                    'classroom_course_id = ? AND teacher_id = ?' => [$classroomCourseId, $teacherId],
                ]);
            }
            // 2. También borrar de tabla Chamilo si hay sesión activa
            if ($sessionId > 0) {
                $srcuTable = Database::get_main_table(TABLE_MAIN_SESSION_COURSE_USER);
                Database::delete($srcuTable, [
                    'session_id = ? AND c_id = ? AND user_id = ? AND status = 2'
                        => [$sessionId, $courseId, $teacherId],
                ]);
            }
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false]);
        }
        break;

    case 'search_teachers':
        $query = $_GET['q'] ?? '';
        $teachers = AcademicManager::searchTeachers($query);
        echo json_encode(['success' => true, 'data' => $teachers]);
        break;

    case 'search_courses':
        $query       = $_GET['q'] ?? '';
        $classroomId = (int) ($_GET['classroom_id'] ?? 0);
        $courses     = AcademicManager::searchCourses($query, $classroomId);
        echo json_encode(['success' => true, 'data' => $courses]);
        break;

    case 'add_classroom_course':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $courseId    = (int) ($_POST['course_id']    ?? 0);
        $sessionId   = (int) ($_POST['session_id']   ?? 0);
        if ($classroomId > 0 && $courseId > 0) {
            $clTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
            $clRow   = Database::fetch_array(Database::query(
                "SELECT academic_year_id FROM $clTable WHERE id = $classroomId LIMIT 1"
            ), 'ASSOC');
            if ($clRow) {
                $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
                $exists  = Database::fetch_array(Database::query(
                    "SELECT id FROM $ccTable WHERE classroom_id=$classroomId AND course_id=$courseId LIMIT 1"
                ), 'ASSOC');
                if (!$exists) {
                    Database::insert($ccTable, [
                        'classroom_id'     => $classroomId,
                        'course_id'        => $courseId,
                        'academic_year_id' => (int) $clRow['academic_year_id'],
                        'session_id'       => $sessionId ?: null,
                        'created_at'       => date('Y-m-d H:i:s'),
                    ]);
                }
                // También agregar a la sesión Chamilo si existe
                if ($sessionId > 0) {
                    $srcTable = Database::get_main_table(TABLE_MAIN_SESSION_COURSE);
                    $sexists  = Database::fetch_array(Database::query(
                        "SELECT id FROM $srcTable WHERE session_id=$sessionId AND c_id=$courseId LIMIT 1"
                    ), 'ASSOC');
                    if (!$sexists) {
                        Database::insert($srcTable, [
                            'session_id' => $sessionId,
                            'c_id'       => $courseId,
                            'nbr_users'  => 0,
                            'position'   => 0,
                        ]);
                    }
                }
                echo json_encode(['success' => true, 'course_id' => $courseId]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Classroom not found']);
            }
        } else {
            echo json_encode(['success' => false]);
        }
        break;

    case 'remove_classroom_course':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $courseId    = (int) ($_POST['course_id']    ?? 0);
        $sessionId   = (int) ($_POST['session_id']   ?? 0);
        if ($classroomId > 0 && $courseId > 0) {
            $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
            $ctTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
            $ccRow   = Database::fetch_array(Database::query(
                "SELECT id FROM $ccTable WHERE classroom_id=$classroomId AND course_id=$courseId LIMIT 1"
            ), 'ASSOC');
            if ($ccRow) {
                $classroomCourseId = (int) $ccRow['id'];
                // Borrar docentes del curso en el plugin
                Database::delete($ctTable, ['classroom_course_id = ?' => $classroomCourseId]);
                // Borrar el curso del plugin
                Database::delete($ccTable, ['id = ?' => $classroomCourseId]);
            }
            // Borrar de tablas Chamilo si hay sesión activa
            if ($sessionId > 0) {
                $srcTable  = Database::get_main_table(TABLE_MAIN_SESSION_COURSE);
                $srcuTable = Database::get_main_table(TABLE_MAIN_SESSION_COURSE_USER);
                Database::delete($srcuTable, [
                    'session_id = ? AND c_id = ?' => [$sessionId, $courseId],
                ]);
                Database::delete($srcTable, [
                    'session_id = ? AND c_id = ?' => [$sessionId, $courseId],
                ]);
            }
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false]);
        }
        break;

    case 'sync_session_courses':
        $classroomId = (int) ($_POST['classroom_id'] ?? 0);
        $sessionId   = (int) ($_POST['session_id']   ?? 0);
        if ($classroomId > 0 && $sessionId > 0) {
            $added = AcademicManager::syncSessionCourses($classroomId, $sessionId);
            echo json_encode(['success' => true, 'added' => $added]);
        } else {
            echo json_encode(['success' => false]);
        }
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
