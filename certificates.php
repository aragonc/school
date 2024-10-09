<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$certificateId = $_GET['id'] ?? 0;
$plugin->setSidebar('certificates');

api_block_anonymous_users();

if ($enable) {
    $userId = api_get_user_id();

    //$courseList = GradebookUtils::getUserCertificatesInCourses($userId);
    //var_dump($courseList);
    $sessionList = $plugin->getCertificatesInSessions($userId);
    var_dump($sessionList);
    //$certificates = $plugin->getCertificates($userId);
    //var_dump($certificates);
    //$certificateData = $certificate->get($certificateId);

    $imgSection = $plugin->get_svg_icon('girl','Cursos Anteriores', 500);
    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $plugin->assign('img_section', $imgSection);
    $plugin->setTitle($plugin->get_lang('MyCertificates'));
    $content = $plugin->fetch('school_certificates.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}
