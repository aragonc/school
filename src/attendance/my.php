<?php

require_once __DIR__ . '/../../config.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();
$plugin->requireModule('attendance');

$enable = $plugin->get('tool_enable') == 'true';
if (!$enable) {
    api_not_allowed(true);
}

$plugin->setCurrentSection('attendance');
$plugin->setSidebar('attendance');
api_block_anonymous_users();

$userId = api_get_user_id();
$isAdmin = api_is_platform_admin();

$today     = date('Y-m-d');
$startYear = date('Y-01-01'); // desde el 1 de enero del año en curso

$myAttendance = $plugin->getAttendanceByUser($userId, $startYear, $today);

$days_es = ['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'];
$months_es = [
    1=>'Enero',2=>'Febrero',3=>'Marzo',4=>'Abril',5=>'Mayo',6=>'Junio',
    7=>'Julio',8=>'Agosto',9=>'Septiembre',10=>'Octubre',11=>'Noviembre',12=>'Diciembre'
];

// Días laborales configurados para el usuario (date('w'): 0=dom,1=lun,...,6=sab)
$workingDaysMap = ['lunes'=>1,'martes'=>2,'miercoles'=>3,'jueves'=>4,'viernes'=>5];
$extraProfile   = $plugin->getExtraProfileData($userId);
$rawDays        = trim($extraProfile['working_days'] ?? '');
if ($rawDays !== '') {
    $allowedDows = array_values(array_filter(array_map(
        fn($d) => $workingDaysMap[trim($d)] ?? null,
        explode(',', $rawDays)
    ), fn($v) => $v !== null));
} else {
    // Sin configuración: mostrar todos los días hábiles (lun-vie)
    $allowedDows = [1, 2, 3, 4, 5];
}

// Agrupar por mes, filtrar solo los días que labora
$byMonth = [];
foreach ($myAttendance as $record) {
    if (!empty($record['check_in'])) {
        $record['check_in'] = api_get_local_time($record['check_in']);
    }
    $ts      = strtotime($record['date']);
    $dow     = (int) date('w', $ts); // 0=dom, 6=sab
    if (!in_array($dow, $allowedDows)) continue;

    $record['day_name']   = $days_es[$dow];
    $monthNum             = (int) date('n', $ts);
    $monthKey             = date('Y-m', $ts);
    $record['month_label'] = $months_es[$monthNum] . ' ' . date('Y', $ts);

    $byMonth[$monthKey]['label']     = $record['month_label'];
    $byMonth[$monthKey]['records'][] = $record;
}

// Ordenar meses de más reciente a más antiguo
krsort($byMonth);

$showCheckinTime = $plugin->getSchoolSetting('attendance_show_checkin_time') === '1';

$plugin->assign('is_admin', $isAdmin);
$plugin->assign('active_tab', 'my');
$plugin->assign('by_month', $byMonth);
$plugin->assign('show_checkin_time', $showCheckinTime);

$plugin->setTitle($plugin->get_lang('AttendanceControl'));

$content = $plugin->fetch('attendance/my.tpl');
$plugin->assign('content', $content);
$plugin->display_blank_template();
