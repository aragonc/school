{% include 'attendance/tabs.tpl' %}

<div class="card">
    <div class="card-header">
        <i class="fas fa-user-graduate"></i> {{ 'AttendanceStudents'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body">

        <!-- Filtros Nivel / Grado / Sección -->
        <form method="get" class="mb-3" id="filterForm">
            <div class="row align-items-end">
                <div class="col-md-3 mb-2">
                    <label class="small font-weight-bold mb-1">{{ 'Level'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select class="form-control form-control-sm" id="filterLevel" name="level_id" onchange="cascadeGrades()">
                        <option value="">— {{ 'AllLevels'|get_plugin_lang('SchoolPlugin') }} —</option>
                        {% for lv in levels %}
                        <option value="{{ lv.id }}" {{ filter_level_id == lv.id ? 'selected' : '' }}>{{ lv.name }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="col-md-3 mb-2">
                    <label class="small font-weight-bold mb-1">{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select class="form-control form-control-sm" id="filterGrade" name="grade_id" onchange="cascadeSections()">
                        <option value="">— {{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }} —</option>
                        {% for gr in grades %}
                        <option value="{{ gr.id }}" data-level="{{ gr.level_id }}" {{ filter_grade_id == gr.id ? 'selected' : '' }}>{{ gr.name }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="col-md-2 mb-2">
                    <label class="small font-weight-bold mb-1">{{ 'Section'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select class="form-control form-control-sm" id="filterSection" name="section_id">
                        <option value="">— {{ 'AllSections'|get_plugin_lang('SchoolPlugin') }} —</option>
                        {% for sec in sections %}
                        <option value="{{ sec.id }}" {{ filter_section_id == sec.id ? 'selected' : '' }}>{{ sec.name }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="col-md-2 mb-2">
                    <button type="submit" class="btn btn-primary btn-sm btn-block">
                        <i class="fas fa-filter mr-1"></i>{{ 'Filter'|get_plugin_lang('SchoolPlugin') }}
                    </button>
                </div>
                <div class="col-md-2 mb-2">
                    <input type="text" class="form-control form-control-sm" id="searchStudent" placeholder="{{ 'SearchByName'|get_plugin_lang('SchoolPlugin') }}">
                </div>
            </div>
        </form>

        <!-- Acciones masivas -->
        <div class="d-flex align-items-center mb-3 flex-wrap" style="gap:8px;">
            <select id="bulkStatus" class="form-control form-control-sm" style="width:auto;">
                <option value="on_time">{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="late">{{ 'Late'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="absent">{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}</option>
            </select>
            <button type="button" class="btn btn-primary btn-sm" id="btnRegisterSelected">
                <i class="fas fa-check-double"></i> {{ 'RegisterSelected'|get_plugin_lang('SchoolPlugin') }}
            </button>
            <span class="text-muted small ml-2" id="selectedCount"></span>
        </div>

        <form id="manualStudentsForm">
            <div class="table-responsive">
                <table class="table table-striped table-hover table-sm" id="studentsTable">
                    <thead class="thead-light">
                        <tr>
                            <th style="width:36px;">
                                <input type="checkbox" id="selectAll">
                            </th>
                            <th>{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>DNI</th>
                            <th>{{ 'Level'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Section'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for st in students %}
                        <tr class="student-row"
                            data-name="{{ st.lastname|lower }}, {{ st.firstname|lower }}"
                            data-level="{{ st.level_id }}"
                            data-grade="{{ st.grade_id }}"
                            data-section="{{ st.section_id }}">
                            <td>
                                <input type="checkbox" name="user_ids[]" value="{{ st.id }}" class="user-checkbox">
                            </td>
                            <td>{{ st.lastname }}, {{ st.firstname }}</td>
                            <td>
                                <code class="text-dark">{{ st.dni_display }}</code>
                            </td>
                            <td><span class="badge badge-secondary">{{ st.level_name }}</span></td>
                            <td>{{ st.grade_name }}</td>
                            <td>{{ st.section_name }}</td>
                            <td>
                                {% if st.attendance_id %}
                                    {% if st.attendance_status == 'on_time' %}
                                        <span class="badge badge-success">{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }} ({{ st.check_in|date('H:i') }})</span>
                                    {% elseif st.attendance_status == 'late' %}
                                        <span class="badge badge-warning">{{ 'Late'|get_plugin_lang('SchoolPlugin') }} ({{ st.check_in|date('H:i') }})</span>
                                    {% else %}
                                        <span class="badge badge-danger">{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% endif %}
                                {% else %}
                                    <span class="badge badge-light">{{ 'NotRegistered'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% endif %}
                            </td>
                            <td>
                                <div class="btn-group btn-group-sm" role="group">
                                    <button type="button" class="btn btn-success btn-mark-single" data-user-id="{{ st.id }}" data-status="on_time" title="{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }}">
                                        <i class="fas fa-check"></i>
                                    </button>
                                    <button type="button" class="btn btn-warning btn-mark-single" data-user-id="{{ st.id }}" data-status="late" title="{{ 'Late'|get_plugin_lang('SchoolPlugin') }}">
                                        <i class="fas fa-clock"></i>
                                    </button>
                                    <button type="button" class="btn btn-danger btn-mark-single" data-user-id="{{ st.id }}" data-status="absent" title="{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}">
                                        <i class="fas fa-times"></i>
                                    </button>
                                    {% if st.attendance_id %}
                                    <button type="button" class="btn btn-outline-danger btn-delete-attendance"
                                            data-attendance-id="{{ st.attendance_id }}"
                                            data-user-name="{{ st.lastname }}, {{ st.firstname }}"
                                            title="{{ 'DeleteAttendance'|get_plugin_lang('SchoolPlugin') }}">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                    {% endif %}
                                </div>
                            </td>
                        </tr>
                        {% else %}
                        <tr><td colspan="8" class="text-center text-muted py-3">{{ 'NoStudentsFound'|get_plugin_lang('SchoolPlugin') }}</td></tr>
                        {% endfor %}
                    </tbody>
                </table>
            </div>
        </form>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';

// All grades/sections data for cascade
var allGrades   = {{ grades|json_encode }};
var allSections = {{ sections|json_encode }};

function cascadeGrades() {
    var levelId = document.getElementById('filterLevel').value;
    var gradeEl = document.getElementById('filterGrade');
    var currentGrade = gradeEl.value;
    gradeEl.innerHTML = '<option value="">— {{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }} —</option>';
    allGrades.forEach(function(g) {
        if (!levelId || String(g.level_id) === String(levelId)) {
            var opt = document.createElement('option');
            opt.value = g.id;
            opt.text  = g.name;
            opt.setAttribute('data-level', g.level_id);
            if (String(g.id) === String(currentGrade)) opt.selected = true;
            gradeEl.appendChild(opt);
        }
    });
    cascadeSections();
}

function cascadeSections() {
    // Section filter is not linked to grade in current data, keep all visible
}

// Search by name (client-side)
document.getElementById('searchStudent').addEventListener('input', function() {
    var q = this.value.toLowerCase().trim();
    document.querySelectorAll('.student-row').forEach(function(row) {
        var name = row.getAttribute('data-name');
        row.style.display = (!q || name.indexOf(q) !== -1) ? '' : 'none';
    });
    updateSelectedCount();
});

// Select all
document.getElementById('selectAll').addEventListener('change', function() {
    var checked = this.checked;
    document.querySelectorAll('.student-row').forEach(function(row) {
        if (row.style.display !== 'none') {
            row.querySelector('.user-checkbox').checked = checked;
        }
    });
    updateSelectedCount();
});

document.querySelectorAll('.user-checkbox').forEach(function(cb) {
    cb.addEventListener('change', updateSelectedCount);
});

function updateSelectedCount() {
    var n = document.querySelectorAll('.user-checkbox:checked').length;
    document.getElementById('selectedCount').textContent = n > 0 ? n + ' seleccionados' : '';
}

// Bulk register
document.getElementById('btnRegisterSelected').addEventListener('click', function() {
    var selected = Array.from(document.querySelectorAll('.user-checkbox:checked')).map(function(cb){ return cb.value; });
    if (selected.length === 0) { alert('Seleccione al menos un alumno'); return; }
    var status = document.getElementById('bulkStatus').value;
    var fd = new FormData();
    fd.append('action', 'mark_attendance');
    fd.append('status', status);
    selected.forEach(function(uid){ fd.append('user_ids[]', uid); });
    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r){ return r.json(); })
        .then(function(d){ if (d.success) location.reload(); else alert(d.message || 'Error'); });
});

// Individual mark
document.querySelectorAll('.btn-mark-single').forEach(function(btn) {
    btn.addEventListener('click', function() {
        var userId = this.getAttribute('data-user-id');
        var status = this.getAttribute('data-status');
        var fd = new FormData();
        fd.append('action', 'mark_attendance');
        fd.append('user_id', userId);
        fd.append('status', status);
        fetch(ajaxUrl, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(d){ if (d.success) location.reload(); else alert(d.message || 'Error'); });
    });
});

// Delete attendance
document.querySelectorAll('.btn-delete-attendance').forEach(function(btn) {
    btn.addEventListener('click', function() {
        var attendanceId = this.getAttribute('data-attendance-id');
        var userName     = this.getAttribute('data-user-name');
        if (!confirm('{{ 'ConfirmDeleteAttendance'|get_plugin_lang('SchoolPlugin') }}\n' + userName)) return;
        var fd = new FormData();
        fd.append('action', 'delete_attendance');
        fd.append('attendance_id', attendanceId);
        fetch(ajaxUrl, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(d){ if (d.success) location.reload(); else alert(d.message || 'Error'); });
    });
});

// Init cascade on load
cascadeGrades();
</script>
