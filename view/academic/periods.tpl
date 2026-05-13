{% include 'academic/tabs.tpl' with {'active_tab': 'periods', 'is_admin': true} %}

<div class="d-flex align-items-center justify-content-between mb-3 flex-wrap" style="gap:8px;">
    <div>
        <h5 class="mb-1 font-weight-bold text-dark">
            <i class="fas fa-calendar-alt text-primary mr-2"></i>Períodos / Bimestres
        </h5>
        <p class="mb-0 text-muted small">Define los bimestres o trimestres de cada año académico con fechas de inicio y fin.</p>
    </div>
    <button class="btn btn-primary btn-sm" onclick="openModal(0, null)">
        <i class="fas fa-plus mr-1"></i> Nuevo Período
    </button>
</div>

{% if academic_years %}
{% for year in academic_years %}
<div class="card shadow-sm border-0 mb-4">
    <div class="card-header bg-white d-flex justify-content-between align-items-center py-2">
        <h6 class="mb-0 font-weight-bold text-primary">
            <i class="fas fa-graduation-cap mr-1"></i>
            Año Académico {{ year.year }}
            {% if year.active %}<span class="badge badge-success ml-2">Activo</span>{% endif %}
        </h6>
        <button class="btn btn-sm btn-outline-primary" onclick="openModal(0, {{ year.id }})">
            <i class="fas fa-plus mr-1"></i> Agregar período
        </button>
    </div>
    <div class="card-body p-0">
        {% if year.periods %}
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="thead-light">
                    <tr>
                        <th style="width:50px;">Orden</th>
                        <th>Nombre del Período</th>
                        <th>Fecha Inicio</th>
                        <th>Fecha Fin</th>
                        <th>Duración</th>
                        <th class="text-center">Estado</th>
                        <th class="text-center">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    {% for period in year.periods %}
                    <tr id="period-row-{{ period.id }}">
                        <td class="text-center text-muted">{{ period.order_index }}</td>
                        <td class="font-weight-bold">{{ period.name }}</td>
                        <td>{{ period.date_start }}</td>
                        <td>{{ period.date_end }}</td>
                        <td class="text-muted small">
                            {% set days = (period.date_end|date('U') - period.date_start|date('U')) / 86400 %}
                            {{ days|round }} días
                        </td>
                        <td class="text-center">
                            {% if period.active %}
                            <span class="badge badge-success">Activo</span>
                            {% else %}
                            <span class="badge badge-secondary">Inactivo</span>
                            {% endif %}
                        </td>
                        <td class="text-center">
                            <button class="btn btn-sm btn-outline-warning" onclick="openModal({{ period.id }}, {{ year.id }}, {{ period|json_encode|e('html_attr') }})" title="Editar">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-danger ml-1" onclick="deletePeriod({{ period.id }}, '{{ period.name|e('js') }}')" title="Eliminar">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
        {% else %}
        <div class="text-center py-4 text-muted">
            <i class="fas fa-calendar-times fa-2x mb-2"></i>
            <p class="mb-0">No hay períodos definidos para este año.</p>
        </div>
        {% endif %}
    </div>
</div>
{% endfor %}
{% else %}
<div class="card shadow-sm border-0">
    <div class="card-body text-center py-5">
        <i class="fas fa-calendar-alt fa-3x text-muted mb-3"></i>
        <p class="text-muted">No hay años académicos registrados.</p>
    </div>
</div>
{% endif %}

