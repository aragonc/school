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

$isAdmin  = api_is_platform_admin();
$userId   = (int) api_get_user_id();
$ticketId = isset($_GET['id']) ? (int) $_GET['id'] : 0;

if ($ticketId <= 0) {
    header('Location: /support');
    exit;
}

$ticket = SupportManager::getTicketById($ticketId);
if (!$ticket || !SupportManager::canAccess($ticket, $userId, $isAdmin)) {
    api_not_allowed(true);
}

$ticket['status_label']   = SupportManager::getStatusLabel($ticket['status']);
$ticket['status_badge']   = SupportManager::getStatusBadgeClass($ticket['status']);
$ticket['priority_label'] = SupportManager::getPriorityLabel($ticket['priority']);
$ticket['priority_badge'] = SupportManager::getPriorityBadgeClass($ticket['priority']);
$ticket['created_at_local'] = api_get_local_time($ticket['created_at']);

$messages  = SupportManager::getMessages($ticketId);
$assignees = SupportManager::getAssignees($ticketId);

$plugin->assign('is_admin',  $isAdmin);
$plugin->assign('ticket',    $ticket);
$plugin->assign('messages',  $messages);
$plugin->assign('assignees', $assignees);
$plugin->assign('ajax_url',  api_get_path(WEB_PLUGIN_PATH) . 'school/ajax/ajax_support.php');

$plugin->setTitle('#' . $ticketId . ' — ' . htmlspecialchars($ticket['subject']));
$content = $plugin->fetch('support/view.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
