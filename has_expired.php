<?php

require_once __DIR__.'/config.php';

$plugin = SchoolPlugin::create();

$enable = $plugin->get('tool_enable') == 'true';

$plugin->assign('form', '');
$content = $plugin->fetch('school_has_expired.tpl');
$plugin->assign('content', $content);
$plugin->display_none_template();
