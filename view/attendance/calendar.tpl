{% include 'attendance/tabs.tpl' %}

<div class="row">
    <!-- Left: Non-working days list -->
    <div class="col-md-8">
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="fas fa-calendar-alt"></i> {{ 'NonWorkingDays'|get_plugin_lang('SchoolPlugin') }}</span>
                <div>
                    <a href="?year={{ current_year - 1 }}" class="btn btn-outline-secondary btn-sm">
                        <i class="fas fa-chevron-left"></i> {{ current_year - 1 }}
                    </a>
                    <strong class="mx-2">{{ current_year }}</strong>
                    <a href="?year={{ current_year + 1 }}" class="btn btn-outline-secondary btn-sm">
                        {{ current_year + 1 }} <i class="fas fa-chevron-right"></i>
                    </a>
                </div>
            </div>
            <div class="card-body p-0">
                <table class="table table-sm table-hover mb-0">
                    <thead class="thead-light">
                        <tr>
                            <th>{{ 'NonWorkingType'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'StartDateLabel'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'EndDateLabel'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'DescriptionLabel'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th style="width:90px;"></th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for nw in non_working_days %}
                        <tr>
                            <td>
                                {% if nw.type == 'holiday' %}
                                    <span class="badge badge-warning">{{ 'Holiday'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% elseif nw.type == 'suspension' %}
                                    <span class="badge badge-danger">{{ 'Suspension'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% elseif nw.type == 'free_day' %}
                                    <span class="badge badge-success">{{ 'Asueto'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% else %}
                                    <span class="badge badge-info">{{ 'Vacation'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% endif %}
                            </td>
                            <td>{{ nw.start_date }}</td>
                            <td>{{ nw.end_date }}</td>
                            <td>{{ nw.description }}</td>
                            <td class="text-nowrap">
                                <button type="button" class="btn btn-outline-primary btn-sm btn-edit-nw"
                                        data-id="{{ nw.id }}"
                                        data-type="{{ nw.type }}"
                                        data-start="{{ nw.start_date }}"
                                        data-end="{{ nw.end_date }}"
                                        data-desc="{{ nw.description }}"
                                        title="{{ 'EditNonWorkingDay'|get_plugin_lang('SchoolPlugin') }}">
                                    <i class="fas fa-pencil-alt"></i>
                                </button>
                                <button type="button" class="btn btn-outline-danger btn-sm btn-delete-nw"
                                        data-id="{{ nw.id }}"
                                        data-desc="{{ nw.description }}"
                                        title="{{ 'DeleteNonWorkingDay'|get_plugin_lang('SchoolPlugin') }}">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        {% else %}
                        <tr>
                            <td colspan="5" class="text-center text-muted py-3">
                                {{ 'NoNonWorkingDays'|get_plugin_lang('SchoolPlugin') }}
                            </td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Cron info card -->
        <div class="card">
            <div class="card-header">
                <i class="fas fa-terminal"></i> Cron Job
            </div>
            <div class="card-body">
                <p class="text-muted small mb-2">{{ 'CronInfo'|get_plugin_lang('SchoolPlugin') }}</p>
                <pre class="bg-dark text-light p-3 rounded small">0 0 * * 1-5 php {{ cron_path }}</pre>
                <p class="text-muted small mt-2 mb-0">
                    <i class="fas fa-info-circle text-primary"></i>
                    Se ejecuta a medianoche de lunes a viernes. Respeta el calendario de días no laborables.
                    Cuando un usuario pasa su QR o se registra manualmente, el estado "ausente" se actualiza.
                </p>
            </div>
        </div>
    </div>

    <!-- Right: Add form + manual trigger -->
    <div class="col-md-4">
        <div class="card mb-3">
            <div class="card-header">
                <i class="fas fa-plus-circle"></i> {{ 'AddNonWorkingDay'|get_plugin_lang('SchoolPlugin') }}
            </div>
            <div class="card-body">
                <form id="addNwForm">
                    <div class="form-group">
                        <label class="small font-weight-bold">{{ 'NonWorkingType'|get_plugin_lang('SchoolPlugin') }}</label>
                        <select name="type" class="form-control form-control-sm" id="nwType">
                            <option value="holiday">{{ 'Holiday'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="vacation">{{ 'Vacation'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="suspension">{{ 'Suspension'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="free_day">{{ 'Asueto'|get_plugin_lang('SchoolPlugin') }}</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="small font-weight-bold">{{ 'StartDateLabel'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="date" name="start_date" class="form-control form-control-sm" id="nwStartDate" required>
                    </div>
                    <div class="form-group" id="endDateGroup">
                        <label class="small font-weight-bold">{{ 'EndDateLabel'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="date" name="end_date" class="form-control form-control-sm" id="nwEndDate" required>
                    </div>
                    <div class="form-group">
                        <label class="small font-weight-bold">{{ 'DescriptionLabel'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="text" name="description" class="form-control form-control-sm" id="nwDescription"
                               placeholder="Ej: Fiestas Patrias" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm btn-block">
                        <i class="fas fa-save"></i> {{ 'AddNonWorkingDay'|get_plugin_lang('SchoolPlugin') }}
                    </button>
                </form>
            </div>
        </div>

        <!-- Manual run -->
        <div class="card">
            <div class="card-header">
                <i class="fas fa-play-circle"></i> {{ 'GenerateAbsences'|get_plugin_lang('SchoolPlugin') }}
            </div>
            <div class="card-body">
                <p class="text-muted small">
                    Genera registros de "ausente" para todos los usuarios activos en la fecha indicada,
                    respetando el calendario y el día de la semana.
                </p>
                <div class="form-group">
                    <label class="small font-weight-bold">Fecha</label>
                    <input type="date" class="form-control form-control-sm" id="generateDate" value="{{ "now"|date("Y-m-d") }}">
                </div>
                <button type="button" class="btn btn-warning btn-sm btn-block" id="btnGenerate">
                    <i class="fas fa-user-times"></i> {{ 'GenerateAbsences'|get_plugin_lang('SchoolPlugin') }}
                </button>
                <div id="generateResult" class="mt-2"></div>
            </div>
        </div>
    </div>
</div>

<!-- Edit modal -->
<div class="modal fade" id="editNwModal" tabindex="-1" role="dialog" aria-labelledby="editNwModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="editNwModalLabel">
                    <i class="fas fa-pencil-alt"></i> {{ 'EditNonWorkingDay'|get_plugin_lang('SchoolPlugin') }}
                </h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id="editNwForm">
                    <input type="hidden" id="editNwId">
                    <div class="form-group">
                        <label class="small font-weight-bold">{{ 'NonWorkingType'|get_plugin_lang('SchoolPlugin') }}</label>
                        <select class="form-control form-control-sm" id="editNwType">
                            <option value="holiday">{{ 'Holiday'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="vacation">{{ 'Vacation'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="suspension">{{ 'Suspension'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="free_day">{{ 'Asueto'|get_plugin_lang('SchoolPlugin') }}</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="small font-weight-bold">{{ 'StartDateLabel'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="date" class="form-control form-control-sm" id="editNwStart" required>
                    </div>
                    <div class="form-group">
                        <label class="small font-weight-bold">{{ 'EndDateLabel'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="date" class="form-control form-control-sm" id="editNwEnd" required>
                    </div>
                    <div class="form-group">
                        <label class="small font-weight-bold">{{ 'DescriptionLabel'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="text" class="form-control form-control-sm" id="editNwDesc" required>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">
                    <i class="fas fa-times"></i> {{ 'Cancel'|get_plugin_lang('SchoolPlugin') }}
                </button>
                <button type="button" class="btn btn-primary btn-sm" id="btnSaveEdit">
                    <i class="fas fa-save"></i> {{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var calAjaxUrl = '{{ ajax_url }}';

var singleDayTypes = ['holiday', 'suspension', 'free_day'];

// Auto-set end_date = start_date for single-day types, allow range for vacation
document.getElementById('nwType').addEventListener('change', function() {
    if (singleDayTypes.indexOf(this.value) !== -1) {
        var sd = document.getElementById('nwStartDate').value;
        document.getElementById('nwEndDate').value = sd;
    }
});
document.getElementById('nwStartDate').addEventListener('change', function() {
    if (singleDayTypes.indexOf(document.getElementById('nwType').value) !== -1) {
        document.getElementById('nwEndDate').value = this.value;
    } else if (!document.getElementById('nwEndDate').value) {
        document.getElementById('nwEndDate').value = this.value;
    }
});

// Add non-working day
document.getElementById('addNwForm').addEventListener('submit', function(e) {
    e.preventDefault();
    var fd = new FormData(this);
    fd.append('action', 'add');
    fetch(calAjaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success) {
                location.reload();
            } else {
                alert(d.message || 'Error');
            }
        });
});

// Open edit modal
document.querySelectorAll('.btn-edit-nw').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.getElementById('editNwId').value   = this.getAttribute('data-id');
        document.getElementById('editNwType').value = this.getAttribute('data-type');
        document.getElementById('editNwStart').value = this.getAttribute('data-start');
        document.getElementById('editNwEnd').value   = this.getAttribute('data-end');
        document.getElementById('editNwDesc').value  = this.getAttribute('data-desc');
        $('#editNwModal').modal('show');
    });
});

// Auto-sync end date when type changes inside modal
document.getElementById('editNwType').addEventListener('change', function() {
    if (singleDayTypes.indexOf(this.value) !== -1) {
        document.getElementById('editNwEnd').value = document.getElementById('editNwStart').value;
    }
});
document.getElementById('editNwStart').addEventListener('change', function() {
    if (singleDayTypes.indexOf(document.getElementById('editNwType').value) !== -1) {
        document.getElementById('editNwEnd').value = this.value;
    }
});

// Save edit
document.getElementById('btnSaveEdit').addEventListener('click', function() {
    var id    = document.getElementById('editNwId').value;
    var type  = document.getElementById('editNwType').value;
    var start = document.getElementById('editNwStart').value;
    var end   = document.getElementById('editNwEnd').value;
    var desc  = document.getElementById('editNwDesc').value.trim();

    if (!start || !end || !desc) { alert('Complete todos los campos'); return; }
    if (end < start) { alert('La fecha de fin debe ser igual o posterior a la de inicio'); return; }

    var btn = this;
    btn.disabled = true;
    var fd = new FormData();
    fd.append('action', 'update');
    fd.append('id', id);
    fd.append('type', type);
    fd.append('start_date', start);
    fd.append('end_date', end);
    fd.append('description', desc);

    fetch(calAjaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            btn.disabled = false;
            if (d.success) {
                $('#editNwModal').modal('hide');
                location.reload();
            } else {
                alert(d.message || 'Error al actualizar');
            }
        });
});

// Delete non-working day
document.querySelectorAll('.btn-delete-nw').forEach(function(btn) {
    btn.addEventListener('click', function() {
        var id   = this.getAttribute('data-id');
        var desc = this.getAttribute('data-desc');
        if (!confirm('{{ 'ConfirmDeleteNonWorking'|get_plugin_lang('SchoolPlugin') }}\n' + desc)) return;
        var fd = new FormData();
        fd.append('action', 'delete');
        fd.append('id', id);
        fetch(calAjaxUrl, { method: 'POST', body: fd })
            .then(function(r) { return r.json(); })
            .then(function(d) {
                if (d.success) {
                    location.reload();
                } else {
                    alert(d.message || 'Error');
                }
            });
    });
});

// Generate absences manually
document.getElementById('btnGenerate').addEventListener('click', function() {
    var date = document.getElementById('generateDate').value;
    if (!date) { alert('Seleccione una fecha'); return; }
    var btn = this;
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
    var fd = new FormData();
    fd.append('action', 'generate_absences');
    fd.append('date', date);
    fetch(calAjaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-user-times"></i> {{ 'GenerateAbsences'|get_plugin_lang('SchoolPlugin') }}';
            var res = document.getElementById('generateResult');
            if (d.skipped) {
                res.innerHTML = '<div class="alert alert-warning py-1 small mb-0">' + d.reason_label + '</div>';
            } else {
                res.innerHTML = '<div class="alert alert-success py-1 small mb-0">' +
                    '{{ 'AbsencesGenerated'|get_plugin_lang('SchoolPlugin') }}: <strong>' + d.inserted + '</strong><br>' +
                    '{{ 'AbsencesSkipped'|get_plugin_lang('SchoolPlugin') }}: ' + d.skipped_existing +
                    '</div>';
            }
        });
});
</script>
