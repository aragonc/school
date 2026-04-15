<?php

require_once __DIR__ . '/../../config.php';
$plugin = SchoolPlugin::create();
api_protect_admin_script();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setSidebar('admin');
$plugin->setCurrentSection('admin-reglamento');
$plugin->setTitle($plugin->get_lang('ReglamentoInterno'));

$uploadDir = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/reglamento/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, api_get_permissions_for_new_directories(), true);
}

$docs = [
    'reglamento_interno'   => $plugin->get_lang('DocReglamentoInterno'),
    'boletin_informativo'  => $plugin->get_lang('DocBoletinInformativo'),
    'reglas_generales'     => $plugin->get_lang('DocReglasGenerales'),
];

$saved = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['save_reglamento'])) {
    foreach (array_keys($docs) as $key) {
        // Fecha de publicación
        $dateValue = trim($_POST['date_' . $key] ?? '');
        if ($dateValue !== '') {
            $plugin->setSchoolSetting('reglamento_date_' . $key, $dateValue);
        }

        // Eliminar documento
        if (!empty($_POST['remove_' . $key])) {
            $current = $plugin->getSchoolSetting('reglamento_file_' . $key);
            if ($current) {
                $filePath = $uploadDir . $current;
                if (file_exists($filePath)) {
                    unlink($filePath);
                }
            }
            $plugin->setSchoolSetting('reglamento_file_' . $key, '');
        }

        // Subir nuevo PDF
        if (!empty($_FILES['file_' . $key]['size'])) {
            // Eliminar anterior si existe
            $current = $plugin->getSchoolSetting('reglamento_file_' . $key);
            if ($current && file_exists($uploadDir . $current)) {
                unlink($uploadDir . $current);
            }

            $extension = strtolower(pathinfo($_FILES['file_' . $key]['name'], PATHINFO_EXTENSION));
            if ($extension === 'pdf') {
                $newFilename = $key . '_' . time() . '.pdf';
                if (move_uploaded_file($_FILES['file_' . $key]['tmp_name'], $uploadDir . $newFilename)) {
                    $plugin->setSchoolSetting('reglamento_file_' . $key, $newFilename);
                }
            }
        }
    }

    $saved = true;
}

// Prepare data for template
$docData = [];
foreach ($docs as $key => $label) {
    $filename = $plugin->getSchoolSetting('reglamento_file_' . $key);
    $fileExists = $filename && file_exists($uploadDir . $filename);
    $docData[] = [
        'key'       => $key,
        'label'     => $label,
        'filename'  => $filename ?: '',
        'exists'    => $fileExists,
        'url'       => $fileExists ? api_get_path(WEB_UPLOAD_PATH) . 'plugins/school/reglamento/' . $filename : '',
        'date'      => $plugin->getSchoolSetting('reglamento_date_' . $key) ?: '',
    ];
}

$plugin->assign('docs', $docData);
$plugin->assign('saved', $saved);
$plugin->assign('form_action', '/admin/reglamento');

$content = $plugin->fetch('admin/reglamento.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
