<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$plugin->setSidebar('notifications');
api_block_anonymous_users();

$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$action = $_GET['action'] ?? 'all';

$perPage = 10;
$userId = api_get_user_id();
$content = null;

$plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');

if ($enable) {
    switch ($action){
        case 'all':
            $messages = $plugin->getMessages($userId,$page,$perPage);
            $totalUnread = $plugin->getMessagesCount($userId);
            $totalMessages = $plugin->getMessagesCount($userId, true);

            $plugin->assign('total_unread', $totalUnread);
            $plugin->assign('total_messages', $totalMessages);
            $plugin->assign('list', $messages);
            $plugin->setTitle($plugin->get_lang('MyNotifications'));
            $content = $plugin->fetch('school_notifications.tpl');
            break;
        case 'view':
            $messageId = isset($_GET['id']) ? (int) $_GET['id'] : 0;
            $type = isset($_GET['type']) ? (int) $_GET['type'] : MessageManager::MESSAGE_TYPE_INBOX;
            $message = $plugin->viewMessage($messageId,$type);
            $plugin->assign('box', $message);
            $content = $plugin->fetch('school_notifications_view.tpl');
            break;

    }

    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}
