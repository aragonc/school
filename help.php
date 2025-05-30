<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$buyCourse = BuyCoursesPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$plugin->setSidebar('help');
api_block_anonymous_users();

$userId = api_get_user_id();

if ($enable) {
    $plugin->setTitle($plugin->get_lang('Help'));
    $imgSection = $plugin->get_svg_icon('helps',$plugin->get_lang('RespondAsSoonAsPossible'), 500);
    $plugin->assign('img_section', $imgSection);
    $content = $plugin->fetch('school_help.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
