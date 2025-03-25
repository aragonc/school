<?php

require_once __DIR__.'/config.php';
$plugin = SchoolPlugin::create();
$enable = $plugin->get('tool_enable') == 'true';
$nameTools = $plugin->get_lang('DashboardSchool');
$certificateId = $_GET['id'] ?? 0;
$plugin->setSidebar('shopping');

$view = $_REQUEST['view'] ?? 'courses';

$nameFilter = null;
$minFilter = 0;
$maxFilter = 0;

api_block_anonymous_users();

$country = $buy = null;

if(class_exists('BuyCoursesPlugin')){
    $buy = new BuyCoursesPlugin();
    if($buy->get('international_enable') == 'true'){
        $country = $buy->getGeo();
        $_SESSION['user_country_login'] = $country;
    }
}
$tags = $plugin->getTags();
$form = new FormValidator(
    'search_filter',
    'get',
    null,
    null,
    [],
    FormValidator::LAYOUT_SEARCH
);
$form->addSelect('tag',$plugin->get_lang('ShowByCategories'), $tags);
$plugin->assign('form', $form->returnForm());

//var_dump($sessionList);
if ($enable) {
    $userId = api_get_user_id();
    $content = '';

    switch ($view) {
        case 'courses':

            $isInternational = false;
            if(isset($_SESSION['user_country_login'])){
                $country = $_SESSION['user_country_login'];
                if($country['country_code'] === 'CL'){
                    $sessions = $plugin->getCoursesByFiltering($nameFilter, 4);
                } else {
                    $sessions = $plugin->getCoursesByFiltering($nameFilter, 6);
                    $isInternational = true;
                }
            } else {
                $sessions = $plugin->getCoursesByFiltering($nameFilter, 4);
            }

            $list = $tags = [];
            foreach ($sessions as $session) {
                $tags =  $plugin->getTagsSession($session['id']);
                $list[] = [
                    'id' => $session['id'],
                    'name' => $session['name'],
                    'description' => ucfirst(strtolower(strip_tags($session['description']))),
                    'tags' => $tags,
                    'dates' => $session['dates'],
                    'courses' => $session['courses'],
                    'has_coupon' => $session['has_coupon'],
                    'price' => $session['price'],
                    'price_without_tax' => $session['price_without_tax'],
                    'image' => $session['image'],
                    'category' => $session['category'],
                    'price_usd' => $session['price_usd'],
                    'total_price_formatted' => $session['total_price_formatted'],
                    'is_international' => $session['is_international'],
                    'coach' => $session['coach'],
                    'enrolled' => $session['enrolled'],
                    'currency' => $session['currency'],
                ];
            }

            $plugin->setTitle($plugin->get_lang('BuyCourses'));
            $plugin->assign('sessions', $list);

            $content = $plugin->fetch('school_shopping_courses.tpl');
            break;

        case 'graduates':

            if(isset($_SESSION['user_country_login'])) {
                $country = $_SESSION['user_country_login'];
                if ($country['country_code'] === 'CL') {
                    $sessions = $plugin->getCoursesByFiltering($nameFilter, 1);
                } else {
                    $sessions = $plugin->getCoursesByFiltering($nameFilter, 8);
                    $isInternational = true;
                }
            } else {
                $sessions = $plugin->getCoursesByFiltering($nameFilter, 1);
            }

            $list = $tags = [];
            foreach ($sessions as $session) {
                $tags =  $plugin->getTagsSession($session['id']);
                $list[] = [
                    'id' => $session['id'],
                    'name' => $session['name'],
                    'description' => ucfirst(strtolower(strip_tags($session['description']))),
                    'tags' => $tags,
                    'dates' => $session['dates'],
                    'courses' => $session['courses'],
                    'has_coupon' => $session['has_coupon'],
                    'price' => $session['price'],
                    'price_without_tax' => $session['price_without_tax'],
                    'image' => $session['image'],
                    'category' => $session['category'],
                    'price_usd' => $session['price_usd'],
                    'total_price_formatted' => $session['total_price_formatted'],
                    'is_international' => $session['is_international'],
                    'coach' => $session['coach'],
                    'enrolled' => $session['enrolled'],
                    'currency' => $session['currency'],
                ];
            }

            $plugin->setTitle($plugin->get_lang('BuyGraduates'));
            $plugin->assign('sessions', $list);
            $content = $plugin->fetch('school_shopping_graduates.tpl');
            break;
    }

    $plugin->assign('content', $content);
    $plugin->display_blank_template();
}
