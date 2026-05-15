<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../src/AcademicManager.php';
require_once __DIR__ . '/../../src/CurriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();
$plugin->requireModule('my_aula');

if ($plugin->get('tool_enable') != 'true') {
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

// ── Load registro ─────────────────────────────────────────────────────────────
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
    "SELECT r.*, c.title AS course_title,
            l.name AS level_name, g.name AS grade_name, sec.name AS section_name,
            a.name AS area_name, cc.classroom_id,
            u.firstname AS teacher_firstname, u.lastname AS teacher_lastname
     FROM $rTable r
     INNER JOIN $ccTable cc ON cc.id = r.classroom_course_id
     INNER JOIN $cTable  c  ON c.id  = cc.course_id
     INNER JOIN $clTable cl ON cl.id = cc.classroom_id
     INNER JOIN $gTable  g  ON g.id  = cl.grade_id
     LEFT  JOIN $sTable sec ON sec.id = cl.section_id
     INNER JOIN $lTable  l  ON l.id  = g.level_id
     LEFT  JOIN $areaTable a ON a.id = r.area_id
     LEFT  JOIN " . Database::get_main_table(TABLE_MAIN_USER) . " u ON u.id = r.created_by
     WHERE r.id = $registroId LIMIT 1"
);
$registro = Database::fetch_array($regRes, 'ASSOC');
if (!$registro) { header('Location: /my-aula/registro'); exit; }

if (!$isAdmin) {
    $ok = Database::fetch_array(Database::query(
        "SELECT ct.id FROM $ctTable ct
         INNER JOIN $ccTable cc ON cc.id = ct.classroom_course_id
         INNER JOIN $rTable  r  ON r.classroom_course_id = cc.id
         WHERE r.id = $registroId AND ct.teacher_id = $userId LIMIT 1"
    ), 'ASSOC');
    if (!$ok) api_not_allowed(true);
}

$registro['teacher_name'] = trim($registro['teacher_lastname'] . ' ' . $registro['teacher_firstname']);

// ── Load competencias & capacidades ───────────────────────────────────────────
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
    $tbl     = $isTrans ? $transTable : $compTable;
    $compInfo = Database::fetch_array(Database::query(
        "SELECT id, name FROM $tbl WHERE id = $compId LIMIT 1"
    ), 'ASSOC');
    if (!$compInfo) continue;

    $capacidades = [];
    $capRes = Database::query(
        "SELECT rc2.id AS aux_cap_id, rc2.capacidad_id, rc2.is_transversal, rc2.criterio
         FROM $rCapTable rc2 WHERE rc2.registro_comp_id = $rcId ORDER BY rc2.order_index ASC"
    );
    while ($capRow = Database::fetch_array($capRes, 'ASSOC')) {
        $capId    = (int) $capRow['capacidad_id'];
        $capTrans = (int) $capRow['is_transversal'];
        $ctbl     = $capTrans ? $tcapTable : $capTable;
        $capInfo  = Database::fetch_array(Database::query(
            "SELECT id, name FROM $ctbl WHERE id = $capId LIMIT 1"
        ), 'ASSOC');
        if (!$capInfo) continue;
        $capacidades[] = [
            'aux_cap_id' => (int) $capRow['aux_cap_id'],
            'name'       => $capInfo['name'],
            'criterio'   => $capRow['criterio'] ?? '',
        ];
    }

    $competencias[] = [
        'label'       => 'C' . $compIndex,
        'name'        => $compInfo['name'],
        'capacidades' => $capacidades,
    ];
    $compIndex++;
}

$students = AcademicManager::getClassroomStudents((int) $registro['classroom_id']);

$notasMap = [];
$notasRes = Database::query(
    "SELECT aux_capacidad_id, student_id, nota FROM $nTable WHERE registro_id = $registroId"
);
while ($r = Database::fetch_array($notasRes, 'ASSOC')) {
    $notasMap[$r['aux_capacidad_id']][$r['student_id']] = $r['nota'];
}

$enfoques = [];
$efRes = Database::query(
    "SELECT * FROM $efTable WHERE registro_id = $registroId ORDER BY order_index ASC"
);
while ($r = Database::fetch_array($efRes, 'ASSOC')) {
    $enfoques[] = $r;
}

