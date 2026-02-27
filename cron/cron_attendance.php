<?php
/**
 * School Plugin – Daily Attendance Cron
 *
 * Marks all active users as "absent" for the given date.
 * Runs only on weekdays (Mon–Fri) that are not holidays or vacations.
 * When a user scans QR or is registered manually, the absent record is
 * automatically updated to on_time / late.
 *
 * Usage:
 *   php /var/www/chamilo/plugin/school/cron/cron_attendance.php [YYYY-MM-DD]
 *
 * Recommended crontab (midnight, Mon–Fri):
 *   0 0 * * 1-5 php /var/www/chamilo/plugin/school/cron/cron_attendance.php
 */

// Bootstrap Chamilo
$rootDir = dirname(__FILE__) . '/../../../';
define('CHAMILO_LOAD_WYSIWYG', false);

if (!file_exists($rootDir . 'main/inc/global.inc.php')) {
    echo "[ERROR] Could not find Chamilo root at $rootDir\n";
    exit(1);
}

require_once $rootDir . 'main/inc/global.inc.php';
require_once dirname(__FILE__) . '/../config.php';

date_default_timezone_set(api_get_timezone());

$plugin = SchoolPlugin::create();

// Allow passing a specific date as argument (for backfill / testing)
$date = isset($argv[1]) ? trim($argv[1]) : date('Y-m-d');

if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
    echo "[ERROR] Invalid date format '$date'. Use YYYY-MM-DD.\n";
    exit(1);
}

echo "[" . date('Y-m-d H:i:s') . "] Generating absences for $date ...\n";

$result = $plugin->generateDailyAbsences($date);

if ($result['skipped']) {
    $reasons = [
        'weekend'    => 'Weekend (Sat/Sun) — skipped.',
        'nonworking' => 'Holiday or vacation — skipped.',
    ];
    $msg = isset($reasons[$result['reason']]) ? $reasons[$result['reason']] : 'Skipped: ' . $result['reason'];
    echo "[" . date('Y-m-d H:i:s') . "] $msg\n";
} else {
    echo "[" . date('Y-m-d H:i:s') . "] Inserted : {$result['inserted']} absent record(s).\n";
    echo "[" . date('Y-m-d H:i:s') . "] Skipped  : {$result['skipped_existing']} user(s) already had a record.\n";
}

echo "[" . date('Y-m-d H:i:s') . "] Done.\n";
