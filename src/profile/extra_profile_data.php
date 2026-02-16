<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setSidebar('dashboard');
api_block_anonymous_users();

$userId = api_get_user_id();

// Peru regions data from JSON
$regionsJson = file_get_contents(__DIR__.'/../../ajax/ubigeo/ubigeo_peru_2016_region.json');
$regions = json_decode($regionsJson, true);

// Get existing data
$extraData = $plugin->getExtraProfileData($userId);

// Build form
$form = new FormValidator(
    'extra_profile_form',
    'post',
    api_get_path(WEB_PATH) . 'extra-profile',
    '',
    []
);

// Document type
$docTypeOptions = [
    '' => '-- ' . $plugin->get_lang('SelectOption') . ' --',
    'DNI' => 'DNI',
    'CE' => $plugin->get_lang('ForeignCard'),
    'PASAPORTE' => $plugin->get_lang('Passport'),
    'OTRO' => $plugin->get_lang('Other'),
];
$form->addSelect('document_type', $plugin->get_lang('DocumentType'), $docTypeOptions);
$form->addRule('document_type', get_lang('ThisFieldIsRequired'), 'required');

// Document number
$form->addText('document_number', $plugin->get_lang('DocumentNumber'), true, ['maxlength' => 50]);

// Birthdate
$form->addElement('DatePicker', 'birthdate', $plugin->get_lang('Birthdate'));

// Address
$form->addText('address', $plugin->get_lang('Address'), false, ['maxlength' => 500]);

// Address reference
$form->addText('address_reference', $plugin->get_lang('AddressReference'), false, ['maxlength' => 255]);

// Phone / WhatsApp
$form->addText('phone', $plugin->get_lang('EmergencyPhone'), false, ['maxlength' => 50]);

// Region
$regionOptions = ['' => '-- ' . $plugin->get_lang('SelectOption') . ' --'];
foreach ($regions as $region) {
    $regionOptions[$region['id']] = $region['name'];
}
$form->addSelect('region', $plugin->get_lang('Region'), $regionOptions, ['id' => 'region']);

// Province
$form->addSelect(
    'province',
    $plugin->get_lang('Province'),
    ['' => '-- ' . $plugin->get_lang('SelectOption') . ' --'],
    ['id' => 'province', 'disabled' => 'disabled']
);

// District
$form->addSelect(
    'district',
    $plugin->get_lang('District'),
    ['' => '-- ' . $plugin->get_lang('SelectOption') . ' --'],
    ['id' => 'district', 'disabled' => 'disabled']
);

$form->addButton('submit', $plugin->get_lang('SaveChanges'), '', 'primary', 'default', 'btn-block');

// Set defaults
$defaults = [
    'document_type' => $extraData['document_type'] ?? '',
    'document_number' => $extraData['document_number'] ?? '',
    'birthdate' => $extraData['birthdate'] ?? '',
    'address' => $extraData['address'] ?? '',
    'address_reference' => $extraData['address_reference'] ?? '',
    'phone' => $extraData['phone'] ?? '',
    'district' => $extraData['district'] ?? '',
    'province' => $extraData['province'] ?? '',
    'region' => $extraData['region'] ?? '',
];
$form->setDefaults($defaults);

// Process form
if ($form->validate()) {
    $values = $form->getSubmitValues();
    $plugin->saveExtraProfileData($userId, $values);

    Display::addFlash(
        Display::return_message($plugin->get_lang('ExtraProfileSaved'), 'success')
    );
    header('Location: ' . api_get_path(WEB_PATH) . 'extra-profile');
    exit;
}

$plugin->setTitle($plugin->get_lang('ExtraProfileData'));
$plugin->assign('ubigeo_path', api_get_path(WEB_PLUGIN_PATH).'school/ajax/ubigeo/');
$plugin->assign('select_option_text', '-- ' . $plugin->get_lang('SelectOption') . ' --');
$plugin->assign('saved_region', $extraData['region'] ?? '');
$plugin->assign('saved_province', $extraData['province'] ?? '');
$plugin->assign('saved_district', $extraData['district'] ?? '');
$plugin->assign('form', $form->returnForm());
$content = $plugin->fetch('profile/extra.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
