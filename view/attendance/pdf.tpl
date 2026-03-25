<style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; font-size: 10px; color: #2c2c2c; }

    /* ---- HEADER ---- */
    .pdf-header { width: 100%; margin-bottom: 16px; border-bottom: 3px solid #1F4E79; padding-bottom: 10px; }
    .pdf-header-title { font-size: 17px; font-weight: bold; color: #1F4E79; text-align: center; }
    .pdf-header-sub   { font-size: 11px; color: #555; text-align: center; margin-top: 3px; }
    .pdf-header-meta  { font-size: 9px; color: #888; text-align: center; margin-top: 2px; }

    /* ---- STATS CARDS ---- */
    .stats-row { width: 100%; margin-bottom: 14px; }
    .stats-row td { width: 25%; padding: 4px; }
    .stat-card { border-radius: 6px; padding: 8px 10px; text-align: center; }
    .stat-total   { background: #EBF5FB; border: 1px solid #AED6F1; }
    .stat-ontime  { background: #EAFAF1; border: 1px solid #A9DFBF; }
    .stat-late    { background: #FEF9E7; border: 1px solid #F9E79F; }
    .stat-absent  { background: #FDEDEC; border: 1px solid #F5B7B1; }
    .stat-card .stat-num  { font-size: 18px; font-weight: bold; }
    .stat-card .stat-lbl  { font-size: 9px; color: #555; margin-top: 2px; }
    .stat-total  .stat-num { color: #1F4E79; }
    .stat-ontime .stat-num { color: #1E8449; }
    .stat-late   .stat-num { color: #B7950B; }
    .stat-absent .stat-num { color: #922B21; }

    /* ---- TABLE ---- */
    table.main-table { width: 100%; border-collapse: collapse; margin-top: 4px; }
    table.main-table thead tr { background-color: #1F4E79; color: #fff; }
    table.main-table thead th { padding: 6px 7px; font-size: 9px; font-weight: bold; text-align: left; }
    table.main-table tbody td { padding: 4px 7px; font-size: 9px; border-bottom: 1px solid #e0e0e0; vertical-align: middle; }
    table.main-table tbody tr:nth-child(even) { background-color: #F4F6F7; }
    table.main-table tbody tr:hover { background-color: #EBF5FB; }

    /* ---- STATUS BADGES ---- */
    .badge { display: inline-block; padding: 2px 7px; border-radius: 10px; font-size: 8.5px; font-weight: bold; color: #fff; }
    .badge-on_time { background-color: #1E8449; }
    .badge-late    { background-color: #D4AC0D; }
    .badge-absent  { background-color: #922B21; }

    /* ---- METHOD ---- */
    .method-qr     { color: #1A5276; font-weight: bold; }
    .method-manual { color: #6C3483; font-weight: bold; }

    /* ---- FOOTER ---- */
    .pdf-footer { margin-top: 18px; border-top: 1px solid #ccc; padding-top: 6px; font-size: 8px; color: #aaa; text-align: center; }
</style>

<!-- HEADER -->
<div class="pdf-header">
    <div class="pdf-header-title">{{ institution }} &mdash; Reporte de Asistencia</div>
    {% if date_range %}
    <div class="pdf-header-sub">{{ date_range }}</div>
    {% endif %}
    <div class="pdf-header-meta">Generado el {{ report_date }}</div>
</div>

<!-- STATS -->
{% if stats %}
<table class="stats-row" cellspacing="0" cellpadding="0">
    <tr>
        <td>
            <div class="stat-card stat-total">
                <div class="stat-num">{{ stats.total }}</div>
                <div class="stat-lbl">Total registros</div>
            </div>
        </td>
        <td>
            <div class="stat-card stat-ontime">
                <div class="stat-num">{{ stats.on_time }}</div>
                <div class="stat-lbl">Puntual</div>
            </div>
        </td>
        <td>
            <div class="stat-card stat-late">
                <div class="stat-num">{{ stats.late }}</div>
                <div class="stat-lbl">Tardanza</div>
            </div>
        </td>
        <td>
            <div class="stat-card stat-absent">
                <div class="stat-num">{{ stats.absent }}</div>
                <div class="stat-lbl">Ausente</div>
            </div>
        </td>
    </tr>
</table>
{% endif %}

<!-- TABLE -->
<table class="main-table">
    <thead>
        <tr>
            <th>Fecha</th>
            <th>Apellidos</th>
            <th>Nombres</th>
            {% if is_student_export %}
            <th>Nivel</th>
            <th>Grado</th>
            <th>Secci&oacute;n</th>
            {% else %}
            <th>Rol</th>
            {% endif %}
            <th>Hora</th>
            <th>Estado</th>
            <th>M&eacute;todo</th>
            <th>Turno</th>
        </tr>
    </thead>
    <tbody>
        {% for r in records %}
        <tr>
            <td>{{ r.date }}</td>
            <td>{{ r.lastname }}</td>
            <td>{{ r.firstname }}</td>
            {% if is_student_export %}
            <td>{{ r.nivel_name ?: '-' }}</td>
            <td>{{ r.grado_name ?: '-' }}</td>
            <td>{{ r.seccion_name ?: '-' }}</td>
            {% else %}
            <td>{{ r.role }}</td>
            {% endif %}
            <td>{{ r.check_in_time }}</td>
            <td>
                {% if r.status == 'on_time' %}
                    <span class="badge badge-on_time">Puntual</span>
                {% elseif r.status == 'late' %}
                    <span class="badge badge-late">Tardanza</span>
                {% else %}
                    <span class="badge badge-absent">Ausente</span>
                {% endif %}
            </td>
            <td>
                {% if r.method == 'qr' %}
                    <span class="method-qr">QR</span>
                {% else %}
                    <span class="method-manual">Manual</span>
                {% endif %}
            </td>
            <td>{{ r.schedule_name ?: '-' }}</td>
        </tr>
        {% endfor %}
    </tbody>
</table>

<div class="pdf-footer">
    {{ institution }} &bull; Sistema de Control de Asistencia &bull; {{ report_date }}
</div>
