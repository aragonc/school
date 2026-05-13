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

$rTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUXILIAR);
$ccTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_COURSE);
$ctTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_COURSE_TEACHER);
$cTable    = Database::get_main_table(TABLE_MAIN_COURSE);
$clTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
$gTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
$sTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
$lTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
$areaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_AREA);
$compTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_COMPETENCIA);
$transTable= Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL);
$capTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_CAPACIDAD);
$tcapTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL_CAP);
$rcTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_COMPETENCIA);
$rCapTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_CAPACIDAD);
$nTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_NOTA);
$efTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_REGISTRO_AUX_ENFOQUE);

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

// Load competencias
$competencias = [];
$rcRes = Database::query(
    "SELECT rc.id AS rc_id, rc.competencia_id, rc.is_transversal, rc.order_index
     FROM $rcTable rc WHERE rc.registro_id = $registroId ORDER BY rc.order_index ASC"
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

    $capacidades = [];
    $capRes = Database::query(
        "SELECT rc2.id AS aux_cap_id, rc2.capacidad_id, rc2.is_transversal, rc2.order_index, rc2.criterio
         FROM $rCapTable rc2 WHERE rc2.registro_comp_id = $rcId ORDER BY rc2.order_index ASC"
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
            'aux_cap_id' => $capAuxId,
            'name'       => $capInfo['name'],
            'criterio'   => $capRow['criterio'] ?? '',
        ];
    }

    $competencias[] = [
        'rc_id'      => $rcId,
        'label'      => 'C' . $compIndex,
        'name'       => $compInfo['name'],
        'capacidades'=> $capacidades,
    ];
    $compIndex++;
}

$classroomId = (int) $registro['classroom_id'];
$students    = AcademicManager::getClassroomStudents($classroomId);

$notasMap = [];
$notasRes = Database::query(
    "SELECT aux_capacidad_id, student_id, nota FROM $nTable WHERE registro_id = $registroId"
);
while ($notaRow = Database::fetch_array($notasRes, 'ASSOC')) {
    $notasMap[$notaRow['aux_capacidad_id']][$notaRow['student_id']] = $notaRow['nota'];
}

$enfoques = [];
$enfsRes  = Database::query(
    "SELECT * FROM $efTable WHERE registro_id = $registroId ORDER BY order_index ASC"
);
while ($efRow = Database::fetch_array($enfsRes, 'ASSOC')) {
    $enfoques[] = $efRow;
}

// ─── Grade helpers ───────────────────────────────────────────────────────────

function schoolLetterToNum($val) {
    $map = ['AD' => 19, 'A' => 16, 'B' => 12, 'C' => 8];
    $v   = strtoupper(trim((string) $val));
    if (isset($map[$v])) return $map[$v];
    $n = filter_var($v, FILTER_VALIDATE_FLOAT);
    return $n !== false ? (float) $n : null;
}

function schoolNumToLetter($n) {
    if ($n >= 18) return 'AD';
    if ($n >= 14) return 'A';
    if ($n >= 11) return 'B';
    return 'C';
}

function schoolFormatDisplay($avg, $gradeType) {
    if ($avg === null) return '';
    if ($gradeType === 'numeric')  return (string) round($avg);
    if ($gradeType === 'letter')   return schoolNumToLetter($avg);
    return round($avg) . ' (' . schoolNumToLetter($avg) . ')';
}

// ─── Build Excel ─────────────────────────────────────────────────────────────

$xls   = new PHPExcel();
$sheet = $xls->getActiveSheet();
$sheet->setTitle('Registro Auxiliar');

$gradeType = $registro['grade_type'] ?? 'numeric';

// Column index plan (0-based)
$colN       = 0;  // N°
$colName    = 1;  // Apellidos y Nombres
$curCol     = 2;  // start of competencias block

$compRanges = [];
foreach ($competencias as $comp) {
    $capCount     = count($comp['capacidades']);
    $compStart    = $curCol;
    $nivelCol     = $curCol + $capCount;
    $compEnd      = $nivelCol;
    $curCol       = $compEnd + 1;
    $compRanges[] = ['start' => $compStart, 'nivel' => $nivelCol, 'end' => $compEnd, 'capCount' => $capCount];
}
$promedioCol = $curCol;

// ── Helper: apply a background fill ──────────────────────────────────────────
function schoolSetFill(PHPExcel_Style $style, $hex) {
    $style->getFill()
          ->setFillType(PHPExcel_Style_Fill::FILL_SOLID)
          ->getStartColor()->setRGB($hex);
}

