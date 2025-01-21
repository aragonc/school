<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$certificateId = $_GET['id'] ?? 0;
$plugin->setSidebar('shopping');

$nameFilter = null;
$minFilter = 0;
$maxFilter = 0;

api_block_anonymous_users();

$country = null;
if(class_exists('BuyCoursesPlugin')){
    $buy = new BuyCoursesPlugin();
    if($buy->get('international_enable') == 'true'){
        $country = $buy->getGeo();
        $_SESSION['user_country_login'] = $country;
    }
}

$isInternational = false;
if(isset($_SESSION['user_country_login'])){
    $country = $_SESSION['user_country_login'];
    if($country['country_code'] === 'CL'){
        $sessionList = $buy->getCatalogSessionList($nameFilter, $minFilter, $maxFilter, false, 4);
    } else {
        $sessionList = $buy->getCatalogSessionList($nameFilter, $minFilter, $maxFilter, true, 6);
        $isInternational = true;
    }
} else {
    $sessionList = $buy->getCatalogSessionList($nameFilter, $minFilter, $maxFilter, true, 4);
}

var_dump($sessionList);
if ($enable) {
    $userId = api_get_user_id();
    $plugin->setTitle($plugin->get_lang('BuyCourses'));
    $content = $plugin->fetch('school_shopping.tpl');
    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
