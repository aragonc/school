<?php

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../src/AcademicManager.php';
require_once __DIR__ . '/../src/CurriculaManager.php';
require_once __DIR__ . '/../src/MatriculaManager.php';

header('Content-Type: application/json');

$plugin = SchoolPlugin::create();

$userId = api_get_user_id();
if (!$userId) {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$isAdmin   = api_is_platform_admin();
$userInfo  = api_get_user_info($userId);
$isTeacher = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;

if (!$isAdmin && !$isTeacher) {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$action = $_POST['action'] ?? ($_GET['action'] ?? '');

switch ($action) {

    case 'get_curricula_for_area':
        $areaId = (int) ($_GET['area_id'] ?? 0);
        if ($areaId <= 0) {
            echo json_encode(['success' => false, 'message' => 'area_id required']);
            exit;
        }
        $compTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_COMPETENCIA);
        $capTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_CAPACIDAD);
        $res = Database::query(
            "SELECT id, name FROM $compTable WHERE area_id = $areaId AND active = 1 ORDER BY order_index ASC"
        );
        $competencias = [];
        while ($row = Database::fetch_array($res, 'ASSOC')) {
            $competencias[] = $row;
        }
        $res2 = Database::query(
            "SELECT id, name FROM $capTable WHERE area_id = $areaId AND active = 1 ORDER BY order_index ASC"
        );
        $capacidades = [];
        while ($row = Database::fetch_array($res2, 'ASSOC')) {
            $capacidades[] = $row;
        }
        $tTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL);
        $tcTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL_CAP);
        $res3 = Database::query(
            "SELECT id, name FROM $tTable WHERE active = 1 ORDER BY order_index ASC"
        );
        $transversales = [];
        while ($row = Database::fetch_array($res3, 'ASSOC')) {
            $capRes = Database::query(
                "SELECT id, name FROM $tcTable WHERE transversal_id = {$row['id']} AND active = 1 ORDER BY order_index ASC"
            );
            $caps = [];
            while ($capRow = Database::fetch_array($capRes, 'ASSOC')) {
                $caps[] = $capRow;
            }
            $row['capacidades'] = $caps;
            $transversales[] = $row;
        }
        echo json_encode([
            'success'       => true,
            'competencias'  => $competencias,
            'capacidades'   => $capacidades,
            'transversales' => $transversales,
        ]);
        break;

    case 'create_registro':
        $classroomCourseId = (int) ($_POST['classroom_course_id'] ?? 0);
        $period            = trim($_POST['period'] ?? '');
        $gradeType         = $_POST['grade_type'] ?? 'letter';
        $areaId            = (int) ($_POST['area_id'] ?? 0);

        if ($classroomCourseId <= 0 || empty($period)) {
            echo json_encode(['success' => false, 'message' => 'Datos incompletos']);
            exit;
        }

        if (!in_array($gradeType, ['numeric', 'letter', 'combined'])) {
            $gradeType = 'letter';
        }

        // Verify teacher owns this classroom_course
        if (!$isAdmin) {
            $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
            $ctTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
            $check = Database::fetch_array(Database::query(
                "SELECT cc.id FROM $ccTable cc
                 INNER JOIN $ctTable ct ON ct.classroom_course_id = cc.id
                 WHERE cc.id = $classroomCourseId AND ct.teacher_id = $userId LIMIT 1"
            ), 'ASSOC');
            if (!$check) {
                echo json_encode(['success' => false, 'message' => 'Sin permisos para este curso']);
                exit;
            }
        }

        $rTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
        $period_e    = Database::escape_string($period);
        $gradeType_e = Database::escape_string($gradeType);
        $now         = date('Y-m-d H:i:s');

        // Check duplicate
        $existing = Database::fetch_array(Database::query(
            "SELECT id FROM $rTable WHERE classroom_course_id = $classroomCourseId AND period = '$period_e' LIMIT 1"
        ), 'ASSOC');
        if ($existing) {
            echo json_encode(['success' => false, 'message' => 'Ya existe un registro para este curso y período']);
            exit;
        }

        Database::query(
            "INSERT INTO $rTable (classroom_course_id, period, grade_type, area_id, created_by, created_at, updated_at)
             VALUES ($classroomCourseId, '$period_e', '$gradeType_e', $areaId, $userId, '$now', '$now')"
        );
        $registroId = Database::insert_id();
        echo json_encode(['success' => true, 'id' => $registroId]);
        break;

    case 'delete_registro':
        $registroId = (int) ($_POST['id'] ?? 0);
        if ($registroId <= 0) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            exit;
        }
        if (!_userCanEditRegistro($registroId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            exit;
        }
        _deleteRegistro($registroId);
        echo json_encode(['success' => true]);
        break;

    case 'save_competencias':
        $registroId  = (int) ($_POST['registro_id'] ?? 0);
        $competencias = json_decode($_POST['competencias'] ?? '[]', true);

        if ($registroId <= 0) {
            echo json_encode(['success' => false, 'message' => 'registro_id requerido']);
            exit;
        }
        if (!_userCanEditRegistro($registroId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            exit;
        }

        $rcTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_COMPETENCIA);
        $rCapTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_CAPACIDAD);
        $nTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_NOTA);

        // Remove competencias (and their capacidades/notas) not in the new list
        $existingRes = Database::query(
            "SELECT id, competencia_id, is_transversal FROM $rcTable WHERE registro_id = $registroId"
        );
        $existing = [];
        while ($row = Database::fetch_array($existingRes, 'ASSOC')) {
            $existing[$row['id']] = $row;
        }

        $keepIds = [];
        $order   = 0;
        if (is_array($competencias)) {
            foreach ($competencias as $comp) {
                $compId       = (int) ($comp['competencia_id'] ?? 0);
                $isTrans      = (int) (!empty($comp['is_transversal']));
                $capacidades  = $comp['capacidades'] ?? [];

                if ($compId <= 0) continue;

                // Find or create registro_comp
                $rcId = null;
                foreach ($existing as $excId => $exc) {
                    if ((int)$exc['competencia_id'] === $compId && (int)$exc['is_transversal'] === $isTrans) {
                        $rcId = $excId;
                        break;
                    }
                }
                if ($rcId === null) {
                    Database::query(
                        "INSERT INTO $rcTable (registro_id, competencia_id, is_transversal, order_index)
                         VALUES ($registroId, $compId, $isTrans, $order)"
                    );
                    $rcId = Database::insert_id();
                } else {
                    Database::query(
                        "UPDATE $rcTable SET order_index = $order WHERE id = $rcId"
                    );
                    $keepIds[] = $rcId;
                }

                // Sync capacidades for this competencia
                $existingCaps = [];
                $capRes = Database::query(
                    "SELECT id, capacidad_id, is_transversal FROM $rCapTable WHERE registro_comp_id = $rcId"
                );
                while ($capRow = Database::fetch_array($capRes, 'ASSOC')) {
                    $existingCaps[$capRow['id']] = $capRow;
                }

                $keepCapIds = [];
                $capOrder   = 0;
                if (is_array($capacidades)) {
                    foreach ($capacidades as $cap) {
                        $capId   = (int) ($cap['capacidad_id'] ?? 0);
                        $capTrans = (int) (!empty($cap['is_transversal']));
                        if ($capId <= 0) continue;

                        $capAuxId = null;
                        foreach ($existingCaps as $ecId => $ec) {
                            if ((int)$ec['capacidad_id'] === $capId && (int)$ec['is_transversal'] === $capTrans) {
                                $capAuxId = $ecId;
                                break;
                            }
                        }
                        if ($capAuxId === null) {
                            Database::query(
                                "INSERT INTO $rCapTable (registro_comp_id, capacidad_id, is_transversal, order_index)
                                 VALUES ($rcId, $capId, $capTrans, $capOrder)"
                            );
                            $capAuxId = Database::insert_id();
                        } else {
                            Database::query(
                                "UPDATE $rCapTable SET order_index = $capOrder WHERE id = $capAuxId"
                            );
                        }
                        $keepCapIds[] = $capAuxId;
                        $capOrder++;
                    }
                }

                // Remove capacidades not in keepCapIds
                $allCapIds = array_keys($existingCaps);
                $removeCapIds = array_diff($allCapIds, $keepCapIds);
                foreach ($removeCapIds as $rmCapId) {
                    Database::query("DELETE FROM $nTable WHERE aux_capacidad_id = $rmCapId AND registro_id = $registroId");
                    Database::query("DELETE FROM $rCapTable WHERE id = $rmCapId");
                }

                $keepIds[] = $rcId;
                $order++;
            }
        }

        // Remove competencias not in keepIds
        $allIds = array_keys($existing);
        $removeIds = array_diff($allIds, $keepIds);
        foreach ($removeIds as $rmId) {
            $capRes2 = Database::query("SELECT id FROM $rCapTable WHERE registro_comp_id = $rmId");
            while ($capRow2 = Database::fetch_array($capRes2, 'ASSOC')) {
                Database::query("DELETE FROM $nTable WHERE aux_capacidad_id = {$capRow2['id']} AND registro_id = $registroId");
            }
            Database::query("DELETE FROM $rCapTable WHERE registro_comp_id = $rmId");
            Database::query("DELETE FROM $rcTable WHERE id = $rmId");
        }

        $rTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
        Database::query("UPDATE $rTable SET updated_at = NOW() WHERE id = $registroId");

        echo json_encode(['success' => true]);
        break;

    case 'save_nota':
        $registroId    = (int) ($_POST['registro_id'] ?? 0);
        $auxCapacidadId = (int) ($_POST['aux_capacidad_id'] ?? 0);
        $studentId     = (int) ($_POST['student_id'] ?? 0);
        $nota          = trim($_POST['nota'] ?? '');

        if ($registroId <= 0 || $auxCapacidadId <= 0 || $studentId <= 0) {
            echo json_encode(['success' => false, 'message' => 'Parámetros incompletos']);
            exit;
        }
        if (!_userCanEditRegistro($registroId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            exit;
        }

        // Validate numeric note range 0-20
        if ($nota !== '') {
            $validLetters = ['AD', 'A', 'B', 'C'];
            if (!in_array(strtoupper($nota), $validLetters)) {
                $notaNum = filter_var($nota, FILTER_VALIDATE_FLOAT);
                if ($notaNum === false || $notaNum < 0 || $notaNum > 20) {
                    echo json_encode(['success' => false, 'message' => 'La nota debe estar entre 0 y 20']);
                    exit;
                }
            }
        }

        $nota_e = Database::escape_string($nota);
        $nTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_NOTA);
        $now    = date('Y-m-d H:i:s');
        Database::query(
            "INSERT INTO $nTable (registro_id, aux_capacidad_id, student_id, nota, updated_at)
             VALUES ($registroId, $auxCapacidadId, $studentId, '$nota_e', '$now')
             ON DUPLICATE KEY UPDATE nota = '$nota_e', updated_at = '$now'"
        );
        echo json_encode(['success' => true]);
        break;

    case 'save_notas_bulk':
        $registroId = (int) ($_POST['registro_id'] ?? 0);
        $notas      = json_decode($_POST['notas'] ?? '[]', true);

        if ($registroId <= 0 || !is_array($notas)) {
            echo json_encode(['success' => false, 'message' => 'Parámetros incompletos']);
            exit;
        }
        if (!_userCanEditRegistro($registroId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            exit;
        }

        $nTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_NOTA);
        $now    = date('Y-m-d H:i:s');
        $validLetters = ['AD', 'A', 'B', 'C'];
        $invalidNotas = [];
        foreach ($notas as $nota) {
            $auxCapId  = (int) ($nota['aux_capacidad_id'] ?? 0);
            $studentId = (int) ($nota['student_id'] ?? 0);
            $val       = trim($nota['nota'] ?? '');
            if ($auxCapId <= 0 || $studentId <= 0) continue;

            // Validate numeric range 0-20
            if ($val !== '' && !in_array(strtoupper($val), $validLetters)) {
                $notaNum = filter_var($val, FILTER_VALIDATE_FLOAT);
                if ($notaNum === false || $notaNum < 0 || $notaNum > 20) {
                    $invalidNotas[] = $val;
                    continue;
                }
            }

            $val_e = Database::escape_string($val);
            Database::query(
                "INSERT INTO $nTable (registro_id, aux_capacidad_id, student_id, nota, updated_at)
                 VALUES ($registroId, $auxCapId, $studentId, '$val_e', '$now')
                 ON DUPLICATE KEY UPDATE nota = '$val_e', updated_at = '$now'"
            );
        }

        if (!empty($invalidNotas)) {
            echo json_encode(['success' => false, 'message' => 'Algunas notas fuera de rango (0-20) fueron ignoradas: ' . implode(', ', $invalidNotas)]);
        } else {
            echo json_encode(['success' => true]);
        }
        break;

    case 'get_teacher_courses':
        $yearId = (int) ($_GET['year_id'] ?? 0);
        if ($yearId <= 0) {
            $activeYear = MatriculaManager::getActiveYear();
            $yearId = $activeYear ? (int) $activeYear['id'] : 0;
        }
        if ($yearId <= 0) {
            echo json_encode(['success' => true, 'courses' => []]);
            exit;
        }
        $classrooms = AcademicManager::getTeacherClassrooms($userId, $yearId);
        $courses = [];
        foreach ($classrooms as $cl) {
            $clCourses = AcademicManager::getClassroomCourses((int) $cl['id']);
            foreach ($clCourses as $c) {
                // only include courses where this teacher is assigned (or admin)
                $isAssigned = $isAdmin;
                if (!$isAssigned) {
                    foreach ($c['teachers'] as $t) {
                        if ((int) $t['user_id'] === $userId) {
                            $isAssigned = true;
                            break;
                        }
                    }
                }
                if ($isAssigned) {
                    $courses[] = [
                        'classroom_course_id' => (int) $c['classroom_course_id'],
                        'course_title'        => $c['title'],
                        'classroom_label'     => $cl['level_name'] . ' — ' . $cl['grade_name'] .
                                                 (!empty($cl['section_name']) ? ' Sec. ' . $cl['section_name'] : ''),
                        'classroom_id'        => (int) $cl['id'],
                    ];
                }
            }
        }
        echo json_encode(['success' => true, 'courses' => $courses]);
        break;

    case 'save_criterio':
        $auxCapId   = (int) ($_POST['aux_capacidad_id'] ?? 0);
        $registroId = (int) ($_POST['registro_id'] ?? 0);
        $criterio   = trim($_POST['criterio'] ?? '');

        if ($auxCapId <= 0 || $registroId <= 0) {
            echo json_encode(['success' => false, 'message' => 'Parámetros incompletos']);
            exit;
        }
        if (!_userCanEditRegistro($registroId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            exit;
        }
        $criterio_e  = Database::escape_string($criterio);
        $rCapTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_CAPACIDAD);
        Database::query("UPDATE $rCapTable SET criterio = '$criterio_e' WHERE id = $auxCapId");
        echo json_encode(['success' => true]);
        break;

    case 'save_enfoques':
        $registroId = (int) ($_POST['registro_id'] ?? 0);
        $enfoques   = json_decode($_POST['enfoques'] ?? '[]', true);

        if ($registroId <= 0) {
            echo json_encode(['success' => false, 'message' => 'registro_id requerido']);
            exit;
        }
        if (!_userCanEditRegistro($registroId, $userId, $isAdmin)) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            exit;
        }

        $efTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_ENFOQUE);
        Database::query("DELETE FROM $efTable WHERE registro_id = $registroId");

        if (is_array($enfoques)) {
            $order = 0;
            foreach ($enfoques as $ef) {
                $efId     = (int) ($ef['enfoque_id'] ?? 0);
                $nombre   = Database::escape_string(trim($ef['nombre'] ?? ''));
                $valores  = Database::escape_string(trim($ef['valores'] ?? ''));
                $actitudes = Database::escape_string(trim($ef['actitudes'] ?? ''));
                if (empty($nombre)) continue;
                Database::query(
                    "INSERT INTO $efTable (registro_id, enfoque_id, nombre, valores, actitudes, order_index)
                     VALUES ($registroId, $efId, '$nombre', '$valores', '$actitudes', $order)"
                );
                $order++;
            }
        }
        echo json_encode(['success' => true]);
        break;

    case 'get_chamilo_activities':
        $registroId = (int) ($_GET['registro_id'] ?? 0);
        if ($registroId <= 0) {
            echo json_encode(['success' => false, 'message' => 'registro_id required']);
            exit;
        }

        $rTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
        $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
        $cTable  = Database::get_main_table(TABLE_MAIN_COURSE);

        $regRow = Database::fetch_array(Database::query(
            "SELECT c.id AS course_c_id FROM $rTable r
             INNER JOIN $ccTable cc ON cc.id = r.classroom_course_id
             INNER JOIN $cTable c ON c.id = cc.course_id
             WHERE r.id = $registroId LIMIT 1"
        ), 'ASSOC');

        if (!$regRow) {
            echo json_encode(['success' => false, 'message' => 'Registro no encontrado']);
            exit;
        }

        $cId = (int) $regRow['course_c_id'];

        // Exercises
        $qTable  = Database::get_course_table(TABLE_QUIZ_TEST);
        $exRes   = Database::query(
            "SELECT iid AS id, title FROM $qTable WHERE c_id = $cId AND active = 1 ORDER BY iid DESC"
        );
        $exercises = [];
        while ($row = Database::fetch_array($exRes, 'ASSOC')) {
            $exercises[] = ['id' => (int) $row['id'], 'title' => $row['title']];
        }

        // Tasks (student publications with grading enabled)
        $spTable  = Database::get_course_table(TABLE_STUDENT_PUBLICATION);
        $spaTable = Database::get_course_table(TABLE_STUDENT_PUBLICATION_ASSIGNMENT);
        $taskRes  = Database::query(
            "SELECT sp.iid AS id, sp.title
             FROM $spTable sp
             INNER JOIN $spaTable spa ON spa.c_id = sp.c_id AND spa.publication_id = sp.id
             WHERE sp.c_id = $cId AND sp.parent_id = 0 AND sp.active = 1 AND spa.enable_qualification = 1
             ORDER BY sp.iid DESC"
        );
        $tasks = [];
        while ($row = Database::fetch_array($taskRes, 'ASSOC')) {
            $tasks[] = ['id' => (int) $row['id'], 'title' => $row['title']];
        }

        echo json_encode(['success' => true, 'exercises' => $exercises, 'tasks' => $tasks]);
        break;

    case 'get_activity_grades':
        $registroId  = (int) ($_GET['registro_id'] ?? 0);
        $type        = $_GET['type'] ?? 'exercise';
        $activityId  = (int) ($_GET['activity_id'] ?? 0);

        if ($registroId <= 0 || $activityId <= 0) {
            echo json_encode(['success' => false, 'message' => 'Parámetros incompletos']);
            exit;
        }

        $rTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
        $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
        $cTable  = Database::get_main_table(TABLE_MAIN_COURSE);

        $regRow = Database::fetch_array(Database::query(
            "SELECT c.id AS course_c_id, cc.classroom_id FROM $rTable r
             INNER JOIN $ccTable cc ON cc.id = r.classroom_course_id
             INNER JOIN $cTable c ON c.id = cc.course_id
             WHERE r.id = $registroId LIMIT 1"
        ), 'ASSOC');

        if (!$regRow) {
            echo json_encode(['success' => false, 'message' => 'Registro no encontrado']);
            exit;
        }

        $cId         = (int) $regRow['course_c_id'];
        $classroomId = (int) $regRow['classroom_id'];

        $students   = AcademicManager::getClassroomStudents($classroomId);
        $studentIds = array_map('intval', array_column($students, 'user_id'));

        if (empty($studentIds)) {
            echo json_encode(['success' => true, 'grades' => [], 'max_score' => 20]);
            exit;
        }

        $ids     = implode(',', $studentIds);
        $grades  = [];
        $maxScore = 20;

        if ($type === 'exercise') {
            $teTable = Database::get_main_table(TABLE_STATISTIC_TRACK_E_EXERCISES);
            $res = Database::query(
                "SELECT exe_user_id, exe_result, exe_weighting
                 FROM $teTable
                 WHERE c_id = $cId AND exe_exo_id = $activityId
                   AND exe_user_id IN ($ids) AND status = '' AND exe_weighting > 0
                 ORDER BY (exe_result / exe_weighting) DESC"
            );
            $seen = [];
            while ($row = Database::fetch_array($res, 'ASSOC')) {
                $uid = (int) $row['exe_user_id'];
                if (!isset($seen[$uid])) {
                    $grades[$uid] = round(($row['exe_result'] / $row['exe_weighting']) * 20, 1);
                    $seen[$uid]   = true;
                }
            }
        } elseif ($type === 'task') {
            $spTable = Database::get_course_table(TABLE_STUDENT_PUBLICATION);
            // Get assignment weight
            $wRow = Database::fetch_array(Database::query(
                "SELECT weight FROM $spTable WHERE c_id = $cId AND id = $activityId LIMIT 1"
            ), 'ASSOC');
            $weight   = ($wRow && (float) $wRow['weight'] > 0) ? (float) $wRow['weight'] : 20;
            $maxScore = $weight;

            $res = Database::query(
                "SELECT user_id, qualification FROM $spTable
                 WHERE c_id = $cId AND parent_id = $activityId
                   AND user_id IN ($ids) AND active = 1
                   AND qualificator_id IS NOT NULL AND qualificator_id > 0
                 ORDER BY sent_date DESC"
            );
            $seen = [];
            while ($row = Database::fetch_array($res, 'ASSOC')) {
                $uid = (int) $row['user_id'];
                if (!isset($seen[$uid])) {
                    $grades[$uid] = round(((float) $row['qualification'] / $weight) * 20, 1);
                    $seen[$uid]   = true;
                }
            }
        }

        echo json_encode(['success' => true, 'grades' => $grades, 'max_score' => (float) $maxScore]);
        break;

    case 'get_enfoques_curricula':
        require_once __DIR__ . '/../src/CurriculaManager.php';
        $enfoques = CurriculaManager::getEnfoquesWithValores();
        // simplify valores to just names array
        foreach ($enfoques as &$ef) {
            $ef['valores_list'] = array_column($ef['valores'], 'name');
            unset($ef['valores']);
        }
        echo json_encode(['success' => true, 'enfoques' => $enfoques]);
        break;

    case 'submit_registro':
        $registroId = (int) ($_POST['id'] ?? 0);
        if ($registroId <= 0) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            exit;
        }

        $rTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);

        // Only the creator (or admin) can submit
        $reg = Database::fetch_array(Database::query(
            "SELECT id, created_by, status FROM $rTable WHERE id = $registroId LIMIT 1"
        ), 'ASSOC');

        if (!$reg) {
            echo json_encode(['success' => false, 'message' => 'Registro no encontrado']);
            exit;
        }
        if (!$isAdmin && (int) $reg['created_by'] !== $userId) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            exit;
        }
        if ($reg['status'] === 'reviewed') {
            echo json_encode(['success' => false, 'message' => 'El registro ya fue revisado por el tutor']);
            exit;
        }

        $now = date('Y-m-d H:i:s');
        Database::query(
            "UPDATE $rTable SET status = 'submitted', submitted_at = '$now', updated_at = '$now'
             WHERE id = $registroId"
        );
        echo json_encode(['success' => true]);
        break;

    case 'mark_reviewed':
        $registroId = (int) ($_POST['id'] ?? 0);
        if ($registroId <= 0) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            exit;
        }

        $rTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
        $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
        $clTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);

        // Verify the user is the tutor of the classroom this registro belongs to (or admin)
        if (!$isAdmin) {
            $check = Database::fetch_array(Database::query(
                "SELECT cl.tutor_id FROM $rTable r
                 INNER JOIN $ccTable cc ON cc.id = r.classroom_course_id
                 INNER JOIN $clTable cl ON cl.id = cc.classroom_id
                 WHERE r.id = $registroId LIMIT 1"
            ), 'ASSOC');
            if (!$check || (int) $check['tutor_id'] !== $userId) {
                echo json_encode(['success' => false, 'message' => 'Solo el tutor del aula puede marcar como revisado']);
                exit;
            }
        }

        $now = date('Y-m-d H:i:s');
        Database::query(
            "UPDATE $rTable SET status = 'reviewed', reviewed_at = '$now', reviewed_by = $userId, updated_at = '$now'
             WHERE id = $registroId"
        );
        echo json_encode(['success' => true]);
        break;

    case 'recall_registro':
        // Creator retracts a submitted registro back to draft
        $registroId = (int) ($_POST['id'] ?? 0);
        if ($registroId <= 0) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            exit;
        }

        $rTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
        $reg = Database::fetch_array(Database::query(
            "SELECT id, created_by, status FROM $rTable WHERE id = $registroId LIMIT 1"
        ), 'ASSOC');

        if (!$reg) {
            echo json_encode(['success' => false, 'message' => 'Registro no encontrado']);
            exit;
        }
        if (!$isAdmin && (int) $reg['created_by'] !== $userId) {
            echo json_encode(['success' => false, 'message' => 'Sin permisos']);
            exit;
        }
        if ($reg['status'] === 'reviewed') {
            echo json_encode(['success' => false, 'message' => 'No se puede retirar un registro ya revisado']);
            exit;
        }

        $now = date('Y-m-d H:i:s');
        Database::query(
            "UPDATE $rTable SET status = 'draft', submitted_at = NULL, updated_at = '$now'
             WHERE id = $registroId"
        );
        echo json_encode(['success' => true]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Unknown action']);
        break;
}

