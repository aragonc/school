<div class="container-fluid px-3 py-3">

    {# Header #}
    <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap" style="gap:8px;">
        <div>
            <h5 class="mb-1 font-weight-bold text-dark">
                <i class="fas fa-clipboard-list text-primary mr-2"></i>
                Registro Auxiliar — {{ registro.period }}
            </h5>
            <p class="mb-0 text-muted small">
                {{ registro.classroom_label }}
                {% if registro.course_title %} &mdash; <strong>{{ registro.course_title }}</strong>{% endif %}
                {% if registro.area_name %} &mdash; {{ registro.area_name }}{% endif %}
            </p>
        </div>
        <div class="d-flex flex-wrap" style="gap:6px;">
            <button class="btn btn-sm btn-outline-secondary" onclick="openEditEnfoques()">
                <i class="fas fa-leaf mr-1"></i> Enfoques Transversales
            </button>
            <button class="btn btn-sm btn-outline-primary" onclick="openEditCompetencias()">
                <i class="fas fa-edit mr-1"></i> Editar competencias
            </button>
            <a href="/my-aula/registro/notas/exportar?id={{ registro_id }}"
               class="btn btn-sm btn-outline-success" title="Exportar a Excel">
                <i class="fas fa-file-excel mr-1"></i> Exportar Excel
            </a>
            <a href="/my-aula/registro" class="btn btn-sm btn-outline-secondary">
                <i class="fas fa-arrow-left mr-1"></i> Volver
            </a>
        </div>
    </div>

    {# Info row + tipo de nota #}
    <div class="card shadow-sm border-0 mb-3">
        <div class="card-body py-2 px-3">
            <div class="row small text-muted align-items-center">
                <div class="col-auto"><strong>Área:</strong> {{ registro.area_name ?: '—' }}</div>
                <div class="col-auto"><strong>Docente:</strong> {{ registro.teacher_name }}</div>
                <div class="col-auto"><strong>Tipo nota:</strong>
                    {% if registro.grade_type == 'numeric' %}Numérica (0–20)
                    {% elseif registro.grade_type == 'letter' %}Literal (AD/A/B/C)
                    {% else %}Combinada{% endif %}
                </div>
                {% if registro.grade_type == 'letter' or registro.grade_type == 'combined' %}
                <div class="col-auto text-info">
                    <i class="fas fa-info-circle"></i> AD ≥ 18 &nbsp; A 14–17 &nbsp; B 11–13 &nbsp; C ≤ 10
                </div>
                {% endif %}
            </div>
        </div>
    </div>

    {# ===== ENFOQUES TRANSVERSALES DISPLAY ===== #}
    {% if enfoques %}
    <div class="card shadow-sm border-0 mb-3" id="enfoques-card">
        <div class="card-header bg-light py-2 d-flex justify-content-between align-items-center">
            <span class="font-weight-bold small text-uppercase text-muted">
                <i class="fas fa-leaf text-success mr-1"></i>Valores y Actitudes de los Enfoques Transversales
            </span>
            <button class="btn btn-xs btn-outline-secondary btn-sm" onclick="openEditEnfoques()">
                <i class="fas fa-edit fa-xs"></i>
            </button>
        </div>
        <div class="card-body py-2 px-3">
            <div class="row">
                <div class="col-md-5">
                    <p class="mb-1 small"><strong>ENFOQUES:</strong>
                        {% for ef in enfoques %}{{ ef.nombre }}{% if not loop.last %}, {% endif %}{% endfor %}
                    </p>
                </div>
                <div class="col-md-7">
                    {% set all_valores = [] %}
                    {% set all_actitudes = [] %}
                    {% for ef in enfoques %}
                        {% if ef.valores %}{% set all_valores = all_valores|merge([ef.valores]) %}{% endif %}
                        {% if ef.actitudes %}{% set all_actitudes = all_actitudes|merge([ef.actitudes]) %}{% endif %}
                    {% endfor %}
                    {% if all_valores %}
                    <p class="mb-1 small"><strong>VALORES:</strong> {{ all_valores|join(', ') }}</p>
                    {% endif %}
                    {% if all_actitudes %}
                    <p class="mb-0 small"><strong>ACTITUDES:</strong> {{ all_actitudes|join(', ') }}</p>
                    {% endif %}
                </div>
            </div>
            {# Detail per enfoque #}
            {% if enfoques|length > 1 %}
            <div class="mt-2 border-top pt-2">
                <div class="row">
                {% for ef in enfoques %}
                <div class="col-md-4 mb-1">
                    <span class="badge badge-light border mr-1">{{ ef.nombre }}</span>
                    {% if ef.valores %}<span class="small text-muted">{{ ef.valores }}</span>{% endif %}
                </div>
                {% endfor %}
                </div>
            </div>
            {% endif %}
        </div>
    </div>
    {% else %}
    <div class="alert alert-light border d-flex justify-content-between align-items-center py-2 mb-3" id="enfoques-empty">
        <span class="small text-muted"><i class="fas fa-leaf mr-1"></i>No se han definido enfoques transversales para este registro.</span>
        <button class="btn btn-xs btn-outline-success btn-sm" onclick="openEditEnfoques()">
            <i class="fas fa-plus mr-1"></i>Agregar enfoques
        </button>
    </div>
    {% endif %}

    {% if not competencias %}
    <div class="card shadow-sm border-0">
        <div class="card-body text-center py-5">
            <i class="fas fa-layer-group fa-3x text-muted mb-3"></i>
            <p class="text-muted mb-2">Este registro no tiene competencias ni capacidades configuradas.</p>
            <button class="btn btn-primary" onclick="openEditCompetencias()">
                <i class="fas fa-plus mr-1"></i> Agregar competencias y capacidades
            </button>
        </div>
    </div>
    {% else %}

    {# ===== Grade Table ===== #}
    {# Pre-calculate total colspan for "COMPETENCIA DEL ÁREA" row #}
    {% set total_comp_cols = 0 %}
    {% for comp in competencias %}{% set total_comp_cols = total_comp_cols + comp.capacidades|length + 1 %}{% endfor %}

    <div class="card shadow-sm border-0 mb-3">
        <div class="card-body p-0">
            <div style="overflow-x:auto;">
                <table class="table table-bordered table-sm mb-0" id="tablaNotas" style="min-width:900px;font-size:0.8rem;">
                    <thead>

                        {# ── ROW 1: "COMPETENCIA DEL ÁREA" ── #}
                        <tr>
                            <th rowspan="5" class="align-middle text-center bg-light" style="min-width:38px;width:38px;">N°</th>
                            <th rowspan="5" class="align-middle bg-light" style="min-width:190px;">Apellidos y Nombres</th>
                            <th colspan="{{ total_comp_cols }}" class="text-center font-weight-bold text-uppercase"
                                style="background:#dce8fc;letter-spacing:1px;">
                                COMPETENCIA DEL ÁREA
                            </th>
                            <th rowspan="5" class="align-middle text-center font-weight-bold"
                                style="min-width:72px;background:#fff3cd;writing-mode:vertical-rl;transform:rotate(180deg);padding:6px;">
                                PROMEDIO DE LA ASIGNATURA
                            </th>
                        </tr>

                        {# ── ROW 2: competencia descriptions ── #}
                        <tr>
                            {% for comp in competencias %}
                            <th colspan="{{ comp.capacidades|length + 1 }}"
                                class="text-center"
                                style="background:#e8f0fe;font-size:0.75rem;padding:4px 6px;">
                                <span class="font-weight-bold text-primary">{{ comp.label }}_</span>{{ comp.name }}
                            </th>
                            {% endfor %}
                        </tr>

                        {# ── ROW 3: "CAPACIDADES" label + NIVEL DE LOGRO (rowspan=3) ── #}
                        <tr>
                            {% for comp in competencias %}
                            <th colspan="{{ comp.capacidades|length }}"
                                class="text-center font-weight-bold text-uppercase"
                                style="background:#e3eeff;font-size:0.72rem;letter-spacing:0.5px;">
                                CAPACIDADES
                            </th>
                            <th rowspan="3"
                                class="text-center font-weight-bold align-middle"
                                style="min-width:68px;background:#c8e6c9;writing-mode:vertical-rl;transform:rotate(180deg);padding:4px;font-size:0.72rem;letter-spacing:0.5px;">
                                NIVEL DE LOGRO
                            </th>
                            {% endfor %}
                        </tr>

                        {# ── ROW 4: individual capacidad names (vertical) ── #}
                        <tr>
                            {% for comp in competencias %}
                            {% for cap in comp.capacidades %}
                            <th class="text-center align-middle"
                                style="min-width:66px;max-width:86px;background:#f0f4ff;font-size:0.68rem;writing-mode:vertical-rl;transform:rotate(180deg);height:90px;padding:4px;"
                                title="{{ cap.name }}">
                                {{ cap.name }}
                            </th>
                            {% endfor %}
                            {# NIVEL DE LOGRO already occupies this cell via rowspan=3 #}
                            {% endfor %}
                        </tr>

                        {# ── ROW 5: CRITERIOS — one editable cell per capacidad ── #}
                        <tr style="background:#fffbf0;">
                            {% for comp in competencias %}
                            {% for cap in comp.capacidades %}
                            <td class="p-0 align-middle text-center" style="min-width:66px;position:relative;">
                                <textarea class="criterio-input form-control form-control-sm border-0 text-center p-1"
                                          style="resize:none;font-size:0.7rem;background:transparent;height:34px;width:100%;"
                                          data-registro="{{ registro_id }}"
                                          data-cap="{{ cap.aux_cap_id }}"
                                          placeholder="Criterio…"
                                          title="Criterio para: {{ cap.name }}">{{ cap.criterio }}</textarea>
                                <button class="btn btn-link p-0 d-block w-100 import-notes-btn"
                                        style="font-size:9px;line-height:1.4;color:#3b7dd8;border-top:1px solid #e8e0c8;"
                                        onclick="openImportModal({{ cap.aux_cap_id }}, '{{ cap.name|e('js') }}')"
                                        title="Importar notas desde Chamilo">
                                    <i class="fas fa-plus-circle"></i>
                                </button>
                            </td>
                            {% endfor %}
                            {# NIVEL DE LOGRO cell covered by rowspan=3 from row 3 #}
                            {% endfor %}
                        </tr>

                    </thead>
                    <tbody>
                        {% for student in students %}
                        <tr data-student="{{ student.user_id }}">
                            <td class="text-center text-muted align-middle">{{ loop.index }}</td>
                            <td class="font-weight-bold small align-middle">{{ student.lastname }}, {{ student.firstname }}</td>
                            {% for comp in competencias %}
                            {% for cap in comp.capacidades %}
                            {% set nota_val = notas_map[cap.aux_cap_id][student.user_id] ?? '' %}
                            <td class="text-center p-0 align-middle">
                                <input type="text"
                                       class="nota-input form-control form-control-sm text-center p-0 border-0"
                                       style="min-width:60px;font-size:0.85rem;"
                                       data-registro="{{ registro_id }}"
                                       data-cap="{{ cap.aux_cap_id }}"
                                       data-student="{{ student.user_id }}"
                                       value="{{ nota_val }}"
                                       maxlength="5"
                                       placeholder="—">
                            </td>
                            {% endfor %}
                            <td class="text-center font-weight-bold align-middle nivel-logro"
                                style="background:#f1faf1;"
                                data-comp="{{ comp.rc_id }}"
                                data-student="{{ student.user_id }}"
                                data-cap-ids="{{ comp.cap_ids|join(',') }}">—</td>
                            {% endfor %}
                            <td class="text-center font-weight-bold align-middle promedio-cell"
                                style="background:#fffde7;"
                                data-student="{{ student.user_id }}">—</td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-end mb-3">
        <button class="btn btn-success btn-sm" id="btnSaveAll" onclick="saveAllNotas()">
            <i class="fas fa-save mr-1"></i> Guardar todo
        </button>
        <span id="saveStatus" class="ml-3 align-self-center text-muted small"></span>
    </div>

    {% endif %}
</div>

{# ===== Modal: Importar Notas desde Chamilo ===== #}
<div class="modal fade" id="modalImportGrades" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white py-2">
                <h6 class="modal-title mb-0">
                    <i class="fas fa-file-import mr-2"></i>Importar notas &mdash; <span id="importCapName" class="font-weight-bold"></span>
                </h6>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body pb-2">
                <ul class="nav nav-tabs nav-sm mb-3" id="importTabs" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link active small py-1 px-3" href="#" data-tab="exercise"
                           onclick="switchImportTab('exercise'); return false;">
                            <i class="fas fa-tasks mr-1"></i>Ejercicios / Exámenes
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link small py-1 px-3" href="#" data-tab="task"
                           onclick="switchImportTab('task'); return false;">
                            <i class="fas fa-file-alt mr-1"></i>Tareas
                        </a>
                    </li>
                </ul>

                <div class="form-group mb-2">
                    <label class="font-weight-bold small mb-1">Seleccionar actividad:</label>
                    <select id="selImportActivity" class="form-control form-control-sm" onchange="loadActivityGrades()">
                        <option value="">— Cargando actividades… —</option>
                    </select>
                </div>

                <div id="importGradesContainer" style="display:none;">
                    <div class="d-flex justify-content-between align-items-center mb-1">
                        <span class="small font-weight-bold text-muted">Notas por estudiante:</span>
                        <span class="small text-info" id="importGradeScale"></span>
                    </div>
                    <div style="max-height:320px;overflow-y:auto;">
                        <table class="table table-sm table-bordered mb-0" id="importGradesTable">
                            <thead class="thead-light">
                                <tr>
                                    <th class="small">Apellidos y Nombres</th>
                                    <th class="text-center small" style="width:110px;">Nota en Chamilo</th>
                                    <th class="text-center small" style="width:110px;">Nota a registrar</th>
                                </tr>
                            </thead>
                            <tbody id="importGradesBody"></tbody>
                        </table>
                    </div>
                </div>

                <div id="importNoActivities" class="text-center text-muted small py-3" style="display:none;">
                    <i class="fas fa-info-circle mr-1"></i>No hay actividades disponibles de este tipo para este curso.
                </div>
                <div id="importNoGrades" class="text-center text-muted small py-2" style="display:none;">
                    <i class="fas fa-exclamation-circle mr-1"></i>No se encontraron notas para esta actividad.
                </div>
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-sm btn-primary" id="btnApplyImport"
                        onclick="applyImportedGrades()" style="display:none;">
                    <i class="fas fa-check mr-1"></i> Aplicar notas a la columna
                </button>
            </div>
        </div>
    </div>
</div>

{# ===== Modal: Enfoques Transversales ===== #}
<div class="modal fade" id="modalEnfoques" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title"><i class="fas fa-leaf mr-2"></i>Enfoques Transversales del Registro</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p class="text-muted small mb-3">
                    Selecciona los enfoques del currículo — los valores se cargan automáticamente y puedes ajustarlos.
                </p>

                <div class="row mb-3">
                    <div class="col-md-8">
                        <label class="font-weight-bold small">Agregar desde currículo:</label>
                        <div class="d-flex" style="gap:6px;">
                            <select id="selEnfoqueCurr" class="form-control form-control-sm">
                                <option value="">— Selecciona enfoque —</option>
                            </select>
                            <button class="btn btn-sm btn-success px-3" onclick="addEnfoqueFromSelect()">
                                <i class="fas fa-plus"></i>
                            </button>
                        </div>
                        <small class="text-muted" id="valoresPreview"></small>
                    </div>
                    <div class="col-md-4 align-self-end">
                        <button class="btn btn-sm btn-outline-secondary" onclick="addEnfoqueCustom()">
                            <i class="fas fa-plus mr-1"></i>Personalizado
                        </button>
                    </div>
                </div>

                <div id="enfoquesList"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-success" id="btnSaveEnfoques" onclick="saveEnfoques()">
                    <i class="fas fa-save mr-1"></i> Guardar enfoques
                </button>
            </div>
        </div>
    </div>
</div>

{# ===== Modal: Editar Competencias & Capacidades ===== #}
<div class="modal fade" id="modalEditComp" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title"><i class="fas fa-edit mr-2"></i>Configurar Competencias y Capacidades</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-5">
                        <h6 class="font-weight-bold text-muted mb-2">Disponibles del Área Curricular</h6>
                        <div class="form-group mb-2">
                            <select id="filterArea" class="form-control form-control-sm" onchange="loadAreaCurricula()">
                                <option value="0">— Selecciona un área —</option>
                                {% for area in areas %}
                                <option value="{{ area.id }}"{% if area.id == registro.area_id %} selected{% endif %}>{{ area.name }}</option>
                                {% endfor %}
                            </select>
                        </div>
                        <div id="availableComp" style="max-height:420px;overflow-y:auto;border:1px solid #dee2e6;border-radius:4px;padding:8px;">
                            <p class="text-muted small m-0">Selecciona un área para ver competencias y capacidades.</p>
                        </div>
                    </div>
                    <div class="col-md-7">
                        <h6 class="font-weight-bold text-muted mb-2">Competencias seleccionadas para el registro</h6>
                        <div id="selectedComps" style="max-height:420px;overflow-y:auto;border:1px solid #dee2e6;border-radius:4px;padding:8px;">
                        </div>
                        <button class="btn btn-sm btn-outline-secondary mt-2" onclick="addCustomCompetencia()">
                            <i class="fas fa-plus mr-1"></i> Añadir competencia personalizada
                        </button>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnSaveComp" onclick="saveCompetencias()">
                    <i class="fas fa-save mr-1"></i> Guardar configuración
                </button>
            </div>
        </div>
    </div>
</div>

<script>
const AJAX_URL    = '{{ ajax_url }}';
const REGISTRO_ID = {{ registro_id }};
const GRADE_TYPE  = '{{ registro.grade_type }}';

// ==================== NOTA HELPERS ====================

function letterToNum(val) {
    const map = { 'AD': 19, 'A': 16, 'B': 12, 'C': 8 };
    const v = val.trim().toUpperCase();
    return map[v] !== undefined ? map[v] : (isNaN(parseFloat(v)) ? null : parseFloat(v));
}

function numToLetter(n) {
    if (n === null || n === undefined) return '—';
    if (n >= 18) return 'AD';
    if (n >= 14) return 'A';
    if (n >= 11) return 'B';
    return 'C';
}

function formatDisplay(avg) {
    if (avg === null) return '—';
    if (GRADE_TYPE === 'numeric') return avg.toFixed(0);
    if (GRADE_TYPE === 'letter')  return numToLetter(avg);
    return avg.toFixed(0) + ' (' + numToLetter(avg) + ')';
}

// ==================== CALCULATE AVERAGES ====================

function recalcAll() {
    $('[data-student]').filter('tr').each(function() {
        const $row      = $(this);
        const nivelVals = [];

        $row.find('.nivel-logro').each(function() {
            const $cell  = $(this);
            const capIds = ($cell.data('cap-ids') || '').toString().split(',').filter(Boolean);
            const vals   = [];
            capIds.forEach(function(capId) {
                const num = letterToNum(($row.find('input.nota-input[data-cap="' + capId + '"]').val() || '').trim());
                if (num !== null) vals.push(num);
            });
            if (vals.length) {
                const avg = vals.reduce(function(a, b) { return a + b; }, 0) / vals.length;
                $cell.text(formatDisplay(avg));
                nivelVals.push(avg);
            } else {
                $cell.text('—');
            }
        });

        const $prom = $row.find('.promedio-cell');
        if (nivelVals.length) {
            const prom = nivelVals.reduce(function(a, b) { return a + b; }, 0) / nivelVals.length;
            $prom.text(formatDisplay(prom));
        } else {
            $prom.text('—');
        }
    });
}

// ==================== CRITERIO AUTO-SAVE ====================

$(document).on('blur', 'textarea.criterio-input', function() {
    const $ta       = $(this);
    const registroId = $ta.data('registro');
    const capId     = $ta.data('cap');
    const criterio  = $ta.val().trim();

    $.post(AJAX_URL, {
        action: 'save_criterio',
        registro_id: registroId,
        aux_capacidad_id: capId,
        criterio: criterio
    }, function(res) {
        if (res.success) {
            $ta.css('background', '#e6ffed');
            setTimeout(function() { $ta.css('background', 'transparent'); }, 700);
        }
    }, 'json');
});

// ==================== NOTA AUTO-SAVE ====================

$(document).on('blur', 'input.nota-input', function() {
    const $inp       = $(this);
    recalcAll();
    $.post(AJAX_URL, {
        action: 'save_nota',
        registro_id: $inp.data('registro'),
        aux_capacidad_id: $inp.data('cap'),
        student_id: $inp.data('student'),
        nota: $inp.val().trim()
    }, function(res) {
        if (res.success) {
            $inp.css('background', '#e6ffed');
            setTimeout(function() { $inp.css('background', ''); }, 800);
        }
    }, 'json');
});

$(document).on('input', 'input.nota-input', function() { recalcAll(); });

$(document).on('keydown', 'input.nota-input', function(e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        const $all = $('input.nota-input');
        $all.eq($all.index(this) + 1).focus();
    }
});

// ==================== SAVE ALL ====================

function saveAllNotas() {
    const notas = [];
    $('input.nota-input').each(function() {
        const $inp = $(this);
        notas.push({ aux_capacidad_id: $inp.data('cap'), student_id: $inp.data('student'), nota: $inp.val().trim() });
    });
    $('#btnSaveAll').prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i> Guardando...');
    $.post(AJAX_URL, { action: 'save_notas_bulk', registro_id: REGISTRO_ID, notas: JSON.stringify(notas) }, function(res) {
        if (res.success) {
            $('#saveStatus').html('<span class="text-success"><i class="fas fa-check-circle mr-1"></i>Guardado</span>');
            setTimeout(function() { $('#saveStatus').html(''); }, 3000);
        } else {
            $('#saveStatus').html('<span class="text-danger">Error: ' + (res.message || '') + '</span>');
        }
        $('#btnSaveAll').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar todo');
    }, 'json').fail(function() {
        $('#saveStatus').html('<span class="text-danger">Error de comunicación</span>');
        $('#btnSaveAll').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar todo');
    });
}

// ==================== ENFOQUES ====================

let selectedEnfoques  = [];
let _enfoquesCache    = [];  // curricula enfoques with valores_list

function openEditEnfoques() {
    selectedEnfoques = [];
    {% for ef in enfoques %}
    selectedEnfoques.push({
        enfoque_id: {{ ef.enfoque_id }},
        nombre:     {{ ef.nombre|json_encode }},
        valores:    {{ ef.valores|json_encode }},
        actitudes:  {{ ef.actitudes|json_encode }}
    });
    {% endfor %}

    // Load curricula enfoques with valores if not cached
    if (_enfoquesCache.length === 0) {
        $.get(AJAX_URL, { action: 'get_enfoques_curricula' }, function(res) {
            if (res.success) {
                _enfoquesCache = res.enfoques || [];
                _populateEnfoqueSelect();
            }
        }, 'json');
    } else {
        _populateEnfoqueSelect();
    }

    renderEnfoquesList();
    $('#modalEnfoques').modal('show');
}

function _populateEnfoqueSelect() {
    const $sel = $('#selEnfoqueCurr');
    $sel.find('option:not(:first)').remove();
    _enfoquesCache.forEach(function(ef) {
        $sel.append('<option value="' + ef.id + '">' + escHtml(ef.name) + '</option>');
    });
}

// Show valores preview when enfoque is selected
$('#selEnfoqueCurr').on('change', function() {
    const id = parseInt($(this).val());
    if (!id || !_enfoquesCache.length) { $('#valoresPreview').text(''); return; }
    const ef = _enfoquesCache.find(function(e) { return e.id == id; });
    if (ef && ef.valores_list && ef.valores_list.length) {
        $('#valoresPreview').html('<i class="fas fa-check-circle text-success mr-1"></i>Valores: ' + ef.valores_list.join(', '));
    } else {
        $('#valoresPreview').text('Sin valores definidos en el currículo');
    }
});

function renderEnfoquesList() {
    if (!selectedEnfoques.length) {
        $('#enfoquesList').html('<p class="text-muted small text-center py-3">No hay enfoques añadidos.</p>');
        return;
    }
    let html = '';
    selectedEnfoques.forEach(function(ef, i) {
        html += '<div class="card mb-2 border" id="ef-row-' + i + '">'
              + '<div class="card-body py-2 px-3">'
              + '<div class="d-flex justify-content-between align-items-center mb-2">'
              + '<strong class="small"><i class="fas fa-leaf text-success mr-1"></i>' + escHtml(ef.nombre) + '</strong>'
              + '<button class="btn btn-xs btn-outline-danger btn-sm" onclick="removeEnfoque(' + i + ')"><i class="fas fa-times"></i></button>'
              + '</div>'
              + '<div class="form-row">'
              + '<div class="form-group col-md-6 mb-1">'
              + '<label class="small font-weight-bold mb-0">Valores:</label>'
              + '<textarea class="form-control form-control-sm ef-valores" rows="2" style="font-size:0.8rem;" '
              + 'data-idx="' + i + '" placeholder="Ej: Laboriosidad, Flexibilidad...">'
              + escHtml(ef.valores) + '</textarea>'
              + '</div>'
              + '<div class="form-group col-md-6 mb-1">'
              + '<label class="small font-weight-bold mb-0">Actitudes:</label>'
              + '<textarea class="form-control form-control-sm ef-actitudes" rows="2" style="font-size:0.8rem;" '
              + 'data-idx="' + i + '" placeholder="Ej: Demuestra empatía...">'
              + escHtml(ef.actitudes) + '</textarea>'
              + '</div>'
              + '</div>'
              + '</div></div>';
    });
    $('#enfoquesList').html(html);
}

// Sync textareas to array on input
$(document).on('input', '.ef-valores', function() {
    selectedEnfoques[$(this).data('idx')].valores = $(this).val();
});
$(document).on('input', '.ef-actitudes', function() {
    selectedEnfoques[$(this).data('idx')].actitudes = $(this).val();
});

function addEnfoqueFromSelect() {
    const $sel = $('#selEnfoqueCurr');
    const id   = parseInt($sel.val());
    if (!id) { alert('Selecciona un enfoque'); return; }

    const already = selectedEnfoques.some(function(e) { return e.enfoque_id == id; });
    if (already) { alert('Este enfoque ya fue añadido.'); return; }

    // Find in cache to auto-populate valores
    const efData   = _enfoquesCache.find(function(e) { return e.id == id; });
    const name     = efData ? efData.name : $sel.find('option:selected').text();
    const valStr   = efData && efData.valores_list ? efData.valores_list.join(', ') : '';

    selectedEnfoques.push({ enfoque_id: id, nombre: name, valores: valStr, actitudes: '' });
    $sel.val('');
    $('#valoresPreview').text('');
    renderEnfoquesList();
}

function addEnfoqueCustom() {
    const nombre = prompt('Nombre del enfoque:');
    if (!nombre || !nombre.trim()) return;
    selectedEnfoques.push({ enfoque_id: 0, nombre: nombre.trim(), valores: '', actitudes: '' });
    renderEnfoquesList();
}

function removeEnfoque(i) {
    selectedEnfoques.splice(i, 1);
    renderEnfoquesList();
}

function saveEnfoques() {
    // Values already synced live via input event handlers

    $('#btnSaveEnfoques').prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i>');
    $.post(AJAX_URL, {
        action: 'save_enfoques',
        registro_id: REGISTRO_ID,
        enfoques: JSON.stringify(selectedEnfoques)
    }, function(res) {
        if (res.success) {
            $('#modalEnfoques').modal('hide');
            location.reload();
        } else {
            alert(res.message || 'Error al guardar');
            $('#btnSaveEnfoques').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar enfoques');
        }
    }, 'json').fail(function() {
        alert('Error de comunicación');
        $('#btnSaveEnfoques').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar enfoques');
    });
}

// ==================== EDIT COMPETENCIAS MODAL ====================

let selectedComps = [];
let _curriculaCache = { competencias: [], capacidades: [], transversales: [] };

function openEditCompetencias() {
    selectedComps = [];
    {% for comp in competencias %}
    selectedComps.push({
        rc_id:          {{ comp.rc_id }},
        competencia_id: {{ comp.competencia_id }},
        is_transversal: {{ comp.is_transversal ? 1 : 0 }},
        label:          '{{ comp.label|e('js') }}',
        name:           {{ comp.name|json_encode }},
        capacidades: [
            {% for cap in comp.capacidades %}
            {
                aux_cap_id:     {{ cap.aux_cap_id }},
                capacidad_id:   {{ cap.capacidad_id }},
                is_transversal: {{ cap.is_transversal ? 1 : 0 }},
                name:           {{ cap.name|json_encode }},
                criterio:       {{ cap.criterio|json_encode }}
            }{% if not loop.last %},{% endif %}
            {% endfor %}
        ]
    });
    {% endfor %}

    renderSelectedComps();
    const areaId = parseInt($('#filterArea').val());
    if (areaId > 0) loadAreaCurricula();
    $('#modalEditComp').modal('show');
}

function renderSelectedComps() {
    let html = '';
    if (!selectedComps.length) {
        html = '<p class="text-muted small">No has seleccionado competencias aún.</p>';
    } else {
        selectedComps.forEach(function(comp, ci) {
            html += '<div class="border rounded p-2 mb-2" id="selcomp-' + ci + '">'
                  + '<div class="d-flex justify-content-between align-items-start">'
                  + '<div><span class="badge badge-primary mr-1">C' + (ci+1) + '</span>'
                  + '<strong class="small">' + escHtml(comp.name) + '</strong>'
                  + (comp.is_transversal ? '<span class="badge badge-info ml-1">Transversal</span>' : '')
                  + '</div>'
                  + '<button class="btn btn-xs btn-outline-danger btn-sm" onclick="removeComp(' + ci + ')"><i class="fas fa-times"></i></button>'
                  + '</div>'
                  + '<div class="mt-2 pl-2"><small class="text-muted font-weight-bold">Capacidades:</small>'
                  + '<div id="selcaps-' + ci + '">';
            comp.capacidades.forEach(function(cap, ki) {
                html += '<div class="d-flex justify-content-between align-items-center py-1 border-bottom">'
                      + '<span class="small">' + escHtml(cap.name) + '</span>'
                      + '<button class="btn btn-xs btn-outline-danger btn-sm" onclick="removeCap(' + ci + ',' + ki + ')"><i class="fas fa-minus"></i></button>'
                      + '</div>';
            });
            html += '</div></div></div>';
        });
    }
    $('#selectedComps').html(html);
}

function loadAreaCurricula() {
    const areaId = parseInt($('#filterArea').val());
    if (!areaId) {
        $('#availableComp').html('<p class="text-muted small m-0">Selecciona un área para ver competencias y capacidades.</p>');
        return;
    }
    $('#availableComp').html('<p class="text-muted small"><i class="fas fa-spinner fa-spin mr-1"></i>Cargando...</p>');
    $.get(AJAX_URL, { action: 'get_curricula_for_area', area_id: areaId }, function(res) {
        if (!res.success) { $('#availableComp').html('<p class="text-danger small">Error al cargar</p>'); return; }
        _curriculaCache = { competencias: res.competencias || [], capacidades: res.capacidades || [], transversales: res.transversales || [] };
        let html = '';

        if (_curriculaCache.competencias.length) {
            html += '<div class="mb-2"><strong class="small text-muted d-block mb-1">COMPETENCIAS DEL ÁREA</strong>';
            _curriculaCache.competencias.forEach(function(comp, i) {
                html += '<div class="d-flex justify-content-between align-items-center border-bottom py-1">'
                      + '<span class="small">' + escHtml(comp.name) + '</span>'
                      + '<button class="btn btn-xs btn-outline-primary btn-sm" onclick="addCompByIdx(' + i + ',0)"><i class="fas fa-plus"></i></button>'
                      + '</div>';
            });
            html += '</div>';
        }
        if (_curriculaCache.capacidades.length) {
            html += '<div class="mb-2"><strong class="small text-muted d-block mb-1">CAPACIDADES DEL ÁREA</strong>'
                  + '<p class="text-muted mb-1" style="font-size:0.7rem;">Se añaden a la última competencia seleccionada</p>';
            _curriculaCache.capacidades.forEach(function(cap, i) {
                html += '<div class="d-flex justify-content-between align-items-center border-bottom py-1">'
                      + '<span class="small">' + escHtml(cap.name) + '</span>'
                      + '<button class="btn btn-xs btn-outline-success btn-sm" onclick="addCapByIdx(' + i + ',0)"><i class="fas fa-plus"></i></button>'
                      + '</div>';
            });
            html += '</div>';
        }
        if (_curriculaCache.transversales.length) {
            html += '<div class="mb-2"><strong class="small text-muted d-block mb-1">COMPETENCIAS TRANSVERSALES</strong>';
            _curriculaCache.transversales.forEach(function(trans, ti) {
                html += '<div class="border rounded p-2 mb-1">'
                      + '<div class="d-flex justify-content-between align-items-center">'
                      + '<span class="small font-weight-bold">' + escHtml(trans.name) + '</span>'
                      + '<button class="btn btn-xs btn-outline-primary btn-sm" onclick="addTransComp(' + ti + ')"><i class="fas fa-plus"></i></button>'
                      + '</div>';
                if (trans.capacidades && trans.capacidades.length) {
                    html += '<div class="pl-2 mt-1">';
                    trans.capacidades.forEach(function(cap, ki) {
                        html += '<div class="d-flex justify-content-between align-items-center border-bottom py-1">'
                              + '<span class="small text-muted">' + escHtml(cap.name) + '</span>'
                              + '<button class="btn btn-xs btn-outline-success btn-sm" onclick="addTransCap(' + ti + ',' + ki + ')"><i class="fas fa-plus"></i></button>'
                              + '</div>';
                    });
                    html += '</div>';
                }
                html += '</div>';
            });
            html += '</div>';
        }
        if (!html) html = '<p class="text-muted small">No hay competencias ni capacidades para esta área.</p>';
        $('#availableComp').html(html);
    }, 'json').fail(function() { $('#availableComp').html('<p class="text-danger small">Error al cargar</p>'); });
}

function addCompByIdx(idx, isTrans) {
    const comp = _curriculaCache.competencias[idx];
    if (comp) addCompFromArea(comp.id, isTrans, comp.name);
}
function addCapByIdx(idx, isTrans) {
    const cap = _curriculaCache.capacidades[idx];
    if (cap) addCapToLastComp(cap.id, isTrans, cap.name);
}
function addTransComp(ti) {
    const trans = _curriculaCache.transversales[ti];
    if (trans) addCompFromArea(trans.id, 1, trans.name);
}
function addTransCap(ti, ki) {
    const trans = _curriculaCache.transversales[ti];
    if (trans && trans.capacidades[ki]) addTransCapToComp(trans.id, trans.capacidades[ki].id, trans.capacidades[ki].name);
}

function addCompFromArea(compId, isTrans, name) {
    if (selectedComps.some(function(c) { return c.competencia_id == compId && c.is_transversal == isTrans; })) {
        alert('Esta competencia ya fue añadida.'); return;
    }
    selectedComps.push({ rc_id: null, competencia_id: compId, is_transversal: isTrans, name: name, capacidades: [] });
    renderSelectedComps();
}
function addCapToLastComp(capId, isTrans, name) {
    if (!selectedComps.length) { alert('Primero añade una competencia.'); return; }
    const last = selectedComps[selectedComps.length - 1];
    if (last.capacidades.some(function(c) { return c.capacidad_id == capId && c.is_transversal == isTrans; })) {
        alert('Esta capacidad ya fue añadida.'); return;
    }
    last.capacidades.push({ aux_cap_id: null, capacidad_id: capId, is_transversal: isTrans, name: name });
    renderSelectedComps();
}
function addTransCapToComp(transId, capId, name) {
    const comp = selectedComps.find(function(c) { return c.competencia_id == transId && c.is_transversal == 1; });
    if (!comp) { alert('Primero añade la competencia transversal correspondiente.'); return; }
    if (comp.capacidades.some(function(c) { return c.capacidad_id == capId && c.is_transversal == 1; })) {
        alert('Esta capacidad ya fue añadida.'); return;
    }
    comp.capacidades.push({ aux_cap_id: null, capacidad_id: capId, is_transversal: 1, name: name });
    renderSelectedComps();
}
function removeComp(ci) {
    if (!confirm('¿Eliminar esta competencia? Se perderán las notas asociadas.')) return;
    selectedComps.splice(ci, 1); renderSelectedComps();
}
function removeCap(ci, ki) { selectedComps[ci].capacidades.splice(ki, 1); renderSelectedComps(); }
function addCustomCompetencia() {
    const name = prompt('Nombre de la competencia:');
    if (!name || !name.trim()) return;
    selectedComps.push({ rc_id: null, competencia_id: 0, is_transversal: 0, name: name.trim(), capacidades: [] });
    renderSelectedComps();
}
function saveCompetencias() {
    if (!selectedComps.length) { alert('Debes añadir al menos una competencia.'); return; }
    for (let i = 0; i < selectedComps.length; i++) {
        if (!selectedComps[i].capacidades.length) {
            alert('La competencia "' + selectedComps[i].name + '" no tiene capacidades.'); return;
        }
    }
    const payload = selectedComps.map(function(c) {
        return {
            competencia_id: c.competencia_id,
            is_transversal: c.is_transversal,
            capacidades: c.capacidades.map(function(cap) {
                return { capacidad_id: cap.capacidad_id, is_transversal: cap.is_transversal };
            })
        };
    });
    $('#btnSaveComp').prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i>');
    $.post(AJAX_URL, { action: 'save_competencias', registro_id: REGISTRO_ID, competencias: JSON.stringify(payload) }, function(res) {
        if (res.success) { location.reload(); }
        else { alert(res.message || 'Error al guardar'); $('#btnSaveComp').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar configuración'); }
    }, 'json').fail(function() {
        alert('Error de comunicación');
        $('#btnSaveComp').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar configuración');
    });
}

function escHtml(str) {
    if (!str) return '';
    return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ==================== IMPORT GRADES MODAL ====================

var _importCapId   = null;
var _importTab     = 'exercise';
var _importActs    = { exercise: [], task: [] };
var _importLoaded  = false;

function openImportModal(capId, capName) {
    _importCapId  = capId;
    _importTab    = 'exercise';
    _importLoaded = false;

    $('#importCapName').text(capName);
    $('#importTabs .nav-link').removeClass('active');
    $('#importTabs .nav-link[data-tab="exercise"]').addClass('active');
    $('#selImportActivity').html('<option value="">— Cargando actividades… —</option>');
    $('#importGradesContainer').hide();
    $('#importNoActivities').hide();
    $('#importNoGrades').hide();
    $('#btnApplyImport').prop('disabled', false)
        .html('<i class="fas fa-check mr-1"></i> Aplicar notas a la columna').hide();

    $('#modalImportGrades').modal('show');

    $.get(AJAX_URL, { action: 'get_chamilo_activities', registro_id: REGISTRO_ID }, function(res) {
        _importLoaded = true;
        if (res.success) {
            _importActs = { exercise: res.exercises || [], task: res.tasks || [] };
        } else {
            _importActs = { exercise: [], task: [] };
        }
        _populateImportSelect();
    }, 'json').fail(function() {
        _importActs = { exercise: [], task: [] };
        _populateImportSelect();
    });
}

function switchImportTab(tab) {
    _importTab = tab;
    $('#importTabs .nav-link').removeClass('active');
    $('#importTabs .nav-link[data-tab="' + tab + '"]').addClass('active');
    $('#importGradesContainer').hide();
    $('#importNoGrades').hide();
    $('#btnApplyImport').hide();
    if (_importLoaded) _populateImportSelect();
}

function _populateImportSelect() {
    var acts = _importActs[_importTab] || [];
    var $sel = $('#selImportActivity');
    $sel.html('<option value="">— Selecciona una actividad —</option>');
    if (!acts.length) {
        $('#importNoActivities').show();
        return;
    }
    $('#importNoActivities').hide();
    acts.forEach(function(a) {
        $sel.append('<option value="' + a.id + '">' + escHtml(a.title) + '</option>');
    });
}

function loadActivityGrades() {
    var actId = $('#selImportActivity').val();
    $('#importGradesContainer').hide();
    $('#importNoGrades').hide();
    $('#btnApplyImport').hide();
    if (!actId) return;

    $.get(AJAX_URL, {
        action: 'get_activity_grades',
        registro_id: REGISTRO_ID,
        type: _importTab,
        activity_id: actId
    }, function(res) {
        if (!res.success) { $('#importNoGrades').show(); return; }
        _renderImportTable(res.grades || {}, res.max_score || 20);
    }, 'json').fail(function() { $('#importNoGrades').show(); });
}

function _renderImportTable(grades, maxScore) {
    var $tbody = $('#importGradesBody');
    $tbody.empty();
    var count = 0;

    $('tr[data-student]').each(function() {
        var $row = $(this);
        var sid  = $row.data('student');
        var name = $row.find('td:nth-child(2)').text().trim();
        var chamGrade = (grades[sid] !== undefined) ? grades[sid] : null;
        var currentVal = $('input.nota-input[data-cap="' + _importCapId + '"][data-student="' + sid + '"]').val() || '';
        var registerVal = chamGrade !== null ? _formatImportGrade(chamGrade) : currentVal;
        var displayGrade = chamGrade !== null
            ? '<span class="badge badge-info">' + parseFloat(chamGrade).toFixed(1) + '</span>'
            : '<span class="text-muted">—</span>';

        $tbody.append(
            '<tr>'
            + '<td class="small align-middle py-1">' + escHtml(name) + '</td>'
            + '<td class="text-center align-middle py-1">' + displayGrade + '</td>'
            + '<td class="text-center p-1">'
            + '<input type="text" class="form-control form-control-sm text-center import-grade-inp"'
            + ' data-sid="' + sid + '" value="' + escHtml(registerVal) + '" maxlength="5">'
            + '</td>'
            + '</tr>'
        );
        count++;
    });

    if (!count) { $('#importNoGrades').show(); return; }

    var scaleHint = GRADE_TYPE === 'letter' ? 'Escala: AD / A / B / C'
                  : GRADE_TYPE === 'numeric' ? 'Escala: 0 – 20'
                  : 'Escala combinada';
    $('#importGradeScale').text(scaleHint + ' · Puntaje máx. Chamilo: ' + maxScore);
    $('#importGradesContainer').show();
    $('#btnApplyImport').show();
}

function _formatImportGrade(num) {
    if (GRADE_TYPE === 'letter')  return numToLetter(num);
    if (GRADE_TYPE === 'numeric') return Math.round(num).toString();
    return Math.round(num) + ' (' + numToLetter(num) + ')';
}

function applyImportedGrades() {
    var notas = [];
    $('#importGradesBody .import-grade-inp').each(function() {
        var $inp = $(this);
        var sid  = parseInt($inp.data('sid'));
        var val  = $inp.val().trim();
        $('input.nota-input[data-cap="' + _importCapId + '"][data-student="' + sid + '"]').val(val);
        notas.push({ aux_capacidad_id: _importCapId, student_id: sid, nota: val });
    });

    if (!notas.length) { $('#modalImportGrades').modal('hide'); return; }

    $('#btnApplyImport').prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i> Guardando…');

    $.post(AJAX_URL, {
        action: 'save_notas_bulk',
        registro_id: REGISTRO_ID,
        notas: JSON.stringify(notas)
    }, function(res) {
        if (res.success) {
            $('#btnApplyImport').prop('disabled', false)
                .html('<i class="fas fa-check mr-1"></i> Aplicar notas a la columna');
            $('#modalImportGrades').modal('hide');
            recalcAll();
            $('input.nota-input[data-cap="' + _importCapId + '"]').css('background', '#e6ffed');
            setTimeout(function() {
                $('input.nota-input[data-cap="' + _importCapId + '"]').css('background', '');
            }, 1200);
        } else {
            alert(res.message || 'Error al guardar');
            $('#btnApplyImport').prop('disabled', false).html('<i class="fas fa-check mr-1"></i> Aplicar notas a la columna');
        }
    }, 'json').fail(function() {
        alert('Error de comunicación');
        $('#btnApplyImport').prop('disabled', false).html('<i class="fas fa-check mr-1"></i> Aplicar notas a la columna');
    });
}

$(document).ready(function() {
    recalcAll();
    const areaId = parseInt('{{ registro.area_id }}');
    if (areaId > 0) $('#filterArea').val(areaId);
});
</script>
