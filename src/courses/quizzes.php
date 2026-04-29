<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();
$plugin->requireModule('courses');

api_protect_course_script(true);

$plugin->setCurrentSection('dashboard');
$plugin->setSidebar('dashboard');

$courseInfo  = api_get_course_info();
$courseId    = api_get_course_int_id();
$sessionId   = api_get_session_id();
$userId      = api_get_user_id();
$cidReq      = api_get_cidreq();

$exercises = ExerciseLib::get_all_exercises($courseInfo, $sessionId, false, '', false, 1);

$trackTable = Database::get_main_table(TABLE_STATISTIC_TRACK_E_EXERCISES);
$now        = api_get_utc_datetime();

$list = [];
foreach ($exercises as $ex) {
    $exId = (int) $ex['iid'];

    // Count attempts this user has made
    $sqlAttempts = "SELECT COUNT(*) AS cnt
                    FROM $trackTable
                    WHERE exe_exo_id = $exId
                      AND exe_user_id = $userId
                      AND c_id = $courseId
                      AND (session_id = $sessionId OR session_id IS NULL OR session_id = 0)
                      AND status != 'incomplete'";
    $resAttempts  = Database::query($sqlAttempts);
    $rowAttempts  = Database::fetch_assoc($resAttempts);
    $attemptsDone = (int) $rowAttempts['cnt'];

    // Best score
    $bestScore = null;
    if ($attemptsDone > 0) {
        $sqlScore = "SELECT MAX(score) AS best, exe_weighting
                     FROM $trackTable
                     WHERE exe_exo_id = $exId
                       AND exe_user_id = $userId
                       AND c_id = $courseId
                       AND status != 'incomplete'
                     GROUP BY exe_weighting
                     LIMIT 1";
        $resScore  = Database::query($sqlScore);
        $rowScore  = Database::fetch_assoc($resScore);
        if ($rowScore && $rowScore['exe_weighting'] > 0) {
            $bestScore = round(($rowScore['best'] / $rowScore['exe_weighting']) * 100);
        }
    }

    // Status
    $status = 'available';
    if (!empty($ex['start_time']) && $ex['start_time'] > $now) {
        $status = 'pending';
    } elseif (!empty($ex['end_time']) && $ex['end_time'] < $now) {
        $status = 'expired';
    } elseif ($ex['max_attempt'] > 0 && $attemptsDone >= $ex['max_attempt']) {
        $status = 'done';
    }

    // Questions count
    $quizQuestionTable = Database::get_course_table(TABLE_QUIZ_TEST_QUESTION);
    $sqlQ   = "SELECT COUNT(*) AS cnt FROM $quizQuestionTable WHERE exercice_id = $exId AND c_id = $courseId";
    $resQ   = Database::query($sqlQ);
    $rowQ   = Database::fetch_assoc($resQ);
    $numQs  = (int) $rowQ['cnt'];

    $list[] = [
        'id'            => $exId,
        'title'         => Security::remove_XSS($ex['title']),
        'description'   => strip_tags($ex['description'] ?? ''),
        'questions'     => $numQs,
        'time_limit'    => (int) $ex['expired_time'],
        'max_attempt'   => (int) $ex['max_attempt'],
        'attempts_done' => $attemptsDone,
        'best_score'    => $bestScore,
        'start_time'    => !empty($ex['start_time']) ? api_convert_and_format_date($ex['start_time'], DATE_TIME_FORMAT_SHORT) : '',
        'end_time'      => !empty($ex['end_time'])   ? api_convert_and_format_date($ex['end_time'],   DATE_TIME_FORMAT_SHORT) : '',
        'status'        => $status,
        'link'          => api_get_path(WEB_CODE_PATH) . 'exercise/overview.php?exerciseId=' . $exId . '&' . $cidReq,
    ];
}

$plugin->setTitle($plugin->get_lang('QuizzesTitle'));
$plugin->assign('quizzes', $list);
$plugin->assign('back_url', api_get_path(WEB_PATH) . 'home/course/' . $courseInfo['directory'] . '?' . $cidReq);

$content = $plugin->fetch('courses/quizzes.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
