<?php
/**
 * School Plugin – Recalculate Attendance Status
 *
 * Recalcula el estado (on_time / late) de todos los registros de asistencia
 * que no son "absent", comparando la hora real de check_in contra el horario
 * aplicable de cada usuario.
 *
 * Útil para corregir registros guardados con status incorrecto debido al bug
 * de la query m.user_id en getApplicableSchedule.
 *
 * Uso:
 *   php recalculate_attendance_status.php              → todos los registros
 *   php recalculate_attendance_status.php 2026-03-24   → solo esa fecha
 *   php recalculate_attendance_status.php 2026-03-01 2026-03-24  → rango
 *
 * Agrega --dry-run para ver qué cambiaría sin escribir en la BD.
 */

$rootDir = dirname(__FILE__) . '/../../../';
define('CHAMILO_LOAD_WYSIWYG', false);

if (!file_exists($rootDir . 'main/inc/global.inc.php')) {
    echo "[ERROR] No se encontró Chamilo en $rootDir\n";
    exit(1);
}

require_once $rootDir . 'main/inc/global.inc.php';

$plugin  = SchoolPlugin::create();
$logTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ATTENDANCE_LOG);
$schedTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ATTENDANCE_SCHEDULE);

// ---- Argumentos de línea de comandos ----
$args    = array_filter($argv ?? [], fn($a) => $a !== $argv[0]);
$args    = array_values($args);
$dryRun  = in_array('--dry-run', $args);
$args    = array_values(array_filter($args, fn($a) => $a !== '--dry-run'));

$dateFrom = $args[0] ?? null;
$dateTo   = $args[1] ?? ($args[0] ?? null);

// ---- Construir WHERE de fechas ----
$whereDate = '';
if ($dateFrom && $dateTo && $dateFrom !== $dateTo) {
    $dateFrom = Database::escape_string($dateFrom);
    $dateTo   = Database::escape_string($dateTo);
    $whereDate = " AND al.date BETWEEN '$dateFrom' AND '$dateTo'";
    echo "Rango: $dateFrom → $dateTo\n";
} elseif ($dateFrom) {
    $dateFrom = Database::escape_string($dateFrom);
    $whereDate = " AND al.date = '$dateFrom'";
    echo "Fecha: $dateFrom\n";
} else {
    echo "Fecha: todos los registros\n";
}

if ($dryRun) echo "[DRY-RUN] No se escribirá en la BD.\n";
echo str_repeat('-', 60) . "\n";

// ---- Obtener registros no ausentes ----
$sql = "SELECT al.id, al.user_id, al.check_in, al.status, al.schedule_id
        FROM $logTable al
        WHERE al.status != 'absent'
        $whereDate
        ORDER BY al.date ASC, al.id ASC";

$result = Database::query($sql);
$total  = Database::num_rows($result);
echo "Registros a evaluar: $total\n\n";

$updated  = 0;
$skipped  = 0;
$noSched  = 0;
$errors   = 0;

while ($row = Database::fetch_array($result, 'ASSOC')) {
    $userId   = (int) $row['user_id'];
    $recordId = (int) $row['id'];
    $checkIn  = $row['check_in'];
    $oldStatus = $row['status'];

    // Obtener horario aplicable
    try {
        $schedule = $plugin->getApplicableSchedule($userId);
    } catch (Exception $e) {
        echo "  [ERROR] user_id=$userId id=$recordId: " . $e->getMessage() . "\n";
        $errors++;
        continue;
    }

    if (!$schedule) {
        // Sin horario → se deja como on_time (comportamiento original)
        if ($oldStatus !== 'on_time') {
            echo "  [SIN HORARIO] id=$recordId user=$userId → forzando on_time\n";
            if (!$dryRun) {
                Database::update($logTable, ['status' => 'on_time'], ['id = ?' => $recordId]);
            }
            $updated++;
        } else {
            $skipped++;
        }
        $noSched++;
        continue;
    }

    // Recalcular status
    $newStatus = $plugin->calculateAttendanceStatus($checkIn, (int) $schedule['id']);

    if ($newStatus === $oldStatus) {
        $skipped++;
        continue;
    }

    $date = substr($checkIn, 0, 10);
    $time = substr($checkIn, 11, 8);
    echo sprintf(
        "  [CAMBIO] id=%-6d user=%-5d %s %s  %-10s → %s\n",
        $recordId, $userId, $date, $time, $oldStatus, $newStatus
    );

    if (!$dryRun) {
        Database::update(
            $logTable,
            ['status' => $newStatus, 'schedule_id' => (int) $schedule['id']],
            ['id = ?' => $recordId]
        );
    }
    $updated++;
}

echo "\n" . str_repeat('-', 60) . "\n";
echo "Resultado:\n";
echo "  Evaluados : $total\n";
echo "  Cambiados : $updated\n";
echo "  Sin cambio: $skipped\n";
echo "  Sin horario: $noSched\n";
if ($errors) echo "  Errores   : $errors\n";
if ($dryRun) echo "\n[DRY-RUN] Nada fue escrito. Ejecuta sin --dry-run para aplicar.\n";
echo "\nListo.\n";
