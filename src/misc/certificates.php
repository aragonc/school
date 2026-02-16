<?php

require_once __DIR__ . '/../../config.php';
$plugin = SchoolPlugin::create();
// Simplemente llama la función
$plugin->requireLogin();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$certificateId = $_GET['id'] ?? 0;
$plugin->setSidebar('certificates');

api_block_anonymous_users();

if ($enable) {

    $userId = api_get_user_id();
    $categories = $plugin->getCertificatesInSessions($userId);
    $imgSection = $plugin->get_svg_icon('certificates','Cursos Anteriores', 500);
    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $plugin->assign('img_section', $imgSection);
    $plugin->assign('categories', $categories);
    $plugin->setTitle($plugin->get_lang('MyCertificates'));
    $content = $plugin->fetch('misc/certificates.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}
