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
        foreach ($notas as $nota) {
            $auxCapId  = (int) ($nota['aux_capacidad_id'] ?? 0);
            $studentId = (int) ($nota['student_id'] ?? 0);
            $val       = Database::escape_string(trim($nota['nota'] ?? ''));
            if ($auxCapId <= 0 || $studentId <= 0) continue;
            Database::query(
                "INSERT INTO $nTable (registro_id, aux_capacidad_id, student_id, nota, updated_at)
                 VALUES ($registroId, $auxCapId, $studentId, '$val', '$now')
                 ON DUPLICATE KEY UPDATE nota = '$val', updated_at = '$now'"
            );
        }
        echo json_encode(['success' => true]);
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
