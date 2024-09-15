<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
//$htmlHeadXtra[] = api_get_css(api_get_path(WEB_PLUGIN_PATH) . 'school/css/style.css');

api_block_anonymous_users();

if ($enable) {
    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $content = $plugin->fetch('school_start.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
