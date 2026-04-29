<?php
/* For licensing terms, see /license.txt */

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();
$plugin->requireModule('courses');

api_protect_course_script(true);

$plugin->setCurrentSection('dashboard');
$plugin->setSidebar('dashboard');

$exerciseId  = isset($_REQUEST['exerciseId']) ? (int) $_REQUEST['exerciseId'] : 0;
$learnpathId = isset($_REQUEST['learnpath_id']) ? (int) $_REQUEST['learnpath_id'] : null;
$lpItemId    = isset($_REQUEST['learnpath_item_id']) ? (int) $_REQUEST['learnpath_item_id'] : null;
$lpItemViewId = isset($_REQUEST['learnpath_item_view_id']) ? (int) $_REQUEST['learnpath_item_view_id'] : null;

$courseInfo = api_get_course_info();
$courseId   = api_get_course_int_id();
$sessionId  = api_get_session_id();
$userId     = api_get_user_id();
$cidReq     = api_get_cidreq();

Exercise::cleanSessionVariables();

$objExercise = new Exercise();
if (!$objExercise->read($exerciseId, true)) {
    api_not_allowed(true);
}

// Check blocking plugins
if ('true' === api_get_plugin_setting('positioning', 'tool_enable')) {
    $posPlugin = Positioning::create();
    if ($posPlugin->blockFinalExercise($userId, $exerciseId, $courseId, $sessionId)) {
        api_not_allowed(true);
    }
}

// Build submit URL (still uses Chamilo's engine)
$submitParams = array_filter([
    'exerciseId'             => $objExercise->iid,
    'learnpath_id'           => $learnpathId,
    'learnpath_item_id'      => $lpItemId,
    'learnpath_item_view_id' => $lpItemViewId,
]);
$submitUrl = api_get_path(WEB_CODE_PATH) . 'exercise/exercise_submit.php?' . $cidReq . '&' . http_build_query($submitParams);

// Time control
$clockExpiredTime = ExerciseLib::get_session_time_control_key($objExercise->iid, $learnpathId, $lpItemId);
$timeControl = $objExercise->expired_time != 0 && !empty($clockExpiredTime);
$timeLeft    = $timeControl ? (api_strtotime($clockExpiredTime, 'UTC') - time()) : null;

// Visibility check
$visibleReturn = $objExercise->is_visible($learnpathId, $lpItemId, null, true, $sessionId);
$canStart      = $visibleReturn['value'] && api_is_allowed_to_session_edit();
$visibilityMsg = !$visibleReturn['value'] ? strip_tags($visibleReturn['message']) : '';

// In-progress attempt
$statInfo = $objExercise->get_stat_track_exercise_info($learnpathId, $lpItemId, 0);
$inProgress = isset($statInfo['exe_id']);

// Previous attempts
$rawAttempts = Event::getExerciseResultsByUser(
    $userId,
    $objExercise->iid,
    $courseId,
    $sessionId,
    $learnpathId,
    $lpItemId,
    'desc'
);

$showScore = !in_array($objExercise->results_disabled, [
    RESULT_DISABLE_NO_SCORE_AND_EXPECTED_ANSWERS,
]);

$showDetails = in_array($objExercise->results_disabled, [
    RESULT_DISABLE_SHOW_SCORE_AND_EXPECTED_ANSWERS,
    RESULT_DISABLE_SHOW_SCORE_AND_EXPECTED_ANSWERS_AND_RANKING,
    RESULT_DISABLE_SHOW_FINAL_SCORE_ONLY_WITH_CATEGORIES,
    RESULT_DISABLE_SHOW_SCORE_ATTEMPT_SHOW_ANSWERS_LAST_ATTEMPT,
    RESULT_DISABLE_SHOW_SCORE_ATTEMPT_SHOW_ANSWERS_LAST_ATTEMPT_NO_FEEDBACK,
    RESULT_DISABLE_DONT_SHOW_SCORE_ONLY_IF_USER_FINISHES_ATTEMPTS_SHOW_ALWAYS_FEEDBACK,
    RESULT_DISABLE_RANKING,
    RESULT_DISABLE_SHOW_ONLY_IN_CORRECT_ANSWER,
]);

