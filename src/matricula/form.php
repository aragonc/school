<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../MatriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$isAdmin = api_is_platform_admin();
$userInfo = api_get_user_info();
$isSecretary = $userInfo && $userInfo['status'] == SCHOOL_SECRETARY;

if (!$isAdmin && !$isSecretary) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('matricula');
$plugin->setSidebar('matricula');

$fichaId   = isset($_GET['ficha_id']) ? (int) $_GET['ficha_id'] : 0;
// Backward compat: ?id=MATRICULA_ID links still work
if (!$fichaId && isset($_GET['id']) && (int) $_GET['id'] > 0) {
    $mat = MatriculaManager::getMatriculaById((int) $_GET['id']);
    if ($mat) {
        $fichaId = (int) $mat['ficha_id'];
    }
}

// Direct access with no context → redirect to alumnos (new flow requires creating user first)
if ($fichaId === 0 && empty($_GET['user_id']) && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: ' . api_get_path(WEB_PATH) . 'matricula/alumnos');
    exit;
}
$matricula       = null;
$madre           = [];
$padre           = [];
$contactos       = [];
$info            = [];
$allPadres       = [];
$allHermanos     = [];
$allObservaciones = [];
$docs            = [];

if ($fichaId > 0) {
    $full = MatriculaManager::getFichaCompleta($fichaId);
    if (!$full) {
        header('Location: ' . api_get_path(WEB_PATH) . 'matricula');
        exit;
    }
    $matricula = $full;
    $madre     = $full['padres']['MADRE'] ?? [];
    $padre     = $full['padres']['PADRE'] ?? [];
    $contactos = $full['contactos'];
    $info      = $full['info'];
    foreach ($full['padres'] as $tipo => $pData) {
        if (!empty($pData)) {
            $allPadres[] = array_merge(['tipo' => $tipo], $pData);
        }
    }
    $allHermanos      = $full['hermanos'] ?? [];
    $allObservaciones = $full['observaciones'] ?? [];
    $docs             = $full['docs'] ?? [];
}

