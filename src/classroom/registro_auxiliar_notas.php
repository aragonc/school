<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../src/AcademicManager.php';
require_once __DIR__ . '/../../src/MatriculaManager.php';
require_once __DIR__ . '/../../src/CurriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();
$plugin->requireModule('my_aula');

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$userId    = api_get_user_id();
$userInfo  = api_get_user_info($userId);
$isAdmin   = api_is_platform_admin();
$isTeacher = $userInfo && (int) $userInfo['status'] === COURSEMANAGER;

if (!$isAdmin && !$isTeacher) {
    api_not_allowed(true);
}

$registroId = (int) ($_GET['id'] ?? 0);
if ($registroId <= 0) {
    header('Location: /my-aula/registro');
    exit;
}

// Load registro
$rTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
$ccTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
$ctTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
$cTable  = Database::get_main_table(TABLE_MAIN_COURSE);
$clTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
$gTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
$sTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
$lTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
$areaTable     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_AREA);
$compTable     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_COMPETENCIA);
$transTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL);
$capTable      = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_CAPACIDAD);
$tcapTable     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL_CAP);
$rcTable       = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_COMPETENCIA);
$rCapTable     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_CAPACIDAD);
$nTable        = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_NOTA);

$regRes = Database::query(
    "SELECT r.*, c.title AS course_title, c.code AS course_code,
            l.name AS level_name, g.name AS grade_name, sec.name AS section_name,
            a.name AS area_name, cc.classroom_id, u.firstname AS teacher_firstname, u.lastname AS teacher_lastname
     FROM $rTable r
     INNER JOIN $ccTable cc ON cc.id = r.classroom_course_id
     INNER JOIN $cTable c ON c.id = cc.course_id
     INNER JOIN $clTable cl ON cl.id = cc.classroom_id
     INNER JOIN $gTable g ON g.id = cl.grade_id
     LEFT JOIN $sTable sec ON sec.id = cl.section_id
     INNER JOIN $lTable l ON l.id = g.level_id
     LEFT JOIN $areaTable a ON a.id = r.area_id
     LEFT JOIN " . Database::get_main_table(TABLE_MAIN_USER) . " u ON u.id = r.created_by
     WHERE r.id = $registroId LIMIT 1"
);
$registro = Database::fetch_array($regRes, 'ASSOC');

if (!$registro) {
    header('Location: /my-aula/registro');
    exit;
}

// Permission check
if (!$isAdmin) {
    $permCheck = Database::fetch_array(Database::query(
        "SELECT ct.id FROM $ctTable ct
         INNER JOIN $ccTable cc ON cc.id = ct.classroom_course_id
         INNER JOIN $rTable r ON r.classroom_course_id = cc.id
         WHERE r.id = $registroId AND ct.teacher_id = $userId LIMIT 1"
    ), 'ASSOC');
    if (!$permCheck) {
        api_not_allowed(true);
    }
}

$registro['classroom_label'] = $registro['level_name'] . ' — ' . $registro['grade_name'] .
                                (!empty($registro['section_name']) ? ' Sec. ' . $registro['section_name'] : '');
$registro['teacher_name'] = trim($registro['teacher_lastname'] . ' ' . $registro['teacher_firstname']);

