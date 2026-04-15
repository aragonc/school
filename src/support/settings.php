<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../SupportManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();
$plugin->requireModule('support');

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

if (!api_is_platform_admin()) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('support-settings');
$plugin->setSidebar('support');

$saved = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_support_settings'])) {
    $plugin->setSchoolSetting(
        'support_attention_message',
        trim($_POST['support_attention_message'] ?? '')
    );
    $plugin->setSchoolSetting(
        'support_whatsapp',
        trim(preg_replace('/[^0-9+]/', '', $_POST['support_whatsapp'] ?? ''))
    );

    $categoriesRaw = trim($_POST['support_categories_json'] ?? '');
    if ($categoriesRaw !== '') {
        $cats = json_decode($categoriesRaw, true);
        if (is_array($cats)) {
            $clean = [];
            foreach ($cats as $cat) {
                $name = trim(strip_tags($cat['name'] ?? ''));
                if ($name !== '') {
                    $clean[] = ['name' => $name, 'active' => !empty($cat['active']), 'template' => trim($cat['template'] ?? '')];
                }
            }
            $plugin->setSchoolSetting('support_categories', json_encode($clean));
        }
    }

    $saved = true;
}

$defaultCats    = '[{"name":"General","active":true},{"name":"Acceso / Contraseña","active":true},{"name":"Pagos","active":true},{"name":"Cursos","active":true},{"name":"Otro","active":true}]';
$categoriesJson = $plugin->getSchoolSetting('support_categories') ?: $defaultCats;

$plugin->assign('support_attention_message', $plugin->getSchoolSetting('support_attention_message') ?: '');
$plugin->assign('support_whatsapp',          $plugin->getSchoolSetting('support_whatsapp') ?: '');
$plugin->assign('support_categories_json',   $categoriesJson);
$plugin->assign('saved',                     $saved);
$plugin->assign('settings_url',              '/support/settings');

$plugin->setTitle('Configuración de tickets');
$content = $plugin->fetch('support/settings.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
