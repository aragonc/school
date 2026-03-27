<?php

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../SupportManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('support');
$plugin->setSidebar('support');

$isAdmin = api_is_platform_admin();
$userId  = (int) api_get_user_id();

$filterStatus = isset($_GET['status']) ? $_GET['status'] : '';

$tickets = SupportManager::getTickets([
    'user_id'  => $userId,
    'is_admin' => $isAdmin,
    'status'   => $filterStatus,
]);

// Enriquecer cada ticket con etiquetas y asignados
foreach ($tickets as &$t) {
    $t['status_label']     = SupportManager::getStatusLabel($t['status']);
    $t['status_badge']     = SupportManager::getStatusBadgeClass($t['status']);
    $t['priority_label']   = SupportManager::getPriorityLabel($t['priority']);
    $t['priority_badge']   = SupportManager::getPriorityBadgeClass($t['priority']);
    $t['created_at_local'] = api_get_local_time($t['created_at']);
    $t['assignees']        = SupportManager::getAssignees((int) $t['id']);
}
unset($t);

$defaultCats = '[{"name":"General","active":true},{"name":"Acceso / Contraseña","active":true},{"name":"Pagos","active":true},{"name":"Cursos","active":true},{"name":"Otro","active":true}]';
$allCats     = json_decode($plugin->getSchoolSetting('support_categories') ?: $defaultCats, true) ?: [];
$activeCats  = array_values(array_filter($allCats, function($c) { return !empty($c['active']); }));

$plugin->assign('is_admin',          $isAdmin);
$plugin->assign('tickets',           $tickets);
$plugin->assign('filter_status',     $filterStatus);
$plugin->assign('support_categories', $activeCats);
$plugin->assign('ajax_url',          api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_support.php');

$plugin->setTitle($plugin->get_lang('SupportTickets'));
$content = $plugin->fetch('support/list.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