function schoolSetBold(PHPExcel_Style $style) {
    $style->getFont()->setBold(true);
}

function schoolCenter(PHPExcel_Style $style) {
    $style->getAlignment()
          ->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER)
          ->setVertical(PHPExcel_Style_Alignment::VERTICAL_CENTER);
}

function schoolWrap(PHPExcel_Style $style) {
    $style->getAlignment()->setWrapText(true);
}

// ── Info rows (rows 1-4 before the table header) ─────────────────────────────
$infoRow = 1;
$sheet->setCellValueByColumnAndRow(0, $infoRow, 'REGISTRO AUXILIAR — ' . strtoupper($registro['period']));
$sheet->mergeCellsByColumnAndRow(0, $infoRow, $promedioCol, $infoRow);
schoolSetBold($sheet->getStyleByColumnAndRow(0, $infoRow));
schoolCenter($sheet->getStyleByColumnAndRow(0, $infoRow));
schoolSetFill($sheet->getStyleByColumnAndRow(0, $infoRow), 'DCE8FC');
$sheet->getRowDimension($infoRow)->setRowHeight(18);

$infoRow++;
$sheet->setCellValueByColumnAndRow(0, $infoRow, $registro['classroom_label'] . '   ' . $registro['course_title'] . '   ' . $registro['area_name']);
$sheet->mergeCellsByColumnAndRow(0, $infoRow, $promedioCol, $infoRow);
schoolCenter($sheet->getStyleByColumnAndRow(0, $infoRow));

$infoRow++;
$gradeTypeLabel = $gradeType === 'numeric' ? 'Numérica (0–20)' : ($gradeType === 'letter' ? 'Literal (AD/A/B/C)' : 'Combinada');
$sheet->setCellValueByColumnAndRow(0, $infoRow,
    'Área: ' . $registro['area_name'] . '   Docente: ' . $registro['teacher_name'] . '   Tipo nota: ' . $gradeTypeLabel
);
$sheet->mergeCellsByColumnAndRow(0, $infoRow, $promedioCol, $infoRow);

// Enfoques info
if (!empty($enfoques)) {
    $infoRow++;
    $nombres = implode(', ', array_column($enfoques, 'nombre'));
    $valores  = implode(', ', array_filter(array_column($enfoques, 'valores')));
    $sheet->setCellValueByColumnAndRow(0, $infoRow, 'Enfoques: ' . $nombres . ($valores ? '   Valores: ' . $valores : ''));
    $sheet->mergeCellsByColumnAndRow(0, $infoRow, $promedioCol, $infoRow);
    schoolWrap($sheet->getStyleByColumnAndRow(0, $infoRow));
}

$infoRow++;
// blank separator
$infoRow++;

// ── Table header rows ─────────────────────────────────────────────────────────
$hdr1 = $infoRow;       // ROW 1: COMPETENCIA DEL ÁREA
$hdr2 = $hdr1 + 1;     // ROW 2: competencia names
$hdr3 = $hdr2 + 1;     // ROW 3: CAPACIDADES / NIVEL DE LOGRO
$hdr4 = $hdr3 + 1;     // ROW 4: individual capacidad names
$hdr5 = $hdr4 + 1;     // ROW 5: criterios
$dataStart = $hdr5 + 1;

// ── ROW 1 ─────────────────────────────────────────────────────────────────────
$sheet->setCellValueByColumnAndRow($colN, $hdr1, 'N°');
$sheet->mergeCellsByColumnAndRow($colN, $hdr1, $colN, $hdr5);
schoolCenter($sheet->getStyleByColumnAndRow($colN, $hdr1));
schoolSetBold($sheet->getStyleByColumnAndRow($colN, $hdr1));
schoolSetFill($sheet->getStyleByColumnAndRow($colN, $hdr1), 'F2F2F2');

$sheet->setCellValueByColumnAndRow($colName, $hdr1, 'Apellidos y Nombres');
$sheet->mergeCellsByColumnAndRow($colName, $hdr1, $colName, $hdr5);
schoolCenter($sheet->getStyleByColumnAndRow($colName, $hdr1));
schoolSetBold($sheet->getStyleByColumnAndRow($colName, $hdr1));
schoolSetFill($sheet->getStyleByColumnAndRow($colName, $hdr1), 'F2F2F2');

