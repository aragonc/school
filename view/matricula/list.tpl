<!-- Contadores -->
<div class="row mb-4">
    <div class="col-md-2">
        <div class="card border-left-primary shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">{{ 'TotalEnrollments'|get_plugin_lang('SchoolPlugin') }}</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ (counts.NUEVO_INGRESO + counts.REINGRESO + counts.CONTINUACION) }}</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-users fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-2">
        <div class="card border-left-success shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">{{ 'NewEnrollments'|get_plugin_lang('SchoolPlugin') }}</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ counts.NUEVO_INGRESO }}</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-user-plus fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-2">
        <div class="card border-left-info shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-info text-uppercase mb-1">{{ 'Reenrollments'|get_plugin_lang('SchoolPlugin') }}</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ counts.REINGRESO }}</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-redo fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-2">
        <div class="card border-left-warning shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">{{ 'Continuacion'|get_plugin_lang('SchoolPlugin') }}</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ counts.CONTINUACION }}</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-arrow-right fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4 d-flex align-items-center justify-content-end" style="gap:8px;">
        {% if all_years|length > 1 %}
        <button class="btn btn-outline-secondary btn-sm" onclick="showPromoteModal()" title="{{ 'PromoteToNextYear'|get_plugin_lang('SchoolPlugin') }}">
            <i class="fas fa-angle-double-right"></i> {{ 'PromoteToNextYear'|get_plugin_lang('SchoolPlugin') }}
        </button>
        {% endif %}
        <a href="{{ _p.web }}matricula/alumnos" class="btn btn-primary btn-sm">
            <i class="fas fa-plus"></i> {{ 'NewEnrollment'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </div>
</div>

<!-- Filtros -->
<div class="card mb-4">
    <div class="card-body py-2">
        <form method="get" class="form-inline flex-wrap" style="gap:8px;">
            <select name="academic_year_id" class="form-control form-control-sm" onchange="this.form.submit()">
                <option value="">{{ 'AllYears'|get_plugin_lang('SchoolPlugin') }}</option>
                {% for y in all_years %}
                <option value="{{ y.id }}" {{ selected_year_id == y.id ? 'selected' : '' }}>
                    {{ y.name }} {% if y.active %}★{% endif %}
                </option>
                {% endfor %}
            </select>
            <input type="text" name="search" class="form-control form-control-sm" placeholder="{{ 'SearchByNameDni'|get_plugin_lang('SchoolPlugin') }}" value="{{ filters.search }}">
            <select name="tipo_ingreso" class="form-control form-control-sm">
                <option value="">{{ 'AllTypes'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="NUEVO_INGRESO" {{ filters.tipo_ingreso == 'NUEVO_INGRESO' ? 'selected' : '' }}>{{ 'NewEnrollmentType'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="REINGRESO" {{ filters.tipo_ingreso == 'REINGRESO' ? 'selected' : '' }}>{{ 'ReenrollmentType'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="CONTINUACION" {{ filters.tipo_ingreso == 'CONTINUACION' ? 'selected' : '' }}>{{ 'ContinuacionType'|get_plugin_lang('SchoolPlugin') }}</option>
            </select>
            <select name="estado" class="form-control form-control-sm">
                <option value="">{{ 'AllStates'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="ACTIVO" {{ filters.estado == 'ACTIVO' ? 'selected' : '' }}>{{ 'Activo'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="RETIRADO" {{ filters.estado == 'RETIRADO' ? 'selected' : '' }}>{{ 'Retirado'|get_plugin_lang('SchoolPlugin') }}</option>
            </select>
            <select name="grade_id" class="form-control form-control-sm">
                <option value="">{{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }}</option>
                {% for level in levels %}
                    <optgroup label="{{ level.name }}">
                        {% for grade in level.grades %}
                        <option value="{{ grade.id }}" {{ filters.grade_id == grade.id ? 'selected' : '' }}>{{ grade.name }}</option>
                        {% endfor %}
                    </optgroup>
                {% endfor %}
            </select>
            <button type="submit" class="btn btn-secondary btn-sm"><i class="fas fa-search"></i> {{ 'Filter'|get_plugin_lang('SchoolPlugin') }}</button>
            <a href="{{ _p.web }}matricula" class="btn btn-outline-secondary btn-sm"><i class="fas fa-times"></i></a>
        </form>
    </div>
</div>

<!-- Tabla -->
<div class="card">
    <div class="card-body p-0">
        {% if matriculas|length > 0 %}
        <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
                <thead>
                    <tr>
                        <th>{{ 'EstadoMatricula'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'TipoIngreso'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'NombreApellidos'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Dni'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Sexo'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'FechaRegistro'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for m in matriculas %}
                    <tr class="{{ m.estado == 'RETIRADO' ? 'text-muted' : '' }}">
                        <td>
                            {% if m.estado == 'RETIRADO' %}
                                <span class="badge badge-secondary"><i class="fas fa-user-times"></i> {{ 'Retirado'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% else %}
                                <span class="badge badge-success"><i class="fas fa-user-check"></i> {{ 'Activo'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% endif %}
                        </td>
                        <td>
                            {% if m.tipo_ingreso == 'NUEVO_INGRESO' %}
                                <span class="badge badge-success">{{ 'NewEnrollmentType'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% elseif m.tipo_ingreso == 'REINGRESO' %}
                                <span class="badge badge-info">{{ 'ReenrollmentType'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% else %}
                                <span class="badge badge-warning text-dark">{{ 'ContinuacionType'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% endif %}
                        </td>
                        <td><strong>{{ m.full_name }}</strong></td>
                        <td>
                            {% if m.level_name %}
                                <small class="text-muted">{{ m.level_name }}</small><br>
                                {{ m.grade_name }}
                            {% else %}
                                <span class="text-muted">—</span>
                            {% endif %}
                        </td>
                        <td>{{ m.dni ?: '—' }}</td>
                        <td>
                            {% if m.sexo == 'F' %}
                                <i class="fas fa-venus text-danger"></i> F
                            {% elseif m.sexo == 'M' %}
                                <i class="fas fa-mars text-primary"></i> M
                            {% else %}—{% endif %}
                        </td>
                        <td><small>{{ m.created_at|date('d/m/Y') }}</small></td>
                        <td>
                            <a href="{{ _p.web }}matricula/ver?ficha_id={{ m.ficha_id }}" class="btn btn-info btn-sm" title="{{ 'View'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-eye"></i>
                            </a>
                            <a href="{{ _p.web }}matricula/editar?ficha_id={{ m.ficha_id }}" class="btn btn-warning btn-sm" title="{{ 'Edit'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-edit"></i>
                            </a>
                            {% if m.estado == 'ACTIVO' %}
                            <button class="btn btn-secondary btn-sm" onclick="retireMatricula({{ m.id }}, '{{ m.full_name|e('js') }}')" title="{{ 'RetirarAlumno'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-user-times"></i>
                            </button>
                            {% endif %}
                            <button class="btn btn-danger btn-sm" onclick="deleteMatricula({{ m.id }}, '{{ m.full_name|e('js') }}')" title="{{ 'Delete'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
        {% else %}
        <div class="p-4">
            <div class="alert alert-info mb-0">
                <i class="fas fa-info-circle"></i> {{ 'NoEnrollments'|get_plugin_lang('SchoolPlugin') }}
            </div>
        </div>
        {% endif %}
    </div>
</div>

<!-- Modal: Retiro de alumno con cálculo de devolución (Minedu) -->
<div class="modal fade" id="retireModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-warning">
                <h5 class="modal-title"><i class="fas fa-user-times"></i> Retirar alumno</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="retire_matricula_id" value="0">
                <input type="hidden" id="retire_ficha_id" value="0">
                <input type="hidden" id="retire_user_id" value="0">

                <div class="alert alert-warning py-2">
                    <i class="fas fa-exclamation-triangle"></i>
                    Esta acción marcará al alumno como <strong>RETIRADO</strong> y calculará la devolución de cuota de ingreso según la norma Minedu.
                </div>

                <div class="form-group">
                    <label class="font-weight-bold">Alumno</label>
                    <input type="text" class="form-control" id="retire_student_name" readonly>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">Nivel educativo</label>
                    <input type="text" class="form-control" id="retire_level_name" readonly>
                </div>

                <hr>
                <h6 class="text-muted mb-3"><i class="fas fa-calculator"></i> Cálculo de devolución (Minedu)</h6>

                <div class="row">
                    <div class="col-6">
                        <div class="form-group">
                            <label>Total años pactados</label>
                            <input type="number" class="form-control" id="retire_years_contracted" min="1" max="20" value="1" oninput="calcRetireRefund()">
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="form-group">
                            <label>Años cursados</label>
                            <input type="number" class="form-control" id="retire_years_attended" min="0" max="20" value="0" oninput="calcRetireRefund()">
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-6">
                        <div class="form-group">
                            <label>Años sin cursar (restantes)</label>
                            <input type="text" class="form-control bg-light" id="retire_years_remaining" readonly value="0">
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="form-group">
                            <label>Cuota de ingreso pagada S/</label>
                            <input type="number" class="form-control" id="retire_admission_paid" min="0" step="0.01" value="0" oninput="calcRetireRefund()" placeholder="0.00">
                        </div>
                    </div>
                </div>

                <div class="alert alert-info py-2" id="retire_refund_box">
                    <strong>Monto a devolver: </strong>
                    <span class="font-weight-bold text-primary" id="retire_refund_amount">S/ 0.00</span>
                    <small class="d-block text-muted mt-1" id="retire_refund_formula"></small>
                </div>

                <div class="form-group">
                    <label>Notas / Observaciones</label>
                    <textarea class="form-control" id="retire_notes" rows="2" placeholder="Motivo del retiro, acuerdos, etc."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-danger" id="btnConfirmRetire" onclick="submitRetire()">
                    <i class="fas fa-user-times"></i> Confirmar retiro
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Promover al siguiente año -->
<div class="modal fade" id="promoteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-angle-double-right"></i> {{ 'PromoteToNextYear'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>{{ 'PromoteHelp'|get_plugin_lang('SchoolPlugin') }}</p>
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'FromYear'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select id="promote_from" class="form-control">
                        {% for y in all_years %}
                        <option value="{{ y.id }}" {{ selected_year_id == y.id ? 'selected' : '' }}>{{ y.name }}{% if y.active %} ★{% endif %}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'ToYear'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select id="promote_to" class="form-control">
                        {% for y in all_years %}
                        <option value="{{ y.id }}">{{ y.name }}{% if y.active %} ★{% endif %}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i> {{ 'ConfirmPromote'|get_plugin_lang('SchoolPlugin') }}
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Cancel'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" id="btnPromote">
                    <i class="fas fa-angle-double-right"></i> {{ 'PromoteToNextYear'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';

function deleteMatricula(id, name) {
    if (!confirm('¿Eliminar la matrícula de ' + name + '? Esta acción no se puede deshacer.')) return;
    var fd = new FormData();
    fd.append('action', 'delete_matricula');
    fd.append('id', id);
    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) { if (d.success) location.reload(); else alert(d.message || 'Error'); });
}

function retireMatricula(id, name) {
    // Pre-fill name while loading info
    document.getElementById('retire_matricula_id').value = id;
    document.getElementById('retire_student_name').value = name;
    document.getElementById('retire_level_name').value = 'Cargando...';
    document.getElementById('retire_years_contracted').value = 1;
    document.getElementById('retire_years_attended').value = 0;
    document.getElementById('retire_admission_paid').value = '0';
    document.getElementById('retire_notes').value = '';
    document.getElementById('retire_ficha_id').value = 0;
    document.getElementById('retire_user_id').value = 0;
    calcRetireRefund();
    $('#retireModal').modal('show');

    // Fetch retirement info (years_contracted, years_attended, level)
    fetch(ajaxUrl + '?action=get_retirement_info&id=' + id)
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success && d.data) {
                document.getElementById('retire_student_name').value  = d.data.full_name  || name;
                document.getElementById('retire_level_name').value    = d.data.level_name || '—';
                document.getElementById('retire_years_contracted').value = d.data.years_contracted || 1;
                document.getElementById('retire_years_attended').value   = d.data.years_attended   || 0;
                document.getElementById('retire_ficha_id').value         = d.data.ficha_id || 0;
                document.getElementById('retire_user_id').value          = d.data.user_id  || 0;
                calcRetireRefund();
            } else {
                document.getElementById('retire_level_name').value = '—';
            }
        })
        .catch(function() {
            document.getElementById('retire_level_name').value = '—';
        });
}

function calcRetireRefund() {
    var contracted = Math.max(1, parseInt(document.getElementById('retire_years_contracted').value) || 1);
    var attended   = Math.max(0, parseInt(document.getElementById('retire_years_attended').value)   || 0);
    var remaining  = Math.max(0, contracted - attended);
    var paid       = parseFloat(document.getElementById('retire_admission_paid').value) || 0;
    var refund     = contracted > 0 ? Math.round(paid * (remaining / contracted) * 100) / 100 : 0;

    document.getElementById('retire_years_remaining').value = remaining;
    document.getElementById('retire_refund_amount').textContent = 'S/ ' + refund.toFixed(2);
    document.getElementById('retire_refund_formula').textContent =
        paid > 0
        ? 'S/ ' + paid.toFixed(2) + ' × (' + remaining + ' / ' + contracted + ') = S/ ' + refund.toFixed(2)
        : 'Ingrese la cuota de ingreso pagada para calcular la devolución.';
}

function submitRetire() {
    var id         = document.getElementById('retire_matricula_id').value;
    var fichaId    = document.getElementById('retire_ficha_id').value;
    var userId     = document.getElementById('retire_user_id').value;
    var contracted = document.getElementById('retire_years_contracted').value;
    var attended   = document.getElementById('retire_years_attended').value;
    var paid       = document.getElementById('retire_admission_paid').value;
    var notes      = document.getElementById('retire_notes').value;

    document.getElementById('btnConfirmRetire').disabled = true;

    var fd = new FormData();
    fd.append('action',            'retire_matricula');
    fd.append('id',                id);
    fd.append('ficha_id',          fichaId);
    fd.append('user_id',           userId);
    fd.append('years_contracted',  contracted);
    fd.append('years_attended',    attended);
    fd.append('admission_paid',    paid);
    fd.append('retire_notes',      notes);

    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            document.getElementById('btnConfirmRetire').disabled = false;
            if (d.success) {
                $('#retireModal').modal('hide');
                location.reload();
            } else {
                alert(d.message || 'Error al procesar el retiro');
            }
        })
        .catch(function() {
            document.getElementById('btnConfirmRetire').disabled = false;
            alert('Error de conexión');
        });
}

function showPromoteModal() {
    $('#promoteModal').modal('show');
}

document.getElementById('btnPromote').addEventListener('click', function() {
    var fromId = document.getElementById('promote_from').value;
    var toId   = document.getElementById('promote_to').value;
    if (fromId === toId) {
        alert('El año de origen y destino no pueden ser iguales.');
        return;
    }
    var fd = new FormData();
    fd.append('action', 'promote_year');
    fd.append('from_year_id', fromId);
    fd.append('to_year_id', toId);
    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success) {
                $('#promoteModal').modal('hide');
                alert(d.count + ' {{ 'StudentsPromoted'|get_plugin_lang('SchoolPlugin') }}');
                location.reload();
            } else {
                alert(d.message || 'Error');
            }
        });
});
</script>
