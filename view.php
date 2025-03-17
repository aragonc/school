<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$sessionId = $_GET['session_id'] ?? 0;

$session = $plugin->getInfoSession($sessionId);
var_dump($session);
$plugin->setSidebar('shopping');

api_block_anonymous_users();
$userId = api_get_user_id();
$content = '';
$plugin->setTitle($plugin->get_lang('BuyGraduates'));
$content = $plugin->fetch('school_courses_view.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
