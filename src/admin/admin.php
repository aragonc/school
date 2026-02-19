<?php

require_once __DIR__ . '/../../config.php';
$plugin = SchoolPlugin::create();
api_protect_admin_script();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setSidebar('admin');
$plugin->setTitle($plugin->get_lang('PluginAdministration'));

$form = new FormValidator(
    'school_admin',
    'post',
    api_get_self(),
    '',
    [],
    FormValidator::LAYOUT_NEW
);

// Logo section
$form->addFile(
    'custom_logo',
    [$plugin->get_lang('CustomLogo'), 'SVG, PNG, JPG'],
    ['accept' => '.svg,.png,.jpg,.jpeg']
);
$form->addText(
    'logo_width',
    [$plugin->get_lang('LogoWidth'), $plugin->get_lang('LogoWidthHelp')],
    false,
    ['placeholder' => '160']
);
$form->addText(
    'logo_height',
    [$plugin->get_lang('LogoHeight'), $plugin->get_lang('LogoHeightHelp')],
    false,
    ['placeholder' => '80']
);

// Sidebar icon (collapsed)
$form->addFile(
    'sidebar_icon',
    [$plugin->get_lang('SidebarIcon'), $plugin->get_lang('SidebarIconHelp')],
    ['accept' => '.svg,.png,.jpg,.jpeg']
);
$form->addCheckBox('remove_sidebar_icon', '', $plugin->get_lang('RemoveSidebarIcon'));

// Colors section
$form->addHtml('<h4>'.$plugin->get_lang('ColorSettings').'</h4>');
$form->addText(
    'primary_color',
    [$plugin->get_lang('PrimaryColor'), $plugin->get_lang('PrimaryColorHelp')],
    false,
    ['placeholder' => '#4e73df', 'class' => 'form-control color-input']
);
$form->addText(
    'sidebar_brand_color',
    [$plugin->get_lang('SidebarBrandColor'), $plugin->get_lang('SidebarBrandColorHelp')],
    false,
    ['placeholder' => '#4e73df', 'class' => 'form-control color-input']
);
$form->addText(
    'sidebar_color',
    [$plugin->get_lang('SidebarColor'), $plugin->get_lang('SidebarColorHelp')],
    false,
    ['placeholder' => '#4e73df', 'class' => 'form-control color-input']
);
$form->addText(
    'sidebar_item_active_text',
    [$plugin->get_lang('SidebarItemActiveText'), $plugin->get_lang('SidebarItemActiveTextHelp')],
    false,
    ['placeholder' => '#ffffff', 'class' => 'form-control color-input']
);
$form->addText(
    'sidebar_text_color',
    [$plugin->get_lang('SidebarTextColor'), $plugin->get_lang('SidebarTextColorHelp')],
    false,
    ['placeholder' => 'rgba(255,255,255,0.8)', 'class' => 'form-control color-input']
);

$form->addCheckBox('remove_logo', '', $plugin->get_lang('RemoveLogo'));

// Login customization section
$form->addHtml('<h4>'.$plugin->get_lang('LoginSettings').'</h4>');
$form->addText(
    'login_bg_color',
    [$plugin->get_lang('LoginBgColor'), $plugin->get_lang('LoginBgColorHelp')],
    false,
    ['placeholder' => '#4e73df', 'class' => 'form-control color-input']
);
$form->addFile(
    'login_bg_image',
    [$plugin->get_lang('LoginBgImage'), $plugin->get_lang('LoginBgImageHelp')],
    ['accept' => '.jpg,.jpeg,.png,.webp']
);
$form->addCheckBox('remove_login_bg_image', '', $plugin->get_lang('RemoveLoginBgImage'));
$form->addFile(
    'login_card_image',
    [$plugin->get_lang('LoginCardImage'), $plugin->get_lang('LoginCardImageHelp')],
    ['accept' => '.jpg,.jpeg,.png,.webp']
);
$form->addCheckBox('remove_login_card_image', '', $plugin->get_lang('RemoveLoginCardImage'));

$form->addButtonSave($plugin->get_lang('SaveChanges'));