{# ===== Modal ===== #}
<div class="modal fade" id="modalPeriod" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="modalTitle"><i class="fas fa-calendar-alt mr-2"></i>Período</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <form id="formPeriod">
                    <input type="hidden" id="periodId" name="id" value="0">
                    <div class="form-group">
                        <label class="font-weight-bold">Año Académico <span class="text-danger">*</span></label>
                        <select id="periodYear" name="academic_year_id" class="form-control" required>
                            {% for year in academic_years %}
                            <option value="{{ year.id }}">{{ year.year }}{% if year.active %} (Activo){% endif %}</option>
                            {% endfor %}
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="font-weight-bold">Nombre del período <span class="text-danger">*</span></label>
                        <input type="text" id="periodName" name="name" class="form-control"
                               placeholder="Ej: I BIMESTRE, II TRIMESTRE..." required maxlength="100">
                        <small class="form-text text-muted">Ejemplos: I BIMESTRE, II BIMESTRE, I TRIMESTRE...</small>
                    </div>
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label class="font-weight-bold">Fecha inicio <span class="text-danger">*</span></label>
                            <input type="date" id="periodStart" name="date_start" class="form-control" required>
                        </div>
                        <div class="form-group col-md-6">
                            <label class="font-weight-bold">Fecha fin <span class="text-danger">*</span></label>
                            <input type="date" id="periodEnd" name="date_end" class="form-control" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="font-weight-bold">Orden</label>
                        <input type="number" id="periodOrder" name="order_index" class="form-control" value="0" min="0">
                        <small class="form-text text-muted">Número de orden para ordenar los períodos (0, 1, 2...)</small>
                    </div>
                    <div id="durationPreview" class="alert alert-info py-2 small" style="display:none;">
                        <i class="fas fa-info-circle mr-1"></i><span id="durationText"></span>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnSavePeriod" onclick="savePeriod()">
                    <i class="fas fa-save mr-1"></i> Guardar
                </button>
            </div>
        </div>
    </div>
</div>

{# ===== Modal: Confirmar Eliminar ===== #}
<div class="modal fade" id="modalDeletePeriod" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="fas fa-exclamation-triangle mr-2"></i>Eliminar Período</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>¿Eliminar el período <strong id="deletePeriodName"></strong>?</p>
                <p class="text-danger small"><i class="fas fa-exclamation-circle mr-1"></i>Los registros auxiliares que usen este período mantendrán su nombre guardado.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-danger" id="btnDeletePeriod" onclick="doDelete()">
                    <i class="fas fa-trash mr-1"></i> Eliminar
                </button>
            </div>
        </div>
    </div>
</div>

<script>
const AJAX_URL = '{{ ajax_url }}';
let deleteId = null;

function openModal(id, yearId, data) {
    $('#periodId').val(id || 0);
    $('#formPeriod')[0].reset();
    $('#periodId').val(id || 0);

    if (yearId) $('#periodYear').val(yearId);
    if (id > 0 && data) {
        $('#modalTitle').html('<i class="fas fa-edit mr-2"></i>Editar Período');
        $('#periodYear').val(data.academic_year_id);
        $('#periodName').val(data.name);
        $('#periodStart').val(data.date_start);
        $('#periodEnd').val(data.date_end);
        $('#periodOrder').val(data.order_index);
        updateDuration();
    } else {
        $('#modalTitle').html('<i class="fas fa-plus-circle mr-2"></i>Nuevo Período');
    }
    $('#modalPeriod').modal('show');
}

function updateDuration() {
    const start = $('#periodStart').val();
    const end   = $('#periodEnd').val();
    if (start && end && end > start) {
        const days = Math.round((new Date(end) - new Date(start)) / 86400000);
        const weeks = Math.floor(days / 7);
        $('#durationText').text('Duración: ' + days + ' días (' + weeks + ' semanas)');
        $('#durationPreview').show();
    } else {
        $('#durationPreview').hide();
    }
}

$('#periodStart, #periodEnd').on('change', updateDuration);

function savePeriod() {
    const id       = $('#periodId').val();
    const yearId   = $('#periodYear').val();
    const name     = $('#periodName').val().trim();
    const start    = $('#periodStart').val();
    const end      = $('#periodEnd').val();
    const order    = $('#periodOrder').val();

    if (!yearId || !name || !start || !end) {
        alert('Completa todos los campos obligatorios');
        return;
    }
    if (start >= end) {
        alert('La fecha de inicio debe ser anterior a la fecha de fin');
        return;
    }

    $('#btnSavePeriod').prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i>');

    $.post(AJAX_URL, {
        action: 'save_period',
        id: id,
        academic_year_id: yearId,
        name: name,
        date_start: start,
        date_end: end,
        order_index: order
    }, function(res) {
        if (res.success) {
            $('#modalPeriod').modal('hide');
            location.reload();
        } else {
            alert(res.message || 'Error al guardar');
            $('#btnSavePeriod').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar');
        }
    }, 'json').fail(function() {
        alert('Error de comunicación');
        $('#btnSavePeriod').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar');
    });
}

function deletePeriod(id, name) {
    deleteId = id;
    $('#deletePeriodName').text(name);
    $('#modalDeletePeriod').modal('show');
}

function doDelete() {
    if (!deleteId) return;
    $('#btnDeletePeriod').prop('disabled', true);
    $.post(AJAX_URL, { action: 'delete_period', id: deleteId }, function(res) {
        if (res.success) {
            location.reload();
        } else {
            alert(res.message || 'Error');
            $('#btnDeletePeriod').prop('disabled', false);
        }
    }, 'json');
}
</script>
