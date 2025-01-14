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

$htmlHeadXtra[] = api_get_password_checker_js('#username', '#password1');

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

    $imgSection = $plugin->get_svg_icon('profile', $plugin->get_lang('HereYourNotificationsWillBe'), 500);

    $array_list_key = UserManager::get_api_keys(api_get_user_id());
    $id_temp_key = UserManager::get_api_key_id(api_get_user_id(), 'dokeos');
    $value_array = [];
    if (isset($array_list_key[$id_temp_key])) {
        $value_array = $array_list_key[$id_temp_key];
    }

    $user_data['api_key_generate'] = $value_array;

    if ($user_data !== false) {
        if (api_get_setting('login_is_email') === 'true') {
            $user_data['username'] = $user_data['email'];
        }
        if (is_null($user_data['language'])) {
            $user_data['language'] = api_get_setting('platformLanguage');
        }
    }

    $form = new FormValidator(
        'profile',
        'post',
        api_get_path(WEB_PATH) . 'profile',
        '',
        [],
        FormValidator::LAYOUT_NEW
    );

    $form->addElement('text', 'firstname', get_lang('FirstName'), ['size' => 40, 'disabled' => 'disabled']);
    $form->addElement('text', 'lastname', get_lang('LastName'), ['size' => 40, 'disabled' => 'disabled']);


    //    USERNAME
    $form->addElement(
        'text',
        'username',
        get_lang('UserName'),
        [
            'id' => 'username',
            'maxlength' => USERNAME_MAX_LENGTH,
            'size' => USERNAME_MAX_LENGTH,
            'disabled' => 'disabled'
        ]
    );

    // EMAIL
    $form->addElement('email', 'email', get_lang('Email'), ['size' => 40, 'disabled' => 'disabled']);

    // PHONE
    $form->addElement('text', 'phone', get_lang('Phone'), ['size' => 20]);

    $showPassword = $plugin->is_platform_authentication();

    //    PASSWORD, if auth_source is platform
    if ($showPassword &&
        $plugin->is_profile_editable() &&
        api_get_setting('profile', 'password') === 'true'
    ) {
        $form->addElement('password', 'password0', [get_lang('Pass'), get_lang('TypeCurrentPassword')], ['size' => 40]);
        $form->addElement(
            'password',
            'password1',
            [get_lang('NewPass'), get_lang('EnterYourNewPassword')],
            ['id' => 'password1', 'size' => 40]
        );
        $form->addElement(
            'password',
            'password2',
            [get_lang('Confirmation'), get_lang('RepeatYourNewPassword')],
            ['size' => 40]
        );
        //    user must enter identical password twice so we can prevent some user errors
        $form->addRule(['password1', 'password2'], get_lang('PassTwo'), 'compare');
        $form->addPasswordRule('password1');
    }

    // INTERNATIONAL BUY COURSE
    $buy = '';
    if (class_exists('BuyCoursesPlugin')) {
        $buy = BuyCoursesPlugin::create();
        $currencies = $buy->getCurrencies();
        $listCountries = [];
        $currencySelect = $form->addSelect(
            'country',
            [
                get_lang('Country')
            ],
            [get_lang('Select')],
            ['class' => 'form-control']
        );

        foreach ($currencies as $currency) {
            $currencyText = $currency['country_name'];
            $currencyValue = $currency['country_code'];

            $currencySelect->addOption($currencyText, $currencyValue);

            if ($currency['status']) {
                $currencySelect->setSelected($currencyValue);
            }
        }
    }

    $extraField = new ExtraField('user');
    $return = $extraField->addElements($form, api_get_user_id(), ['pause_formation', 'start_pause_date', 'end_pause_date']);

    //    SUBMIT
    if ($plugin->is_profile_editable()) {
        $form->addButtonUpdate(get_lang('SaveSettings'), 'apply_change');
    } else {
        $form->freeze();
    }

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

        if ($user &&
            (!empty($user_data['password0']) &&
                !empty($user_data['password1'])) ||
            (!empty($user_data['password0']) &&
                api_get_setting('profile', 'email') == 'true')
        ) {
            $passwordWasChecked = true;
            $validPassword = UserManager::isPasswordValid(
                $user->getPassword(),
                $user_data['password0'],
                $user->getSalt()
            );

            if ($validPassword) {
                $password = $user_data['password1'];
            } else {
                Display::addFlash(
                    Display:: return_message(
                        get_lang('CurrentPasswordEmptyOrIncorrect'),
                        'warning',
                        false
                    )
                );
            }
        }

        //Only update values that are request by the "profile" setting
        $profile_list = api_get_setting('profile');
        //Adding missing variables

        $available_values_to_modify = [];
        foreach ($profile_list as $key => $status) {
            if ($status == 'true') {
                switch ($key) {
                    case 'login':
                        $available_values_to_modify[] = 'username';
                        break;
                    case 'name':
                        $available_values_to_modify[] = 'firstname';
                        $available_values_to_modify[] = 'lastname';
                        break;
                    case 'picture':
                        $available_values_to_modify[] = 'picture_uri';
                        break;
                    default:
                        $available_values_to_modify[] = $key;
                        break;
                }
            }
        }

        // build SQL query
        $sql = "UPDATE $table_user SET";
        unset($user_data['api_key_generate']);

        foreach ($user_data as $key => $value) {
            if (substr($key, 0, 6) === 'extra_') { //an extra field
                continue;
            } elseif (strpos($key, 'remove_extra_') !== false) {
            } else {
                if (in_array($key, $available_values_to_modify)) {
                    $sql .= " $key = '".Database::escape_string($value)."',";
                }
            }
        }

        $changePassword = false;
        // Change email
        if ($allow_users_to_change_email_with_no_password) {
            if (isset($changeemail) && in_array('email', $available_values_to_modify)) {
                $sql .= " email = '".Database::escape_string($changeemail)."' ";
            }
            if (isset($password) && in_array('password', $available_values_to_modify)) {
                $changePassword = true;
            }
        } else {
            if (isset($changeemail) && !isset($password) && in_array('email', $available_values_to_modify)) {
                $sql .= " email = '".Database::escape_string($changeemail)."'";
            } else {
                if (isset($password) && in_array('password', $available_values_to_modify)) {
                    if (isset($changeemail) && in_array('email', $available_values_to_modify)) {
                        $sql .= " email = '".Database::escape_string($changeemail)."' ";
                    }
                    $changePassword = true;
                }
            }
        }

        $sql = rtrim($sql, ',');
        if ($changePassword && !empty($password)) {
            UserManager::updatePassword(api_get_user_id(), $password);
        }

        if (api_get_setting('profile', 'officialcode') === 'true' &&
            isset($user_data['official_code'])
        ) {
            $sql .= ", official_code = '".Database::escape_string($user_data['official_code'])."'";
        }
        $sql .= " , country = '".$user_data['country']."' ";
        $sql .= " WHERE id  = '".api_get_user_id()."'";

        Database::query($sql);

        if (!$passwordWasChecked) {
            Display::addFlash(
                Display:: return_message(get_lang('Changesweresuccessfullyupdated'), 'normal', false)
            );
        } else {
            if ($validPassword) {
                Display::addFlash(
                    Display:: return_message(get_lang('Changesweresuccessfullyupdated'), 'normal', false)
                );
            }
        }


        $extraField = new ExtraFieldValue('user');
        $extraField->saveFieldValues($user_data);

        $userInfo = api_get_user_info(
            api_get_user_id(),
            false,
            false,
            false,
            false,
            true,
            true
        );
        Session::write('_user', $userInfo);

        if ($hook) {
            Database::getManager()->clear(User::class); // Avoid cache issue (user entity is used before)
            $user = api_get_user_entity(api_get_user_id()); // Get updated user info for hook event
            $hook->setEventData(['user' => $user]);
            $hook->notifyUpdateUser(HOOK_EVENT_TYPE_POST);
        }

        Session::erase('system_timezone');

        $url = api_get_self();
        header("Location: $url");
        exit;

    }

    $plugin->setTitle($plugin->get_lang('EditProfile'));
    $plugin->assign('img_section', $imgSection);
    $plugin->assign('form', $form->returnForm());
    $content = $plugin->fetch('school_profile.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}
