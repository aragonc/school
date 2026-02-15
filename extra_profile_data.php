<?php

require_once __DIR__.'/config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setSidebar('dashboard');
api_block_anonymous_users();

$userId = api_get_user_id();

// Peru regions data
$regions = [
    'Amazonas', 'Áncash', 'Apurímac', 'Arequipa', 'Ayacucho',
    'Cajamarca', 'Callao', 'Cusco', 'Huancavelica', 'Huánuco',
    'Ica', 'Junín', 'La Libertad', 'Lambayeque', 'Lima',
    'Loreto', 'Madre de Dios', 'Moquegua', 'Pasco', 'Piura',
    'Puno', 'San Martín', 'Tacna', 'Tumbes', 'Ucayali'
];

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
$form->addText('phone', $plugin->get_lang('PhoneWhatsApp'), false, ['maxlength' => 50]);

// Region
$regionOptions = ['' => '-- ' . $plugin->get_lang('SelectOption') . ' --'];
foreach ($regions as $region) {
    $regionOptions[$region] = $region;
}
$form->addSelect('region', $plugin->get_lang('Region'), $regionOptions);

// Province
$form->addText('province', $plugin->get_lang('Province'), false, ['maxlength' => 100]);

// District
$form->addText('district', $plugin->get_lang('District'), false, ['maxlength' => 100]);

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
$plugin->assign('form', $form->returnForm());
$content = $plugin->fetch('school_extra_profile.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