$blockShowAnswers = false;
if (in_array($objExercise->results_disabled, [
    RESULT_DISABLE_SHOW_SCORE_ATTEMPT_SHOW_ANSWERS_LAST_ATTEMPT,
    RESULT_DISABLE_DONT_SHOW_SCORE_ONLY_IF_USER_FINISHES_ATTEMPTS_SHOW_ALWAYS_FEEDBACK,
]) && count($rawAttempts) < $objExercise->attempts) {
    $blockShowAnswers = true;
}

$attempts = [];
$counter  = count($rawAttempts);
$i        = $counter;
foreach ($rawAttempts as $att) {
    $scorePercent = null;
    $scoreText    = null;
    if ($showScore && $att['exe_weighting'] > 0) {
        $scorePercent = round(($att['exe_result'] / $att['exe_weighting']) * 100);
        $scoreText    = ExerciseLib::show_score($att['exe_result'], $att['exe_weighting']);
    }

    $resultUrl = null;
    if ($showDetails && !$blockShowAnswers) {
        if (!empty($objExercise->getResultAccess()) && !$objExercise->hasResultsAccess($att)) {
            $resultUrl = null;
        } else {
            $resultUrl = api_get_path(WEB_CODE_PATH) . 'exercise/result.php?' . $cidReq . '&show_headers=1&id=' . $att['exe_id'];
        }
    }

    $validated = (int) $att['attempt_revised'] === 1;

    $attempts[] = [
        'number'       => $i,
        'date'         => api_convert_and_format_date($att['start_date'], DATE_TIME_FORMAT_LONG),
        'score_text'   => $scoreText,
        'score_pct'    => $scorePercent,
        'validated'    => $validated,
        'result_url'   => $resultUrl,
    ];
    $i--;
}

// Max attempts / remaining
$maxAttempts  = (int) $objExercise->selectAttempts();
$attemptsLeft = $maxAttempts > 0 ? max(0, $maxAttempts - $counter) : null;
if ($maxAttempts > 0 && $counter >= $maxAttempts) {
    $canStart = false;
}

// Questions count
$quizQuestionTable = Database::get_course_table(TABLE_QUIZ_TEST_QUESTION);
$resQs  = Database::query("SELECT COUNT(*) AS cnt FROM $quizQuestionTable WHERE exercice_id = $exerciseId AND c_id = $courseId");
$numQs  = (int) Database::fetch_assoc($resQs)['cnt'];

// Start/continue label
$startLabel = $inProgress ? $plugin->get_lang('QuizContinue') : $plugin->get_lang('QuizStart');

$plugin->setTitle(Security::remove_XSS($objExercise->selectTitle(true)));
$plugin->assign('exercise', [
    'id'           => $objExercise->iid,
    'title'        => Security::remove_XSS($objExercise->selectTitle(true)),
    'description'  => Security::remove_XSS($objExercise->description ?? '', COURSEMANAGERLOWSECURITY),
    'questions'    => $numQs,
    'time_limit'   => (int) $objExercise->expired_time,
    'max_attempts' => $maxAttempts,
    'hide_attempts_table' => (int) $objExercise->getHideAttemptsTableOnStartPage(),
]);
$plugin->assign('attempts',        $attempts);
$plugin->assign('attempts_done',   $counter);
$plugin->assign('attempts_left',   $attemptsLeft);
$plugin->assign('can_start',       $canStart);
$plugin->assign('in_progress',     $inProgress);
$plugin->assign('start_label',     $startLabel);
$plugin->assign('submit_url',      $submitUrl);
$plugin->assign('time_control',    $timeControl);
$plugin->assign('time_left',       $timeLeft);
$plugin->assign('visibility_msg',  $visibilityMsg);
$plugin->assign('back_url',        api_get_path(WEB_PATH) . 'course/quizzes?' . $cidReq);

$content = $plugin->fetch('courses/quiz_overview.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
