<?php
/* For licensing terms, see /license.txt */
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../MatriculaManager.php';

api_protect_admin_script();

$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

// ---- Query all students with their active matricula info ----
$fichaTable       = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
$matriculaTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
$gradeTable       = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
$levelTable       = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
$yearTable        = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
$classroomTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
$classroomStuTbl  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
$sectionTable     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
$userTable        = Database::get_main_table(TABLE_MAIN_USER);

$activeYear   = MatriculaManager::getActiveYear();
$activeYearId = $activeYear ? (int) $activeYear['id'] : 0;

$sql = "SELECT
            f.id          AS ficha_id,
            f.apellido_paterno,
            f.apellido_materno,
            f.nombres,
            COALESCE(NULLIF(TRIM(f.dni), ''), u.official_code) AS dni,
            f.user_id,
            m.grade_id,
            g.name        AS grade_name,
            l.name        AS level_name,
            sec.name      AS section_name
        FROM $fichaTable f
        LEFT JOIN $userTable u ON u.id = f.user_id
        LEFT JOIN $matriculaTable m
            ON m.id = (
                SELECT m2.id FROM $matriculaTable m2
                WHERE m2.ficha_id = f.id
                ORDER BY
                    CASE WHEN m2.academic_year_id = $activeYearId THEN 0 ELSE 1 END,
                    m2.id DESC
                LIMIT 1
            )
        LEFT JOIN $gradeTable g   ON g.id  = m.grade_id
        LEFT JOIN $levelTable l   ON l.id  = g.level_id
        LEFT JOIN $classroomStuTbl cls_stu
            ON f.user_id IS NOT NULL
            AND cls_stu.user_id = f.user_id
        LEFT JOIN $classroomTable cls
            ON cls.id = cls_stu.classroom_id
            AND cls.active = 1
            AND cls.academic_year_id = $activeYearId
        LEFT JOIN $sectionTable sec ON sec.id = cls.section_id
        ORDER BY
            ISNULL(l.order_index), l.order_index ASC,
            l.name ASC,
            ISNULL(g.order_index), g.order_index ASC,
            g.name ASC,
            sec.name ASC,
            f.apellido_paterno ASC,
            f.apellido_materno ASC,
            f.nombres ASC";

$result  = Database::query($sql);
$allRows = [];
while ($row = Database::fetch_array($result, 'ASSOC')) {
    $allRows[] = $row;
}

// ---- Agrupar por nivel → grado → sección ----
$groups   = [];
$sinGrupo = [];

foreach ($allRows as $row) {
    if (empty($row['grade_id'])) {
        $sinGrupo[] = $row;
    } else {
        $lvl = $row['level_name'] ?: '(Sin nivel)';
        $grd = $row['grade_name'] ?: '(Sin grado)';
        $sec = $row['section_name'] ?: '';
        $key = $lvl . '|||' . $grd . '|||' . $sec;
        if (!isset($groups[$key])) {
            $label = $lvl . ' — ' . $grd;
            if ($sec !== '') {
                $label .= ' — Sección ' . $sec;
            }
            $groups[$key] = ['label' => $label, 'students' => []];
        }
        $groups[$key]['students'][] = $row;
    }
}

$qrcodeJs      = api_get_path(WEB_PLUGIN_PATH) . 'school/js/qrcode.min.js';
$backUrl       = api_get_path(WEB_PATH) . 'matricula/alumnos';
$totalStudents = count($allRows);

header('Content-Type: text/html; charset=utf-8');
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>QR Alumnos</title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: Arial, Helvetica, sans-serif;
    background: #eef1f6;
    padding: 20px 16px;
    color: #2d3748;
}

/* ---- Toolbar ---- */
.toolbar {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 12px;
    margin-bottom: 24px;
    flex-wrap: wrap;
}
.page-title {
    font-size: 17px;
    font-weight: 700;
    color: #1a3558;
}
.btn {
    padding: 8px 18px;
    border-radius: 6px;
    border: none;
    cursor: pointer;
    font-size: 13px;
    font-weight: 600;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}
