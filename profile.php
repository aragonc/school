<?php

require_once __DIR__.'/config.php';
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

    $imgSection = $plugin->get_svg_icon('profile',$plugin->get_lang('HereYourNotificationsWillBe'), 500);

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
        api_get_path(WEB_PATH).'profile?action='.Security::remove_XSS($action),
        '',
        [],
        FormValidator::LAYOUT_PAY
    );
    $form->addElement('text', 'firstname', get_lang('FirstName'), ['size' => 40]);
    $form->addElement('text', 'lastname', get_lang('LastName'), ['size' => 40]);
    if (api_get_setting('profile', 'name') !== 'true') {
        $form->freeze(['lastname', 'firstname']);
    }

    //    USERNAME
    $form->addElement(
        'text',
        'username',
        get_lang('UserName'),
        [
            'id' => 'username',
            'maxlength' => USERNAME_MAX_LENGTH,
            'size' => USERNAME_MAX_LENGTH,
        ]
    );

    $form->freeze('username');

    // EMAIL
    $form->addElement('email', 'email', get_lang('Email'), ['size' => 40]);
    $form->freeze('email');

    // PHONE
    $form->addElement('text', 'phone', get_lang('Phone'), ['size' => 20]);
    $form->freeze('phone');

    // INTERNATIONAL BUY COURSE
    $buy = null;
    if(class_exists('BuyCoursesPlugin')) {
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

    //    SUBMIT
    if ($plugin->is_profile_editable()) {
        $form->addButtonUpdate(get_lang('SaveSettings'), 'apply_change');
    } else {
        $form->freeze();
    }

    $form->setDefaults($user_data);

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

    }

    $plugin->setTitle($plugin->get_lang('EditProfile'));
    $plugin->assign('img_section', $imgSection);
    $plugin->assign('form', $form->returnForm());
    $content = $plugin->fetch('school_profile.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