if (!empty($competencias)) {
    $sheet->setCellValueByColumnAndRow(2, $hdr1, 'COMPETENCIA DEL ÁREA');
    $sheet->mergeCellsByColumnAndRow(2, $hdr1, $promedioCol - 1, $hdr1);
    schoolCenter($sheet->getStyleByColumnAndRow(2, $hdr1));
    schoolSetBold($sheet->getStyleByColumnAndRow(2, $hdr1));
    schoolSetFill($sheet->getStyleByColumnAndRow(2, $hdr1), 'DCE8FC');
}

$sheet->setCellValueByColumnAndRow($promedioCol, $hdr1, 'PROMEDIO DE LA ASIGNATURA');
$sheet->mergeCellsByColumnAndRow($promedioCol, $hdr1, $promedioCol, $hdr5);
schoolCenter($sheet->getStyleByColumnAndRow($promedioCol, $hdr1));
schoolSetBold($sheet->getStyleByColumnAndRow($promedioCol, $hdr1));
schoolSetFill($sheet->getStyleByColumnAndRow($promedioCol, $hdr1), 'FFF3CD');
schoolWrap($sheet->getStyleByColumnAndRow($promedioCol, $hdr1));

// ── ROW 2: competencia names ──────────────────────────────────────────────────
foreach ($competencias as $i => $comp) {
    $r = $compRanges[$i];
    $sheet->setCellValueByColumnAndRow($r['start'], $hdr2, $comp['label'] . '_' . $comp['name']);
    $sheet->mergeCellsByColumnAndRow($r['start'], $hdr2, $r['end'], $hdr2);
    schoolCenter($sheet->getStyleByColumnAndRow($r['start'], $hdr2));
    schoolSetBold($sheet->getStyleByColumnAndRow($r['start'], $hdr2));
    schoolSetFill($sheet->getStyleByColumnAndRow($r['start'], $hdr2), 'E8F0FE');
    schoolWrap($sheet->getStyleByColumnAndRow($r['start'], $hdr2));
}

// ── ROW 3: CAPACIDADES + NIVEL DE LOGRO (rowspan 3) ──────────────────────────
foreach ($competencias as $i => $comp) {
    $r = $compRanges[$i];

    $sheet->setCellValueByColumnAndRow($r['start'], $hdr3, 'CAPACIDADES');
    if ($r['capCount'] > 1) {
        $sheet->mergeCellsByColumnAndRow($r['start'], $hdr3, $r['nivel'] - 1, $hdr3);
    }
    schoolCenter($sheet->getStyleByColumnAndRow($r['start'], $hdr3));
    schoolSetBold($sheet->getStyleByColumnAndRow($r['start'], $hdr3));
    schoolSetFill($sheet->getStyleByColumnAndRow($r['start'], $hdr3), 'E3EEFF');

    $sheet->setCellValueByColumnAndRow($r['nivel'], $hdr3, 'NIVEL DE LOGRO');
    $sheet->mergeCellsByColumnAndRow($r['nivel'], $hdr3, $r['nivel'], $hdr5);
    schoolCenter($sheet->getStyleByColumnAndRow($r['nivel'], $hdr3));
    schoolSetBold($sheet->getStyleByColumnAndRow($r['nivel'], $hdr3));
    schoolSetFill($sheet->getStyleByColumnAndRow($r['nivel'], $hdr3), 'C8E6C9');
    schoolWrap($sheet->getStyleByColumnAndRow($r['nivel'], $hdr3));
}

// ── ROW 4: individual capacidad names ────────────────────────────────────────
foreach ($competencias as $i => $comp) {
    $r   = $compRanges[$i];
    $col = $r['start'];
    foreach ($comp['capacidades'] as $cap) {
        $sheet->setCellValueByColumnAndRow($col, $hdr4, $cap['name']);
        schoolCenter($sheet->getStyleByColumnAndRow($col, $hdr4));
        schoolSetFill($sheet->getStyleByColumnAndRow($col, $hdr4), 'F0F4FF');
        schoolWrap($sheet->getStyleByColumnAndRow($col, $hdr4));
        $col++;
    }
}
$sheet->getRowDimension($hdr4)->setRowHeight(60);

