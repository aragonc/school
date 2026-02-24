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

// Get active year (for classroom section lookup)
$activeYear   = MatriculaManager::getActiveYear();
$activeYearId = $activeYear ? (int) $activeYear['id'] : 0;

// Fetch all fichas with their most recent matricula data.
// Section comes from classroom assignment (classroom_student → classroom → section),
// not from the grade table (which has no section column).
$sql = "SELECT
            f.id          AS ficha_id,
            f.apellido_paterno,
            f.apellido_materno,
            f.nombres,
            f.dni,
            f.foto,
            f.user_id,
            m.id          AS matricula_id,
            m.grade_id,
            m.estado,
            m.tipo_ingreso,
            m.academic_year_id,
            ay.year       AS academic_year,
            g.name        AS grade_name,
            g.order_index AS grade_order,
            l.id          AS level_id,
            l.name        AS level_name,
            l.order_index AS level_order,
            sec.name      AS section_name
        FROM $fichaTable f
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
        LEFT JOIN $yearTable  ay  ON ay.id = m.academic_year_id
        -- Classroom/section: look up active-year classroom where this user is enrolled
        LEFT JOIN $classroomStuTbl  cls_stu
            ON f.user_id IS NOT NULL
            AND cls_stu.user_id = f.user_id
        LEFT JOIN $classroomTable   cls
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
    // Resolve photo URL
    if (!empty($row['foto'])) {
        $row['foto_url'] = api_get_path(WEB_PLUGIN_PATH) . 'school/uploads/matricula/' . $row['foto'];
    } elseif (!empty($row['user_id'])) {
        $uInfo = api_get_user_info((int) $row['user_id']);
        $row['foto_url'] = $uInfo['avatar'] ?? '';
    } else {
        $row['foto_url'] = '';
    }
    $allRows[] = $row;
}

// ---- Group by nivel → grado+sección ----
// Students without a grade go into a special group
$groups      = [];  // [ 'level_name|grade_name|section' => ['label'=>..., 'students'=>[]] ]
$sinGrupo    = [];  // students with no grade assigned

foreach ($allRows as $row) {
    if (empty($row['grade_id'])) {
        $sinGrupo[] = $row;
    } else {
        $lvl     = $row['level_name'] ?: '(Sin nivel)';
        $grd     = $row['grade_name'] ?: '(Sin grado)';
        $sec     = $row['section_name'] ?: '';
        $key     = $lvl . '|||' . $grd . '|||' . $sec;
        if (!isset($groups[$key])) {
            $label = $lvl . ' — ' . $grd;
            if ($sec !== '') {
                $label .= ' — Sección ' . $sec;
            }
            $groups[$key] = ['label' => $label, 'level' => $lvl, 'grade' => $grd, 'section' => $sec, 'students' => []];
        }
        $groups[$key]['students'][] = $row;
    }
}

// ---- Institution logo ----
$customLogo = $plugin->getCustomLogo();
if (!$customLogo) {
    $theme      = api_get_visual_theme();
    $themeDir   = Template::getThemeDir($theme);
    $customLogo = api_get_path(WEB_CSS_PATH) . $themeDir . 'images/header-logo-vector.svg';
}

$institutionName = htmlspecialchars(api_get_setting('Institution') ?: 'Institución');
$qrcodeJs        = api_get_path(WEB_PLUGIN_PATH) . 'school/js/qrcode.min.js';
$backUrl         = api_get_path(WEB_PATH) . 'matricula/alumnos';
$totalStudents   = count($allRows);

header('Content-Type: text/html; charset=utf-8');
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tarjetas de Alumnos — <?= $institutionName ?></title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: Arial, Helvetica, sans-serif;
    background: #eef1f6;
    padding: 24px 16px;
    color: #2d3748;
}

