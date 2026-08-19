<?php
require_once __DIR__ . '/../../config.php';
$plugin = SchoolPlugin::create();
api_protect_admin_script();

if ($plugin->get('tool_enable') != 'true') {
    api_not_allowed(true);
}

$plugin->exportAdminUsersExcel($_GET['search'] ?? '');
