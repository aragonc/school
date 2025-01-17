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

    $imgSection = $plugin->get_svg_icon('photo', $plugin->get_lang('HereYourNotificationsWillBe'), 500,true);

    $form = new FormValidator(
        'form_avatar',
        'post',
        api_get_path(WEB_PATH) . 'avatar',
        '',
        [],
        FormValidator::LAYOUT_NEW
    );
    $form->addHtml('<div class="form-group">');
    $form->addHtml('<label class="form-label label">'.$plugin->get_lang('ImagePreview').'</label>');
    $form->addHtml('<div class="card avatar-profile mb-4">
        <div class="card-body preview">
            <img class="img-fluid img-circle" src="' . $user_data['avatar']. '"  alt=""/>
    </div>
    </div>');

    try {
        $form->addFile(
            'picture',
            [
                $user_data['picture_uri'] != '' ? get_lang('UpdateImage') : get_lang('AddImage'),
                get_lang('OnlyImagesAllowed'),
            ],
            [
                'id' => 'picture',
                'class' => 'picture-form',
                'crop_image' => true,
                'crop_ratio' => '1 / 1',
                'accept' => 'image/*',
            ]
        );
    } catch (Exception $e) {
        print_r($e->getMessage());
    }

    $form->addProgress();
    if (!empty($user_data['picture_uri'])) {
        $form->addElement('checkbox', 'remove_picture', null, get_lang('DelImage'));
    }
    $allowed_picture_types = api_get_supported_image_extensions(false);
    $form->addRule(
        'picture',
        get_lang('OnlyImagesAllowed').' ('.implode(', ', $allowed_picture_types).')',
        'filetype',
        $allowed_picture_types
    );


    $plugin->setTitle($plugin->get_lang('EditProfile'));
    $plugin->assign('img_section', $imgSection);
    $plugin->assign('form', $form->returnForm());
    $content = $plugin->fetch('school_avatar.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}

