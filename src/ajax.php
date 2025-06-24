<?php

require_once __DIR__ . '/../config.php';
//api_block_anonymous_users();
$action = $_REQUEST['action'] ?? null;
$search = $_REQUEST['term'] ?? null;
$plugin = SchoolPlugin::create();

switch ($action) {
    case 'check_notifications':
        $userId = api_get_user_id();
        $messages = $plugin->getAjaxMessages($userId);
        $jsonResponse  = [
            'count_messages' => $messages['totalMessages'],
            'messages' => $messages['messages']
        ];

        header('Content-Type: application/json');
        echo json_encode($jsonResponse);
        break;
    case 'search':
        $userId = api_get_user_id();
        $sessions = $plugin->getSearchCourse($search);
        $jsonResponse  = [
            'sessions' => $sessions,
            'count' => count($sessions)
        ];
        header('Content-Type: application/json');
        echo json_encode($jsonResponse);
        break;
        case 'search_course':
}
