<!-- Tabs Navigation -->
<ul class="nav nav-tabs mb-4" id="attendanceTabs" role="tablist">
    {% if is_admin %}
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'today' ? 'active' : '' }}" id="today-tab" data-toggle="tab" href="#today" role="tab">
            <i class="fas fa-calendar-day"></i> {{ 'TodayAttendance'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'manual' ? 'active' : '' }}" id="manual-tab" data-toggle="tab" href="#manual" role="tab">
            <i class="fas fa-user-check"></i> {{ 'ManualRegistration'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'schedules' ? 'active' : '' }}" id="schedules-tab" data-toggle="tab" href="#schedules" role="tab">
            <i class="fas fa-clock"></i> {{ 'Schedules'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'reports' ? 'active' : '' }}" id="reports-tab" data-toggle="tab" href="#reports" role="tab">
            <i class="fas fa-chart-bar"></i> {{ 'Reports'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    {% endif %}
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'my' or (not is_admin and active_tab == 'today') ? 'active' : '' }}" id="my-tab" data-toggle="tab" href="#my" role="tab">
            <i class="fas fa-user-clock"></i> {{ 'MyAttendance'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>

<div class="tab-content" id="attendanceTabContent">

    {% if is_admin %}
    <!-- TAB: Today's Attendance -->
    <div class="tab-pane fade {{ active_tab == 'today' ? 'show active' : '' }}" id="today" role="tabpanel">
        <div class="row">
            <!-- QR Code Section -->
            <div class="col-lg-4 mb-4">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <i class="fas fa-qrcode"></i> {{ 'QRCodeForToday'|get_plugin_lang('SchoolPlugin') }}
                    </div>
                    <div class="card-body text-center">
                        {% if qr_data %}
                            <img src="data:image/png;base64,{{ qr_data.qr_image }}" alt="QR Code" class="img-fluid mb-3" style="max-width: 250px;">
                            <p class="text-muted small">{{ 'QRInstructions'|get_plugin_lang('SchoolPlugin') }}</p>
                            <button class="btn btn-outline-primary btn-sm" onclick="printQR()">
                                <i class="fas fa-print"></i> {{ 'PrintQR'|get_plugin_lang('SchoolPlugin') }}
                            </button>
                        {% else %}
                            <button class="btn btn-primary" id="btnGenerateQR">
                                <i class="fas fa-qrcode"></i> {{ 'GenerateQR'|get_plugin_lang('SchoolPlugin') }}
                            </button>
                        {% endif %}
                    </div>
                </div>
            </div>

            <!-- Today's Stats -->
            <div class="col-lg-8 mb-4">
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-chart-pie"></i> {{ 'AttendanceSummary'|get_plugin_lang('SchoolPlugin') }} - {{ today }}
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
                                                <span class="badge badge-info">{{ 'Staff'|get_plugin_lang('SchoolPlugin') }}</span>
                                            {% else %}
                                                <span class="badge badge-secondary">{{ 'Students'|get_plugin_lang('SchoolPlugin') }}</span>
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
    </div>

    <!-- TAB: Manual Registration -->
    <div class="tab-pane fade {{ active_tab == 'manual' ? 'show active' : '' }}" id="manual" role="tabpanel">
        <div class="card">
            <div class="card-header">
                <i class="fas fa-user-check"></i> {{ 'ManualRegistration'|get_plugin_lang('SchoolPlugin') }}
            </div>
            <div class="card-body">
                <div class="mb-3 d-flex justify-content-between align-items-center flex-wrap">
                    <div class="btn-group mr-2 mb-2" role="group">
                        <button type="button" class="btn btn-outline-secondary btn-sm filter-users active" data-filter="all">{{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }}</button>
                        <button type="button" class="btn btn-outline-secondary btn-sm filter-users" data-filter="staff">{{ 'Staff'|get_plugin_lang('SchoolPlugin') }}</button>
                        <button type="button" class="btn btn-outline-secondary btn-sm filter-users" data-filter="students">{{ 'Students'|get_plugin_lang('SchoolPlugin') }}</button>
                    </div>
                    <!-- Bulk action controls -->
                    <div class="d-flex align-items-center mb-2">
                        <select id="bulkStatus" class="form-control form-control-sm mr-2" style="width: auto;">
                            <option value="on_time">{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="late">{{ 'Late'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="absent">{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}</option>
                        </select>
                        <button type="button" class="btn btn-primary btn-sm" id="btnRegisterSelected">
                            <i class="fas fa-check-double"></i> {{ 'RegisterSelected'|get_plugin_lang('SchoolPlugin') }}
                        </button>
                    </div>
                </div>
                <form id="manualAttendanceForm">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover" id="usersTable">
                            <thead class="thead-light">
                                <tr>
                                    <th style="width: 40px;">
                                        <input type="checkbox" id="selectAll">
                                    </th>
                                    <th>{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}</th>
                                    <th>{{ 'Role'|get_plugin_lang('SchoolPlugin') }}</th>
                                    <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                                    <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                                </tr>
                            </thead>
                            <tbody>
                                {% for user in users %}
                                <tr class="user-row" data-role="{{ user.role_type }}">
                                    <td>
                                        <input type="checkbox" name="user_ids[]" value="{{ user.id }}" class="user-checkbox">
                                    </td>
                                    <td>{{ user.lastname }}, {{ user.firstname }}</td>
                                    <td>
                                        {% if user.role_type == 'staff' %}
                                            <span class="badge badge-info">{{ user.role_label }}</span>
                                        {% else %}
                                            <span class="badge badge-secondary">{{ user.role_label }}</span>
                                        {% endif %}
                                    </td>
                                    <td>
                                        {% if user.attendance_id %}
                                            {% if user.attendance_status == 'on_time' %}
                                                <span class="badge badge-success">{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }} ({{ user.check_in|date('H:i') }})</span>
                                            {% elseif user.attendance_status == 'late' %}
                                                <span class="badge badge-warning">{{ 'Late'|get_plugin_lang('SchoolPlugin') }} ({{ user.check_in|date('H:i') }})</span>
                                            {% else %}
                                                <span class="badge badge-danger">{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}</span>
                                            {% endif %}
                                        {% else %}
                                            <span class="badge badge-light">{{ 'NotRegistered'|get_plugin_lang('SchoolPlugin') }}</span>
                                        {% endif %}
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm" role="group">
                                            <button type="button" class="btn btn-success btn-mark-single" data-user-id="{{ user.id }}" data-status="on_time" title="{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }}">
                                                <i class="fas fa-check"></i>
                                            </button>
                                            <button type="button" class="btn btn-warning btn-mark-single" data-user-id="{{ user.id }}" data-status="late" title="{{ 'Late'|get_plugin_lang('SchoolPlugin') }}">
                                                <i class="fas fa-clock"></i>
                                            </button>
                                            <button type="button" class="btn btn-danger btn-mark-single" data-user-id="{{ user.id }}" data-status="absent" title="{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}">
                                                <i class="fas fa-times"></i>
                                            </button>
                                            {% if user.attendance_id %}
                                            <button type="button" class="btn btn-outline-danger btn-delete-attendance" data-attendance-id="{{ user.attendance_id }}" data-user-name="{{ user.lastname }}, {{ user.firstname }}" title="{{ 'DeleteAttendance'|get_plugin_lang('SchoolPlugin') }}">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                            {% endif %}
                                        </div>
                                    </td>
                                </tr>
                                {% endfor %}
                            </tbody>
                        </table>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- TAB: Schedules -->
    <div class="tab-pane fade {{ active_tab == 'schedules' ? 'show active' : '' }}" id="schedules" role="tabpanel">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="fas fa-clock"></i> {{ 'Schedules'|get_plugin_lang('SchoolPlugin') }}</span>
                <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#scheduleModal" onclick="clearScheduleForm()">
                    <i class="fas fa-plus"></i> {{ 'AddSchedule'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-striped mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>{{ 'ScheduleName'|get_plugin_lang('SchoolPlugin') }}</th>
                                <th>{{ 'EntryTime'|get_plugin_lang('SchoolPlugin') }}</th>
                                <th>{{ 'LateTime'|get_plugin_lang('SchoolPlugin') }}</th>
                                <th>{{ 'AppliesTo'|get_plugin_lang('SchoolPlugin') }}</th>
                                <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                                <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                            </tr>
                        </thead>
                        <tbody id="schedulesBody">
                            {% for schedule in schedules %}
                            <tr>
                                <td>{{ schedule.name }}</td>
                                <td>{{ schedule.entry_time }}</td>
                                <td>{{ schedule.late_time }}</td>
                                <td>
                                    {% if schedule.applies_to == 'all' %}
                                        {{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }}
                                    {% elseif schedule.applies_to == 'staff' %}
                                        {{ 'Staff'|get_plugin_lang('SchoolPlugin') }}
                                    {% else %}
                                        {{ 'Students'|get_plugin_lang('SchoolPlugin') }}
                                    {% endif %}
                                </td>
                                <td>
                                    {% if schedule.active %}
                                        <span class="badge badge-success">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% else %}
                                        <span class="badge badge-secondary">{{ 'Inactive'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% endif %}
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-outline-primary btn-edit-schedule"
                                            data-id="{{ schedule.id }}"
                                            data-name="{{ schedule.name }}"
                                            data-entry-time="{{ schedule.entry_time }}"
                                            data-late-time="{{ schedule.late_time }}"
                                            data-applies-to="{{ schedule.applies_to }}"
                                            data-active="{{ schedule.active }}">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger btn-delete-schedule" data-id="{{ schedule.id }}">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- TAB: Reports -->
    <div class="tab-pane fade {{ active_tab == 'reports' ? 'show active' : '' }}" id="reports" role="tabpanel">
        <div class="card mb-4">
            <div class="card-header">
                <i class="fas fa-filter"></i> {{ 'FilterByDate'|get_plugin_lang('SchoolPlugin') }}
            </div>
            <div class="card-body">
                <form method="get" action="" class="form-inline">
                    <input type="hidden" name="tab" value="reports">
                    <div class="form-group mr-2 mb-2">
                        <label class="mr-1">{{ 'StartDateFilter'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="date" name="start_date" class="form-control form-control-sm" value="{{ report_start_date }}">
                    </div>
                    <div class="form-group mr-2 mb-2">
                        <label class="mr-1">{{ 'EndDateFilter'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="date" name="end_date" class="form-control form-control-sm" value="{{ report_end_date }}">
                    </div>
                    <div class="form-group mr-2 mb-2">
                        <label class="mr-1">{{ 'FilterByType'|get_plugin_lang('SchoolPlugin') }}</label>
                        <select name="user_type" class="form-control form-control-sm">
                            <option value="">{{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="staff" {{ report_user_type == 'staff' ? 'selected' : '' }}>{{ 'Staff'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="students" {{ report_user_type == 'students' ? 'selected' : '' }}>{{ 'Students'|get_plugin_lang('SchoolPlugin') }}</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm mb-2 mr-2">
                        <i class="fas fa-search"></i> {{ 'Filter'|get_plugin_lang('SchoolPlugin') }}
                    </button>
                    <a href="{{ ajax_url }}?action=export_excel&start_date={{ report_start_date }}&end_date={{ report_end_date }}&user_type={{ report_user_type }}" class="btn btn-success btn-sm mb-2 mr-2">
                        <i class="fas fa-file-excel"></i> {{ 'ExportExcel'|get_plugin_lang('SchoolPlugin') }}
                    </a>
                    <a href="{{ ajax_url }}?action=export_pdf&start_date={{ report_start_date }}&end_date={{ report_end_date }}&user_type={{ report_user_type }}" class="btn btn-danger btn-sm mb-2">
                        <i class="fas fa-file-pdf"></i> {{ 'ExportPDF'|get_plugin_lang('SchoolPlugin') }}
                    </a>
                </form>
            </div>
        </div>

        {% if report_stats %}
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h4>{{ report_stats.total }}</h4>
                        <small class="text-muted">{{ 'TotalRecords'|get_plugin_lang('SchoolPlugin') }}</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center border-success">
                    <div class="card-body">
                        <h4 class="text-success">{{ report_stats.on_time }}</h4>
                        <small class="text-muted">{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }}</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center border-warning">
                    <div class="card-body">
                        <h4 class="text-warning">{{ report_stats.late }}</h4>
                        <small class="text-muted">{{ 'Late'|get_plugin_lang('SchoolPlugin') }}</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center border-danger">
                    <div class="card-body">
                        <h4 class="text-danger">{{ report_stats.absent }}</h4>
                        <small class="text-muted">{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}</small>
                    </div>
                </div>
            </div>
        </div>
        {% endif %}
    </div>
    {% endif %}

    <!-- TAB: My Attendance (visible for all users) -->
    <div class="tab-pane fade {{ active_tab == 'my' or (not is_admin and active_tab == 'today') ? 'show active' : '' }}" id="my" role="tabpanel">
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
    </div>
</div>

<!-- Schedule Modal -->
<div class="modal fade" id="scheduleModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="scheduleModalTitle">{{ 'AddSchedule'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <form id="scheduleForm">
                    <input type="hidden" id="schedule_id" name="id" value="">
                    <div class="form-group">
                        <label>{{ 'ScheduleName'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <input type="text" class="form-control" id="schedule_name" name="name" required placeholder="Ej: Turno Mañana">
                    </div>
                    <div class="form-group">
                        <label>{{ 'EntryTime'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <input type="time" class="form-control" id="schedule_entry_time" name="entry_time" required>
                    </div>
                    <div class="form-group">
                        <label>{{ 'LateTime'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <input type="time" class="form-control" id="schedule_late_time" name="late_time" required>
                    </div>
                    <div class="form-group">
                        <label>{{ 'AppliesTo'|get_plugin_lang('SchoolPlugin') }}</label>
                        <select class="form-control" id="schedule_applies_to" name="applies_to">
                            <option value="all">{{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="staff">{{ 'Staff'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="students">{{ 'Students'|get_plugin_lang('SchoolPlugin') }}</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <div class="custom-control custom-switch">
                            <input type="checkbox" class="custom-control-input" id="schedule_active" name="active" value="1" checked>
                            <label class="custom-control-label" for="schedule_active">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</label>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" id="btnSaveSchedule">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';

// Select all checkbox
document.getElementById('selectAll') && document.getElementById('selectAll').addEventListener('change', function() {
    var checkboxes = document.querySelectorAll('.user-checkbox');
    var checked = this.checked;
    checkboxes.forEach(function(cb) {
        var row = cb.closest('.user-row');
        if (row.style.display !== 'none') {
            cb.checked = checked;
        }
    });
});

// Filter users by role
document.querySelectorAll('.filter-users').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.filter-users').forEach(function(b) { b.classList.remove('active'); });
        this.classList.add('active');
        var filter = this.getAttribute('data-filter');
        document.querySelectorAll('.user-row').forEach(function(row) {
            if (filter === 'all' || row.getAttribute('data-role') === filter) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
});

// Register selected users with chosen status
document.getElementById('btnRegisterSelected') && document.getElementById('btnRegisterSelected').addEventListener('click', function() {
    var selected = [];
    document.querySelectorAll('.user-checkbox:checked').forEach(function(cb) {
        selected.push(cb.value);
    });
    if (selected.length === 0) {
        alert('Seleccione al menos un usuario');
        return;
    }

    var status = document.getElementById('bulkStatus').value;
    var formData = new FormData();
    formData.append('action', 'mark_attendance');
    formData.append('status', status);
    selected.forEach(function(uid) {
        formData.append('user_ids[]', uid);
    });

    fetch(ajaxUrl, { method: 'POST', body: formData })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                window.location.reload();
            } else {
                alert(data.message || 'Error');
            }
        });
});

// Individual status buttons (on_time, late, absent)
document.querySelectorAll('.btn-mark-single').forEach(function(btn) {
    btn.addEventListener('click', function() {
        var userId = this.getAttribute('data-user-id');
        var status = this.getAttribute('data-status');
        var formData = new FormData();
        formData.append('action', 'mark_attendance');
        formData.append('user_id', userId);
        formData.append('status', status);

        fetch(ajaxUrl, { method: 'POST', body: formData })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    window.location.reload();
                } else {
                    alert(data.message || 'Error');
                }
            });
    });
});

// Save schedule
document.getElementById('btnSaveSchedule') && document.getElementById('btnSaveSchedule').addEventListener('click', function() {
    var formData = new FormData();
    formData.append('action', 'save_schedule');
    formData.append('id', document.getElementById('schedule_id').value);
    formData.append('name', document.getElementById('schedule_name').value);
    formData.append('entry_time', document.getElementById('schedule_entry_time').value);
    formData.append('late_time', document.getElementById('schedule_late_time').value);
    formData.append('applies_to', document.getElementById('schedule_applies_to').value);
    formData.append('active', document.getElementById('schedule_active').checked ? 1 : 0);

    if (!document.getElementById('schedule_name').value || !document.getElementById('schedule_entry_time').value || !document.getElementById('schedule_late_time').value) {
        alert('Complete todos los campos obligatorios');
        return;
    }

    fetch(ajaxUrl, { method: 'POST', body: formData })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                window.location.href = window.location.pathname + '?tab=schedules';
            } else {
                alert(data.message || 'Error');
            }
        });
});

// Edit schedule
document.querySelectorAll('.btn-edit-schedule').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.getElementById('schedule_id').value = this.getAttribute('data-id');
        document.getElementById('schedule_name').value = this.getAttribute('data-name');
        document.getElementById('schedule_entry_time').value = this.getAttribute('data-entry-time');
        document.getElementById('schedule_late_time').value = this.getAttribute('data-late-time');
        document.getElementById('schedule_applies_to').value = this.getAttribute('data-applies-to');
        document.getElementById('schedule_active').checked = this.getAttribute('data-active') == '1';
        document.getElementById('scheduleModalTitle').textContent = '{{ 'EditSchedule'|get_plugin_lang('SchoolPlugin') }}';
        $('#scheduleModal').modal('show');
    });
});

// Delete schedule
document.querySelectorAll('.btn-delete-schedule').forEach(function(btn) {
    btn.addEventListener('click', function() {
        if (!confirm('{{ 'ConfirmDeleteSchedule'|get_plugin_lang('SchoolPlugin') }}')) return;
        var formData = new FormData();
        formData.append('action', 'delete_schedule');
        formData.append('id', this.getAttribute('data-id'));

        fetch(ajaxUrl, { method: 'POST', body: formData })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    window.location.href = window.location.pathname + '?tab=schedules';
                }
            });
    });
});

function clearScheduleForm() {
    document.getElementById('schedule_id').value = '';
    document.getElementById('schedule_name').value = '';
    document.getElementById('schedule_entry_time').value = '';
    document.getElementById('schedule_late_time').value = '';
    document.getElementById('schedule_applies_to').value = 'all';
    document.getElementById('schedule_active').checked = true;
    document.getElementById('scheduleModalTitle').textContent = '{{ 'AddSchedule'|get_plugin_lang('SchoolPlugin') }}';
}

// Delete attendance record
document.querySelectorAll('.btn-delete-attendance').forEach(function(btn) {
    btn.addEventListener('click', function() {
        var attendanceId = this.getAttribute('data-attendance-id');
        var userName = this.getAttribute('data-user-name');
        if (!confirm('{{ 'ConfirmDeleteAttendance'|get_plugin_lang('SchoolPlugin') }}\n' + userName)) return;

        var formData = new FormData();
        formData.append('action', 'delete_attendance');
        formData.append('attendance_id', attendanceId);

        fetch(ajaxUrl, { method: 'POST', body: formData })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    window.location.href = window.location.pathname + '?tab=manual';
                } else {
                    alert(data.message || 'Error');
                }
            });
    });
});

// Print QR
function printQR() {
    var qrImg = document.querySelector('#today img[alt="QR Code"]');
    if (!qrImg) return;
    var win = window.open('', '_blank');
    win.document.write('<html><head><title>QR Asistencia</title></head><body style="text-align:center; padding:40px;">');
    win.document.write('<h2>{{ 'QRCodeForToday'|get_plugin_lang('SchoolPlugin') }} - {{ today }}</h2>');
    win.document.write('<img src="' + qrImg.src + '" style="width:400px;height:400px;">');
    win.document.write('<p>{{ 'QRInstructions'|get_plugin_lang('SchoolPlugin') }}</p>');
    win.document.write('</body></html>');
    win.document.close();
    win.print();
}
</script>
