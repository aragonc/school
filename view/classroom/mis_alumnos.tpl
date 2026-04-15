<div class="container-fluid px-4 py-4">

    {# ---- Encabezado ---- #}
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap" style="gap:10px;">
        <div>
            <h4 class="mb-1 font-weight-bold text-dark">
                <i class="fas fa-users text-primary mr-2"></i>Mis Alumnos
            </h4>
            {% if classroom %}
            <p class="mb-0 text-muted small">
                {{ classroom.level_name }} &mdash; {{ classroom.grade_name }}
                {% if classroom.section_name %} &mdash; Sección {{ classroom.section_name }}{% endif %}
                {% if classroom.tutor_name %}
                <span class="ml-2 badge badge-light text-muted">
                    <i class="fas fa-chalkboard-teacher mr-1"></i>{{ classroom.tutor_name }}
                </span>
                {% endif %}
            </p>
            {% endif %}
        </div>
        <a href="/my-aula" class="btn btn-sm btn-outline-secondary">
            <i class="fas fa-arrow-left mr-1"></i> Mi Aula
        </a>
    </div>

    {# ---- Filtros ---- #}
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body py-3">
            <form method="get" action="" class="d-flex align-items-end flex-wrap" style="gap:16px;">
                {% if is_admin_or_secretary and classrooms_list %}
                <div>
                    <label class="mb-1 small font-weight-bold text-muted">Aula</label>
                    <select name="classroom_id" class="form-control form-control-sm" onchange="this.form.submit()" style="min-width:220px;">
                        {% for cls in classrooms_list %}
                        <option value="{{ cls.id }}" {% if cls.id == classroom_id %}selected{% endif %}>
                            {{ cls.level_name }} — {{ cls.grade_name }}{% if cls.section_name %} Sec. {{ cls.section_name }}{% endif %}
                        </option>
                        {% endfor %}
                    </select>
                </div>
                {% endif %}
                <div>
                    <label class="mb-1 small font-weight-bold text-muted">Fecha</label>
                    <div class="d-flex" style="gap:6px;">
                        <input type="date" name="date" class="form-control form-control-sm"
                               value="{{ selected_date }}"
                               max="{{ "now"|date("Y-m-d") }}">
                        <button type="submit" class="btn btn-sm btn-primary">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
                {% if not is_today %}
                <div class="align-self-end">
                    <a href="?{% if classroom_id %}classroom_id={{ classroom_id }}&{% endif %}date={{ "now"|date("Y-m-d") }}"
                       class="btn btn-sm btn-outline-primary">
                        <i class="fas fa-calendar-day mr-1"></i>Hoy
                    </a>
                </div>
                {% endif %}
            </form>
        </div>
    </div>

    {% if not classroom %}
    <div class="alert alert-info">
        <i class="fas fa-info-circle mr-2"></i>
        No tienes un aula asignada como tutor en el año académico activo.
    </div>

    {% else %}

    {# ---- Resumen de asistencia ---- #}
    <div class="row mb-4" style="row-gap:12px;">
        <div class="col-6 col-md-3">
            <div class="card border-left-success shadow-sm h-100 py-2">
                <div class="card-body py-2">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Puntual</div>
                            <div class="h4 mb-0 font-weight-bold text-gray-800">{{ count_puntual }}</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-check-circle fa-2x text-success" style="opacity:.4;"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card border-left-warning shadow-sm h-100 py-2">
                <div class="card-body py-2">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Tardanza</div>
                            <div class="h4 mb-0 font-weight-bold text-gray-800">{{ count_tardanza }}</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-clock fa-2x text-warning" style="opacity:.4;"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card border-left-danger shadow-sm h-100 py-2">
                <div class="card-body py-2">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">Ausente</div>
                            <div class="h4 mb-0 font-weight-bold text-gray-800">{{ count_ausente }}</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-times-circle fa-2x text-danger" style="opacity:.4;"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {# ---- Lista de alumnos ---- #}
    <div class="card shadow-sm border-0">
        <div class="card-header bg-white py-3 d-flex align-items-center justify-content-between flex-wrap" style="gap:8px;">
            <span class="font-weight-bold text-dark">
                <i class="fas fa-list mr-1 text-muted"></i>
                Alumnos &mdash; {{ total_students }} en total
            </span>
            <div class="d-flex align-items-center flex-wrap" style="gap:8px;">
                <span class="text-muted small">
                    <i class="fas fa-calendar-alt mr-1"></i>{{ selected_date }}
                </span>
                {% if enable_manual_attendance and students %}
                <button class="btn btn-sm btn-primary" onclick="openAttModal(null, null)" title="Registrar asistencia manual a varios alumnos">
                    <i class="fas fa-clipboard-check mr-1"></i> Asistencia manual
                </button>
                {% endif %}
                {% if students %}
                <button class="btn btn-sm btn-outline-info" data-toggle="modal" data-target="#loginHistoryModal">
                    <i class="fas fa-history mr-1"></i> Historial de conexiones
                </button>
                {% endif %}
            </div>
        </div>
        <div class="card-body p-0">
            {% if students %}
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="thead-light">
                        <tr>
                            <th style="width:48px;" class="pl-3"></th>
                            <th>Alumno</th>
                            <th>DNI</th>
                            <th>Correo</th>
                            <th>Última conexión</th>
                            <th>Asistencia</th>
                            <th>Hora entrada</th>
                            {% if enable_manual_attendance %}
                            <th style="width:110px;">Acción</th>
                            {% endif %}
                        </tr>
                    </thead>
                    <tbody>
                        {% for s in students %}
                        <tr data-user-id="{{ s.user_id }}">
                            {# Foto #}
                            <td class="pl-3 pr-0">
                                {% if s.foto_url %}
                                <img src="{{ s.foto_url }}"
                                     class="rounded-circle"
                                     style="width:38px;height:38px;object-fit:cover;border:2px solid #e2e8f0;"
                                     alt="">
                                {% else %}
                                <div class="rounded-circle bg-light border d-flex align-items-center justify-content-center"
                                     style="width:38px;height:38px;">
                                    <i class="fas fa-user text-secondary"></i>
                                </div>
                                {% endif %}
                            </td>

                            {# Nombre #}
                            <td>
                                <div class="font-weight-bold text-dark" style="font-size:13px;">
                                    {{ s.display_apellidos }}
                                </div>
                                <div class="text-muted" style="font-size:12px;">{{ s.display_nombres }}</div>
                            </td>

                            {# DNI #}
                            <td class="text-muted" style="font-size:12px;letter-spacing:.5px;">
                                {{ s.dni ?: '—' }}
                            </td>

                            {# Correo #}
                            <td class="text-muted" style="font-size:12px;">
                                {% if s.email %}
                                <a href="mailto:{{ s.email }}" class="text-muted">{{ s.email }}</a>
                                {% else %}
                                &mdash;
                                {% endif %}
                            </td>

                            {# Última conexión #}
                            <td style="font-size:12px;white-space:nowrap;">
                                {% if s.last_login_local %}
                                <span class="text-dark">{{ s.last_login_local|date('d/m/Y') }}</span>
                                <span class="text-muted d-block" style="font-size:11px;">{{ s.last_login_local|date('H:i') }}</span>
                                {% else %}
                                <span class="text-muted">—</span>
                                {% endif %}
                            </td>

                            {# Estado asistencia #}
                            <td class="att-badge-cell">
                                {% if s.att_status == 'on_time' %}
                                <span class="badge badge-success px-2 py-1">
                                    <i class="fas fa-check mr-1"></i>Puntual
                                </span>
                                {% elseif s.att_status == 'late' %}
                                <span class="badge badge-warning px-2 py-1 text-dark">
                                    <i class="fas fa-clock mr-1"></i>Tardanza
                                </span>
                                {% elseif s.att_status == 'absent' %}
                                <span class="badge badge-danger px-2 py-1">
                                    <i class="fas fa-times mr-1"></i>Ausente
                                </span>
                                {% else %}
                                <span class="badge badge-secondary px-2 py-1">
                                    <i class="fas fa-minus mr-1"></i>Sin registro
                                </span>
                                {% endif %}
                            </td>

                            {# Hora #}
                            <td class="text-muted att-time-cell" style="font-size:12px;">
                                {% if s.att_time %}
                                <i class="fas fa-clock mr-1 text-muted" style="font-size:10px;"></i>{{ s.att_time }}
                                {% else %}
                                &mdash;
                                {% endif %}
                            </td>

                            {# Acción manual de asistencia #}
                            {% if enable_manual_attendance %}
                            <td>
                                <div class="btn-group btn-group-sm att-action-group" role="group">
                                    <button type="button"
                                            class="btn btn-att {% if s.att_status == 'on_time' %}btn-success{% else %}btn-outline-success{% endif %}"
                                            data-status="on_time"
                                            title="Puntual"
                                            onclick="openAttModal('{{ s.user_id }}', 'on_time')">
                                        <i class="fas fa-check"></i>
                                    </button>
                                    <button type="button"
                                            class="btn btn-att {% if s.att_status == 'late' %}btn-warning{% else %}btn-outline-warning{% endif %}"
                                            data-status="late"
                                            title="Tardanza"
                                            onclick="openAttModal('{{ s.user_id }}', 'late')">
                                        <i class="fas fa-clock"></i>
                                    </button>
                                    <button type="button"
                                            class="btn btn-att {% if s.att_status == 'absent' or not s.att_status %}btn-danger{% else %}btn-outline-danger{% endif %}"
                                            data-status="absent"
                                            title="Ausente"
                                            onclick="openAttModal('{{ s.user_id }}', 'absent')">
                                        <i class="fas fa-times"></i>
                                    </button>
                                </div>
                            </td>
                            {% endif %}

                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
            </div>
            {% else %}
            <div class="p-5 text-center text-muted">
                <i class="fas fa-users fa-2x mb-3 d-block text-secondary" style="opacity:.4;"></i>
                No hay alumnos asignados a esta aula.
            </div>
            {% endif %}
        </div>
    </div>

    {% endif %}

</div>

{# ===== Modal: Historial de Conexiones (todos los alumnos) ===== #}
{% if students %}
<div class="modal fade" id="loginHistoryModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fas fa-history mr-2 text-info"></i>
                    Historial de conexiones
                    {% if classroom %}
                    <small class="text-muted font-weight-normal ml-2">
                        {{ classroom.level_name }} — {{ classroom.grade_name }}
                        {% if classroom.section_name %} Sec. {{ classroom.section_name }}{% endif %}
                    </small>
                    {% endif %}
                </h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body p-0">
                <div class="px-3 pt-3 pb-2">
                    <input type="text" id="lhSearch" class="form-control form-control-sm"
                           placeholder="Buscar alumno..." oninput="lhFilter()">
                </div>
                <div class="table-responsive">
                    <table class="table table-sm table-hover mb-0" id="lhTable">
                        <thead class="thead-light sticky-top">
                            <tr>
                                <th style="width:38px;" class="pl-3"></th>
                                <th>Alumno</th>
                                <th style="white-space:nowrap;">
                                    <i class="fas fa-sign-in-alt mr-1 text-info"></i>Última conexión
                                </th>
                                <th style="white-space:nowrap;">Hace</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for s in students %}
                            <tr class="lh-row">
                                <td class="pl-3">
                                    {% if s.foto_url %}
                                    <img src="{{ s.foto_url }}" class="rounded-circle"
                                         style="width:30px;height:30px;object-fit:cover;" alt="">
                                    {% else %}
                                    <div class="rounded-circle bg-light border d-flex align-items-center justify-content-center"
                                         style="width:30px;height:30px;">
                                        <i class="fas fa-user text-secondary" style="font-size:12px;"></i>
                                    </div>
                                    {% endif %}
                                </td>
                                <td>
                                    <div class="font-weight-bold lh-name" style="font-size:13px;">
                                        {{ s.display_apellidos }}
                                    </div>
                                    <div class="text-muted" style="font-size:11px;">{{ s.display_nombres }}</div>
                                </td>
                                <td style="white-space:nowrap;">
                                    {% if s.last_login_local %}
                                    <span class="text-dark" style="font-size:13px;">
                                        {{ s.last_login_local|date('d/m/Y H:i') }}
                                    </span>
                                    {% else %}
                                    <span class="badge badge-secondary">Sin conexión</span>
                                    {% endif %}
                                </td>
                                <td style="font-size:12px;">
                                    {% if s.last_login_local %}
                                    <span class="text-muted lh-ago"
                                          data-ts="{{ s.last_login_local|date('U') }}"></span>
                                    {% else %}
                                    <span class="text-muted">—</span>
                                    {% endif %}
                                </td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function lhFilter() {
    var q = document.getElementById('lhSearch').value.toLowerCase();
    document.querySelectorAll('#lhTable .lh-row').forEach(function(tr) {
        var name = (tr.querySelector('.lh-name') || {}).textContent || '';
        tr.style.display = name.toLowerCase().indexOf(q) >= 0 ? '' : 'none';
    });
}

// Calcular "hace X días/horas"
function lhTimeAgo(ts) {
    var diff = Math.floor(Date.now() / 1000) - parseInt(ts);
    if (diff < 60)         return 'Hace un momento';
    if (diff < 3600)       return 'Hace ' + Math.floor(diff / 60) + ' min';
    if (diff < 86400)      return 'Hace ' + Math.floor(diff / 3600) + ' h';
    if (diff < 86400 * 30) return 'Hace ' + Math.floor(diff / 86400) + ' días';
    return 'Hace ' + Math.floor(diff / (86400 * 30)) + ' meses';
}

document.querySelectorAll('.lh-ago').forEach(function(el) {
    el.textContent = lhTimeAgo(el.getAttribute('data-ts'));
});
</script>
{% endif %}

{% if enable_manual_attendance %}

{# ===== Modal: Asistencia Manual ===== #}
<div class="modal fade" id="attManualModal" tabindex="-1" aria-labelledby="attManualModalLabel">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="attManualModalLabel">
                    <i class="fas fa-clipboard-check mr-2 text-primary"></i>
                    Registrar Asistencia Manual
                    <small class="text-muted font-weight-normal ml-2" style="font-size:13px;">
                        {{ selected_date }}
                    </small>
                </h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">

                {# Estado + Hora #}
                <div class="row mb-4">
                    <div class="col-md-7 mb-3 mb-md-0">
                        <label class="font-weight-bold mb-2 d-block">Estado de asistencia</label>
                        <div class="btn-group btn-group-toggle d-flex" data-toggle="buttons" id="attStatusGroup">
                            <label class="btn btn-outline-success flex-fill att-status-btn" id="attBtnOnTime">
                                <input type="radio" name="att_status" value="on_time" autocomplete="off">
                                <i class="fas fa-check mr-1"></i> Puntual
                            </label>
                            <label class="btn btn-outline-warning flex-fill att-status-btn" id="attBtnLate">
                                <input type="radio" name="att_status" value="late" autocomplete="off">
                                <i class="fas fa-clock mr-1"></i> Tardanza
                            </label>
                            <label class="btn btn-outline-danger flex-fill att-status-btn" id="attBtnAbsent">
                                <input type="radio" name="att_status" value="absent" autocomplete="off">
                                <i class="fas fa-times mr-1"></i> Ausente
                            </label>
                        </div>
                    </div>
                    <div class="col-md-5" id="attTimeGroup">
                        <label class="font-weight-bold mb-2 d-block" for="attTimeInput">Hora de entrada</label>
                        <input type="time" class="form-control" id="attTimeInput">
                        <small class="form-text text-muted">Se omite si el estado es Ausente.</small>
                    </div>
                </div>

                {# Lista de alumnos con checkboxes #}
                <div class="d-flex align-items-center justify-content-between mb-2 flex-wrap" style="gap:8px;">
                    <label class="font-weight-bold mb-0">Alumnos</label>
                    <div class="d-flex align-items-center" style="gap:8px;" id="attSelectAllBar">
                        <button type="button" class="btn btn-sm btn-outline-secondary" onclick="attSelectAll(true)">
                            <i class="fas fa-check-square mr-1"></i> Todos
                        </button>
                        <button type="button" class="btn btn-sm btn-outline-secondary" onclick="attSelectAll(false)">
                            <i class="far fa-square mr-1"></i> Ninguno
                        </button>
                        <span class="text-muted small" id="attSelectedCount"></span>
                    </div>
                </div>
                <div id="attStudentList"
                     style="max-height:340px;overflow-y:auto;border:1px solid #e2e8f0;border-radius:6px;">
                    {# Llenado dinámico por JS #}
                </div>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="attSaveBtn" onclick="saveAttManual()">
                    <i class="fas fa-save mr-1"></i> Registrar
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var AJAX_URL       = '{{ ajax_url }}';
var ATT_CLASSROOM  = {{ classroom_id }};
var ATT_DATE       = '{{ selected_date }}';

// Datos de alumnos serializados desde Twig
var ATT_STUDENTS = [
    {% for s in students %}
    {
        userId:        '{{ s.user_id }}',
        name:          '{{ (s.display_apellidos ~ ' ' ~ s.display_nombres)|e('js') }}',
        foto:          '{{ s.foto_url|e('js') }}',
        currentStatus: '{{ s.att_status|e('js') }}'
    }{% if not loop.last %},{% endif %}
    {% endfor %}
];

// ---- Helpers de badge ----
function attBadgeSmall(status) {
    if (status === 'on_time') return '<span class="badge badge-success ml-1" style="font-size:10px;">Puntual</span>';
    if (status === 'late')    return '<span class="badge badge-warning text-dark ml-1" style="font-size:10px;">Tardanza</span>';
    if (status === 'absent')  return '<span class="badge badge-danger ml-1" style="font-size:10px;">Ausente</span>';
    return '<span class="badge badge-secondary ml-1" style="font-size:10px;">Sin registro</span>';
}
function attBadgeFull(status) {
    if (status === 'on_time') return '<span class="badge badge-success px-2 py-1"><i class="fas fa-check mr-1"></i>Puntual</span>';
    if (status === 'late')    return '<span class="badge badge-warning px-2 py-1 text-dark"><i class="fas fa-clock mr-1"></i>Tardanza</span>';
    if (status === 'absent')  return '<span class="badge badge-danger px-2 py-1"><i class="fas fa-times mr-1"></i>Ausente</span>';
    return '<span class="badge badge-secondary px-2 py-1"><i class="fas fa-minus mr-1"></i>Sin registro</span>';
}

// ---- Abrir modal ----
// userId: ID del alumno al abrir desde fila (null = todos)
// defaultStatus: estado pre-seleccionado (null = ninguno)
function openAttModal(userId, defaultStatus) {
    // Construir lista de alumnos
    var html = '';
    ATT_STUDENTS.forEach(function(s) {
        var checked = (userId === null || userId == s.userId) ? 'checked' : '';
        var foto = s.foto
            ? '<img src="'+s.foto+'" class="rounded-circle mr-2 flex-shrink-0" style="width:34px;height:34px;object-fit:cover;" alt="">'
            : '<div class="rounded-circle bg-light border d-flex align-items-center justify-content-center mr-2 flex-shrink-0" style="width:34px;height:34px;"><i class="fas fa-user text-secondary" style="font-size:13px;"></i></div>';
        html += '<label class="d-flex align-items-center px-3 py-2 att-student-item mb-0"'
              + ' style="cursor:pointer;border-bottom:1px solid #f3f4f6;">'
              + '<input type="checkbox" class="mr-3 att-cb" value="'+s.userId+'" '+checked
              + ' onchange="updateAttCount()" style="width:16px;height:16px;cursor:pointer;flex-shrink:0;">'
              + foto
              + '<span class="flex-grow-1 font-weight-500" style="font-size:13px;">'+s.name+'</span>'
              + attBadgeSmall(s.currentStatus)
              + '</label>';
    });
    document.getElementById('attStudentList').innerHTML = html;

    // Estado
    document.querySelectorAll('input[name="att_status"]').forEach(function(r) {
        r.checked = false;
        r.closest('label').classList.remove('active');
    });
    if (defaultStatus) {
        var radio = document.querySelector('input[name="att_status"][value="'+defaultStatus+'"]');
        if (radio) {
            radio.checked = true;
            radio.closest('label').classList.add('active');
        }
    }

    // Hora actual
    var now = new Date();
    document.getElementById('attTimeInput').value =
        String(now.getHours()).padStart(2,'0') + ':' + String(now.getMinutes()).padStart(2,'0');

    toggleTimeInput(defaultStatus);
    updateAttCount();
    $('#attManualModal').modal('show');
}

// ---- Toggle hora según estado ----
function toggleTimeInput(status) {
    var grp = document.getElementById('attTimeGroup');
    var inp = document.getElementById('attTimeInput');
    if (status === 'absent') {
        grp.style.opacity = '0.45';
        inp.disabled = true;
    } else {
        grp.style.opacity = '1';
        inp.disabled = false;
    }
}

// ---- Contador seleccionados ----
function updateAttCount() {
    var n = document.querySelectorAll('.att-cb:checked').length;
    document.getElementById('attSelectedCount').textContent = n + ' seleccionado(s)';
}

function attSelectAll(val) {
    document.querySelectorAll('.att-cb').forEach(function(cb) { cb.checked = val; });
    updateAttCount();
}

// ---- Actualizar fila tras guardar ----
function updateRowUI(userId, status, attTime) {
    var row = document.querySelector('tr[data-user-id="'+userId+'"]');
    if (!row) return;

    var badgeCell = row.querySelector('.att-badge-cell');
    if (badgeCell) badgeCell.innerHTML = attBadgeFull(status);

    var timeCell = row.querySelector('.att-time-cell');
    if (timeCell) {
        timeCell.innerHTML = attTime
            ? '<i class="fas fa-clock mr-1 text-muted" style="font-size:10px;"></i>' + attTime
            : '&mdash;';
    }

    // Botones de la fila
    row.querySelectorAll('.btn-att').forEach(function(btn) {
        var s = btn.getAttribute('data-status');
        if (s === 'on_time') {
            btn.classList.toggle('btn-success',        status === 'on_time');
            btn.classList.toggle('btn-outline-success', status !== 'on_time');
        } else if (s === 'late') {
            btn.classList.toggle('btn-warning',        status === 'late');
            btn.classList.toggle('btn-outline-warning', status !== 'late');
        } else if (s === 'absent') {
            btn.classList.toggle('btn-danger',        status === 'absent');
            btn.classList.toggle('btn-outline-danger', status !== 'absent');
        }
    });

    // Mini-badge dentro del modal (si está abierto)
    var cb = document.querySelector('.att-cb[value="'+userId+'"]');
    if (cb) {
        var lbl = cb.closest('label');
        var badgeSpan = lbl ? lbl.querySelector('.badge') : null;
        if (badgeSpan) badgeSpan.outerHTML = attBadgeSmall(status);
    }

    // Actualizar array en memoria
    var student = ATT_STUDENTS.find(function(s) { return s.userId == userId; });
    if (student) student.currentStatus = status;
}

// ---- Guardar ----
async function saveAttManual() {
    var statusInput = document.querySelector('input[name="att_status"]:checked');
    if (!statusInput) { alert('Selecciona un estado de asistencia.'); return; }
    var status = statusInput.value;

    var checkInTime = (status !== 'absent') ? document.getElementById('attTimeInput').value : '';

    var selected = Array.from(document.querySelectorAll('.att-cb:checked'));
    if (selected.length === 0) { alert('Selecciona al menos un alumno.'); return; }

    var btn = document.getElementById('attSaveBtn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i> Guardando ' + selected.length + '…';

    var errors = 0;
    for (var i = 0; i < selected.length; i++) {
        var uid = selected[i].value;
        try {
            var params = new URLSearchParams({
                action:        'mark_student_attendance',
                user_id:       uid,
                classroom_id:  ATT_CLASSROOM,
                date:          ATT_DATE,
                status:        status,
                check_in_time: checkInTime
            });
            var resp = await fetch(AJAX_URL, {
                method:  'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body:    params.toString()
            });
            var data = await resp.json();
            if (data.success) {
                updateRowUI(uid, status, data.att_time || '');
            } else {
                errors++;
            }
        } catch(e) {
            errors++;
        }
    }

    btn.disabled = false;
    btn.innerHTML = '<i class="fas fa-save mr-1"></i> Registrar';

    if (errors > 0) {
        alert('No se pudo registrar ' + errors + ' alumno(s). Intenta de nuevo.');
    } else {
        $('#attManualModal').modal('hide');
    }
}

// Escuchar cambio de estado para toggle de hora
document.querySelectorAll('input[name="att_status"]').forEach(function(radio) {
    radio.addEventListener('change', function() { toggleTimeInput(this.value); });
});
</script>
{% endif %}
