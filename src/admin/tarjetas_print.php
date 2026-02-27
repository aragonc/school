<?php
/* For licensing terms, see /license.txt */
require_once __DIR__ . '/../../config.php';

api_protect_admin_script();

$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

// Query all staff users (same logic as usuarios.php)
$userTable  = Database::get_main_table(TABLE_MAIN_USER);
$adminTable = Database::get_main_table(TABLE_MAIN_ADMIN);
$nonStudentStatuses = implode(',', [COURSEMANAGER, DRH, SCHOOL_SECRETARY, SCHOOL_AUXILIARY, SCHOOL_PARENT, SCHOOL_GUARDIAN]);

$sql = "SELECT u.user_id, u.firstname, u.lastname, u.username, u.email, u.status,
               CASE
                   WHEN adm.user_id IS NOT NULL THEN 'Administrador'
                   WHEN u.status = " . COURSEMANAGER . "    THEN 'Docente'
                   WHEN u.status = " . DRH . "              THEN 'Administrativo'
                   WHEN u.status = " . SCHOOL_SECRETARY . " THEN 'Secretaria'
                   WHEN u.status = " . SCHOOL_AUXILIARY . " THEN 'Auxiliar'
                   WHEN u.status = " . SCHOOL_PARENT . "    THEN 'Padre de familia'
                   WHEN u.status = " . SCHOOL_GUARDIAN . "  THEN 'Apoderado'
                   ELSE 'Otro'
               END AS role_label
        FROM $userTable u
        LEFT JOIN $adminTable adm ON adm.user_id = u.user_id
        WHERE (u.status IN ($nonStudentStatuses) OR adm.user_id IS NOT NULL)
        ORDER BY u.lastname, u.firstname";

$result = Database::query($sql);
$users  = [];
while ($row = Database::fetch_array($result, 'ASSOC')) {
    $uInfo         = api_get_user_info($row['user_id']);
    $row['foto_url'] = $uInfo['avatar'] ?? '';
    $users[]       = $row;
}

// Institution logo
$customLogo = $plugin->getCustomLogo();
if (!$customLogo) {
    $theme      = api_get_visual_theme();
    $themeDir   = Template::getThemeDir($theme);
    $customLogo = api_get_path(WEB_CSS_PATH) . $themeDir . 'images/header-logo-vector.svg';
}

$institutionName = htmlspecialchars(api_get_setting('Institution') ?: 'Institución');
$qrcodeJs        = api_get_path(WEB_PLUGIN_PATH) . 'school/js/qrcode.min.js';
$backUrl         = api_get_path(WEB_PATH) . 'admin/usuarios';

header('Content-Type: text/html; charset=utf-8');
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tarjetas de Personal — <?= $institutionName ?></title>
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
.card-head .inst { font-size: 8px; font-weight: 700; letter-spacing: .8px; text-transform: uppercase; color: #a8c4e0; line-height: 1.3; }
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
.card-name { text-align: center; padding: 0 14px 10px; }
.card-name .lbl { font-size: 7px; color: #718096; text-transform: uppercase; letter-spacing: .8px; margin-bottom: 2px; }
.card-name .apellidos { font-size: 14px; font-weight: 800; color: #1a202c; line-height: 1.2; }
.card-name .nombres   { font-size: 12px; font-weight: 500; color: #4a5568; line-height: 1.3; }

/* Cargo */
.card-cargo { margin: 0 12px 10px; background: #f7f8fa; border-radius: 7px; border: 1px solid #e2e8f0; padding: 8px 10px; }
.card-cargo .lbl   { font-size: 7px; color: #718096; text-transform: uppercase; letter-spacing: .8px; }
.card-cargo .value { font-size: 12px; font-weight: 700; color: #2d3748; }

/* QR */
.card-qr { text-align: center; padding: 0 14px 12px; }
.qr-box  { background: #f7f8fa; border: 1px solid #e2e8f0; padding: 6px; border-radius: 6px; display: inline-block; max-width: 100%; }
.qr-box img, .qr-box canvas { max-width: 100%; height: auto !important; }
.card-qr .email { font-size: 8px; color: #718096; margin-top: 4px; word-break: break-all; }

/* Footer azul marino */
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
}
@page { size: A4 portrait; margin: 1cm; }
</style>
</head>
<body>

<div class="toolbar">
    <span class="page-title">Tarjetas de Personal</span>
    <span class="badge-count"><?= count($users) ?> usuarios</span>
    <button class="btn btn-print" onclick="window.print()">
        &#128438; Imprimir / Guardar PDF
    </button>
    <a href="<?= $backUrl ?>" class="btn btn-back">&#8592; Volver</a>
</div>

<div class="cards-grid">
<?php foreach ($users as $idx => $u):
    $apellidos = htmlspecialchars(trim($u['lastname']));
    $nombres   = htmlspecialchars(trim($u['firstname']));
    $cargo     = htmlspecialchars($u['role_label']);
    $email     = htmlspecialchars($u['email']);
    $fotoUrl   = htmlspecialchars($u['foto_url']);
?>
    <div class="id-card">
        <!-- Header -->
        <div class="card-head">
            <img class="logo" src="<?= htmlspecialchars($customLogo) ?>" alt="Logo">
            <div>
                <div class="inst"><?= $institutionName ?></div>
                <div class="carnet">CARNET DE PERSONAL</div>
            </div>
        </div>

        <!-- Foto -->
        <div class="card-photo">
            <div class="photo-wrap">
                <?php if ($fotoUrl): ?>
                <img src="<?= $fotoUrl ?>" alt="Foto">
                <?php else: ?>
                <span class="no-photo">&#128100;</span>
                <?php endif; ?>
            </div>
        </div>

        <!-- Nombre -->
        <div class="card-name">
            <div class="lbl">Apellidos y Nombres</div>
            <div class="apellidos"><?= $apellidos ?></div>
            <div class="nombres"><?= $nombres ?></div>
        </div>

        <!-- Cargo -->
        <div class="card-cargo">
            <div class="lbl">Cargo</div>
            <div class="value"><?= $cargo ?></div>
        </div>

        <!-- QR -->
        <div class="card-qr">
            <div class="qr-box" id="qr-<?= $idx ?>" data-value="<?= $email ?>"></div>
            <div class="email"><?= $email ?></div>
        </div>

        <!-- Footer -->
        <div class="card-foot">DOCUMENTO DE IDENTIFICACIÓN &mdash; PERSONAL</div>
    </div>
<?php endforeach; ?>
</div>

<script src="<?= $qrcodeJs ?>"></script>
<script>
(function () {
    var boxes = document.querySelectorAll('.qr-box');
    boxes.forEach(function (box) {
        new QRCode(box, {
            text: box.dataset.value || '-',
            width:  200,
            height: 200,
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