// POST handling
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $fichaId = isset($_POST['ficha_id']) ? (int) $_POST['ficha_id'] : 0;

    // Handle photo upload (temp name — will be renamed after ficha save)
    $uploadDir = realpath(__DIR__ . '/../../uploads') . '/matricula/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }
    if (!empty($_POST['foto_crop_data'])) {
        // Cropped image sent as base64 data URL
        $base64Raw = $_POST['foto_crop_data'];
        $base64Raw = preg_replace('/^data:image\/[a-z]+;base64,/i', '', $base64Raw);
        $imageData = base64_decode($base64Raw, true);
        if ($imageData !== false && strlen($imageData) > 0 && strlen($imageData) <= 5 * 1024 * 1024) {
            $filename = 'foto_new_' . time() . '.jpg';
            if (file_put_contents($uploadDir . $filename, $imageData) !== false) {
                $_POST['foto'] = $filename;
            }
        }
    } elseif (!empty($_FILES['foto']['tmp_name']) && $_FILES['foto']['error'] === UPLOAD_ERR_OK) {
        // Fallback: direct file upload (sin crop)
        $allowedMime = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime  = $finfo->file($_FILES['foto']['tmp_name']);
        if (in_array($mime, $allowedMime, true)) {
            $ext      = strtolower(preg_replace('/[^a-z]/', '', pathinfo($_FILES['foto']['name'], PATHINFO_EXTENSION)));
            $filename = 'foto_new_' . time() . '.' . $ext;
            if (move_uploaded_file($_FILES['foto']['tmp_name'], $uploadDir . $filename)) {
                $_POST['foto'] = $filename;
            }
        }
    }

    // Auto-fill names from linked Chamilo user (avoids re-entering data already in the profile)
    $postLinkedUserId = isset($_POST['user_id']) ? (int) $_POST['user_id'] : 0;
    if ($postLinkedUserId > 0) {
        $luData = api_get_user_info($postLinkedUserId);
        if ($luData) {
            $lparts = explode(' ', trim($luData['lastname']), 2);
            $_POST['apellido_paterno'] = mb_strtoupper(trim($lparts[0] ?? ''));
            $_POST['apellido_materno'] = mb_strtoupper(trim($lparts[1] ?? ''));
            $_POST['nombres']          = mb_strtoupper(trim($luData['firstname']));
        }
    }

    // Save ficha (personal data) — creates or updates the permanent student record
    $fichaData = array_merge($_POST, ['id' => $fichaId]);
    $fichaId   = MatriculaManager::saveFicha($fichaData);

    // Rename temp foto and update ficha record
    $fotoActualizada = false;
    if (!empty($_POST['foto']) && strpos($_POST['foto'], '_new_') !== false) {
        $oldPath = $uploadDir . $_POST['foto'];
        $newName = str_replace('_new_', '_' . $fichaId . '_', $_POST['foto']);
        if (file_exists($oldPath)) {
            rename($oldPath, $uploadDir . $newName);
            Database::update(
                Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA),
                ['foto' => $newName],
                ['id = ?' => $fichaId]
            );
            $_POST['foto'] = $newName;
            $fotoActualizada = true;
        }
    }

    // Update linked Chamilo user's profile photo
    if ($fotoActualizada) {
        $linkedUserId = (int) ($fichaData['user_id'] ?? 0);
        if ($linkedUserId > 0) {
            $photoPath = $uploadDir . $_POST['foto'];
            if (file_exists($photoPath)) {
                $newPicName = UserManager::update_user_picture(
                    $linkedUserId,
                    $_POST['foto'],
                    $photoPath
                );
                if ($newPicName) {
                    Database::update(
                        Database::get_main_table(TABLE_MAIN_USER),
                        ['picture_uri' => $newPicName],
                        ['user_id = ?' => $linkedUserId]
                    );
                }
            }
        }
    }

    // Save padres / apoderados from modal JSON
    if (isset($_POST['padres_data'])) {
        $padresData = json_decode($_POST['padres_data'], true);
        if (is_array($padresData)) {
            $padreTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_PADRE);
            Database::query("DELETE FROM $padreTable WHERE ficha_id = " . (int) $fichaId);
            foreach ($padresData as $padreEntry) {
                $tipo = strtoupper(trim($padreEntry['tipo'] ?? ''));
                if (in_array($tipo, ['PADRE', 'MADRE', 'APODERADO'])) {
                    MatriculaManager::savePadre($fichaId, $tipo, $padreEntry);
                }
            }
        }
    }

    // Save contactos de emergencia from modal JSON
    if (isset($_POST['contactos_data'])) {
        $contactosData = json_decode($_POST['contactos_data'], true);
        if (is_array($contactosData)) {
            $contactoTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_CONTACTO);
            Database::query("DELETE FROM $contactoTable WHERE ficha_id = " . (int) $fichaId);
            foreach ($contactosData as $contactoEntry) {
                if (!empty($contactoEntry['nombre_contacto']) || !empty($contactoEntry['telefono'])) {
                    MatriculaManager::saveContacto($fichaId, $contactoEntry);
                }
            }
        }
    }

    // Save hermanos from modal JSON
    if (isset($_POST['hermanos_data'])) {
        $hermanosData = json_decode($_POST['hermanos_data'], true);
        if (is_array($hermanosData)) {
            $hermanoTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA_HERMANO);
            Database::query("DELETE FROM $hermanoTable WHERE ficha_id = " . (int) $fichaId);
            foreach ($hermanosData as $h) {
                $hUserId = (int) ($h['user_id'] ?? 0);
                if ($hUserId > 0) {
                    Database::insert($hermanoTable, [
                        'ficha_id'        => $fichaId,
                        'hermano_user_id' => $hUserId,
                    ]);
                }
            }
        }
    }

    // Save observaciones from modal JSON
    if (isset($_POST['observaciones_data'])) {
        $obsData = json_decode($_POST['observaciones_data'], true);
        if (is_array($obsData)) {
            $obsTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_OBSERVACION);
            Database::query("DELETE FROM $obsTable WHERE ficha_id = " . (int) $fichaId);
            foreach ($obsData as $obs) {
                if (!empty($obs['titulo']) || !empty($obs['observacion'])) {
                    MatriculaManager::saveObservacion($fichaId, $obs);
                }
            }
        }
    }

    // Save document checklist
    MatriculaManager::saveDocs($fichaId, $_POST);

    Display::addFlash(Display::return_message($plugin->get_lang('EnrollmentSaved'), 'success'));
    header('Location: ' . api_get_path(WEB_PATH) . 'matricula/ver?ficha_id=' . $fichaId);
    exit;
}

$tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

// Load regions for ubigeo
$regionsJson = file_get_contents(__DIR__ . '/../../ajax/ubigeo/ubigeo_peru_2016_region.json');
$regions = json_decode($regionsJson, true) ?: [];

$plugin->assign('matricula', $matricula);
$plugin->assign('madre', $madre);
$plugin->assign('padre', $padre);
$plugin->assign('all_padres_json', json_encode($allPadres));
$plugin->assign('contactos', $contactos);
$plugin->assign('all_contactos_json', json_encode($contactos));
$plugin->assign('all_hermanos_json', json_encode($allHermanos));
$plugin->assign('all_observaciones_json', json_encode($allObservaciones));
$plugin->assign('docs', $docs);
$plugin->assign('info', $info);
$plugin->assign('tipos_sangre', $tiposSangre);
$plugin->assign('ficha_id', $fichaId);
$plugin->assign('regions', $regions);
$plugin->assign('ubigeo_path', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ubigeo/');
$plugin->assign('select_option_text', '-- ' . $plugin->get_lang('SelectOption') . ' --');
$plugin->assign('saved_region', $matricula['region'] ?? '');
$plugin->assign('saved_province', $matricula['provincia'] ?? '');
$plugin->assign('saved_district', $matricula['distrito'] ?? '');
$plugin->assign('ajax_matricula_url', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_matricula.php');
$plugin->assign('reniec_visible', $plugin->getSchoolSetting('reniec_visible') !== '0');
$plugin->assign('cropper_css_url', 'https://cdn.jsdelivr.net/npm/cropperjs@1.6.2/dist/cropper.min.css');
$plugin->assign('cropper_js_url', 'https://cdn.jsdelivr.net/npm/cropperjs@1.6.2/dist/cropper.min.js');
$fotoUrl = '';
if (!empty($matricula['foto'])) {
    $fotoUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/uploads/matricula/' . $matricula['foto'];
}
$plugin->assign('foto_url', $fotoUrl);

// Linked user: from existing matricula or pre-filled via GET ?user_id=
$linkedUserId   = 0;
$linkedUserName = '';
$preload        = [];

if (!empty($matricula['user_id'])) {
    $linkedUserId = (int) $matricula['user_id'];
} elseif (isset($_GET['user_id']) && (int) $_GET['user_id'] > 0) {
    $linkedUserId = (int) $_GET['user_id'];
}

if ($linkedUserId > 0) {
    $linkedUser = api_get_user_info($linkedUserId);
    if ($linkedUser) {
        $linkedUserName = $linkedUser['lastname'] . ' ' . $linkedUser['firstname'] . ' (' . $linkedUser['username'] . ')';

        // Pre-fill form for new ficha from Chamilo user
        if ($fichaId === 0) {
            // Split lastname: first word = apellido_paterno, rest = apellido_materno
            $lastnameParts    = explode(' ', trim($linkedUser['lastname']), 2);
            $apellidoPaterno  = $lastnameParts[0] ?? '';
            $apellidoMaterno  = $lastnameParts[1] ?? '';

            // DNI = first 8 chars of email (before @)
            $emailLocal = explode('@', $linkedUser['email'])[0] ?? '';
            $dniPreload = substr($emailLocal, 0, 8);

            $preload = [
                'apellido_paterno' => $apellidoPaterno,
                'apellido_materno' => $apellidoMaterno,
                'nombres'          => trim($linkedUser['firstname']),
                'tipo_documento'   => 'DNI',
                'dni'              => $dniPreload,
            ];
        }
    }
}

$plugin->assign('prelinked_user_id', $linkedUserId);
$plugin->assign('linked_user_name', $linkedUserName);
$plugin->assign('preload', $preload);

$title = $fichaId > 0 ? $plugin->get_lang('EditEnrollment') : $plugin->get_lang('NewEnrollment');
$plugin->setTitle($title);
$content = $plugin->fetch('matricula/form.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
