{% include 'attendance/tabs.tpl' %}

{% if by_month|length > 0 %}

{% for monthKey, monthData in by_month %}
<div class="card shadow-sm border-0 mb-4">
    <div class="card-header bg-white py-2 px-3 d-flex align-items-center" style="border-left:4px solid #4e73df;">
        <i class="fas fa-calendar-alt text-primary mr-2"></i>
        <span class="font-weight-bold text-dark">{{ monthData.label }}</span>
        <span class="badge badge-light border ml-2 text-muted" style="font-size:11px;">
            {{ monthData.records|length }} día(s)
        </span>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0" style="font-size:13px;">
                <thead class="thead-light">
                    <tr>
                        <th style="width:180px;">Fecha</th>
                        {% if show_checkin_time %}<th>Hora de Ingreso</th>{% endif %}
                        <th>Estado</th>
                        <th>Método</th>
                        <th>Turno</th>
                    </tr>
                </thead>
                <tbody>
                    {% for record in monthData.records %}
                    <tr>
                        <td>
                            <span class="font-weight-bold text-dark">{{ record.date }}</span>
                            <span class="ml-2 badge badge-light text-muted" style="font-size:11px;">
                                {{ record.day_name }}
                            </span>
                        </td>
                        {% if show_checkin_time %}
                        <td>{{ record.check_in|date('H:i:s') }}</td>
                        {% endif %}
                        <td>
                            {% if record.nw_type is defined %}
                                <span class="text-muted">—</span>
                            {% elseif record.status == 'on_time' %}
                                <span class="badge badge-success">{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% elseif record.status == 'late' %}
                                <span class="badge badge-warning text-dark">{{ 'Late'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% else %}
                                <span class="badge badge-danger">{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% endif %}
                        </td>
                        <td>
                            {% if record.method == 'qr' %}
                                <i class="fas fa-qrcode mr-1"></i> QR
                            {% else %}
                                <i class="fas fa-hand-pointer mr-1"></i> Manual
                            {% endif %}
                        </td>
                        <td class="text-muted">{{ record.schedule_name ?? '-' }}</td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</div>
{% endfor %}

{% else %}
<div class="card">
    <div class="card-body p-5 text-center text-muted">
        <i class="fas fa-clipboard-list fa-2x mb-3 d-block text-secondary" style="opacity:.4;"></i>
        {{ 'NoAttendanceRecords'|get_plugin_lang('SchoolPlugin') }}
    </div>
</div>
{% endif %}