// ── Grade helpers ─────────────────────────────────────────────────────────────
function raLetterToNum($val) {
    $map = ['AD' => 19, 'A' => 16, 'B' => 12, 'C' => 8];
    $v   = strtoupper(trim((string) $val));
    if (isset($map[$v])) return $map[$v];
    $n = filter_var($v, FILTER_VALIDATE_FLOAT);
    return $n !== false ? (float) $n : null;
}
function raNumToLetter($n) {
    if ($n >= 18) return 'AD';
    if ($n >= 14) return 'A';
    if ($n >= 11) return 'B';
    return 'C';
}
function raFormat($avg, $type) {
    if ($avg === null) return '';
    if ($type === 'numeric') return (string) round($avg);
    if ($type === 'letter')  return raNumToLetter($avg);
    return round($avg) . ' (' . raNumToLetter($avg) . ')';
}

// ── Column layout (0-based) ───────────────────────────────────────────────────
// 0 = N°,  1 = Apellidos y Nombres,  2..N = competencias block,  last = PROMEDIO
$compRanges = [];
$cur = 2;
foreach ($competencias as $comp) {
    $capCount      = count($comp['capacidades']);
    $start         = $cur;
    $nivelCol      = $cur + $capCount;
    $compRanges[]  = ['start' => $start, 'nivel' => $nivelCol, 'capCount' => $capCount];
    $cur           = $nivelCol + 1;
}
$promedioCol = $cur;   // last column (0-based)
$totalCols   = $cur + 1;

// ── XML helpers ───────────────────────────────────────────────────────────────
function xe($s) { return htmlspecialchars((string) $s, ENT_XML1, 'UTF-8'); }

function xlCell($value, $styleId, $mergeAcross = 0, $mergeDown = 0, $index = 0, $type = 'String') {
    $attrs  = ' ss:StyleID="' . $styleId . '"';
    if ($index     > 0) $attrs .= ' ss:Index="' . $index . '"';
    if ($mergeAcross > 0) $attrs .= ' ss:MergeAcross="' . $mergeAcross . '"';
    if ($mergeDown   > 0) $attrs .= ' ss:MergeDown="' . $mergeDown . '"';
    $val = ($value !== '') ? '<Data ss:Type="' . $type . '">' . xe($value) . '</Data>' : '';
    return '<Cell' . $attrs . '>' . $val . '</Cell>';
}

// ── Styles ────────────────────────────────────────────────────────────────────
$gradeType = $registro['grade_type'] ?? 'numeric';

$styles = <<<XML
<Styles>
  <Style ss:ID="Default"><Alignment ss:Vertical="Center"/><Font ss:FontName="Calibri" ss:Size="10"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sTitle"><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="12" ss:Bold="1"/><Interior ss:Color="#DCE8FC" ss:Pattern="Solid"/></Style>
  <Style ss:ID="sInfo"><Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="10"/></Style>
  <Style ss:ID="sHdrNro"><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="9" ss:Bold="1"/><Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sHdrComp"><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="9" ss:Bold="1"/><Interior ss:Color="#DCE8FC" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sHdrCompName"><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="8" ss:Bold="1" ss:Color="#1A56CC"/><Interior ss:Color="#E8F0FE" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sHdrCaps"><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="8" ss:Bold="1"/><Interior ss:Color="#E3EEFF" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sHdrNivel"><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="8" ss:Bold="1"/><Interior ss:Color="#C8E6C9" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sHdrProm"><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="8" ss:Bold="1"/><Interior ss:Color="#FFF3CD" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sHdrCapName"><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="8"/><Interior ss:Color="#F0F4FF" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sHdrCriterio"><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="8"/><Interior ss:Color="#FFFBF0" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sDataNro"><Alignment ss:Horizontal="Center" ss:Vertical="Center"/><Font ss:FontName="Calibri" ss:Size="10"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sDataName"><Alignment ss:Horizontal="Left" ss:Vertical="Center"/><Font ss:FontName="Calibri" ss:Size="10" ss:Bold="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sDataNota"><Alignment ss:Horizontal="Center" ss:Vertical="Center"/><Font ss:FontName="Calibri" ss:Size="10"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sDataNivel"><Alignment ss:Horizontal="Center" ss:Vertical="Center"/><Font ss:FontName="Calibri" ss:Size="10" ss:Bold="1"/><Interior ss:Color="#F1FAF1" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
  <Style ss:ID="sDataProm"><Alignment ss:Horizontal="Center" ss:Vertical="Center"/><Font ss:FontName="Calibri" ss:Size="10" ss:Bold="1"/><Interior ss:Color="#FFFDE7" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#BBBBBB"/></Borders></Style>
