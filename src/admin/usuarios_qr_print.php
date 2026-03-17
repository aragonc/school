<?php
/* For licensing terms, see /license.txt */
require_once __DIR__ . '/../../config.php';

api_protect_admin_script();

$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$userTable  = Database::get_main_table(TABLE_MAIN_USER);
$adminTable = Database::get_main_table(TABLE_MAIN_ADMIN);

$nonStudentStatuses = implode(',', [COURSEMANAGER, DRH, SCHOOL_SECRETARY, SCHOOL_AUXILIARY, SCHOOL_PARENT, SCHOOL_GUARDIAN]);

$sql = "SELECT u.user_id, u.firstname, u.lastname, u.username, u.email, u.status,
               CASE
                   WHEN adm.user_id IS NOT NULL THEN 'Administrador'
                   WHEN u.status = ".COURSEMANAGER." THEN 'Docente'
                   WHEN u.status = ".DRH."           THEN 'Administrativo'
                   WHEN u.status = ".SCHOOL_SECRETARY." THEN 'Secretaria'
                   WHEN u.status = ".SCHOOL_AUXILIARY." THEN 'Auxiliar'
                   WHEN u.status = ".SCHOOL_PARENT."    THEN 'Padre de familia'
                   WHEN u.status = ".SCHOOL_GUARDIAN."  THEN 'Apoderado'
                   ELSE 'Otro'
               END AS role_label
        FROM $userTable u
        LEFT JOIN $adminTable adm ON adm.user_id = u.user_id
        WHERE u.status IN ($nonStudentStatuses) OR adm.user_id IS NOT NULL
        ORDER BY role_label, u.lastname, u.firstname";

$result  = Database::query($sql);
$allRows = [];
while ($row = Database::fetch_array($result, 'ASSOC')) {
    $allRows[] = $row;
}

// Agrupar por rol
$groups = [];
foreach ($allRows as $row) {
    $rol = $row['role_label'] ?: 'Otro';
    if (!isset($groups[$rol])) {
        $groups[$rol] = [];
    }
    $groups[$rol][] = $row;
}

$qrcodeJs    = api_get_path(WEB_PLUGIN_PATH) . 'school/js/qrcode.min.js';
$backUrl     = api_get_path(WEB_PATH) . 'admin/usuarios';
$totalUsers  = count($allRows);

header('Content-Type: text/html; charset=utf-8');
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>QR Usuarios</title>
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
.qr-info .usr-apellidos {
    font-size: 9.5pt;
    font-weight: 800;
    color: #1a202c;
    word-break: break-word;
}
.qr-info .usr-nombres {
    font-size: 8.5pt;
    font-weight: 500;
    color: #4a5568;
}
.qr-info .usr-rol {
    margin-top: 4px;
    font-size: 8pt;
    color: #1a3558;
    font-weight: 700;
    letter-spacing: .3px;
}
.qr-info .usr-email {
    margin-top: 2px;
    font-size: 7.5pt;
    color: #718096;
    word-break: break-all;
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
    <span class="page-title">QR de Usuarios</span>
    <span class="badge-count"><?= $totalUsers ?> usuarios</span>
    <button class="btn btn-print" onclick="window.print()">&#128438; Imprimir / PDF</button>
    <a href="<?= $backUrl ?>" class="btn btn-back">&#8592; Volver</a>
</div>

<?php
$idx = 0;

function renderQrCard(array $u, int &$idx): void {
    $apellidos = htmlspecialchars(trim($u['lastname']));
    $nombres   = htmlspecialchars(trim($u['firstname']));
    $email     = htmlspecialchars($u['email'] ?? '');
    $rol       = htmlspecialchars($u['role_label'] ?? '');
    $qrVal     = $email ?: ($apellidos . ' ' . $nombres);

    echo '<div class="qr-label">';
    echo '<div class="qr-wrap" id="qr-' . $idx . '" data-value="' . htmlspecialchars($qrVal) . '"></div>';
    echo '<div class="qr-info">';
    echo '<div class="usr-apellidos">' . $apellidos . '</div>';
    echo '<div class="usr-nombres">' . $nombres . '</div>';
    echo '<div class="usr-rol">' . $rol . '</div>';
    if ($email) {
        echo '<div class="usr-email">' . $email . '</div>';
    }
    echo '</div></div>';
    $idx++;
}

foreach ($groups as $rolLabel => $users):
?>
<div class="group-heading">
    <?= htmlspecialchars($rolLabel) ?>
    <span class="group-count">(<?= count($users) ?> usuarios)</span>
</div>
<div class="qr-grid">
<?php foreach ($users as $u): renderQrCard($u, $idx); endforeach; ?>
</div>
<?php endforeach; ?>

<script src="<?= $qrcodeJs ?>"></script>
<script>
(function () {
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
