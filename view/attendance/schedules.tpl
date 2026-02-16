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
    document.getElementById('schedule_active').checked = true;
    document.getElementById('scheduleModalTitle').textContent = '{{ 'AddSchedule'|get_plugin_lang('SchoolPlugin') }}';
}
</script>