</Styles>
XML;

// ── Build XML output ──────────────────────────────────────────────────────────
$gradeLabel = $gradeType === 'numeric' ? 'Numérica (0–20)'
            : ($gradeType === 'letter' ? 'Literal (AD/A/B/C)' : 'Combinada');

$xml  = '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
$xml .= '<?mso-application progid="Excel.Sheet"?>' . "\n";
$xml .= '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'
      . ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'
      . ' xmlns:x="urn:schemas-microsoft-com:office:excel">' . "\n";
$xml .= $styles . "\n";
$xml .= '<Worksheet ss:Name="Registro Auxiliar"><Table>' . "\n";

// Column widths
$xml .= '<Column ss:Index="1" ss:Width="28"/>'; // N°
$xml .= '<Column ss:Index="2" ss:Width="170"/>'; // Apellidos y Nombres
for ($c = 2; $c < $promedioCol; $c++) {
    $xml .= '<Column ss:Index="' . ($c + 1) . '" ss:Width="72"/>';
}
$xml .= '<Column ss:Index="' . ($promedioCol + 1) . '" ss:Width="80"/>'; // PROMEDIO
$xml .= "\n";

// ── Info rows ─────────────────────────────────────────────────────────────────
$span = $promedioCol; // MergeAcross to cover all columns (0-based last col = promedioCol)

$xml .= '<Row ss:Height="20">'
      . xlCell('REGISTRO AUXILIAR — ' . strtoupper($registro['period']), 'sTitle', $span)
      . '</Row>' . "\n";

$classroom = $registro['level_name'] . ' — ' . $registro['grade_name']
           . (!empty($registro['section_name']) ? ' Sec. ' . $registro['section_name'] : '');
$xml .= '<Row ss:Height="16">'
      . xlCell($classroom . '   ' . $registro['course_title'] . '   ' . $registro['area_name'], 'sInfo', $span)
      . '</Row>' . "\n";

$xml .= '<Row ss:Height="16">'
      . xlCell('Área: ' . $registro['area_name'] . '   Docente: ' . $registro['teacher_name'] . '   Tipo nota: ' . $gradeLabel, 'sInfo', $span)
      . '</Row>' . "\n";

if (!empty($enfoques)) {
    $nombres = implode(', ', array_column($enfoques, 'nombre'));
    $valores = implode(', ', array_filter(array_column($enfoques, 'valores')));
    $xml .= '<Row ss:Height="30">'
          . xlCell('Enfoques: ' . $nombres . ($valores ? '   |   Valores: ' . $valores : ''), 'sInfo', $span)
          . '</Row>' . "\n";
}

// blank separator
$xml .= '<Row ss:Height="8"><Cell ss:StyleID="Default"/></Row>' . "\n";

// ── Header rows ───────────────────────────────────────────────────────────────
// Structure (0-based columns):
//   0 = N°, 1 = Apellidos, 2..promedioCol-1 = comps block, promedioCol = PROMEDIO
//
// hdr1: N°(MD4), Apellidos(MD4), COMPETENCIA DEL ÁREA(MA=promedioCol-3), PROMEDIO(MD4)
// hdr2: [skip 0,1] comp names each with MA=(end-start)
// hdr3: [skip 0,1] CAPACIDADES(MA=capCount-1) + NIVEL(MD2) per comp
// hdr4: [skip 0,1] cap names (individual) + [skip nivel] per comp
// hdr5: [skip 0,1] criterios + [skip nivel] per comp

$compAreaSpan = $promedioCol - 3; // MergeAcross for "COMPETENCIA DEL ÁREA"

// hdr1
$xml .= '<Row ss:Height="30">'
      . xlCell('N°',                       'sHdrNro',   0, 4)
      . xlCell('Apellidos y Nombres',       'sHdrNro',   0, 4)
      . xlCell('COMPETENCIA DEL ÁREA',      'sHdrComp',  $compAreaSpan)
      . xlCell('PROMEDIO DE LA ASIGNATURA', 'sHdrProm',  0, 4, $promedioCol + 1)
      . '</Row>' . "\n";

// hdr2 — comp names (cols 0,1 covered)
$xml .= '<Row ss:Height="36">';
foreach ($competencias as $i => $comp) {
    $r    = $compRanges[$i];
    $idx  = $r['start'] + 1; // 1-based
    $xml .= xlCell($comp['label'] . '_' . $comp['name'], 'sHdrCompName', $r['capCount'], 0, $idx);
}
$xml .= '</Row>' . "\n";

