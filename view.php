<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$buyCourse = BuyCoursesPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$sessionId = $_GET['session_id'] ?? 0;
$session = $plugin->getInfoSession($sessionId);

$session['display_start_date_text'] = $plugin->formatDateEs($session['display_start_date']);
$session['display_end_date_text'] = $plugin->formatDateEs($session['display_end_date']);
$sessionURL = $plugin->getSessionTabURL($session['reference_session']);
$plugin->setSidebar('shopping');
$itemBuy = $buyCourse->getItemByProduct($sessionId,$buyCourse::PRODUCT_TYPE_SESSION);
$itemBuy['price_view'] = str_replace(',', '.', $itemBuy['price_formatted']);

api_block_anonymous_users();
$userId = api_get_user_id();
$content = '';
$imgSection = $plugin->get_svg_icon('payment_methods','Cursos Anteriores', 400,false, 'png');
$plugin->setTitle('');

$plugin->assign('session', $session);
$plugin->assign('url_pdf', $sessionURL);
$plugin->assign('item', $itemBuy);
$plugin->assign('img_section', $imgSection);
$content = $plugin->fetch('school_courses_view.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
