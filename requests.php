<?php

require_once __DIR__.'/config.php';
require __DIR__ . '/vendor/autoload.php';

use School\PipedriveAPI;

$plugin = SchoolPlugin::create();
// Simplemente llama la función
$plugin->requireLogin();

$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$certificateId = $_GET['id'] ?? 0;
$plugin->setSidebar('requests');
$apiToken = $plugin->get('api_token_pipedrive');

$pipedriveAPI = new PipedriveAPI($apiToken);
$action = $_GET['action'] ?? 'list';

api_block_anonymous_users();

if ($enable) {

    $userId = api_get_user_id();
    $sessionsCurrent = $plugin->getSessionRelUser($userId);
    $plugin->assign('src_plugin', api_get_path(WEB_PLUGIN_PATH) . 'school/');
    $idBoard = $plugin->get('board_pipedrive');
    $idPhase = $plugin->get('phase_pipedrive');

    switch ($action) {

        case 'create':
            $form = new FormValidator('requests','post',api_get_path(WEB_PATH).'requests?action='.Security::remove_XSS($_GET['action']));
            $form->addSelect('session_id', $plugin->get_lang('SelectProgram'), $sessionsCurrent);
            $form->addText('title',$plugin->get_lang('TitleOfTheProject'));
            $form->addHidden('board_id',$idBoard);
            $form->addHidden('phase_id',$idPhase);
            $form->addHtmlEditor('description',$plugin->get_lang('DescriptionProject'));
            $form->addButton('submit',$plugin->get_lang('SendRequest'),'','primary');
            $plugin->assign('action', $action);
            $plugin->assign('form', $form->returnForm());

            if (!empty($defaults)) {
                $form->setDefaults($defaults);
            }

            if ($form->validate()) {
                $values = $form->exportValues();
                $session = api_get_session_name($values['session_id']);
                $user = api_get_user_info($userId);
                $html = 'Usuario: '.$user['firstname'].' '.$user['lastname'].'<br>';
                $html.= 'Email: '.$user['email'].'</br>';
                $html.= 'Programa: '.$session.'</br>';

                $values['description'] .= '<br>'.$html;
                $res = $plugin->saveRequest($values);
                $pipedriveAPI->addProject($values);

                if ($res) {
                    $url = api_get_path(WEB_PATH).'requests?action=list';
                    header('Location: '.$url);
                }
            }

            break;
        case 'list':
            $requests = $plugin->getRequestUser($userId);
            $plugin->assign('action', $action);
            $plugin->assign('requests', $requests);
            break;

    }

    $plugin->setTitle($plugin->get_lang('MyRequests'));
    $content = $plugin->fetch('school_requests.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();

}