.btn-print { background: #1a3558; color: #fff; }
.btn-back  { background: #6c757d; color: #fff; }
.badge-count {
    background: #1a3558;
    color: #fff;
    border-radius: 20px;
    padding: 2px 10px;
    font-size: 13px;
    font-weight: 700;
}

/* ---- Encabezado de grupo ---- */
.group-heading {
    max-width: 980px;
    margin: 24px auto 10px;
    padding: 10px 18px;
    background: #1a3558;
    color: #fff;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 700;
    letter-spacing: .5px;
}
.group-heading .group-count {
    font-size: 12px;
    font-weight: 400;
    opacity: .75;
    margin-left: 8px;
}
.group-heading-sin { background: #718096; }

/* ---- Grid de QR ---- */
.qr-grid {
    display: grid;
    grid-template-columns: repeat(3, auto);
    gap: 14px;
    justify-content: center;
    max-width: 980px;
    margin: 0 auto;
}

/* ---- Cada etiqueta QR ---- */
.qr-label {
    display: flex;
    flex-direction: column;
    align-items: center;
    background: #fff;
    border: 1px solid #d1d9e6;
    border-radius: 8px;
    padding: 8px 8px 10px;
    break-inside: avoid;
    page-break-inside: avoid;
    width: 6.4cm;
}

/* El contenedor del QR fuerza exactamente 5cm × 5cm */
.qr-wrap {
    width: 5cm;
    height: 5cm;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
}
.qr-wrap canvas,
.qr-wrap img {
    width: 5cm !important;
    height: 5cm !important;
    display: block;
}

/* Texto debajo del QR */
.qr-info {
    margin-top: 7px;
    text-align: center;
    line-height: 1.4;
    width: 100%;
}
.qr-info .stu-apellidos {
    font-size: 9.5pt;
    font-weight: 800;
    color: #1a202c;
    word-break: break-word;
}
.qr-info .stu-nombres {
    font-size: 8.5pt;
    font-weight: 500;
    color: #4a5568;
}
.qr-info .stu-grado {
    margin-top: 4px;
    font-size: 8pt;
    color: #1a3558;
    font-weight: 700;
    letter-spacing: .3px;
}

/* ---- Print ---- */
@media print {
    body { background: #fff; padding: 0; }
    .toolbar { display: none !important; }
    .group-heading { max-width: 100%; margin: 14px 0 6px; font-size: 13px; }
    .qr-grid { gap: 6px; max-width: 100%; }
    .qr-label {
        border: 1px solid #aaa;
        border-radius: 4px;
        padding: 5px 5px 7px;
        box-shadow: none;
    }
}
@page { size: A4 portrait; margin: 1cm; }
</style>
</head>
<body>

<div class="toolbar">
    <span class="page-title">QR de Alumnos</span>
    <span class="badge-count"><?= $totalStudents ?> alumnos</span>
    <button class="btn btn-print" onclick="window.print()">&#128438; Imprimir / PDF</button>
    <a href="<?= $backUrl ?>" class="btn btn-back">&#8592; Volver</a>
</div>

<?php
$idx = 0;

// Helper para renderizar una tarjeta QR
function renderQrCard(array $u, int &$idx): void {
    $apellidos  = htmlspecialchars(trim($u['apellido_paterno'] . ' ' . $u['apellido_materno']));
    $nombres    = htmlspecialchars(trim($u['nombres']));
    $dni        = htmlspecialchars($u['dni'] ?? '');
    $nivel      = htmlspecialchars($u['level_name'] ?? '');
    $grado      = htmlspecialchars($u['grade_name'] ?? '');
    $seccion    = htmlspecialchars($u['section_name'] ?? '');
    $qrVal      = $dni ?: ($apellidos . ' ' . $nombres);

    $gradoLinea = '';
    if ($grado) {
        $gradoLinea = $grado;
        if ($seccion) $gradoLinea .= ' — Sec. ' . $seccion;
        if ($nivel)   $gradoLinea .= ' | ' . $nivel;
    }
    echo '<div class="qr-label">';
    echo '<div class="qr-wrap" id="qr-' . $idx . '" data-value="' . htmlspecialchars($qrVal) . '"></div>';
    echo '<div class="qr-info">';
    echo '<div class="stu-apellidos">' . $apellidos . '</div>';
    echo '<div class="stu-nombres">' . $nombres . '</div>';
    if ($gradoLinea) {
        echo '<div class="stu-grado">' . $gradoLinea . '</div>';
    }
    echo '</div></div>';
    $idx++;
}

// Grupos con grado
foreach ($groups as $groupData):
?>
<div class="group-heading">
    <?= htmlspecialchars($groupData['label']) ?>
    <span class="group-count">(<?= count($groupData['students']) ?> alumnos)</span>
</div>
<div class="qr-grid">
<?php foreach ($groupData['students'] as $u): renderQrCard($u, $idx); endforeach; ?>
</div>
<?php endforeach; ?>

<?php if (!empty($sinGrupo)): ?>
<div class="group-heading group-heading-sin">
    Sin asignación de aula
    <span class="group-count">(<?= count($sinGrupo) ?> alumnos)</span>
</div>
<div class="qr-grid">
<?php foreach ($sinGrupo as $u): renderQrCard($u, $idx); endforeach; ?>
</div>
<?php endif; ?>

<script src="<?= $qrcodeJs ?>"></script>
<script>
(function () {
    // Genera QR a 300px; el CSS lo escala a 5cm×5cm
    document.querySelectorAll('.qr-wrap').forEach(function (wrap) {
        new QRCode(wrap, {
            text:         wrap.dataset.value || '-',
            width:        300,
            height:       300,
            colorDark:    '#000000',
            colorLight:   '#ffffff',
            correctLevel: QRCode.CorrectLevel.M
        });
    });
})();
</script>
</body>
</html>
<?php exit; ?>
