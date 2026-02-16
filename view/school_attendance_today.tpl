{% include 'school_attendance_tabs.tpl' %}

<div class="row">
    <!-- Today's Stats -->
    <div class="col-lg-12 mb-4">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="fas fa-chart-pie"></i> {{ 'AttendanceSummary'|get_plugin_lang('SchoolPlugin') }} - {{ today }}</span>
                <a href="{{ kiosk_url }}" target="_blank" class="btn btn-info btn-sm">
                    <i class="fas fa-desktop"></i> {{ 'AttendanceKiosk'|get_plugin_lang('SchoolPlugin') }}
                </a>
            </div>
            <div class="card-body">
                <div class="row text-center">
                    <div class="col-3">
                        <h3>{{ today_stats.total }}</h3>
                        <small class="text-muted">{{ 'TotalRecords'|get_plugin_lang('SchoolPlugin') }}</small>
                    </div>
                    <div class="col-3">
                        <h3 class="text-success">{{ today_stats.on_time }}</h3>
                        <small class="text-muted">{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }}</small>
                    </div>
                    <div class="col-3">
                        <h3 class="text-warning">{{ today_stats.late }}</h3>
                        <small class="text-muted">{{ 'Late'|get_plugin_lang('SchoolPlugin') }}</small>
                    </div>
                    <div class="col-3">
                        <h3 class="text-danger">{{ today_stats.absent }}</h3>
                        <small class="text-muted">{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Today's Records Table -->
        <div class="card mt-3">
            <div class="card-header">
                <i class="fas fa-list"></i> {{ 'TodayAttendance'|get_plugin_lang('SchoolPlugin') }}
            </div>
            <div class="card-body p-0">
                {% if today_records|length > 0 %}
                <div class="table-responsive">
                    <table class="table table-striped table-hover mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}</th>
                                <th>{{ 'Role'|get_plugin_lang('SchoolPlugin') }}</th>
                                <th>{{ 'CheckIn'|get_plugin_lang('SchoolPlugin') }}</th>
                                <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                                <th>{{ 'Method'|get_plugin_lang('SchoolPlugin') }}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for record in today_records %}
                            <tr>
                                <td>{{ record.lastname }}, {{ record.firstname }}</td>
                                <td>
                                    {% if record.user_status == 1 %}
                                        <span class="badge badge-primary">{{ 'RoleTeacher'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% elseif record.user_status == 25 %}
                                        <span class="badge badge-info">{{ 'RoleSecretary'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% elseif record.user_status == 26 %}
                                        <span class="badge badge-info">{{ 'RoleAuxiliary'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% elseif record.user_status == 4 %}
                                        <span class="badge badge-dark">{{ 'RoleAdmin'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% elseif record.user_status == 23 %}
                                        <span class="badge badge-warning">{{ 'RoleParent'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% elseif record.user_status == 24 %}
                                        <span class="badge badge-warning">{{ 'RoleGuardian'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% else %}
                                        <span class="badge badge-secondary">{{ 'RoleStudent'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% endif %}
                                </td>
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
    </div>
</div>
