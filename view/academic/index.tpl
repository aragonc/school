{% include 'academic/tabs.tpl' with {'active_tab': 'classrooms', 'is_admin': is_admin} %}

<!-- Year selector + Create classroom button -->
<div class="card mb-4">
    <div class="card-body py-2 d-flex justify-content-between align-items-center">
        <form method="get" class="form-inline">
            <label class="mr-2"><strong>{{ 'AcademicYear'|get_plugin_lang('SchoolPlugin') }}:</strong></label>
            <select name="year_id" class="form-control form-control-sm mr-2" onchange="this.form.submit()">
                {% for y in years %}
                <option value="{{ y.id }}" {{ year_id == y.id ? 'selected' : '' }}>
                    {{ y.name }} {{ y.active ? '' : '(Inactivo)' }}
                </option>
                {% endfor %}
            </select>
        </form>
        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#classroomModal" onclick="resetClassroomForm()">
            <i class="fas fa-plus"></i> {{ 'AddClassroom'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
</div>

{% if years|length == 0 %}
<div class="alert alert-warning">
    <i class="fas fa-exclamation-triangle"></i> {{ 'NoAcademicYears'|get_plugin_lang('SchoolPlugin') }}
    {% if is_admin %}
    <a href="{{ _p.web }}academic/settings" class="btn btn-sm btn-outline-primary ml-2">
        <i class="fas fa-cogs"></i> {{ 'AcademicSettings'|get_plugin_lang('SchoolPlugin') }}
    </a>
    {% endif %}
</div>
{% elseif classrooms_by_level|length == 0 %}
<div class="alert alert-info">
    <i class="fas fa-info-circle"></i> {{ 'NoClassrooms'|get_plugin_lang('SchoolPlugin') }}
</div>
{% else %}
    {% for levelName, classrooms in classrooms_by_level %}
    <div class="card mb-4">
        <div class="card-header">
            <i class="fas fa-layer-group"></i> <strong>{{ levelName }}</strong>
            <span class="badge badge-secondary ml-2">{{ classrooms|length }} {{ 'Classrooms'|get_plugin_lang('SchoolPlugin')|lower }}</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover table-sm mb-0">
                    <thead class="thead-light">
                        <tr>
                            <th>{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Section'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Tutor'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th class="text-center">{{ 'Students'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th class="text-center">{{ 'Capacity'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th class="text-center">{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for c in classrooms %}
                        <tr>
                            <td><strong>{{ c.grade_name }}</strong></td>
                            <td><span class="badge badge-primary">{{ c.section_name }}</span></td>
                            <td>
                                {% if c.tutor_name %}
                                    <i class="fas fa-user-tie text-muted"></i> {{ c.tutor_name }}
                                {% else %}
                                    <span class="text-muted">{{ 'NoTutor'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% endif %}
                            </td>
                            <td class="text-center">
                                <span class="badge {% if c.student_count >= c.capacity %}badge-danger{% elseif c.student_count > 0 %}badge-success{% else %}badge-secondary{% endif %}">
                                    {{ c.student_count }}
                                </span>
                            </td>
                            <td class="text-center">{{ c.capacity }}</td>
                            <td class="text-center">
                                <a href="{{ _p.web }}academic/classroom?id={{ c.id }}" class="btn btn-info btn-sm" title="{{ 'ViewClassroom'|get_plugin_lang('SchoolPlugin') }}">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <button class="btn btn-warning btn-sm" onclick="editClassroom({{ c|json_encode|e('html_attr') }})" title="{{ 'Edit'|get_plugin_lang('SchoolPlugin') }}">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-danger btn-sm" onclick="deleteClassroom({{ c.id }})" title="{{ 'Delete'|get_plugin_lang('SchoolPlugin') }}">
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
    {% endfor %}
{% endif %}

<!-- Classroom Modal -->
<div class="modal fade" id="classroomModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="classroomModalTitle">{{ 'AddClassroom'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <form id="classroomForm">
                    <input type="hidden" name="id" id="classroom_id" value="0">
                    <div class="form-group">
                        <label>{{ 'Grade'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <select class="form-control" id="classroom_grade" required>
                            <option value="">{{ 'SelectOption'|get_plugin_lang('SchoolPlugin') }}</option>
                            {% for g in grades %}
                            <option value="{{ g.id }}" data-level="{{ g.level_name }}">{{ g.level_name }} - {{ g.name }}</option>
                            {% endfor %}
                        </select>
                    </div>
                    <div class="form-group">
                        <label>{{ 'Section'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <select class="form-control" id="classroom_section" required>
                            <option value="">{{ 'SelectOption'|get_plugin_lang('SchoolPlugin') }}</option>
                            {% for s in sections %}
                            <option value="{{ s.id }}">{{ s.name }}</option>
                            {% endfor %}
                        </select>
                    </div>
                    <div class="form-group">
                        <label>{{ 'Tutor'|get_plugin_lang('SchoolPlugin') }}</label>
                        <select id="classroom_tutor" style="width:100%">
                            <option value="">{{ 'NoTutor'|get_plugin_lang('SchoolPlugin') }}</option>
                            {% for t in teachers %}
                            <option value="{{ t.user_id }}">{{ t.lastname }}, {{ t.firstname }}</option>
                            {% endfor %}
                        </select>
                    </div>
                    <div class="form-group">
                        <label>{{ 'Capacity'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="number" class="form-control" id="classroom_capacity" value="30" min="1" max="100">
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveClassroom()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';
var yearId = {{ year_id }};

// Inicializa Select2 en el tutor al abrir el modal (solo una vez)
$('#classroomModal').on('shown.bs.modal', function() {
    if (!$('#classroom_tutor').hasClass('select2-hidden-accessible')) {
        $('#classroom_tutor').select2({
            dropdownParent: $('#classroomModal'),
            allowClear: true,
            placeholder: '{{ 'NoTutor'|get_plugin_lang('SchoolPlugin') }}',
            width: '100%'
        });
    }
});

function resetClassroomForm() {
    document.getElementById('classroomModalTitle').textContent = '{{ 'AddClassroom'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('classroom_id').value = 0;
    document.getElementById('classroom_grade').value = '';
    document.getElementById('classroom_section').value = '';
    $('#classroom_tutor').val(null).trigger('change');
    document.getElementById('classroom_capacity').value = 30;
}

function editClassroom(c) {
    document.getElementById('classroomModalTitle').textContent = '{{ 'EditClassroom'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('classroom_id').value = c.id;
    document.getElementById('classroom_grade').value = c.grade_id;
    document.getElementById('classroom_section').value = c.section_id;
    document.getElementById('classroom_capacity').value = c.capacity;
    // Asigna el valor de tutor después de que Select2 esté inicializado
    $('#classroomModal').one('shown.bs.modal', function() {
        $('#classroom_tutor').val(c.tutor_id || null).trigger('change');
    });
    $('#classroomModal').modal('show');
}

function saveClassroom() {
    var gradeId = document.getElementById('classroom_grade').value;
    var sectionId = document.getElementById('classroom_section').value;
    if (!gradeId || !sectionId) {
        alert('{{ 'SelectGradeAndSection'|get_plugin_lang('SchoolPlugin') }}');
        return;
    }

    var formData = new FormData();
    formData.append('action', 'save_classroom');
    formData.append('id', document.getElementById('classroom_id').value);
    formData.append('academic_year_id', yearId);
    formData.append('grade_id', gradeId);
    formData.append('section_id', sectionId);
    formData.append('tutor_id', document.getElementById('classroom_tutor').value);
    formData.append('capacity', document.getElementById('classroom_capacity').value);

    fetch(ajaxUrl, { method: 'POST', body: formData })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                location.reload();
            } else {
                alert(data.message || 'Error');
            }
        });
}

function deleteClassroom(id) {
    if (!confirm('{{ 'ConfirmDeleteClassroom'|get_plugin_lang('SchoolPlugin') }}')) return;

    var formData = new FormData();
    formData.append('action', 'delete_classroom');
    formData.append('id', id);

    fetch(ajaxUrl, { method: 'POST', body: formData })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                location.reload();
            }
        });
}
</script>