// ── ROW 5: criterios ──────────────────────────────────────────────────────────
foreach ($competencias as $i => $comp) {
    $r   = $compRanges[$i];
    $col = $r['start'];
    foreach ($comp['capacidades'] as $cap) {
        $sheet->setCellValueByColumnAndRow($col, $hdr5, $cap['criterio']);
        schoolCenter($sheet->getStyleByColumnAndRow($col, $hdr5));
        schoolSetFill($sheet->getStyleByColumnAndRow($col, $hdr5), 'FFFBF0');
        schoolWrap($sheet->getStyleByColumnAndRow($col, $hdr5));
        $col++;
    }
}

// ── Data rows ─────────────────────────────────────────────────────────────────
$row = $dataStart;
foreach ($students as $si => $student) {
    $sheet->setCellValueByColumnAndRow($colN, $row, $si + 1);
    schoolCenter($sheet->getStyleByColumnAndRow($colN, $row));

    $sheet->setCellValueByColumnAndRow($colName, $row, $student['lastname'] . ', ' . $student['firstname']);
    $sheet->getStyleByColumnAndRow($colName, $row)->getFont()->setBold(true);

    $nivelVals = [];
    foreach ($competencias as $i => $comp) {
        $r   = $compRanges[$i];
        $col = $r['start'];
        $vals = [];
        foreach ($comp['capacidades'] as $cap) {
            $nota = $notasMap[$cap['aux_cap_id']][$student['user_id']] ?? '';
            $sheet->setCellValueByColumnAndRow($col, $row, $nota);
            schoolCenter($sheet->getStyleByColumnAndRow($col, $row));
            if ($nota !== '') {
                $num = schoolLetterToNum($nota);
                if ($num !== null) $vals[] = $num;
            }
            $col++;
        }

        if (!empty($vals)) {
            $avg      = array_sum($vals) / count($vals);
            $nivelStr = schoolFormatDisplay($avg, $gradeType);
            $nivelVals[] = $avg;
        } else {
            $nivelStr = '';
        }

        $sheet->setCellValueByColumnAndRow($r['nivel'], $row, $nivelStr);
        schoolCenter($sheet->getStyleByColumnAndRow($r['nivel'], $row));
        schoolSetFill($sheet->getStyleByColumnAndRow($r['nivel'], $row), 'F1FAF1');
        $sheet->getStyleByColumnAndRow($r['nivel'], $row)->getFont()->setBold(true);
    }

    $promStr = '';
    if (!empty($nivelVals)) {
        $prom    = array_sum($nivelVals) / count($nivelVals);
        $promStr = schoolFormatDisplay($prom, $gradeType);
    }
    $sheet->setCellValueByColumnAndRow($promedioCol, $row, $promStr);
    schoolCenter($sheet->getStyleByColumnAndRow($promedioCol, $row));
    schoolSetFill($sheet->getStyleByColumnAndRow($promedioCol, $row), 'FFFDE7');
    $sheet->getStyleByColumnAndRow($promedioCol, $row)->getFont()->setBold(true);

    $row++;
}

// ── Column widths ─────────────────────────────────────────────────────────────
$sheet->getColumnDimensionByColumn($colN)->setWidth(5);
$sheet->getColumnDimensionByColumn($colName)->setWidth(30);
foreach ($competencias as $i => $comp) {
    $r   = $compRanges[$i];
    $col = $r['start'];
    foreach ($comp['capacidades'] as $cap) {
        $sheet->getColumnDimensionByColumn($col)->setWidth(12);
        $col++;
    }
    $sheet->getColumnDimensionByColumn($r['nivel'])->setWidth(12);
}
$sheet->getColumnDimensionByColumn($promedioCol)->setWidth(14);

// ── Borders on header block ────────────────────────────────────────────────────
$lastCol = PHPExcel_Cell::stringFromColumnIndex($promedioCol);
$borderStyle = [
    'borders' => [
        'allborders' => [
            'style' => PHPExcel_Style_Border::BORDER_THIN,
            'color' => ['rgb' => 'BBBBBB'],
        ],
    ],
];
$sheet->getStyle('A' . $hdr1 . ':' . $lastCol . ($row - 1))->applyFromArray($borderStyle);

// ── Output ────────────────────────────────────────────────────────────────────
$filename = 'Registro_Auxiliar_' . $registro['period'] . '_' . str_replace(['/', '\\', ' '], '_', $registro['area_name']) . '.xlsx';

header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment; filename="' . $filename . '"');
header('Cache-Control: max-age=0');

$writer = new PHPExcel_Writer_Excel2007($xls);
$writer->save('php://output');
exit;