// hdr3 — CAPACIDADES + NIVEL DE LOGRO (MD2)
$xml .= '<Row ss:Height="20">';
foreach ($competencias as $i => $comp) {
    $r   = $compRanges[$i];
    $idx = $r['start'] + 1;
    $ma  = $r['capCount'] > 1 ? $r['capCount'] - 1 : 0;
    $xml .= xlCell('CAPACIDADES',    'sHdrCaps',  $ma, 0, $idx);
    $xml .= xlCell('NIVEL DE LOGRO', 'sHdrNivel', 0,   2, $r['nivel'] + 1);
}
$xml .= '</Row>' . "\n";

// hdr4 — individual capacidad names (nivel cols covered by MD2)
$xml .= '<Row ss:Height="72">';
foreach ($competencias as $i => $comp) {
    $r   = $compRanges[$i];
    $col = $r['start'];
    foreach ($comp['capacidades'] as $ci => $cap) {
        $idx = ($ci === 0) ? ($col + 1) : 0; // only set index for first of each comp block
        $xml .= xlCell($cap['name'], 'sHdrCapName', 0, 0, $idx);
        $col++;
        $idx = 0;
    }
    // nivel column is covered — skip with explicit index on next comp's first cap
}
$xml .= '</Row>' . "\n";

// hdr5 — criterios (nivel cols still covered)
$xml .= '<Row ss:Height="28">';
foreach ($competencias as $i => $comp) {
    $r   = $compRanges[$i];
    $col = $r['start'];
    foreach ($comp['capacidades'] as $ci => $cap) {
        $idx = ($ci === 0) ? ($col + 1) : 0;
        $xml .= xlCell($cap['criterio'], 'sHdrCriterio', 0, 0, $idx);
        $col++;
    }
}
$xml .= '</Row>' . "\n";

// ── Data rows ─────────────────────────────────────────────────────────────────
foreach ($students as $si => $student) {
    $xml .= '<Row ss:Height="18">';
    $xml .= xlCell($si + 1, 'sDataNro', 0, 0, 0, 'Number');
    $xml .= xlCell($student['lastname'] . ', ' . $student['firstname'], 'sDataName');

    $nivelVals = [];
    foreach ($competencias as $i => $comp) {
        $vals = [];
        foreach ($comp['capacidades'] as $cap) {
            $nota     = $notasMap[$cap['aux_cap_id']][$student['user_id']] ?? '';
            $notaNum  = ($nota !== '') ? raLetterToNum($nota) : null;
            $notaIsNum = ($notaNum !== null && !in_array(strtoupper(trim($nota)), ['AD','A','B','C']));
            $xml .= xlCell(
                $notaIsNum ? $notaNum : $nota,
                'sDataNota',
                0, 0, 0,
                $notaIsNum ? 'Number' : 'String'
            );
            if ($notaNum !== null) $vals[] = $notaNum;
        }
        if (!empty($vals)) {
            $avg         = array_sum($vals) / count($vals);
            $nivelVals[] = $avg;
            if ($gradeType === 'numeric') {
                $xml .= xlCell(round($avg, 2), 'sDataNivel', 0, 0, 0, 'Number');
            } else {
                $xml .= xlCell(raFormat($avg, $gradeType), 'sDataNivel');
            }
        } else {
            $xml .= xlCell('', 'sDataNivel');
        }
    }

    if (!empty($nivelVals)) {
        $prom = array_sum($nivelVals) / count($nivelVals);
        if ($gradeType === 'numeric') {
            $xml .= xlCell(round($prom, 2), 'sDataProm', 0, 0, 0, 'Number');
        } else {
            $xml .= xlCell(raFormat($prom, $gradeType), 'sDataProm');
        }
    } else {
        $xml .= xlCell('', 'sDataProm');
    }
    $xml .= '</Row>' . "\n";
}

$xml .= '</Table></Worksheet></Workbook>';

// ── Send file ─────────────────────────────────────────────────────────────────
$area     = preg_replace('/[^A-Za-z0-9_\-]/', '_', $registro['area_name'] ?? 'Area');
$filename = 'Registro_Auxiliar_' . $registro['period'] . '_' . $area . '.xls';

header('Content-Type: application/vnd.ms-excel; charset=UTF-8');
header('Content-Disposition: attachment; filename="' . $filename . '"');
header('Cache-Control: max-age=0');
header('Pragma: no-cache');

echo $xml;
exit;
