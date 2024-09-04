<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$htmlHeadXtra[] = api_get_css(api_get_path(WEB_PLUGIN_PATH) . 'school/css/style.css');

api_block_anonymous_users();

if ($enable) {
    if (api_is_platform_admin()) {
        $tpl = new Template($nameTools, true, true, false, false, true, false);
        $tpl->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
        $content = $tpl->fetch('school/view/school_start.tpl');
        $tpl->assign('content', $content);
        $tpl->display_one_col_template();
    }
}