// ---- helpers ----

function _userCanEditRegistro(int $registroId, int $userId, bool $isAdmin): bool
{
    if ($isAdmin) return true;
    $rTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
    $ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
    $ctTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
    $row = Database::fetch_array(Database::query(
        "SELECT r.id FROM $rTable r
         INNER JOIN $ccTable cc ON cc.id = r.classroom_course_id
         INNER JOIN $ctTable ct ON ct.classroom_course_id = cc.id
         WHERE r.id = $registroId AND (r.created_by = $userId OR ct.teacher_id = $userId) LIMIT 1"
    ), 'ASSOC');
    return !empty($row);
}

function _deleteRegistro(int $registroId): void
{
    $rTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
    $rcTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_COMPETENCIA);
    $rCapTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_CAPACIDAD);
    $nTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_NOTA);

    Database::query("DELETE FROM $nTable WHERE registro_id = $registroId");
    $rcRes = Database::query("SELECT id FROM $rcTable WHERE registro_id = $registroId");
    while ($rcRow = Database::fetch_array($rcRes, 'ASSOC')) {
        Database::query("DELETE FROM $rCapTable WHERE registro_comp_id = {$rcRow['id']}");
    }
    Database::query("DELETE FROM $rcTable WHERE registro_id = $registroId");
    Database::query("DELETE FROM $rTable WHERE id = $registroId");
}
