<?php
// plugin/school/check_redirect.php

require_once __DIR__.'/../../../../main/inc/global.inc.php';
require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();

if (api_get_user_id()) {
    $plugin->handleLoginRedirect();
}

// Si llegamos aquí, no había redirección pendiente
header('Location: ' . api_get_path(WEB_PATH) . 'user_portal.php');
exit;

