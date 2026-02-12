<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$plugin->setSidebar('');
$content = null;
api_block_anonymous_users();
$userId = api_get_user_id();
$action = $_REQUEST['action'] ?? '';

$plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');

if ($enable) {
    $form = new FormValidator(
        'settings',
        'post',
        api_get_self().'?action='.Security::remove_XSS($action).'&'.api_get_cidreq()
    );
    $form->addText('Institution',[$plugin->get_lang('InstitutionTitle'), $plugin->get_lang('InstitutionComment')]);
    $form->addText('InstitutionUrl',[$plugin->get_lang('InstitutionUrlTitle'), $plugin->get_lang('InstitutionUrlComment')]);
    $form->addText('siteName',[$plugin->get_lang('SiteNameTitle'), $plugin->get_lang('SiteNameComment')]);
    $form->addText('emailAdministrator',[$plugin->get_lang('emailAdministratorTitle'), $plugin->get_lang('emailAdministratorComment')]);
    $plugin->setTitle($plugin->get_lang('BasicSystemConfiguration'));
    $plugin->assign('form', $form->returnForm());
    $content = $plugin->fetch('school_settings.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
