<?php

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../vendor/autoload.php';
// include autoloader
//api_block_anonymous_users();
$action = $_REQUEST['action'] ?? null;
$certificateId = $_GET['id'] ?? 0;
$userId = api_get_user_id();
$validPassword = false;
$plugin = SchoolPlugin::create();

$certificate = new Certificate($certificateId, $userId);
$certId = (int) $certificateId;
$infoCertificate = EasyCertificatePlugin::getCertificateData($certId, $userId);

$archivePath = api_get_path(SYS_ARCHIVE_PATH) . 'certificates/';
if (!is_dir($archivePath)) {
    mkdir($archivePath, api_get_permissions_for_new_directories());
}
$archiveCacheUserURL = api_get_path(WEB_ARCHIVE_PATH) . 'certificates/'.$userId.'/';
$archiveCacheUser = api_get_path(SYS_ARCHIVE_PATH) . 'certificates/'.$userId.'/';

if (!is_dir($archiveCacheUser)) {
    mkdir($archiveCacheUser, api_get_permissions_for_new_directories());
}

switch ($action) {
    case 'export_pdf':
        $html = '';

        if(empty($infoCertificate)){
            echo 'No certificate data found';
            exit;
        }

        $users = [api_get_user_info($userId)];
        $courseInfo = api_get_course_info($infoCertificate['course_code']);

        $accessUrlId = api_get_current_access_url_id();
        $sessionInfo = SessionManager::fetch($infoCertificate['session_id']);

        $currentLocalTime = api_get_local_time();

        $certificateTemplate = EasyCertificatePlugin::getInfoCertificate($courseInfo['real_id'], $sessionInfo['id'], $accessUrlId);
        if (empty($certificateTemplate)) {
            $certificateTemplate = EasyCertificatePlugin::getInfoCertificateDefault($accessUrlId);
        }
        $path = api_get_path(SYS_UPLOAD_PATH) . 'certificates';
        //$users = $plugin->getUsersWithCourseCertificates($infoCertificate['course_code'], $infoCertificate['session_id'], $userId);

        foreach ($users as $user) {
            $userID = $user['id'];
            $linkCertificateCSS = '<link rel="stylesheet" type="text/css" href="' . api_get_path(WEB_PLUGIN_PATH) . 'easycertificate/resources/css/certificate.css">';

            if(isset($certificateTemplate['background_h'])){
                $urlBackgroundHorizontal = $path . $certificateTemplate['background_h'];
            } else {
                $urlBackgroundHorizontal = '';
            }
            if(isset($certificateTemplate['background_v'])){
                $urlBackgroundVertical = $path . $certificateTemplate['background_v'];
            } else {
                $urlBackgroundVertical = '';
            }

            $allUserInfo = DocumentManager::get_all_info_to_certificate(
                $userID,
                $courseInfo['code'],
                false
            );

            $myContentHtml = $certificateTemplate['front_content'];
            $myContentHtml = str_replace(chr(13) . chr(10) . chr(13) . chr(10), chr(13) . chr(10), $myContentHtml);
            $infoToBeReplacedInContentHtml = $allUserInfo[0];
            $infoToReplaceInContentHtml = $allUserInfo[1];
            $myContentHtml = str_replace(
                $infoToBeReplacedInContentHtml,
                $infoToReplaceInContentHtml,
                $myContentHtml
            );

            $score = GradebookUtils::get_certificate_by_user_id(
                $infoCertificate['category_id'],
                $userID
            );

            $myContentHtml = str_replace(
                '((score_certificate))',
                $score['score_certificate'],
                $myContentHtml
            );

            $myContentHtml = str_replace(
                '((score_certificate))',
                $score['score_certificate'],
                $myContentHtml
            );

            $simpleAverageNotCategory = EasyCertificatePlugin::getScoreForEvaluations($courseInfo['code'], $userID, 0, $sessionInfo['id']);

            $myContentHtml = str_replace(
                '((simple_average))',
                $simpleAverageNotCategory,
                $myContentHtml
            );

            //simple average with category
            $simpleAverageCategory = EasyCertificatePlugin::getScoreForEvaluations($courseInfo['code'], $userID, 1, $sessionInfo['id']);
            $myContentHtml = str_replace(
                '((simple_average_category))',
                $simpleAverageCategory,
                $myContentHtml
            );

            //ExtraField
            $extraFieldsAll = EasyCertificatePlugin::getExtraFieldsUserAll();
            foreach ($extraFieldsAll as $field) {
                $valueExtraField = EasyCertificatePlugin::getValueExtraField($field, $userID);
                $myContentHtml = str_replace(
                    '(('.$field.'))',
                    $valueExtraField,
                    $myContentHtml
                );
            }

            //Session Date.
            $startDate = null;
            $endDate = null;
            if ($sessionInfo['id'] > 0) {
                switch ($certificateTemplate['date_change']) {
                    case 0:
                        if (!empty($sessionInfo['display_start_date'])) {
                            $startDate = strtotime(api_get_local_time($sessionInfo['display_start_date']));
                            $startDate = api_format_date($startDate, DATE_FORMAT_LONG_NO_DAY);
                        }
                        if (!empty($sessionInfo['display_end_date'])) {
                            $endDate = strtotime(api_get_local_time($sessionInfo['display_end_date']));
                            $endDate = api_format_date($endDate, DATE_FORMAT_LONG_NO_DAY);
                        }
                        break;
                    case 1:
                        if (!empty($sessionInfo['access_start_date'])) {
                            $startDate = strtotime(api_get_local_time($sessionInfo['access_start_date']));
                            $startDate = api_format_date($startDate, DATE_FORMAT_LONG_NO_DAY);
                        }
                        if (!empty($sessionInfo['access_end_date'])) {
                            $endDate = strtotime(api_get_local_time($sessionInfo['access_end_date']));
                            $endDate = api_format_date($endDate, DATE_FORMAT_LONG_NO_DAY);
                        }
                        break;
                }
                $myContentHtml = str_replace(
                    '((session_start_date))',
                    $startDate,
                    $myContentHtml
                );

                $myContentHtml = str_replace(
                    '((session_end_date))',
                    $endDate,
                    $myContentHtml
                );
            }

            //Date Expedition
            //Get Category GradeBook
            $myCertificate = GradebookUtils::get_certificate_by_user_id(
                $infoCertificate['category_id'],
                $userID
            );
            $createdAt = '';
            if (!empty($myCertificate['created_at'])) {
                $createdAt = strtotime(api_get_local_time($myCertificate['created_at']));
                $createdAt = api_format_date($createdAt, DATE_FORMAT_LONG_NO_DAY);
            }
            $myContentHtml = str_replace(
                '((expedition_date))',
                $createdAt,
                $myContentHtml
            );

            $codeCertificate = EasyCertificatePlugin::getCodeCertificate($infoCertificate['category_id'],$userID);
            $myContentHtml = str_replace(
                '((code_certificate))',
                strtoupper($codeCertificate['code_certificate_md5']),
                $myContentHtml
            );

            $certificateQR = EasyCertificatePlugin::getGenerateUrlImg($userID, $infoCertificate['category_id'], $codeCertificate['code_certificate_md5']);
            $myContentHtml = str_replace(
                '((qr-code))',
                '<img src="data:image/png;base64,'.$certificateQR.'">'
                ,
                $myContentHtml
            );

            $generator = new Picqer\Barcode\BarcodeGeneratorPNG();
            $codCertificate = $codeCertificate['code_certificate'];
            if (!empty($codCertificate)) {
                $myContentHtml = str_replace(
                    '((bar_code))',
                    '<img src="data:image/png;base64,' . base64_encode($generator->getBarcode($codCertificate, $generator::TYPE_CODE_128)) . '">'
                    ,
                    $myContentHtml
                );
            }

            $myContentHtml = strip_tags(
                $myContentHtml,
                '<p><b><strong><table><tr><td><th><tbody><span><i><li><ol><ul>
        <dd><dt><dl><br><hr><img><a><div><h1><h2><h3><h4><h5><h6>'
            );

            $orientation = $certificateTemplate['orientation'];
            $format = 'A4-L';
            $pageOrientation = 'L';
            if($orientation != 'h'){
                $format = 'A4';
                $pageOrientation = 'P';
            }

            $marginLeft = ($certificateTemplate['margin_left'] > 0) ? $certificateTemplate['margin_left'].'cm' : 0;
            $marginRight = ($certificateTemplate['margin_right'] > 0) ? $certificateTemplate['margin_right'].'cm' : 0;
            $marginTop = ($certificateTemplate['margin_top'] > 0) ? $certificateTemplate['margin_top'].'cm' : 0;
            $marginBottom = ($certificateTemplate['margin_bottom'] > 0) ? $certificateTemplate['margin_bottom'].'cm' : 0;
            $margin = $marginTop.' '.$marginRight.' '.$marginBottom.' '.$marginLeft;

            $templateName = $plugin->get_lang('ExportCertificate');
            $template = new Template($templateName);
            $template->assign('css_certificate', $linkCertificateCSS);
            $template->assign('orientation', $orientation);
            $template->assign('background_h', $urlBackgroundHorizontal);
            $template->assign('background_v', $urlBackgroundVertical);
            $template->assign('margin', $margin);
            $template->assign('front_content', $myContentHtml);
            $template->assign('show_back', $certificateTemplate['show_back']);

            // Rear certificate
            $laterContent = null;
            $laterContent .= '<table width="100%" class="contents-learnpath">';
            $laterContent .= '<tr>';
            $laterContent .= '<td>';
            $myContentHtml = strip_tags(
                $certificateTemplate['back_content'],
                '<p><b><strong><table><tr><td><th><span><i><li><ol><ul>' .
                '<dd><dt><dl><br><hr><img><a><div><h1><h2><h3><h4><h5><h6>'
            );
            $laterContent .= $myContentHtml;
            $laterContent .= '</td>';
            $laterContent .= '</tr>';
            $laterContent .= '</table>';

            $template->assign('back_content', $laterContent);
            $content = $template->fetch('easycertificate/template/certificate.tpl');
            $fileName = 'certificate_' . $courseInfo['code'] . '_' . $userId;

        }

        $mpdf = new \Mpdf\Mpdf([
            'tempDir' => $archivePath,
            'allow_output_buffering' => true,
            'curlAllowUnsafeSslRequests' => true,
            'margin_left' => 0,  // Margen izquierdo
            'margin_right' => 0,  // Margen derecho
            'margin_top' => 0,  // Margen superior
            'margin_bottom' => 0,  // Margen inferior
        ]);

        $mpdf->WriteHTML($content);
        $mpdf->Output($archiveCacheUser.$fileName.'.pdf', \Mpdf\Output\Destination::FILE);

        header('Content-Type: application/pdf');
        header('Content-Disposition: inline; filename="' . $fileName . '"');
        header('Content-Transfer-Encoding: binary');
        header('Accept-Ranges: bytes');
        readfile($archiveCacheUser . $fileName);
        break;
    case 'share':

        //generar imagen
        $fileName = 'certificate_' . $infoCertificate['course_code'] . '_' . $userId;

        $pdfImage = new Imagick();
        $pdfImage->readImage($archiveCacheUser.$fileName.'.pdf');
        $pdfImage->setResolution(300, 300);
        $pdfImage->setIteratorIndex(0);
        $pdfImage->setImageFormat('jpg');
        $pdfImage->writeImage($archiveCacheUser.$fileName.'.jpg');
        $pdfImage->clear();
        $pdfImage->destroy();


        $certificateURLUser = $archiveCacheUserURL.$fileName;
        $linkedinShareUrl = 'https://www.linkedin.com/sharing/share-offsite/?url=' . urlencode($certificateURLUser);
        header('Location: '.$linkedinShareUrl);
        exit();
        //var_dump($certificateURLUser);
    default;
}