// Load current values
$defaults = [
    'logo_width' => $plugin->getSchoolSetting('logo_width') ?? '',
    'logo_height' => $plugin->getSchoolSetting('logo_height') ?? '',
    'primary_color' => $plugin->getSchoolSetting('primary_color') ?? '',
    'sidebar_brand_color' => $plugin->getSchoolSetting('sidebar_brand_color') ?? '',
    'sidebar_color' => $plugin->getSchoolSetting('sidebar_color') ?? '',
    'sidebar_item_active_text' => $plugin->getSchoolSetting('sidebar_item_active_text') ?? '',
    'sidebar_text_color' => $plugin->getSchoolSetting('sidebar_text_color') ?? '',
    'login_bg_color' => $plugin->getSchoolSetting('login_bg_color') ?? '',
];
$form->setDefaults($defaults);

if ($form->validate()) {
    $values = $form->getSubmitValues();

    // Handle logo removal
    if (!empty($values['remove_logo'])) {
        $currentLogo = $plugin->getSchoolSetting('custom_logo');
        if ($currentLogo) {
            $filePath = api_get_path(SYS_UPLOAD_PATH).'plugins/school/'.$currentLogo;
            if (file_exists($filePath)) {
                unlink($filePath);
            }
        }
        $plugin->setSchoolSetting('custom_logo', '');
    }

    // Handle logo upload
    if (!empty($_FILES['custom_logo']['size'])) {
        $uploadDir = api_get_path(SYS_UPLOAD_PATH).'plugins/school/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, api_get_permissions_for_new_directories(), true);
        }

        // Remove old logo
        $currentLogo = $plugin->getSchoolSetting('custom_logo');
        if ($currentLogo) {
            $oldFile = $uploadDir.$currentLogo;
            if (file_exists($oldFile)) {
                unlink($oldFile);
            }
        }

        $extension = pathinfo($_FILES['custom_logo']['name'], PATHINFO_EXTENSION);
        $newFilename = 'logo_'.time().'.'.$extension;

        if (move_uploaded_file($_FILES['custom_logo']['tmp_name'], $uploadDir.$newFilename)) {
            $plugin->setSchoolSetting('custom_logo', $newFilename);
        }
    }

    // Handle sidebar icon removal
    if (!empty($values['remove_sidebar_icon'])) {
        $currentIcon = $plugin->getSchoolSetting('sidebar_icon');
        if ($currentIcon) {
            $filePath = api_get_path(SYS_UPLOAD_PATH).'plugins/school/'.$currentIcon;
            if (file_exists($filePath)) {
                unlink($filePath);
            }
        }
        $plugin->setSchoolSetting('sidebar_icon', '');
    }

    // Handle sidebar icon upload
    if (!empty($_FILES['sidebar_icon']['size'])) {
        $uploadDir = api_get_path(SYS_UPLOAD_PATH).'plugins/school/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, api_get_permissions_for_new_directories(), true);
        }

        // Remove old icon
        $currentIcon = $plugin->getSchoolSetting('sidebar_icon');
        if ($currentIcon) {
            $oldFile = $uploadDir.$currentIcon;
            if (file_exists($oldFile)) {
                unlink($oldFile);
            }
        }

        $extension = pathinfo($_FILES['sidebar_icon']['name'], PATHINFO_EXTENSION);
        $newFilename = 'sidebar_icon_'.time().'.'.$extension;

        if (move_uploaded_file($_FILES['sidebar_icon']['tmp_name'], $uploadDir.$newFilename)) {
            $plugin->setSchoolSetting('sidebar_icon', $newFilename);
        }
    }

    // Save logo dimensions
    $plugin->setSchoolSetting('logo_width', $values['logo_width'] ?? '');
    $plugin->setSchoolSetting('logo_height', $values['logo_height'] ?? '');

    // Save colors
    $plugin->setSchoolSetting('primary_color', $values['primary_color'] ?? '');
    $plugin->setSchoolSetting('sidebar_brand_color', $values['sidebar_brand_color'] ?? '');
    $plugin->setSchoolSetting('sidebar_color', $values['sidebar_color'] ?? '');
    $plugin->setSchoolSetting('sidebar_item_active_text', $values['sidebar_item_active_text'] ?? '');
    $plugin->setSchoolSetting('sidebar_text_color', $values['sidebar_text_color'] ?? '');

    // Save login settings
    $plugin->setSchoolSetting('login_bg_color', $values['login_bg_color'] ?? '');

    // Handle login background image removal
    if (!empty($values['remove_login_bg_image'])) {
        $currentBg = $plugin->getSchoolSetting('login_bg_image');
        if ($currentBg) {
            $filePath = api_get_path(SYS_UPLOAD_PATH).'plugins/school/'.$currentBg;
            if (file_exists($filePath)) {
                unlink($filePath);
            }
        }
        $plugin->setSchoolSetting('login_bg_image', '');
    }

    // Handle login background image upload
    if (!empty($_FILES['login_bg_image']['size'])) {
        $uploadDir = api_get_path(SYS_UPLOAD_PATH).'plugins/school/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, api_get_permissions_for_new_directories(), true);
        }

        $currentBg = $plugin->getSchoolSetting('login_bg_image');
        if ($currentBg) {
            $oldFile = $uploadDir.$currentBg;
            if (file_exists($oldFile)) {
                unlink($oldFile);
            }
        }

        $extension = pathinfo($_FILES['login_bg_image']['name'], PATHINFO_EXTENSION);
        $newFilename = 'login_bg_'.time().'.'.$extension;

        if (move_uploaded_file($_FILES['login_bg_image']['tmp_name'], $uploadDir.$newFilename)) {
            $plugin->setSchoolSetting('login_bg_image', $newFilename);
        }
    }

    // Handle login card image removal
    if (!empty($values['remove_login_card_image'])) {
        $currentCard = $plugin->getSchoolSetting('login_card_image');
        if ($currentCard) {
            $filePath = api_get_path(SYS_UPLOAD_PATH).'plugins/school/'.$currentCard;
            if (file_exists($filePath)) {
                unlink($filePath);
            }
        }
        $plugin->setSchoolSetting('login_card_image', '');
    }

    // Handle login card image upload
    if (!empty($_FILES['login_card_image']['size'])) {
        $uploadDir = api_get_path(SYS_UPLOAD_PATH).'plugins/school/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, api_get_permissions_for_new_directories(), true);
        }

        $currentCard = $plugin->getSchoolSetting('login_card_image');
        if ($currentCard) {
            $oldFile = $uploadDir.$currentCard;
            if (file_exists($oldFile)) {
                unlink($oldFile);
            }
        }

        $extension = pathinfo($_FILES['login_card_image']['name'], PATHINFO_EXTENSION);
        $newFilename = 'login_card_'.time().'.'.$extension;

        if (move_uploaded_file($_FILES['login_card_image']['tmp_name'], $uploadDir.$newFilename)) {
            $plugin->setSchoolSetting('login_card_image', $newFilename);
        }
    }

    Display::addFlash(
        Display::return_message($plugin->get_lang('SettingsSaved'), 'success')
    );
    header('Location: '.api_get_self());
    exit;
}

// Pass current logo and sidebar icon to template
$currentLogo = $plugin->getCustomLogo();
$plugin->assign('current_logo', $currentLogo);
$sidebarIcon = $plugin->getSchoolSetting('sidebar_icon');
if ($sidebarIcon) {
    $plugin->assign('current_sidebar_icon', api_get_path(WEB_UPLOAD_PATH).'plugins/school/'.$sidebarIcon);
} else {
    $plugin->assign('current_sidebar_icon', '');
}
$loginBgImage = $plugin->getSchoolSetting('login_bg_image');
if ($loginBgImage) {
    $plugin->assign('current_login_bg_image', api_get_path(WEB_UPLOAD_PATH).'plugins/school/'.$loginBgImage);
} else {
    $plugin->assign('current_login_bg_image', '');
}
$loginCardImage = $plugin->getSchoolSetting('login_card_image');
if ($loginCardImage) {
    $plugin->assign('current_login_card_image', api_get_path(WEB_UPLOAD_PATH).'plugins/school/'.$loginCardImage);
} else {
    $plugin->assign('current_login_card_image', '');
}
$plugin->assign('form', $form->returnForm());
$content = $plugin->fetch('admin/admin.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
