{% include 'school_attendance_tabs.tpl' %}

<div class="card">
    <div class="card-header">
        <i class="fas fa-user-check"></i> {{ 'ManualRegistration'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body">
        <!-- Search and filters -->
        <div class="mb-3">
            <div class="row align-items-center">
                <div class="col-md-5 mb-2">
                    <div class="input-group input-group-sm">
                        <div class="input-group-prepend">
                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                        </div>
                        <input type="text" class="form-control" id="searchUser" placeholder="{{ 'SearchByName'|get_plugin_lang('SchoolPlugin') }}">
                    </div>
                </div>
                <div class="col-md-7 mb-2">
                    <div class="d-flex justify-content-between align-items-center flex-wrap">
                        <div class="btn-group mr-2 mb-1" role="group">
                            <button type="button" class="btn btn-outline-secondary btn-sm filter-users active" data-filter="all">{{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }}</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm filter-users" data-filter="teacher">{{ 'RoleTeacher'|get_plugin_lang('SchoolPlugin') }}</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm filter-users" data-filter="students">{{ 'RoleStudent'|get_plugin_lang('SchoolPlugin') }}</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm filter-users" data-filter="secretary">{{ 'RoleSecretary'|get_plugin_lang('SchoolPlugin') }}</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm filter-users" data-filter="auxiliary">{{ 'RoleAuxiliary'|get_plugin_lang('SchoolPlugin') }}</button>
                        </div>
                        <div class="d-flex align-items-center mb-1">
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
                </div>
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
                        <tr class="user-row" data-role="{{ user.role_type }}" data-name="{{ user.lastname|lower }}, {{ user.firstname|lower }}">
                            <td>
                                <input type="checkbox" name="user_ids[]" value="{{ user.id }}" class="user-checkbox">
                            </td>
                            <td>{{ user.lastname }}, {{ user.firstname }}</td>
                            <td>
                                {% if user.role_type == 'teacher' %}
                                    <span class="badge badge-primary">{{ user.role_label }}</span>
                                {% elseif user.role_type == 'secretary' %}
                                    <span class="badge badge-info">{{ user.role_label }}</span>
                                {% elseif user.role_type == 'auxiliary' %}
                                    <span class="badge badge-info">{{ user.role_label }}</span>
                                {% elseif user.role_type == 'admin' %}
                                    <span class="badge badge-dark">{{ user.role_label }}</span>
                                {% elseif user.role_type == 'family' %}
                                    <span class="badge badge-warning">{{ user.role_label }}</span>
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

<script>
var ajaxUrl = '{{ ajax_url }}';
var currentFilter = 'all';
var currentSearch = '';

function applyFilters() {
    var rows = document.querySelectorAll('.user-row');
    rows.forEach(function(row) {
        var matchesRole = (currentFilter === 'all' || row.getAttribute('data-role') === currentFilter);
        var matchesSearch = true;
        if (currentSearch.length > 0) {
            var name = row.getAttribute('data-name');
            matchesSearch = name.indexOf(currentSearch) !== -1;
        }
        row.style.display = (matchesRole && matchesSearch) ? '' : 'none';
    });
}

// Search by name
document.getElementById('searchUser').addEventListener('input', function() {
    currentSearch = this.value.toLowerCase().trim();
    applyFilters();
});

// Select all checkbox
document.getElementById('selectAll').addEventListener('change', function() {
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
        currentFilter = this.getAttribute('data-filter');
        applyFilters();
    });
});

// Register selected users with chosen status
document.getElementById('btnRegisterSelected').addEventListener('click', function() {
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
                    window.location.reload();
                } else {
                    alert(data.message || 'Error');
                }
            });
    });
});
</script>
