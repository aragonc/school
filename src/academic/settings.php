<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../AcademicManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

// Only admin can access settings
if (!api_is_platform_admin()) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('academic');
$plugin->setSidebar('academic');

$years = AcademicManager::getAcademicYears();
$levels = AcademicManager::getLevels();
$grades = AcademicManager::getGrades();
$sections = AcademicManager::getSections();

$plugin->assign('years', $years);
$plugin->assign('levels', $levels);
$plugin->assign('grades', $grades);
$plugin->assign('sections', $sections);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_academic.php');

$plugin->setTitle($plugin->get_lang('AcademicSettings'));

$content = $plugin->fetch('academic/settings.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
