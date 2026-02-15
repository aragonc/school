<style>
    body { font-family: Arial, sans-serif; font-size: 11px; }
    h1 { font-size: 18px; text-align: center; margin-bottom: 5px; }
    h3 { font-size: 13px; text-align: center; color: #555; margin-top: 0; }
    table { width: 100%; border-collapse: collapse; margin-top: 15px; }
    th { background-color: #4472C4; color: white; padding: 6px 8px; text-align: left; font-size: 10px; }
    td { padding: 5px 8px; border-bottom: 1px solid #ddd; font-size: 10px; }
    tr:nth-child(even) { background-color: #f2f2f2; }
    .on_time { color: #28a745; font-weight: bold; }
    .late { color: #ffc107; font-weight: bold; }
    .absent { color: #dc3545; font-weight: bold; }
    .footer { margin-top: 20px; font-size: 9px; color: #888; text-align: center; }
</style>

<h1>{{ institution }} - Reporte de Asistencia</h1>
{% if date_range %}
<h3>{{ date_range }}</h3>
{% endif %}

<table>
    <thead>
        <tr>
            <th>Fecha</th>
            <th>Apellidos</th>
            <th>Nombres</th>
            <th>Usuario</th>
            <th>Rol</th>
            <th>Hora Ingreso</th>
            <th>Estado</th>
            <th>M&eacute;todo</th>
            <th>Turno</th>
            <th>Notas</th>
        </tr>
    </thead>
    <tbody>
        {% for record in records %}
        <tr>
            <td>{{ record.date }}</td>
            <td>{{ record.lastname }}</td>
            <td>{{ record.firstname }}</td>
            <td>{{ record.username }}</td>
            <td>{{ record.role }}</td>
            <td>{{ record.check_in_time }}</td>
            <td class="{{ record.status }}">{{ record.status_label }}</td>
            <td>{{ record.method_label }}</td>
            <td>{{ record.schedule_name ?? '-' }}</td>
            <td>{{ record.notes ?? '' }}</td>
        </tr>
        {% endfor %}
    </tbody>
</table>

<div class="footer">
    Generado el {{ report_date }}
</div>
