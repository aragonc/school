<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$plugin->setSidebar('notifications');
api_block_anonymous_users();

$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$action = isset($_GET['action']) ? (int)$_GET['action'] : 'all';
$type = isset($_GET['type']) ? (int) $_GET['type'] : MessageManager::MESSAGE_TYPE_INBOX;
$perPage = 10;
$userId = api_get_user_id();


if ($enable) {
    switch ($action){
        case 'all':
            $messages = $plugin->getMessages($userId,$page,$perPage);
            $totalUnread = $plugin->getMessagesCount($userId);
            $plugin->assign('total_unread', $totalUnread);
            $plugin->assign('list', $messages);
            $content = $plugin->fetch('school_notifications.tpl');
            break;
        case 'view':


    }



    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $plugin->setTitle($plugin->get_lang('MyNotifications'));
    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}