// Load competencias for this registro
$competencias = [];
$rcRes = Database::query(
    "SELECT rc.id AS rc_id, rc.competencia_id, rc.is_transversal, rc.order_index
     FROM $rcTable rc
     WHERE rc.registro_id = $registroId
     ORDER BY rc.order_index ASC"
);
$compIndex = 1;
while ($rcRow = Database::fetch_array($rcRes, 'ASSOC')) {
    $rcId    = (int) $rcRow['rc_id'];
    $compId  = (int) $rcRow['competencia_id'];
    $isTrans = (int) $rcRow['is_transversal'];

    if ($isTrans) {
        $compInfo = Database::fetch_array(Database::query(
            "SELECT id, name FROM $transTable WHERE id = $compId LIMIT 1"
        ), 'ASSOC');
    } else {
        $compInfo = Database::fetch_array(Database::query(
            "SELECT id, name FROM $compTable WHERE id = $compId LIMIT 1"
        ), 'ASSOC');
    }

    if (!$compInfo) continue;

    // Load capacidades for this competencia
    $capacidades = [];
    $capRes = Database::query(
        "SELECT rc2.id AS aux_cap_id, rc2.capacidad_id, rc2.is_transversal, rc2.order_index, rc2.criterio
         FROM $rCapTable rc2
         WHERE rc2.registro_comp_id = $rcId
         ORDER BY rc2.order_index ASC"
    );
    while ($capRow = Database::fetch_array($capRes, 'ASSOC')) {
        $capAuxId = (int) $capRow['aux_cap_id'];
        $capId    = (int) $capRow['capacidad_id'];
        $capTrans = (int) $capRow['is_transversal'];

        if ($capTrans) {
            $capInfo = Database::fetch_array(Database::query(
                "SELECT id, name FROM $tcapTable WHERE id = $capId LIMIT 1"
            ), 'ASSOC');
        } else {
            $capInfo = Database::fetch_array(Database::query(
                "SELECT id, name FROM $capTable WHERE id = $capId LIMIT 1"
            ), 'ASSOC');
        }

        if (!$capInfo) continue;

        $capacidades[] = [
            'aux_cap_id'     => $capAuxId,
            'capacidad_id'   => $capId,
            'is_transversal' => $capTrans,
            'name'           => $capInfo['name'],
            'criterio'       => $capRow['criterio'] ?? '',
        ];
    }

    $competencias[] = [
        'rc_id'         => $rcId,
        'competencia_id' => $compId,
        'is_transversal' => $isTrans,
        'label'         => 'C' . $compIndex,
        'name'          => $compInfo['name'],
        'capacidades'   => $capacidades,
    ];
    $compIndex++;
}

// Load students
$classroomId = (int) $registro['classroom_id'];
$students    = AcademicManager::getClassroomStudents($classroomId);

// Load all notes for this registro
$notasMap = [];
$notasRes = Database::query(
    "SELECT aux_capacidad_id, student_id, nota FROM $nTable WHERE registro_id = $registroId"
);
while ($notaRow = Database::fetch_array($notasRes, 'ASSOC')) {
    $notasMap[$notaRow['aux_capacidad_id']][$notaRow['student_id']] = $notaRow['nota'];
}

// Build competencia data with all capacidades having cap columns
// and collect all aux_cap_ids per competencia for nivel de logro
$competenciasData = [];
foreach ($competencias as $comp) {
    $capIds = array_column($comp['capacidades'], 'aux_cap_id');
    $competenciasData[] = array_merge($comp, ['cap_ids' => $capIds]);
}

// Load enfoques for this registro
$efTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_ENFOQUE);
$enfsRes   = Database::query(
    "SELECT * FROM $efTable WHERE registro_id = $registroId ORDER BY order_index ASC"
);
$enfoques = [];
while ($efRow = Database::fetch_array($enfsRes, 'ASSOC')) {
    $enfoques[] = $efRow;
}

// Load curricula enfoques for the selection modal
$enfCurriculaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_ENFOQUE);
$enfCurriculaRes   = Database::query(
    "SELECT id, name FROM $enfCurriculaTable WHERE active = 1 ORDER BY order_index ASC"
);
$enfoquesDisponibles = [];
while ($row = Database::fetch_array($enfCurriculaRes, 'ASSOC')) {
    $enfoquesDisponibles[] = $row;
}

// Load curricula areas and all competencias/capacidades for the edit modal
$areas     = CurriculaManager::getAreas();
$ajaxUrl   = api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_registro_auxiliar.php';

$plugin->setCurrentSection('my-classroom-registro-notas');
$plugin->setSidebar('my-classroom-registro-notas');

$plugin->assign('registro', $registro);
$plugin->assign('competencias', $competenciasData);
$plugin->assign('students', $students);
$plugin->assign('notas_map', $notasMap);
$plugin->assign('areas', $areas);
$plugin->assign('enfoques', $enfoques);
$plugin->assign('enfoques_disponibles', $enfoquesDisponibles);
$plugin->assign('ajax_url', $ajaxUrl);
$plugin->assign('is_admin', $isAdmin);
$plugin->assign('registro_id', $registroId);

$content = $plugin->fetch('classroom/registro_auxiliar_notas.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