/* ---- Toolbar ---- */
.toolbar {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 12px;
    margin-bottom: 28px;
    flex-wrap: wrap;
}
.page-title {
    font-size: 18px;
    font-weight: 700;
    color: #1a3558;
    letter-spacing: .5px;
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
.btn-print  { background: #1a3558; color: #fff; }
.btn-back   { background: #6c757d; color: #fff; }
.badge-count {
    background: #1a3558;
    color: #fff;
    border-radius: 20px;
    padding: 2px 10px;
    font-size: 13px;
    font-weight: 700;
}

/* ---- Group heading ---- */
.group-heading {
    max-width: 980px;
    margin: 28px auto 12px;
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
.group-heading-sin {
    background: #718096;
}

/* ---- Grid ---- */
.cards-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 18px;
    max-width: 980px;
    margin: 0 auto;
}

/* ---- Tarjeta ---- */
.id-card {
    background: #fff;
    border-radius: 12px;
    overflow: hidden;
    border: 1px solid #d1d9e6;
    box-shadow: 0 2px 8px rgba(0,0,0,.10);
    break-inside: avoid;
    page-break-inside: avoid;
}

/* Header azul marino */
.card-head {
    display: flex;
    align-items: center;
    padding: 12px 14px 10px;
    background: #1a3558;
    border-bottom: 3px solid #0f2040;
}
.card-head .logo {
    height: 38px;
    max-width: 66px;
    object-fit: contain;
    background: #fff;
    border-radius: 5px;
    padding: 2px;
    margin-right: 10px;
    flex-shrink: 0;
}
.card-head .inst   { font-size: 8px; font-weight: 700; letter-spacing: .8px; text-transform: uppercase; color: #a8c4e0; line-height: 1.3; }
.card-head .carnet { font-size: 10px; font-weight: 800; letter-spacing: .8px; color: #fff; line-height: 1.4; }

/* Foto */
.card-photo { text-align: center; padding: 14px 14px 8px; }
.photo-wrap {
    width: 90px; height: 115px;
    background: #f0f4f8;
    border-radius: 8px;
    overflow: hidden;
    border: 2px solid #cbd5e0;
    display: inline-flex;
    align-items: center;
    justify-content: center;
}
.photo-wrap img { width: 100%; height: 100%; object-fit: cover; display: block; }
.photo-wrap .no-photo { font-size: 42px; color: #a0aec0; line-height: 1; }

/* Nombre */
.card-name { text-align: center; padding: 0 14px 8px; }
.card-name .lbl      { font-size: 7px; color: #718096; text-transform: uppercase; letter-spacing: .8px; margin-bottom: 2px; }
.card-name .apellidos{ font-size: 13px; font-weight: 800; color: #1a202c; line-height: 1.2; }
.card-name .nombres  { font-size: 11px; font-weight: 500; color: #4a5568; line-height: 1.3; }

/* DNI + Nivel row */
.card-info {
    display: flex;
    margin: 0 12px 8px;
    background: #f7f8fa;
    border-radius: 7px;
    border: 1px solid #e2e8f0;
    overflow: hidden;
}
.card-info .info-cell,
.card-grado .info-cell {
    flex: 1;
    padding: 6px 10px;
}
.card-info .info-cell + .info-cell,
.card-grado .info-cell + .info-cell {
    border-left: 1px solid #e2e8f0;
}
.card-info .lbl,
.card-grado .lbl   { font-size: 7px; color: #718096; text-transform: uppercase; letter-spacing: .8px; }
.card-info .value,
.card-grado .value { font-size: 11px; font-weight: 700; color: #2d3748; }

/* Grado row */
.card-grado {
    margin: 0 12px 10px;
    background: #f7f8fa;
    border-radius: 7px;
    border: 1px solid #e2e8f0;
    overflow: hidden;
    display: flex;
}

/* QR */
.card-qr { text-align: center; padding: 0 14px 12px; }
.qr-box  { background: #f7f8fa; border: 1px solid #e2e8f0; padding: 6px; border-radius: 6px; display: inline-block; }
.card-qr .dni-text { font-size: 9px; color: #718096; margin-top: 4px; font-weight: 700; letter-spacing: 1px; }

/* Footer */
.card-foot {
    background: #1a3558;
    border-top: 3px solid #0f2040;
    text-align: center;
    padding: 8px;
    font-size: 7px;
    letter-spacing: 1.3px;
    color: #fff;
    font-weight: 700;
    text-transform: uppercase;
}

/* ---- Print ---- */
@media print {
    body { background: #fff; padding: 4px; }
    .toolbar { display: none !important; }
    .cards-grid { gap: 8px; max-width: 100%; grid-template-columns: repeat(3, 1fr); }
    .id-card { box-shadow: none; border: 1px solid #bbb; }
    .group-heading { max-width: 100%; margin: 16px 0 8px; font-size: 13px; }
}
@page { size: A4 portrait; margin: 1cm; }
</style>
</head>
<body>

<div class="toolbar">
    <span class="page-title">Tarjetas de Alumnos</span>
    <span class="badge-count"><?= $totalStudents ?> alumnos</span>
    <button class="btn btn-print" onclick="window.print()">
        &#128438; Imprimir / Guardar PDF
    </button>
    <a href="<?= $backUrl ?>" class="btn btn-back">&#8592; Volver</a>
</div>

<?php
// ---- Render grouped cards ----
$cardIdx = 0;

// Render each group
foreach ($groups as $groupData):
    $groupLabel    = $groupData['label'];
    $groupStudents = $groupData['students'];
?>
<div class="group-heading">
    <?= htmlspecialchars($groupLabel) ?>
    <span class="group-count">(<?= count($groupStudents) ?> alumnos)</span>
</div>
<div class="cards-grid">
<?php foreach ($groupStudents as $u):
    $apellidos = htmlspecialchars(trim($u['apellido_paterno'] . ' ' . $u['apellido_materno']));
    $nombres   = htmlspecialchars(trim($u['nombres']));
    $dni       = htmlspecialchars($u['dni'] ?? '');
    $nivel     = htmlspecialchars($u['level_name'] ?? '');
    $grado     = htmlspecialchars($u['grade_name'] ?? '');
    $seccion   = htmlspecialchars($u['section_name'] ?? '');
    $fotoUrl   = htmlspecialchars($u['foto_url']);
    $qrVal     = $dni ?: ($apellidos . ' ' . $nombres);
?>
    <div class="id-card">
        <div class="card-head">
            <img class="logo" src="<?= htmlspecialchars($customLogo) ?>" alt="Logo">
            <div>
                <div class="inst"><?= $institutionName ?></div>
                <div class="carnet">TARJETA ESTUDIANTIL</div>
            </div>
        </div>

        <div class="card-photo">
            <div class="photo-wrap">
                <?php if ($fotoUrl): ?>
                <img src="<?= $fotoUrl ?>" alt="Foto">
                <?php else: ?>
                <span class="no-photo">&#128100;</span>
                <?php endif; ?>
            </div>
        </div>

        <div class="card-name">
            <div class="lbl">Apellidos y Nombres</div>
            <div class="apellidos"><?= $apellidos ?></div>
            <div class="nombres"><?= $nombres ?></div>
        </div>

        <div class="card-info">
            <div class="info-cell">
                <div class="lbl">DNI</div>
                <div class="value"><?= $dni ?: '—' ?></div>
            </div>
            <div class="info-cell">
                <div class="lbl">Nivel</div>
                <div class="value"><?= $nivel ?: '—' ?></div>
            </div>
        </div>

        <div class="card-grado">
            <div class="info-cell">
                <div class="lbl">Grado</div>
                <div class="value"><?= $grado ?: '—' ?></div>
            </div>
            <div class="info-cell">
                <div class="lbl">Sección</div>
                <div class="value"><?= $seccion ?: '—' ?></div>
            </div>
        </div>

        <div class="card-qr">
            <div class="qr-box" id="qr-<?= $cardIdx ?>" data-value="<?= htmlspecialchars($qrVal) ?>"></div>
            <?php if ($dni): ?>
            <div class="dni-text">DNI: <?= $dni ?></div>
            <?php endif; ?>
        </div>

        <div class="card-foot">DOCUMENTO DE IDENTIFICACIÓN ESTUDIANTIL</div>
    </div>
<?php $cardIdx++; endforeach; ?>
</div>
<?php endforeach; ?>

<?php if (!empty($sinGrupo)): ?>
<div class="group-heading group-heading-sin">
    Sin asignación de aula
    <span class="group-count">(<?= count($sinGrupo) ?> alumnos)</span>
</div>
<div class="cards-grid">
<?php foreach ($sinGrupo as $u):
    $apellidos = htmlspecialchars(trim($u['apellido_paterno'] . ' ' . $u['apellido_materno']));
    $nombres   = htmlspecialchars(trim($u['nombres']));
    $dni       = htmlspecialchars($u['dni'] ?? '');
    $fotoUrl   = htmlspecialchars($u['foto_url']);
    $qrVal     = $dni ?: ($apellidos . ' ' . $nombres);
?>
    <div class="id-card">
        <div class="card-head">
            <img class="logo" src="<?= htmlspecialchars($customLogo) ?>" alt="Logo">
            <div>
                <div class="inst"><?= $institutionName ?></div>
                <div class="carnet">TARJETA ESTUDIANTIL</div>
            </div>
        </div>

        <div class="card-photo">
            <div class="photo-wrap">
                <?php if ($fotoUrl): ?>
                <img src="<?= $fotoUrl ?>" alt="Foto">
                <?php else: ?>
                <span class="no-photo">&#128100;</span>
                <?php endif; ?>
            </div>
        </div>

        <div class="card-name">
            <div class="lbl">Apellidos y Nombres</div>
            <div class="apellidos"><?= $apellidos ?></div>
            <div class="nombres"><?= $nombres ?></div>
        </div>

        <div class="card-info">
            <div class="info-cell">
                <div class="lbl">DNI</div>
                <div class="value"><?= $dni ?: '—' ?></div>
            </div>
            <div class="info-cell">
                <div class="lbl">Nivel</div>
                <div class="value">—</div>
            </div>
        </div>

        <div class="card-grado">
            <div class="info-cell">
                <div class="lbl">Grado</div>
                <div class="value">—</div>
            </div>
            <div class="info-cell">
                <div class="lbl">Sección</div>
                <div class="value">—</div>
            </div>
        </div>

        <div class="card-qr">
            <div class="qr-box" id="qr-<?= $cardIdx ?>" data-value="<?= htmlspecialchars($qrVal) ?>"></div>
            <?php if ($dni): ?>
            <div class="dni-text">DNI: <?= $dni ?></div>
            <?php endif; ?>
        </div>

        <div class="card-foot">DOCUMENTO DE IDENTIFICACIÓN ESTUDIANTIL</div>
    </div>
<?php $cardIdx++; endforeach; ?>
</div>
<?php endif; ?>

<script src="<?= $qrcodeJs ?>"></script>
<script>
(function () {
    var boxes = document.querySelectorAll('.qr-box');
    boxes.forEach(function (box) {
        new QRCode(box, {
            text: box.dataset.value || '-',
            width:  64,
            height: 64,
            colorDark:  '#1a3558',
            colorLight: '#f7f8fa',
            correctLevel: QRCode.CorrectLevel.M
        });
    });
})();
</script>
</body>
</html>
<?php exit; ?>
