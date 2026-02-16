<?php

use Chamilo\UserBundle\Entity\User;

require_once __DIR__ . '/../../config.php';
$plugin = SchoolPlugin::create();
// Simplemente llama la función
$plugin->requireLogin();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$plugin->setSidebar('dashboard');
api_block_anonymous_users();
$action = $_GET['action'] ?? '';
$table_user = Database::get_main_table(TABLE_MAIN_USER);

$htmlHeadXtra[]= api_get_css_asset('cropper/dist/cropper.min.css');
$htmlHeadXtra[]= api_get_asset('cropper/dist/cropper.min.js');

$plugin->assign('extra_headers', $plugin->set_js_extras($htmlHeadXtra));

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

    //$imgSection = $plugin->get_svg_icon('photo', $plugin->get_lang('HereYourNotificationsWillBe'), 500,true);

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
    $labelImage =  [
        $user_data['picture_uri'] != '' ? $plugin->get_lang('SelectAnImage') : get_lang('AddImage')
    ];
    try {
        $form->addFile(
            'picture',
            $labelImage,
            [
                'id' => 'picture',
                'class' => 'picture-form',
                'crop_image' => true,
                'crop_ratio' => '1 / 1',
                'accept' => 'image/*',
            ]
        );
        $form->addHtml('<div class="help-block">'.get_lang('OnlyImagesAllowed').'</div>');
    } catch (Exception $e) {
        print_r($e->getMessage());
    }

    $form->addProgress();
    /*if (!empty($user_data['picture_uri'])) {
        $form->addElement('checkbox', 'remove_picture', null, get_lang('DelImage'));
    }*/
    $allowed_picture_types = api_get_supported_image_extensions(false);
    $form->addRule(
        'picture',
        get_lang('OnlyImagesAllowed').' ('.implode(', ', $allowed_picture_types).')',
        'filetype',
        $allowed_picture_types
    );
    $form->addButton('submit',$plugin->get_lang('UpdateAvatar'), '','primary','default','btn-block', ['disabled']);
    $form->setDefaults($user_data);

    if ($form->validate()) {

        $user_data = $form->getSubmitValues(1);
        /** @var User $user */
        $user = UserManager::getRepository()->find(api_get_user_id());

        // Upload picture if a new one is provided
        if ($_FILES['picture']['size']) {
            $new_picture = UserManager::update_user_picture(
                api_get_user_id(),
                $_FILES['picture']['name'],
                $_FILES['picture']['tmp_name'],
                $user_data['picture_crop_result']
            );

            if ($new_picture) {
                $user_data['picture_uri'] = $new_picture;

                Display::addFlash(
                    Display:: return_message(
                        get_lang('PictureUploaded'),
                        'normal',
                        false
                    )
                );
            }
            $sql = "UPDATE $table_user u SET";
            unset($user_data['api_key_generate']);
            $sql .= " u.picture_uri = '".Database::escape_string($user_data['picture_uri'])."' ";
            $sql .= " WHERE u.id  = '".api_get_user_id()."';";
            Database::query($sql);

        } else {

            Display::addFlash(
                Display:: return_message(
                    $plugin->get_lang('NoImageSelected'),
                    'warning',
                    false
                )
            );
        }

        $url = api_get_path(WEB_PATH) . 'avatar';
        header("Location: $url");
        exit;
    }

    $plugin->setTitle($plugin->get_lang('EditProfile'));
    $plugin->assign('form', $form->returnForm());
    $content = $plugin->fetch('profile/avatar.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}

