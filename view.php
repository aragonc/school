<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$buyCourse = BuyCoursesPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$sessionId = $_GET['session_id'] ?? 0;

$session = $plugin->getInfoSession($sessionId);
$plugin->setSidebar('shopping');
$itemBuy = $buyCourse->getItemByProduct($sessionId,$buyCourse::PRODUCT_TYPE_SESSION);
var_dump($itemBuy);

api_block_anonymous_users();
$userId = api_get_user_id();
$content = '';
$imgSection = $plugin->get_svg_icon('payment_methods','Cursos Anteriores', 100,false, 'png');
$plugin->setTitle('');
$plugin->assign('session', $session);
$plugin->assign('img_section', $imgSection);
$content = $plugin->fetch('school_courses_view.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
