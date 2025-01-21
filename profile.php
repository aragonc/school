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

    $imgSection = $plugin->get_svg_icon('profile', $plugin->get_lang('HereYourNotificationsWillBe'), 500, true);

    if ($user_data !== false) {
        if (api_get_setting('login_is_email') === 'true') {
            $user_data['username'] = $user_data['email'];
        }
        if (is_null($user_data['language'])) {
            $user_data['language'] = api_get_setting('platformLanguage');
        }
    }

    $form = new FormValidator(
        'form_profile',
        'post',
        api_get_path(WEB_PATH) . 'profile',
        '',
        [],
        FormValidator::LAYOUT_NEW
    );
    $form->addElement('text', 'firstname', '* '. get_lang('FirstName'), ['size' => 40, 'disabled' => 'disabled']);

    $form->addElement('text', 'lastname', '* '. get_lang('LastName'), ['size' => 40, 'disabled' => 'disabled']);


    // USERNAME
    $form->addElement(
        'text',
        'username',
        '* '. $plugin->get_lang('User'),
        [
            'id' => 'username',
            'maxlength' => USERNAME_MAX_LENGTH,
            'size' => USERNAME_MAX_LENGTH,
            'disabled' => 'disabled'
        ]
    );

    // EMAIL
    $form->addElement('email', 'email', '* '. get_lang('Email'), ['size' => 40, 'disabled' => 'disabled']);

    // PHONE
    $form->addElement('text', 'phone', get_lang('Phone'), ['size' => 20]);
    $form->addRule('phone', get_lang('ThisFieldIsRequired'), 'required');

    // COUNTRY
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
        $form->addRule('country', get_lang('ThisFieldIsRequired'), 'required');
    }

    $extraField = new ExtraField('user');
    $return = $extraField->addElements(
        $form,
        api_get_user_id(),
        [
            'pause_formation',
            'start_pause_date',
            'end_pause_date'
        ]
    );
//,false,false,[],[],[],false,false,[],[],false,[],['identificador']
    // SUBMIT
    $form->addButton('submit',$plugin->get_lang('SaveChanges'), '','primary','default','btn-block');
    $form->addHtml($plugin->get_lang('TheFollowingFieldsAreRequired'));
    $form->setDefaults($user_data);

    // VALIDATE FORM
    if ($form->validate()) {
        $user_data = $form->getSubmitValues(1);

        /** @var User $user */
        $user = UserManager::getRepository()->find(api_get_user_id());

        // Only update values that are allowed by the "profile" setting
        $profile_list = api_get_setting('profile');
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

        // Build SQL query
        $sql = "UPDATE $table_user SET";

        foreach ($user_data as $key => $value) {
            if (substr($key, 0, 6) === 'extra_') { // Extra field
                continue;
            } elseif (strpos($key, 'remove_extra_') !== false) {
                continue;
            } else {
                if (in_array($key, $available_values_to_modify)) {
                    $sql .= " $key = '" . Database::escape_string($value) . "',";
                }
            }
        }

        $sql = rtrim($sql, ',');
        $sql .= " , country = '".$user_data['country']."' ";
        $sql .= " WHERE id  = '" . api_get_user_id() . "'";

        Database::query($sql);

        Display::addFlash(
            Display::return_message(get_lang('Changesweresuccessfullyupdated'), 'normal', false)
        );

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

        $url = api_get_path(WEB_PATH) . 'profile';
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
