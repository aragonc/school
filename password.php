<?php

require_once __DIR__ . '/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$plugin->setSidebar('dashboard');
api_block_anonymous_users();
$action = $_GET['action'] ?? '';

if ($enable) {

    $userId = api_get_user_id();
    $user_data = api_get_user_info(
        api_get_user_id(),
        false,
        false,
        false,
        false,
        true,
        true
    );

    $imgSection = $plugin->get_svg_icon('profile', $plugin->get_lang('HereYourNotificationsWillBe'), 500,true);

    $form = new FormValidator(
        'profile',
        'post',
        api_get_path(WEB_PATH) . 'profile',
        '',
        [],
        FormValidator::LAYOUT_NEW
    );

    $plugin->setTitle($plugin->get_lang('EditProfile'));
    $plugin->assign('img_section', $imgSection);
    $plugin->assign('form', '');
    $content = $plugin->fetch('school_password.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}
