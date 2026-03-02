{% include 'attendance/tabs.tpl' %}

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
                        <th>{{ 'Level'|get_plugin_lang('SchoolPlugin') }} / {{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</th>
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
                            {% set roles = schedule.applies_to|split(',') %}
                            {% set labels = [] %}
                            {% for role in roles %}
                                {% if role == 'all' %}
                                    {% set labels = labels|merge([('AllUsers'|get_plugin_lang('SchoolPlugin'))]) %}
                                {% elseif role == 'teacher' %}
                                    {% set labels = labels|merge([('RoleTeacher'|get_plugin_lang('SchoolPlugin'))]) %}
                                {% elseif role == 'student' %}
                                    {% set labels = labels|merge([('RoleStudent'|get_plugin_lang('SchoolPlugin'))]) %}
                                {% elseif role == 'parent' %}
                                    {% set labels = labels|merge([('RoleParent'|get_plugin_lang('SchoolPlugin'))]) %}
                                {% elseif role == 'auxiliary' %}
                                    {% set labels = labels|merge([('RoleAuxiliary'|get_plugin_lang('SchoolPlugin'))]) %}
                                {% elseif role == 'secretary' %}
                                    {% set labels = labels|merge([('RoleSecretary'|get_plugin_lang('SchoolPlugin'))]) %}
                                {% elseif role == 'staff' %}
                                    {% set labels = labels|merge([('Staff'|get_plugin_lang('SchoolPlugin'))]) %}
                                {% elseif role == 'students' %}
                                    {% set labels = labels|merge([('Students'|get_plugin_lang('SchoolPlugin'))]) %}
                                {% endif %}
                            {% endfor %}
                            {{ labels|join(', ') }}
                        </td>
                        <td>
                            {% if schedule.level_name %}
                                {{ schedule.level_name }}{% if schedule.grade_name %} / {{ schedule.grade_name }}{% endif %}
                            {% else %}
                                <span class="text-muted">—</span>
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
                                    data-level-id="{{ schedule.level_id }}"
                                    data-grade-id="{{ schedule.grade_id }}"
                                    data-active="{{ schedule.active }}">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-info btn-schedule-users"
                                    data-id="{{ schedule.id }}"
                                    data-name="{{ schedule.name }}"
                                    title="{{ 'ScheduleUsers'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-users"></i>
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
                        <input type="text" class="form-control" id="schedule_name" name="name" required placeholder="Ej: Turno Ma&ntilde;ana">
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
                        <select class="form-control" id="schedule_applies_to" name="applies_to[]" multiple size="6">
                            <option value="all">{{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="teacher">{{ 'RoleTeacher'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="student">{{ 'RoleStudent'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="parent">{{ 'RoleParent'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="auxiliary">{{ 'RoleAuxiliary'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="secretary">{{ 'RoleSecretary'|get_plugin_lang('SchoolPlugin') }}</option>
                        </select>
                        <small class="form-text text-muted">{{ 'HoldCtrlToSelectMultiple'|get_plugin_lang('SchoolPlugin') }}</small>
                    </div>

                    <!-- Level/Grade fields (shown when student is selected) -->
                    <div id="levelGradeFields" style="display:none;">
                        <div class="form-group">
                            <label>{{ 'ScheduleLevel'|get_plugin_lang('SchoolPlugin') }}</label>
                            <select class="form-control" id="schedule_level_id" name="level_id">
                                <option value="">{{ 'AllLevels'|get_plugin_lang('SchoolPlugin') }}</option>
                                {% for level in levels %}
                                <option value="{{ level.id }}">{{ level.name }}</option>
                                {% endfor %}
                            </select>
                        </div>
                        <div class="form-group" id="gradeFieldWrapper" style="display:none;">
                            <label>{{ 'ScheduleGrade'|get_plugin_lang('SchoolPlugin') }}</label>
                            <select class="form-control" id="schedule_grade_id" name="grade_id">
                                <option value="">{{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }}</option>
                            </select>
                        </div>
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

<!-- Modal: Users assigned to schedule -->
<div class="modal fade" id="scheduleUsersModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fas fa-users"></i>
                    {{ 'ScheduleUsers'|get_plugin_lang('SchoolPlugin') }}:
                    <span id="suModalScheduleName"></span>
                </h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p class="text-muted small mb-3">{{ 'ScheduleUsersHint'|get_plugin_lang('SchoolPlugin') }}</p>

                <!-- Search -->
                <div class="input-group mb-3">
                    <input type="text" id="suSearchInput" class="form-control" placeholder="{{ 'SearchUserPlaceholder'|get_plugin_lang('SchoolPlugin') }}">
                    <div class="input-group-append">
                        <button class="btn btn-outline-secondary" id="suSearchBtn" type="button">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
                <div id="suSearchResults" class="list-group mb-3" style="max-height:180px;overflow-y:auto;display:none;"></div>

                <hr>
                <!-- Assigned users list -->
                <h6>{{ 'AssignedUsers'|get_plugin_lang('SchoolPlugin') }}</h6>
                <div id="suAssignedList">
                    <p class="text-muted">{{ 'NoAssignedUsers'|get_plugin_lang('SchoolPlugin') }}</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';

// Grades data indexed by level_id
var gradesByLevel = {};
{% for grade in grades %}
if (!gradesByLevel[{{ grade.level_id }}]) gradesByLevel[{{ grade.level_id }}] = [];
gradesByLevel[{{ grade.level_id }}].push({id: {{ grade.id }}, name: '{{ grade.name|e('js') }}'});
{% endfor %}

function hasStudentRole() {
    var sel = document.getElementById('schedule_applies_to');
    return Array.from(sel.selectedOptions).some(function(o) {
        return o.value === 'student' || o.value === 'all';
    });
}

function toggleLevelGradeFields() {
    var show = hasStudentRole();
    document.getElementById('levelGradeFields').style.display = show ? '' : 'none';
    if (!show) {
        document.getElementById('schedule_level_id').value = '';
        document.getElementById('schedule_grade_id').value = '';
        document.getElementById('gradeFieldWrapper').style.display = 'none';
    }
}

function updateGradeSelect(selectedGradeId) {
    var levelId = parseInt(document.getElementById('schedule_level_id').value);
    var gradeSelect = document.getElementById('schedule_grade_id');
    var wrapper = document.getElementById('gradeFieldWrapper');

    // Clear
    gradeSelect.innerHTML = '<option value="">{{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }}</option>';

    if (!levelId || !gradesByLevel[levelId] || gradesByLevel[levelId].length === 0) {
        wrapper.style.display = 'none';
        return;
    }

    gradesByLevel[levelId].forEach(function(g) {
        var opt = document.createElement('option');
        opt.value = g.id;
        opt.textContent = g.name;
        if (selectedGradeId && parseInt(selectedGradeId) === g.id) opt.selected = true;
        gradeSelect.appendChild(opt);
    });
    wrapper.style.display = '';
}

document.getElementById('schedule_applies_to').addEventListener('change', toggleLevelGradeFields);
document.getElementById('schedule_level_id').addEventListener('change', function() {
    updateGradeSelect(null);
});

// Save schedule
document.getElementById('btnSaveSchedule').addEventListener('click', function() {
    var formData = new FormData();
    formData.append('action', 'save_schedule');
    formData.append('id', document.getElementById('schedule_id').value);
    formData.append('name', document.getElementById('schedule_name').value);
    formData.append('entry_time', document.getElementById('schedule_entry_time').value);
    formData.append('late_time', document.getElementById('schedule_late_time').value);
    var appliesSelect = document.getElementById('schedule_applies_to');
    var selectedRoles = Array.from(appliesSelect.selectedOptions).map(function(opt) { return opt.value; });
    selectedRoles.forEach(function(role) {
        formData.append('applies_to[]', role);
    });
    formData.append('level_id', document.getElementById('schedule_level_id').value);
    formData.append('grade_id', document.getElementById('schedule_grade_id').value);
    formData.append('active', document.getElementById('schedule_active').checked ? 1 : 0);

    if (!document.getElementById('schedule_name').value || !document.getElementById('schedule_entry_time').value || !document.getElementById('schedule_late_time').value) {
        alert('Complete todos los campos obligatorios');
        return;
    }

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

// Edit schedule
document.querySelectorAll('.btn-edit-schedule').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.getElementById('schedule_id').value = this.getAttribute('data-id');
        document.getElementById('schedule_name').value = this.getAttribute('data-name');
        document.getElementById('schedule_entry_time').value = this.getAttribute('data-entry-time');
        document.getElementById('schedule_late_time').value = this.getAttribute('data-late-time');
        var appliesValues = this.getAttribute('data-applies-to').split(',');
        var appliesSelect = document.getElementById('schedule_applies_to');
        Array.from(appliesSelect.options).forEach(function(opt) {
            opt.selected = appliesValues.indexOf(opt.value) !== -1;
        });
        document.getElementById('schedule_active').checked = this.getAttribute('data-active') == '1';
        document.getElementById('scheduleModalTitle').textContent = '{{ 'EditSchedule'|get_plugin_lang('SchoolPlugin') }}';

        // Level/grade
        toggleLevelGradeFields();
        var levelId = this.getAttribute('data-level-id') || '';
        var gradeId = this.getAttribute('data-grade-id') || '';
        document.getElementById('schedule_level_id').value = levelId;
        updateGradeSelect(gradeId);

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
                    window.location.reload();
                }
            });
    });
});

function clearScheduleForm() {
    document.getElementById('schedule_id').value = '';
    document.getElementById('schedule_name').value = '';
    document.getElementById('schedule_entry_time').value = '';
    document.getElementById('schedule_late_time').value = '';
    var appliesSelect = document.getElementById('schedule_applies_to');
    Array.from(appliesSelect.options).forEach(function(opt) {
        opt.selected = opt.value === 'all';
    });
    document.getElementById('schedule_level_id').value = '';
    document.getElementById('schedule_grade_id').innerHTML = '<option value="">{{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }}</option>';
    document.getElementById('gradeFieldWrapper').style.display = 'none';
    document.getElementById('schedule_active').checked = true;
    document.getElementById('scheduleModalTitle').textContent = '{{ 'AddSchedule'|get_plugin_lang('SchoolPlugin') }}';
    toggleLevelGradeFields();
}

// ──────────────────────────────────────────────
// Users modal
// ──────────────────────────────────────────────
var suCurrentScheduleId = 0;

function suRenderAssigned(users) {
    var container = document.getElementById('suAssignedList');
    if (!users || users.length === 0) {
        container.innerHTML = '<p class="text-muted small">{{ 'NoAssignedUsers'|get_plugin_lang('SchoolPlugin') }}</p>';
        return;
    }
    var html = '<ul class="list-group">';
    users.forEach(function(u) {
        html += '<li class="list-group-item d-flex justify-content-between align-items-center py-1">'
            + '<span><strong>' + escHtml(u.lastname + ', ' + u.firstname) + '</strong>'
            + ' <small class="text-muted">(' + escHtml(u.username) + ')</small></span>'
            + '<button class="btn btn-sm btn-outline-danger su-remove-btn" data-uid="' + u.id + '">'
            + '<i class="fas fa-times"></i></button>'
            + '</li>';
    });
    html += '</ul>';
    container.innerHTML = html;
    container.querySelectorAll('.su-remove-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var uid = parseInt(this.getAttribute('data-uid'));
            var fd = new FormData();
            fd.append('action', 'remove_user_schedule');
            fd.append('user_id', uid);
            fetch(ajaxUrl, { method: 'POST', body: fd })
                .then(function(r) { return r.json(); })
                .then(function(d) { if (d.success) suLoadAssigned(); });
        });
    });
}

function suLoadAssigned() {
    fetch(ajaxUrl + '?action=get_schedule_users&schedule_id=' + suCurrentScheduleId)
        .then(function(r) { return r.json(); })
        .then(function(d) { if (d.success) suRenderAssigned(d.data); });
}

function escHtml(str) {
    var d = document.createElement('div');
    d.appendChild(document.createTextNode(str || ''));
    return d.innerHTML;
}

document.querySelectorAll('.btn-schedule-users').forEach(function(btn) {
    btn.addEventListener('click', function() {
        suCurrentScheduleId = parseInt(this.getAttribute('data-id'));
        document.getElementById('suModalScheduleName').textContent = this.getAttribute('data-name');
        document.getElementById('suSearchInput').value = '';
        document.getElementById('suSearchResults').innerHTML = '';
        document.getElementById('suSearchResults').style.display = 'none';
        suLoadAssigned();
        $('#scheduleUsersModal').modal('show');
    });
});

function suDoSearch() {
    var q = document.getElementById('suSearchInput').value.trim();
    if (q.length < 2) return;
    fetch(ajaxUrl + '?action=search_users_for_schedule&q=' + encodeURIComponent(q))
        .then(function(r) { return r.json(); })
        .then(function(d) {
            var container = document.getElementById('suSearchResults');
            if (!d.success || !d.data.length) {
                container.innerHTML = '<div class="list-group-item text-muted small">{{ 'NoUsersFound'|get_plugin_lang('SchoolPlugin') }}</div>';
                container.style.display = '';
                return;
            }
            var html = '';
            d.data.forEach(function(u) {
                html += '<button type="button" class="list-group-item list-group-item-action py-1 su-add-user-btn" data-uid="' + u.id + '">'
                    + escHtml(u.lastname + ', ' + u.firstname)
                    + ' <small class="text-muted">(' + escHtml(u.username) + ')</small>'
                    + '</button>';
            });
            container.innerHTML = html;
            container.style.display = '';
            container.querySelectorAll('.su-add-user-btn').forEach(function(item) {
                item.addEventListener('click', function() {
                    var uid = parseInt(this.getAttribute('data-uid'));
                    var fd = new FormData();
                    fd.append('action', 'assign_user_schedule');
                    fd.append('user_id', uid);
                    fd.append('schedule_id', suCurrentScheduleId);
                    fetch(ajaxUrl, { method: 'POST', body: fd })
                        .then(function(r) { return r.json(); })
                        .then(function(d2) {
                            if (d2.success) {
                                document.getElementById('suSearchInput').value = '';
                                container.innerHTML = '';
                                container.style.display = 'none';
                                suLoadAssigned();
                            }
                        });
                });
            });
        });
}

document.getElementById('suSearchBtn').addEventListener('click', suDoSearch);
document.getElementById('suSearchInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') { e.preventDefault(); suDoSearch(); }
});
</script>
