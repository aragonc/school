<?php

require_once __DIR__ . '/../config.php';
//api_block_anonymous_users();
$action = $_REQUEST['action'] ?? null;
$plugin = SchoolPlugin::create();

switch ($action) {
    case 'check_notifications':
        $userId = api_get_user_id();
        $countMessages = $plugin->getMessagesCount($userId);
        $messages = $plugin->getMessages($userId,1,5);
        $jsonResponse  = [
            'count_messages' => $countMessages,
            'messages' => $messages['messages']
        ];

        header('Content-Type: application/json');
        echo json_encode($jsonResponse);
        break;
}
