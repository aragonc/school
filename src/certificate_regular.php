<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../vendor/autoload.php';

$idSession = isset($_GET['id_session']) ? (int)$_GET['id_session'] : null;
$plugin = SchoolPlugin::create();

$userID = api_get_user_id();
$userInfo = api_get_user_info($userID);
$session = api_get_session_info($idSession);
$extraField = new ExtraField('user');
$extraData = $extraField->get_handler_extra_data($userID);

$nCourse = intval($session['nbr_courses']);
$textHours = $plugin->get_lang('CourseHours');
if($nCourse > 1){
    $textHours = $plugin->get_lang('DiplomaHours');
}
$currentLocalTime = api_get_local_time(null,null,null,false,false,true);
$displayStartDate = api_get_local_time($session['display_start_date'],null,null,false,false,true);
$displayEndDate = api_get_local_time($session['display_end_date'],null,null,false,false,true);

$paramsUser = [
    'user_id' => $userInfo['id'],
    'lastname' => $userInfo['lastname'],
    'firstname' => $userInfo['firstname'],
    'email' => $userInfo['email'],
    'rut' => $extraData['extra_rol_unico_tributario'],
    'course_name' => $session['name'],
    'hours' => $textHours,
    'date_current' => $currentLocalTime,
    'display_start_date' => $displayStartDate,
    'display_end_date' => $displayEndDate,
    'session_id' => $session['id']
];

api_block_anonymous_users();

$format = 'A4-L';
$pageOrientation = 'L';
$fileName = 'certificate_regular_' . $userInfo['complete_name'] . '_' . $currentLocalTime;

$fileName = api_replace_dangerous_char($fileName);
$params = [
    'filename' => $fileName,
    'pdf_title' => 'Certificate',
    'pdf_description' => '',
    'format' => $format,
    'orientation' => $pageOrientation,
    'left' => 0,
    'top' => 0,
    'bottom' => 0,
    'right' => 0
];

$templateName = $plugin->get_lang('ExportCertificate');
$typeCertificate = $plugin->get('template_certificate');
$valueBarCode = $paramsUser['session_id'].$paramsUser['rut'];
$generateImgCodeBar = $plugin->generateBarcode($paramsUser['session_id'].$paramsUser['rut']);
$certificateBarCode = '<img src="data:image/png;base64,'.$generateImgCodeBar.'">';

$template = new Template($templateName);

if($typeCertificate === '1'){
    $signature= api_get_path(WEB_PLUGIN_PATH).'school/img/certificate/firma_sence.png';
    $logoCampus= api_get_path(WEB_PLUGIN_PATH).'school/img/certificate/logo_sence.png';
    $timbre= api_get_path(WEB_PLUGIN_PATH).'school/img/certificate/timbre_sence.jpg';
} else {
    $signature= api_get_path(WEB_PLUGIN_PATH).'school/img/certificate/firma.png';
    $logoCampus= api_get_path(WEB_PLUGIN_PATH).'school/img/certificate/logo.png';
    $timbre= api_get_path(WEB_PLUGIN_PATH).'school/img/certificate/timbre.jpg';
}

$template->assign('data', $paramsUser);
$template->assign('logo_path', $logoCampus);
$template->assign('signature_path', $signature);
$template->assign('timbre_path', $timbre);
$template->assign('bar_code', $certificateBarCode);
$template->assign('bar_code_value', $valueBarCode);

if($typeCertificate === '1'){
    $content = $template->fetch('school/view/certificate/school_certificate_sence.tpl');
} else {
    $content = $template->fetch('school/view/certificate/school_certificate_regular.tpl');
}

$archivePath = api_get_path(SYS_ARCHIVE_PATH) . 'certificates/';
if (!is_dir($archivePath)) {
    mkdir($archivePath, api_get_permissions_for_new_directories());
}
$archiveCacheUserURL = api_get_path(WEB_ARCHIVE_PATH) . 'certificates/'.$userID.'/';
$archiveCacheUser = api_get_path(SYS_ARCHIVE_PATH) . 'certificates/'.$userID.'/';

if (!is_dir($archiveCacheUser)) {
    mkdir($archiveCacheUser, api_get_permissions_for_new_directories());
}

$mpdf = new \Mpdf\Mpdf([
    'tempDir' => $archivePath,
    'allow_output_buffering' => true,
    'curlAllowUnsafeSslRequests' => true,
    'margin_left' => 20,  // Margen izquierdo
    'margin_right' => 20,  // Margen derecho
    'margin_top' => 10,  // Margen superior
    'margin_bottom' => 10,  // Margen inferior
]);

$mpdf->WriteHTML($content);
$mpdf->Output($archiveCacheUser.$fileName, \Mpdf\Output\Destination::FILE);

header('Content-Type: application/pdf');
header('Content-Disposition: inline; filename="' . $fileName . '"');
header('Content-Transfer-Encoding: binary');
header('Accept-Ranges: bytes');
readfile($archiveCacheUser . $fileName);
exit;

