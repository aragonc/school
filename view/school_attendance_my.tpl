{% include 'school_attendance_tabs.tpl' %}

<div class="card">
    <div class="card-header">
        <i class="fas fa-user-clock"></i> {{ 'MyAttendance'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body p-0">
        {% if my_attendance|length > 0 %}
        <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
                <thead class="thead-light">
                    <tr>
                        <th>{{ 'Date'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'CheckIn'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Method'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Schedule'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for record in my_attendance %}
                    <tr>
                        <td>{{ record.date }}</td>
                        <td>{{ record.check_in|date('H:i:s') }}</td>
                        <td>
                            {% if record.status == 'on_time' %}
                                <span class="badge badge-success">{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% elseif record.status == 'late' %}
                                <span class="badge badge-warning">{{ 'Late'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% else %}
                                <span class="badge badge-danger">{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% endif %}
                        </td>
                        <td>
                            {% if record.method == 'qr' %}
                                <i class="fas fa-qrcode"></i> QR
                            {% else %}
                                <i class="fas fa-hand-pointer"></i> Manual
                            {% endif %}
                        </td>
                        <td>{{ record.schedule_name ?? '-' }}</td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
        {% else %}
            <div class="p-4 text-center text-muted">
                <i class="fas fa-clipboard-list fa-2x mb-2"></i>
                <p>{{ 'NoAttendanceRecords'|get_plugin_lang('SchoolPlugin') }}</p>
            </div>
        {% endif %}
    </div>
</div>
