<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../AcademicManager.php';

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

$plugin->setCurrentSection('academic');
$plugin->setSidebar('academic');

$years = AcademicManager::getAcademicYears();
$yearId = isset($_GET['year_id']) ? (int) $_GET['year_id'] : 0;

// Default to first active year
if (!$yearId && !empty($years)) {
    foreach ($years as $y) {
        if ($y['active']) {
            $yearId = (int) $y['id'];
            break;
        }
    }
    if (!$yearId) {
        $yearId = (int) $years[0]['id'];
    }
}

$classrooms = $yearId ? AcademicManager::getClassrooms($yearId) : [];
$levels = AcademicManager::getLevels(true);
$grades = AcademicManager::getGrades(null, true);
$sections = AcademicManager::getSections(true);
$teachers = AcademicManager::getTeachers();

// Group classrooms by level
$classroomsByLevel = [];
foreach ($classrooms as $c) {
    $levelName = $c['level_name'];
    if (!isset($classroomsByLevel[$levelName])) {
        $classroomsByLevel[$levelName] = [];
    }
    $classroomsByLevel[$levelName][] = $c;
}

$plugin->assign('years', $years);
$plugin->assign('year_id', $yearId);
$plugin->assign('classrooms_by_level', $classroomsByLevel);
$plugin->assign('levels', $levels);
$plugin->assign('grades', $grades);
$plugin->assign('sections', $sections);
$plugin->assign('teachers', $teachers);
$plugin->assign('is_admin', $isAdmin);
$plugin->assign('ajax_url', api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_academic.php');

$plugin->setTitle($plugin->get_lang('Academic'));

$content = $plugin->fetch('academic/index.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
