<?php

use Chamilo\UserBundle\Entity\User;
use ChamiloSession as Session;

require_once __DIR__ . '/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$plugin->setSidebar('dashboard');
api_block_anonymous_users();
$action = $_GET['action'] ?? '';

$table_user = Database::get_main_table(TABLE_MAIN_USER);
$allow_users_to_change_email_with_no_password = true;
if ($plugin->is_platform_authentication() &&
    api_get_setting('allow_users_to_change_email_with_no_password') == 'false'
) {
    $allow_users_to_change_email_with_no_password = false;
}


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

    $imgSection = $plugin->get_svg_icon('security', $plugin->get_lang('HereYourNotificationsWillBe'), 500,true);

    $form = new FormValidator(
        'form_password',
        'post',
        api_get_path(WEB_PATH) . 'password',
        '',
        [],
        FormValidator::LAYOUT_NEW
    );

    $showPassword = $plugin->is_platform_authentication();

    //    PASSWORD, if auth_source is platform
    if ($showPassword &&
        $plugin->is_profile_editable() &&
        api_get_setting('profile', 'password') === 'true'
    ) {
        $form->addElement('password', 'password0', [$plugin->get_lang('EnterYourCurrentPassword')], ['id' => 'password0', 'size' => 40, 'required']);

        $form->addRule('password0', $plugin->get_lang('EnterYourCurrentPasswordHelp'), 'required');
        $form->addElement(
            'password',
            'password1',
            [
                $plugin->get_lang('EnterYourNewPassword')
            ],
            ['id' => 'password1', 'size' => 40, 'required']
        );
        $form->addRule('password1', $plugin->get_lang('EnterYourNewPasswordHelp'), 'required');
        $form->addElement(
            'password',
            'password2',
            [
                $plugin->get_lang('ConfirmYourNewPassword')
            ],
            ['id' => 'password2', 'size' => 40, 'required']
        );
        $form->addRule('password2', $plugin->get_lang('ConfirmYourNewPasswordHelp'), 'required');
        //    user must enter identical password twice so we can prevent some user errors
        $form->addRule(['password2', 'password1'], get_lang('PassTwo'), 'compare');
        $form->addPasswordRule('password1');
    }

    $form->addButton('submit',$plugin->get_lang('UpdatePassword'), '','primary','default','btn-block');
    $form->addHtml($plugin->get_lang('TheFollowingFieldsAreRequired'));

   // var_dump($_POST);

    $form->setDefaults($user_data);

    // VALIDATE FORM
    if ($form->validate()) {
        $hook = HookUpdateUser::create();

        if ($hook) {
            $hook->notifyUpdateUser(HOOK_EVENT_TYPE_PRE);
        }

        $wrong_current_password = false;
        $user_data = $form->getSubmitValues(1);

        /** @var User $user */
        $user = UserManager::getRepository()->find(api_get_user_id());

        // set password if a new one was provided
        $validPassword = false;
        $passwordWasChecked = false;

        $user_data = $form->getSubmitValues(1);

        /** @var User $user */
        $user = UserManager::getRepository()->find($userId);

        if ($user && !empty($user_data['password0']) && !empty($user_data['password1']) && !empty($user_data['password2'])) {
            if ($user_data['password1'] !== $user_data['password2']) {
                Display::addFlash(
                    Display::return_message(
                        get_lang('NewPasswordsDoNotMatch'),
                        'warning',
                        false
                    )
                );
            } else {
                $validPassword = UserManager::isPasswordValid(
                    $user->getPassword(),
                    $user_data['password0'],
                    $user->getSalt()
                );

                if ($validPassword) {
                    UserManager::updatePassword($userId, $user_data['password1']);
                    Display::addFlash(
                        Display::return_message(get_lang('Changesweresuccessfullyupdated'), 'normal', false)
                    );

                    $url = api_get_path(WEB_PATH) . 'password';
                    header("Location: $url");
                    exit;

                } else {
                    $form->setElementError('password0', $plugin->get_lang('TheCurrentPasswordFieldIsEmpty'));
                    /*Display::addFlash(
                        Display::return_message(
                            $plugin->get_lang('CurrentPasswordEmptyOrIncorrect'),
                            'warning',
                            false
                        )
                    );*/
                }
            }
        }
    }



    $plugin->setTitle($plugin->get_lang('EditProfile'));
    $plugin->assign('img_section', $imgSection);
    $plugin->assign('form', $form->returnForm());
    $content = $plugin->fetch('school_password.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}
