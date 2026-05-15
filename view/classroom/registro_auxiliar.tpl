<div class="container-fluid px-4 py-4">

    {# Header #}
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap" style="gap:10px;">
        <div>
            <h4 class="mb-1 font-weight-bold text-dark">
                <i class="fas fa-clipboard-list text-primary mr-2"></i>Registro Auxiliar de Evaluación
            </h4>
            {% if active_year %}
            <p class="mb-0 text-muted small">Año académico {{ active_year.year }}</p>
            {% endif %}
        </div>
        {% if teacher_courses %}
        <button class="btn btn-primary btn-sm" onclick="openCreateModal()">
            <i class="fas fa-plus mr-1"></i> Nuevo Registro
        </button>
        {% endif %}
    </div>

    {# List #}
    {% if registros %}
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-header bg-white py-3">
            <h6 class="m-0 font-weight-bold text-primary">Mis Registros</h6>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead class="thead-light">
                        <tr>
                            <th>Nivel / Grado / Sección</th>
                            <th>Curso</th>
                            <th>Área Curricular</th>
                            <th>Período</th>
                            <th>Tipo de nota</th>
                            <th class="text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for reg in registros %}
                        <tr>
                            <td>
                                <span class="font-weight-bold">{{ reg.classroom_label }}</span>
                            </td>
                            <td>{{ reg.course_title }}</td>
                            <td>{{ reg.area_name ?: '—' }}</td>
                            <td><span class="badge badge-secondary">{{ reg.period }}</span></td>
                            <td>
                                {% if reg.grade_type == 'numeric' %}
                                    <span class="badge badge-info">Numérica (0–20)</span>
                                {% elseif reg.grade_type == 'letter' %}
                                    <span class="badge badge-success">Literal (AD/A/B/C)</span>
                                {% else %}
                                    <span class="badge badge-warning">Combinada</span>
                                {% endif %}
                            </td>
                            <td class="text-center">
                                <a href="/my-aula/registro/notas?id={{ reg.id }}"
                                   class="btn btn-sm btn-primary" title="Ver notas">
                                    <i class="fas fa-table"></i> Notas
                                </a>
                                <button class="btn btn-sm btn-danger ml-1"
                                        onclick="confirmDelete({{ reg.id }}, '{{ reg.course_title|e('js') }} – {{ reg.period|e('js') }}')"
                                        title="Eliminar">
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
    {% else %}
    <div class="card shadow-sm border-0">
        <div class="card-body text-center py-5">
            <i class="fas fa-clipboard fa-3x text-muted mb-3"></i>
            <p class="text-muted mb-0">No tienes registros auxiliares aún.</p>
            {% if teacher_courses %}
            <button class="btn btn-primary mt-3" onclick="openCreateModal()">
                <i class="fas fa-plus mr-1"></i> Crear primer registro
            </button>
            {% else %}
            <p class="text-muted small mt-2">No tienes cursos asignados en el año académico activo.</p>
            {% endif %}
        </div>
    </div>
    {% endif %}

</div>

{# ===== Modal: Crear Registro ===== #}
<div class="modal fade" id="modalCreate" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title"><i class="fas fa-plus-circle mr-2"></i>Nuevo Registro Auxiliar</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <form id="formCreate">
                    {% if active_year %}
                    <div class="alert alert-info py-2 mb-3 d-flex align-items-center" style="font-size:0.92em;">
                        <i class="fas fa-calendar-alt mr-2"></i>
                        Este registro se creará para el año académico <strong class="ml-1">{{ active_year.year }}</strong>.
                    </div>
                    {% endif %}
                    <div class="form-group">
                        <label class="font-weight-bold">Curso asignado <span class="text-danger">*</span></label>
                        <select id="selCourse" name="classroom_course_id" class="form-control" required>
                            <option value="">— Selecciona un curso —</option>
                            {% for tc in teacher_courses %}
                            <option value="{{ tc.classroom_course_id }}">
                                {{ tc.classroom_label }} — {{ tc.course_title }}
                            </option>
                            {% endfor %}
                        </select>
                    </div>
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label class="font-weight-bold">Período / Bimestre <span class="text-danger">*</span></label>
                            <select id="selPeriod" name="period" class="form-control" required>
                                <option value="">— Selecciona —</option>
                                {% for p in periods %}
                                <option value="{{ p.name }}">
                                    {{ p.name }}{% if p.date_start %} ({{ p.date_start }} – {{ p.date_end }}){% endif %}
                                </option>
                                {% endfor %}
                            </select>
                            {% if is_admin %}
                            <small class="form-text text-muted">
                                <a href="/academic/periods" target="_blank">
                                    <i class="fas fa-cog mr-1"></i>Gestionar períodos
                                </a>
                            </small>
                            {% endif %}
                        </div>
                        <div class="form-group col-md-6">
                            <label class="font-weight-bold">Tipo de nota <span class="text-danger">*</span></label>
                            <select id="selGradeType" name="grade_type" class="form-control">
                                <option value="letter">Literal — AD / A / B / C</option>
                                <option value="numeric">Numérica — 0 al 20</option>
                                <option value="combined">Combinada</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="font-weight-bold">Área Curricular</label>
                        <select id="selArea" name="area_id" class="form-control">
                            <option value="0">— Sin área específica —</option>
                            {% for area in areas %}
                            <option value="{{ area.id }}">{{ area.name }}</option>
                            {% endfor %}
                        </select>
                        <small class="form-text text-muted">Selecciona el área para pre-cargar competencias y capacidades al editar.</small>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnCreateSave" onclick="saveCreate()">
                    <i class="fas fa-save mr-1"></i> Crear Registro
                </button>
            </div>
        </div>
    </div>
</div>

{# ===== Modal: Confirmar Eliminar ===== #}
<div class="modal fade" id="modalDelete" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="fas fa-exclamation-triangle mr-2"></i>Eliminar Registro</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>¿Estás seguro de eliminar el registro <strong id="deleteLabel"></strong>?</p>
                <p class="text-danger small"><i class="fas fa-exclamation-circle mr-1"></i>Se eliminarán todas las notas asociadas.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-danger" id="btnDeleteConfirm" onclick="doDelete()">
                    <i class="fas fa-trash mr-1"></i> Eliminar
                </button>
            </div>
        </div>
    </div>
</div>

<script>
const AJAX_URL = '{{ ajax_url }}';
let deleteId = null;

function openCreateModal() {
    $('#formCreate')[0].reset();
    $('#modalCreate').modal('show');
}

function saveCreate() {
    const courseId  = $('#selCourse').val();
    const period    = $('#selPeriod').val();
    const gradeType = $('#selGradeType').val();
    const areaId    = $('#selArea').val();

    if (!courseId) {
        alert('Selecciona un curso');
        return;
    }

    $('#btnCreateSave').prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i> Guardando...');

    $.post(AJAX_URL, {
        action: 'create_registro',
        classroom_course_id: courseId,
        period: period,
        grade_type: gradeType,
        area_id: areaId
    }, function(res) {
        if (res.success) {
            $('#modalCreate').modal('hide');
            window.location.href = '/my-aula/registro/notas?id=' + res.id;
        } else {
            alert(res.message || 'Error al crear el registro');
            $('#btnCreateSave').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Crear Registro');
        }
    }, 'json').fail(function() {
        alert('Error de comunicación');
        $('#btnCreateSave').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Crear Registro');
    });
}

function confirmDelete(id, label) {
    deleteId = id;
    $('#deleteLabel').text(label);
    $('#modalDelete').modal('show');
}

function doDelete() {
    if (!deleteId) return;
    $('#btnDeleteConfirm').prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i>');

    $.post(AJAX_URL, { action: 'delete_registro', id: deleteId }, function(res) {
        if (res.success) {
            location.reload();
        } else {
            alert(res.message || 'Error al eliminar');
            $('#btnDeleteConfirm').prop('disabled', false).html('<i class="fas fa-trash mr-1"></i> Eliminar');
        }
    }, 'json').fail(function() {
        alert('Error de comunicación');
        $('#btnDeleteConfirm').prop('disabled', false).html('<i class="fas fa-trash mr-1"></i> Eliminar');
    });
}
</script>
