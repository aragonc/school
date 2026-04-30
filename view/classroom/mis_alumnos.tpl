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
                {% if enable_manual_attendance and students and is_admin_or_secretary %}
                <button class="btn btn-sm btn-primary" onclick="openAttModal(null, null, null, null, null, null)" title="Registrar asistencia manual a varios alumnos">
                    <i class="fas fa-clipboard-check mr-1"></i> Asistencia manual
                </button>
                {% endif %}
                {% if classroom %}
                <button class="btn btn-sm btn-success" data-toggle="modal" data-target="#exportExcelModal">
                    <i class="fas fa-file-excel mr-1"></i> Exportar Excel
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
                            <th class="pl-3 text-center" style="width:40px;">#</th>
                            <th style="width:48px;"></th>
                            <th>Alumno</th>
                            <th>DNI</th>
                            <th>Correo</th>
                            <th>Última conexión en la plataforma</th>
                            <th>Asistencia</th>
                            <th>Hora entrada</th>
                            <th>Observaciones</th>
                            {% if enable_manual_attendance %}
                            <th style="width:110px;">Acción</th>
                            {% endif %}
                        </tr>
                    </thead>
                    <tbody>
                        {% for s in students %}
                        <tr data-user-id="{{ s.user_id }}">
                            {# Número #}
                            <td class="pl-3 text-center text-muted" style="font-size:12px;font-weight:600;">
                                {{ loop.index }}
                            </td>
                            {# Foto #}
                            <td class="pr-0">
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

                            {# Observaciones #}
                            <td class="att-notes-cell" style="font-size:12px;max-width:200px;">
                                {% if s.att_notes %}
                                <span class="text-dark d-block" title="{{ s.att_notes }}"
                                      style="display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
                                    {{ s.att_notes }}
                                </span>
                                {% endif %}
                                {% if s.att_attachment %}
                                <div class="d-flex align-items-center mt-1" style="gap:6px;">
                                    <a href="{{ s.att_attachment_url }}" download
                                       class="d-inline-flex align-items-center small text-secondary"
                                       title="Descargar sustento">
                                        <i class="fas fa-paperclip mr-1"></i>Sustento adjunto
                                    </a>
                                    <button type="button"
                                            class="btn btn-link p-0 text-danger"
                                            style="font-size:11px;line-height:1;"
                                            title="Eliminar adjunto"
                                            onclick="deleteAttachment('{{ s.user_id }}', this)">
                                        <i class="fas fa-times-circle"></i>
                                    </button>
                                </div>
                                {% endif %}
                                {% if not s.att_notes and not s.att_attachment %}
                                <span class="text-muted">&mdash;</span>
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
                                            onclick="openAttModal('{{ s.user_id }}', 'on_time', '{{ (s.display_apellidos ~ ' ' ~ s.display_nombres)|e('js') }}', '{{ s.foto_url|e('js') }}', '{{ s.att_status }}', '{{ s.att_time }}')">
                                        <i class="fas fa-check"></i>
                                    </button>
                                    <button type="button"
                                            class="btn btn-att {% if s.att_status == 'late' %}btn-warning{% else %}btn-outline-warning{% endif %}"
                                            data-status="late"
                                            title="Tardanza"
                                            onclick="openAttModal('{{ s.user_id }}', 'late', '{{ (s.display_apellidos ~ ' ' ~ s.display_nombres)|e('js') }}', '{{ s.foto_url|e('js') }}', '{{ s.att_status }}', '{{ s.att_time }}')">
                                        <i class="fas fa-clock"></i>
                                    </button>
                                    <button type="button"
                                            class="btn btn-att {% if s.att_status == 'absent' or not s.att_status %}btn-danger{% else %}btn-outline-danger{% endif %}"
                                            data-status="absent"
                                            title="Ausente"
                                            onclick="openAttModal('{{ s.user_id }}', 'absent', '{{ (s.display_apellidos ~ ' ' ~ s.display_nombres)|e('js') }}', '{{ s.foto_url|e('js') }}', '{{ s.att_status }}', '{{ s.att_time }}')">
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
                    <span id="attModalTitle">Registrar Asistencia Manual</span>
                    <small class="text-muted font-weight-normal ml-2" style="font-size:13px;">
                        {{ selected_date }}
                    </small>
                </h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">

                {# Alumno destacado (modo individual) #}
                <div id="attSingleStudentInfo" class="d-none mb-3 p-3 rounded" style="background:#f8fafc;border:1px solid #e2e8f0;">
                    <div class="d-flex align-items-center">
                        <div id="attSinglePhoto" class="mr-3 flex-shrink-0"></div>
                        <div>
                            <div id="attSingleName" class="font-weight-bold text-dark" style="font-size:15px;"></div>
                            <div id="attSingleCurrentStatus" class="mt-1"></div>
                        </div>
                    </div>
                </div>

                {# Estado + Hora #}
                <div class="row mb-3">
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

                {# Comentario / observación #}
                <div class="mb-3">
                    <label class="font-weight-bold mb-1 d-block" for="attNotesInput">
                        <i class="fas fa-comment-alt mr-1 text-muted"></i> Comentario u observación
                        <span class="text-muted font-weight-normal" style="font-size:12px;">(opcional)</span>
                    </label>
                    <textarea id="attNotesInput" class="form-control" rows="2"
                              placeholder="Ej: El alumno llegó tarde por motivos de salud…"
                              maxlength="500" style="resize:vertical;"></textarea>
                    <small class="form-text text-muted text-right" id="attNotesCount">0/500</small>
                </div>

                {# Adjunto (solo tardanza / ausente) #}
                <div class="mb-1" id="attAttachmentGroup" style="display:none;">
                    <label class="font-weight-bold mb-1 d-block" for="attFileInput">
                        <i class="fas fa-paperclip mr-1 text-muted"></i> Documento sustento
                        <span class="text-muted font-weight-normal" style="font-size:12px;">(opcional — imagen o PDF)</span>
                    </label>
                    <div class="custom-file">
                        <input type="file" class="custom-file-input" id="attFileInput"
                               accept="image/jpeg,image/png,image/gif,application/pdf"
                               onchange="attFileChanged(this)">
                        <label class="custom-file-label text-muted" for="attFileInput" id="attFileLabel">
                            Seleccionar archivo…
                        </label>
                    </div>
                    <small class="form-text text-muted">Máximo 5 MB. Formatos: JPG, PNG, GIF, PDF.</small>
                    <div id="attFilePreview" class="mt-2" style="display:none;"></div>
                </div>

                {# Lista de alumnos con checkboxes (modo bulk, solo admins) #}
                <div id="attBulkSection">
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
                         style="max-height:300px;overflow-y:auto;border:1px solid #e2e8f0;border-radius:6px;">
                        {# Llenado dinámico por JS #}
                    </div>
                </div>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="attSaveBtn" onclick="saveAttManual()">
                    <i class="fas fa-save mr-1"></i> Guardar
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var AJAX_URL       = '{{ ajax_url }}';
var ATT_CLASSROOM  = {{ classroom_id }};
var ATT_DATE       = '{{ selected_date }}';
var ATT_IS_ADMIN   = {{ is_admin_or_secretary ? 'true' : 'false' }};

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

function attPhotoHtml(foto, size) {
    size = size || 34;
    if (foto) {
        return '<img src="'+foto+'" class="rounded-circle flex-shrink-0" style="width:'+size+'px;height:'+size+'px;object-fit:cover;" alt="">';
    }
    return '<div class="rounded-circle bg-light border d-flex align-items-center justify-content-center flex-shrink-0" style="width:'+size+'px;height:'+size+'px;"><i class="fas fa-user text-secondary" style="font-size:'+(size/2.5|0)+'px;"></i></div>';
}

// ---- Abrir modal ----
// userId      : ID del alumno (null = modo bulk para admin)
// defaultStatus: estado pre-seleccionado
// name, foto  : datos del alumno (para modo individual)
// currentStatus: estado actual del alumno
// currentTime : hora de entrada actual del alumno
function openAttModal(userId, defaultStatus, name, foto, currentStatus, currentTime) {
    var isSingle = (userId !== null);
    var isBulk   = !isSingle;

    // Título
    document.getElementById('attModalTitle').textContent = isSingle
        ? 'Modificar Asistencia'
        : 'Registrar Asistencia Manual';

    // Info alumno individual
    var singleInfo = document.getElementById('attSingleStudentInfo');
    if (isSingle) {
        document.getElementById('attSinglePhoto').innerHTML = attPhotoHtml(foto, 44);
        document.getElementById('attSingleName').textContent = name || '';
        document.getElementById('attSingleCurrentStatus').innerHTML =
            '<span class="text-muted small">Estado actual: </span>' + attBadgeFull(currentStatus || '');
        singleInfo.classList.remove('d-none');
    } else {
        singleInfo.classList.add('d-none');
    }

    // Sección bulk (lista de alumnos con checkboxes)
    var bulkSection = document.getElementById('attBulkSection');
    if (isBulk && ATT_IS_ADMIN) {
        bulkSection.style.display = '';
        var html = '';
        ATT_STUDENTS.forEach(function(s) {
            var foto2 = '<span class="mr-2">' + attPhotoHtml(s.foto, 34) + '</span>';
            html += '<label class="d-flex align-items-center px-3 py-2 att-student-item mb-0"'
                  + ' style="cursor:pointer;border-bottom:1px solid #f3f4f6;">'
                  + '<input type="checkbox" class="mr-3 att-cb" value="'+s.userId+'" checked'
                  + ' onchange="updateAttCount()" style="width:16px;height:16px;cursor:pointer;flex-shrink:0;">'
                  + foto2
                  + '<span class="flex-grow-1 font-weight-500" style="font-size:13px;">'+s.name+'</span>'
                  + attBadgeSmall(s.currentStatus)
                  + '</label>';
        });
        document.getElementById('attStudentList').innerHTML = html;
        updateAttCount();
    } else {
        bulkSection.style.display = 'none';
    }

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

    // Hora: usar la existente si hay, si no la hora actual
    var now = new Date();
    var timeVal = currentTime
        ? currentTime
        : String(now.getHours()).padStart(2,'0') + ':' + String(now.getMinutes()).padStart(2,'0');
    document.getElementById('attTimeInput').value = timeVal;

    // Limpiar comentario
    document.getElementById('attNotesInput').value = '';
    document.getElementById('attNotesCount').textContent = '0/500';

    // Limpiar adjunto
    var fileInput = document.getElementById('attFileInput');
    if (fileInput) {
        fileInput.value = '';
        document.getElementById('attFileLabel').textContent = 'Seleccionar archivo…';
        var prev = document.getElementById('attFilePreview');
        prev.style.display = 'none';
        prev.innerHTML = '';
    }

    // Guardar userId en el botón save para modo individual
    document.getElementById('attSaveBtn').setAttribute('data-single-user', userId || '');

    toggleTimeInput(defaultStatus);
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
    // Mostrar adjunto solo para tardanza/ausente
    var attachGroup = document.getElementById('attAttachmentGroup');
    if (attachGroup) {
        attachGroup.style.display = (status === 'late' || status === 'absent') ? '' : 'none';
    }
}

// ---- Preview del archivo adjunto ----
function attFileChanged(input) {
    var label   = document.getElementById('attFileLabel');
    var preview = document.getElementById('attFilePreview');
    if (!input.files || !input.files[0]) {
        label.textContent = 'Seleccionar archivo…';
        preview.style.display = 'none';
        preview.innerHTML = '';
        return;
    }
    var file = input.files[0];
    if (file.size > 5 * 1024 * 1024) {
        alert('El archivo supera los 5 MB.');
        input.value = '';
        label.textContent = 'Seleccionar archivo…';
        preview.style.display = 'none';
        preview.innerHTML = '';
        return;
    }
    label.textContent = file.name;
    preview.style.display = '';
    if (file.type.startsWith('image/')) {
        var reader = new FileReader();
        reader.onload = function(e) {
            preview.innerHTML = '<img src="'+e.target.result+'" style="max-height:120px;max-width:100%;border-radius:6px;border:1px solid #e2e8f0;" alt="">';
        };
        reader.readAsDataURL(file);
    } else {
        preview.innerHTML = '<span class="badge badge-light border"><i class="fas fa-file-pdf text-danger mr-1"></i>' + file.name + '</span>';
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
function updateRowUI(userId, status, attTime, notes, attachmentUrl) {
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

    var notesCell = row.querySelector('.att-notes-cell');
    if (notesCell) {
        var html = '';
        if (notes) {
            var escaped = notes.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
            html += '<span class="text-dark d-block" title="'+escaped+'" style="display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">'+escaped+'</span>';
        }
        if (attachmentUrl) {
            html += '<div class="d-flex align-items-center mt-1" style="gap:6px;">'
                  + '<a href="'+attachmentUrl+'" download class="d-inline-flex align-items-center small text-secondary" title="Descargar sustento"><i class="fas fa-paperclip mr-1"></i>Sustento adjunto</a>'
                  + '<button type="button" class="btn btn-link p-0 text-danger" style="font-size:11px;line-height:1;" title="Eliminar adjunto" onclick="deleteAttachment(\''+userId+'\', this)"><i class="fas fa-times-circle"></i></button>'
                  + '</div>';
        }
        notesCell.innerHTML = html || '<span class="text-muted">&mdash;</span>';
    }

    // Botones de la fila (admin: btn-group; tutor: botón Modificar)
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
    var notes       = document.getElementById('attNotesInput').value.trim();

    var saveBtn    = document.getElementById('attSaveBtn');
    var singleUser = saveBtn.getAttribute('data-single-user');

    // Determinar lista de usuarios a guardar
    var userIds = [];
    if (singleUser) {
        userIds = [singleUser];
    } else {
        userIds = Array.from(document.querySelectorAll('.att-cb:checked')).map(function(cb) { return cb.value; });
    }

    if (userIds.length === 0) { alert('Selecciona al menos un alumno.'); return; }

    saveBtn.disabled = true;
    saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i> Guardando…';

    var fileInput  = document.getElementById('attFileInput');
    var fileToSend = (fileInput && fileInput.files && fileInput.files[0]) ? fileInput.files[0] : null;

    var errors = 0;
    for (var i = 0; i < userIds.length; i++) {
        var uid = userIds[i];
        try {
            var fd = new FormData();
            fd.append('action',        'mark_student_attendance');
            fd.append('user_id',       uid);
            fd.append('classroom_id',  ATT_CLASSROOM);
            fd.append('date',          ATT_DATE);
            fd.append('status',        status);
            fd.append('check_in_time', checkInTime);
            fd.append('notes',         notes);
            if (fileToSend && (status === 'late' || status === 'absent')) {
                fd.append('attachment', fileToSend, fileToSend.name);
            }
            var resp = await fetch(AJAX_URL, { method: 'POST', body: fd });
            var data = await resp.json();
            if (data.success) {
                updateRowUI(uid, status, data.att_time || '', notes, data.attachment_url || '');
            } else {
                errors++;
                console.warn('Error al guardar alumno '+uid+':', data.error);
            }
        } catch(e) {
            errors++;
        }
    }

    saveBtn.disabled = false;
    saveBtn.innerHTML = '<i class="fas fa-save mr-1"></i> Guardar';

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

// Contador de caracteres del comentario
document.getElementById('attNotesInput').addEventListener('input', function() {
    document.getElementById('attNotesCount').textContent = this.value.length + '/500';
});

// ---- Eliminar adjunto ----
async function deleteAttachment(userId, btn) {
    if (!confirm('¿Eliminar el documento adjunto de este registro?')) return;

    btn.disabled = true;
    try {
        var fd = new FormData();
        fd.append('action',       'delete_attendance_attachment');
        fd.append('user_id',      userId);
        fd.append('date',         ATT_DATE);
        fd.append('classroom_id', ATT_CLASSROOM);
        var resp = await fetch(AJAX_URL, { method: 'POST', body: fd });
        var data = await resp.json();
        if (data.success) {
            // Eliminar el bloque del adjunto de la celda
            var row = document.querySelector('tr[data-user-id="'+userId+'"]');
            if (row) {
                var cell = row.querySelector('.att-notes-cell');
                if (cell) {
                    var attachDiv = cell.querySelector('.d-flex');
                    if (attachDiv) attachDiv.remove();
                    // Si la celda quedó vacía, mostrar guión
                    if (!cell.textContent.trim()) {
                        cell.innerHTML = '<span class="text-muted">&mdash;</span>';
                    }
                }
            }
        } else {
            alert(data.error || 'No se pudo eliminar el adjunto.');
            btn.disabled = false;
        }
    } catch(e) {
        alert('Error al eliminar el adjunto.');
        btn.disabled = false;
    }
}
</script>
{% endif %}

{# ===== Modal: Exportar Excel de Asistencias ===== #}
{% if classroom %}
<div class="modal fade" id="exportExcelModal" tabindex="-1" aria-labelledby="exportExcelModalLabel">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exportExcelModalLabel">
                    <i class="fas fa-file-excel mr-2 text-success"></i>Exportar Asistencias a Excel
                </h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <p class="text-muted small mb-3">
                    Selecciona el rango de fechas para exportar las asistencias del aula
                    <strong>{{ classroom.grade_name }}{% if classroom.section_name %} Sec. {{ classroom.section_name }}{% endif %}</strong>.
                </p>
                <div class="form-group">
                    <label class="font-weight-bold small">Fecha inicial</label>
                    <input type="date" id="exportStartDate" class="form-control"
                           max="{{ "now"|date("Y-m-d") }}">
                </div>
                <div class="form-group mb-0">
                    <label class="font-weight-bold small">Fecha final</label>
                    <input type="date" id="exportEndDate" class="form-control"
                           value="{{ "now"|date("Y-m-d") }}"
                           max="{{ "now"|date("Y-m-d") }}">
                </div>
                <div id="exportExcelError" class="alert alert-danger mt-3 d-none small py-2"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-success btn-sm" id="exportExcelBtn" onclick="doExportExcel()">
                    <i class="fas fa-download mr-1"></i> Descargar Excel
                </button>
            </div>
        </div>
    </div>
</div>

<script>
(function() {
    // Set default start date to first day of current month
    var now = new Date();
    var firstDay = now.getFullYear() + '-' +
        String(now.getMonth() + 1).padStart(2, '0') + '-01';
    document.getElementById('exportStartDate').value = firstDay;
})();

function doExportExcel() {
    var start = document.getElementById('exportStartDate').value;
    var end   = document.getElementById('exportEndDate').value;
    var errEl = document.getElementById('exportExcelError');
    errEl.classList.add('d-none');
    errEl.textContent = '';

    if (!start) {
        errEl.textContent = 'Por favor selecciona la fecha inicial.';
        errEl.classList.remove('d-none');
        return;
    }
    if (!end) {
        errEl.textContent = 'Por favor selecciona la fecha final.';
        errEl.classList.remove('d-none');
        return;
    }
    if (start > end) {
        errEl.textContent = 'La fecha inicial no puede ser mayor que la fecha final.';
        errEl.classList.remove('d-none');
        return;
    }

    var classroomId = {{ classroom_id }};
    var ajaxBase = '{{ ajax_attendance_url }}';
    var url = ajaxBase + '?action=export_excel_classroom'
            + '&classroom_id=' + classroomId
            + '&start_date='   + encodeURIComponent(start)
            + '&end_date='     + encodeURIComponent(end);

    document.getElementById('exportExcelBtn').innerHTML =
        '<i class="fas fa-spinner fa-spin mr-1"></i> Generando...';
    document.getElementById('exportExcelBtn').disabled = true;

    // Trigger download via hidden link
    var a = document.createElement('a');
    a.href = url;
    a.style.display = 'none';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    setTimeout(function() {
        document.getElementById('exportExcelBtn').innerHTML =
            '<i class="fas fa-download mr-1"></i> Descargar Excel';
        document.getElementById('exportExcelBtn').disabled = false;
        $('#exportExcelModal').modal('hide');
    }, 1500);
}
</script>
{% endif %}
