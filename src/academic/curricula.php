<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../CurriculaManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();
$plugin->requireModule('academic');

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

if (!api_is_platform_admin()) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('academic');
$plugin->setSidebar('academic');

$areasByLevel     = CurriculaManager::getAllDataByLevel();
$transversalesEbr = CurriculaManager::getTransversalesWithCaps('ebr');
$transversalesIni = CurriculaManager::getTransversalesWithCaps('inicial');
$enfoquesEbr      = CurriculaManager::getEnfoquesWithValores('ebr');
$enfoquesIni      = CurriculaManager::getEnfoquesWithValores('inicial');

$plugin->assign('areas_by_level',       $areasByLevel);
$plugin->assign('transversales_ebr',    $transversalesEbr);
$plugin->assign('transversales_ini',    $transversalesIni);
$plugin->assign('enfoques_ebr',         $enfoquesEbr);
$plugin->assign('enfoques_ini',         $enfoquesIni);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_curricula.php');

$plugin->setTitle($plugin->get_lang('CurricularAreas'));

$content = $plugin->fetch('academic/curricula.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
