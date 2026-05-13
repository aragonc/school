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
        <div class="d-flex" style="gap:6px; flex-wrap:wrap;">
            <button class="btn btn-sm btn-outline-primary" onclick="openEditCompetencias()">
                <i class="fas fa-edit mr-1"></i> Editar competencias
            </button>
            <a href="/my-aula/registro" class="btn btn-sm btn-outline-secondary">
                <i class="fas fa-arrow-left mr-1"></i> Volver
            </a>
        </div>
    </div>

    {# Info row #}
    <div class="card shadow-sm border-0 mb-3">
        <div class="card-body py-2 px-3">
            <div class="row small text-muted">
                <div class="col-auto"><strong>Área:</strong> {{ registro.area_name ?: '—' }}</div>
                <div class="col-auto"><strong>Docente:</strong> {{ registro.teacher_name }}</div>
                <div class="col-auto"><strong>Tipo nota:</strong>
                    {% if registro.grade_type == 'numeric' %}Numérica (0–20)
                    {% elseif registro.grade_type == 'letter' %}Literal (AD/A/B/C)
                    {% else %}Combinada{% endif %}
                </div>
                {% if registro.grade_type == 'letter' or registro.grade_type == 'combined' %}
                <div class="col-auto text-info">
                    <i class="fas fa-info-circle"></i> AD=18–20 &nbsp; A=14–17 &nbsp; B=11–13 &nbsp; C=0–10
                </div>
                {% endif %}
            </div>
        </div>
    </div>

    {% if not competencias %}
    {# No competencias yet #}
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
    <div class="card shadow-sm border-0 mb-3">
        <div class="card-body p-0">
            <div style="overflow-x:auto;">
                <table class="table table-bordered table-sm mb-0" id="tablaNotas" style="min-width:900px;">
                    <thead>
                        {# Row 1: Competencias header #}
                        <tr class="bg-light">
                            <th rowspan="3" class="align-middle text-center" style="min-width:40px;width:40px;">N°</th>
                            <th rowspan="3" class="align-middle" style="min-width:200px;">Apellidos y Nombres</th>
                            {% for comp in competencias %}
                            <th colspan="{{ comp.capacidades|length + 1 }}" class="text-center text-primary font-weight-bold" style="background:#e8f0fe;">
                                {{ comp.label }} — {{ comp.name|slice(0,50) }}{% if comp.name|length > 50 %}...{% endif %}
                            </th>
                            {% endfor %}
                            <th rowspan="3" class="align-middle text-center font-weight-bold" style="min-width:80px;background:#fff3cd;">
                                PROMEDIO
                            </th>
                        </tr>
                        {# Row 2: Capacidades label #}
                        <tr>
                            {% for comp in competencias %}
                            {% for cap in comp.capacidades %}
                            <th class="text-center small" style="min-width:70px;max-width:90px;background:#f0f4ff;font-size:0.7rem;writing-mode:vertical-rl;transform:rotate(180deg);height:80px;padding:4px;">
                                {{ cap.name }}
                            </th>
                            {% endfor %}
                            <th class="text-center small font-weight-bold" style="min-width:70px;background:#d4edda;">NIVEL<br>LOGRO</th>
                            {% endfor %}
                        </tr>
                    </thead>
                    <tbody>
                        {% for student in students %}
                        <tr data-student="{{ student.user_id }}">
                            <td class="text-center text-muted">{{ loop.index }}</td>
                            <td class="font-weight-bold small">{{ student.lastname }}, {{ student.firstname }}</td>
                            {% for comp in competencias %}
                            {% for cap in comp.capacidades %}
                            {% set nota_val = notas_map[cap.aux_cap_id][student.user_id] ?? '' %}
                            <td class="text-center p-0" data-comp="{{ comp.rc_id }}" data-cap="{{ cap.aux_cap_id }}">
                                <input type="text"
                                       class="nota-input form-control form-control-sm text-center p-0 border-0"
                                       style="min-width:60px;max-width:80px;font-size:0.85rem;"
                                       data-registro="{{ registro_id }}"
                                       data-cap="{{ cap.aux_cap_id }}"
                                       data-student="{{ student.user_id }}"
                                       value="{{ nota_val }}"
                                       maxlength="5"
                                       placeholder="—">
                            </td>
                            {% endfor %}
                            {# NIVEL DE LOGRO per competencia #}
                            <td class="text-center font-weight-bold nivel-logro" style="background:#f8fff8;"
                                data-comp="{{ comp.rc_id }}"
                                data-student="{{ student.user_id }}"
                                data-cap-ids="{{ comp.cap_ids|join(',') }}">
                                —
                            </td>
                            {% endfor %}
                            {# PROMEDIO ASIGNATURA #}
                            <td class="text-center font-weight-bold promedio-cell" style="background:#fffde7;"
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
                    {# Left: Available from area #}
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
                        <div id="availableComp" style="max-height:450px;overflow-y:auto;border:1px solid #dee2e6;border-radius:4px;padding:8px;">
                            <p class="text-muted small m-0">Selecciona un área para ver competencias y capacidades.</p>
                        </div>
                    </div>

                    {# Right: Selected competencias/capacidades #}
                    <div class="col-md-7">
                        <h6 class="font-weight-bold text-muted mb-2">Competencias seleccionadas para el registro</h6>
                        <div id="selectedComps" style="max-height:450px;overflow-y:auto;border:1px solid #dee2e6;border-radius:4px;padding:8px;">
                            {# Dynamically populated #}
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
    // For each student row, recalc nivel logro per competencia and overall promedio
    $('[data-student]').filter('tr').each(function() {
        const $row     = $(this);
        const stuId    = $row.data('student');
        const nivelVals = [];

        $row.find('.nivel-logro').each(function() {
            const $cell   = $(this);
            const capIds  = ($cell.data('cap-ids') || '').toString().split(',').filter(Boolean);
            const vals    = [];

            capIds.forEach(function(capId) {
                const $input = $row.find('input.nota-input[data-cap="' + capId + '"]');
                const num    = letterToNum(($input.val() || '').trim());
                if (num !== null) vals.push(num);
            });

            if (vals.length > 0) {
                const avg = vals.reduce((a, b) => a + b, 0) / vals.length;
                $cell.text(formatDisplay(avg));
                nivelVals.push(avg);
            } else {
                $cell.text('—');
            }
        });

        const $prom = $row.find('.promedio-cell');
        if (nivelVals.length > 0) {
            const prom = nivelVals.reduce((a, b) => a + b, 0) / nivelVals.length;
            $prom.text(formatDisplay(prom));
        } else {
            $prom.text('—');
        }
    });
}

// ==================== AUTO-SAVE ON BLUR ====================

$(document).on('blur', 'input.nota-input', function() {
    const $inp      = $(this);
    const registroId = $inp.data('registro');
    const capId     = $inp.data('cap');
    const studentId = $inp.data('student');
    const nota      = $inp.val().trim();

    recalcAll();

    $.post(AJAX_URL, {
        action: 'save_nota',
        registro_id: registroId,
        aux_capacidad_id: capId,
        student_id: studentId,
        nota: nota
    }, function(res) {
        if (res.success) {
            $inp.css('background', '#e6ffed');
            setTimeout(() => $inp.css('background', ''), 800);
        }
    }, 'json');
});

$(document).on('input', 'input.nota-input', function() {
    recalcAll();
});

$(document).on('keydown', 'input.nota-input', function(e) {
    if (e.key === 'Enter' || e.key === 'Tab') {
        // Move to next cell in same column
        const $all = $('input.nota-input');
        const idx  = $all.index(this);
        if (e.key === 'Enter') {
            e.preventDefault();
            const $next = $all.eq(idx + 1);
            if ($next.length) $next.focus();
        }
    }
});

// ==================== SAVE ALL ====================

function saveAllNotas() {
    const notas = [];
    $('input.nota-input').each(function() {
        const $inp = $(this);
        notas.push({
            aux_capacidad_id: $inp.data('cap'),
            student_id: $inp.data('student'),
            nota: $inp.val().trim()
        });
    });

    $('#btnSaveAll').prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i> Guardando...');

    $.post(AJAX_URL, {
        action: 'save_notas_bulk',
        registro_id: REGISTRO_ID,
        notas: JSON.stringify(notas)
    }, function(res) {
        if (res.success) {
            $('#saveStatus').html('<span class="text-success"><i class="fas fa-check-circle mr-1"></i>Guardado</span>');
            setTimeout(() => $('#saveStatus').html(''), 3000);
        } else {
            $('#saveStatus').html('<span class="text-danger">Error: ' + (res.message||'') + '</span>');
        }
        $('#btnSaveAll').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar todo');
    }, 'json').fail(function() {
        $('#saveStatus').html('<span class="text-danger">Error de comunicación</span>');
        $('#btnSaveAll').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar todo');
    });
}

// ==================== EDIT COMPETENCIAS MODAL ====================

// State: list of selected competencias
let selectedComps = [];

function openEditCompetencias() {
    // Build selectedComps from current table state
    selectedComps = [];
    {% for comp in competencias %}
    selectedComps.push({
        rc_id:         {{ comp.rc_id }},
        competencia_id: {{ comp.competencia_id }},
        is_transversal: {{ comp.is_transversal ? 1 : 0 }},
        label:         '{{ comp.label|e('js') }}',
        name:          {{ comp.name|json_encode }},
        capacidades:   [
            {% for cap in comp.capacidades %}
            {
                aux_cap_id:    {{ cap.aux_cap_id }},
                capacidad_id:  {{ cap.capacidad_id }},
                is_transversal: {{ cap.is_transversal ? 1 : 0 }},
                name:          {{ cap.name|json_encode }}
            }{% if not loop.last %},{% endif %}
            {% endfor %}
        ]
    });
    {% endfor %}

    renderSelectedComps();

    // Auto-load area if set
    const areaId = $('#filterArea').val();
    if (parseInt(areaId) > 0) {
        loadAreaCurricula();
    }

    $('#modalEditComp').modal('show');
}

function renderSelectedComps() {
    let html = '';
    if (!selectedComps.length) {
        html = '<p class="text-muted small">No has seleccionado competencias aún.</p>';
    } else {
        selectedComps.forEach(function(comp, ci) {
            html += `<div class="border rounded p-2 mb-2" id="selcomp-${ci}">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <span class="badge badge-primary mr-1">C${ci+1}</span>
                        <strong class="small">${escHtml(comp.name)}</strong>
                        ${comp.is_transversal ? '<span class="badge badge-info ml-1">Transversal</span>' : ''}
                    </div>
                    <button class="btn btn-xs btn-outline-danger btn-sm" onclick="removeComp(${ci})">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="mt-2 pl-2">
                    <small class="text-muted font-weight-bold">Capacidades:</small>
                    <div id="selcaps-${ci}">`;
            comp.capacidades.forEach(function(cap, ki) {
                html += `<div class="d-flex justify-content-between align-items-center py-1 border-bottom" id="selcap-${ci}-${ki}">
                    <span class="small">${escHtml(cap.name)}</span>
                    <button class="btn btn-xs btn-outline-danger btn-sm" onclick="removeCap(${ci},${ki})">
                        <i class="fas fa-minus"></i>
                    </button>
                </div>`;
            });
            html += `</div></div></div>`;
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
        if (!res.success) {
            $('#availableComp').html('<p class="text-danger small">Error al cargar</p>');
            return;
        }

        let html = '';

        // Competencias del área
        if (res.competencias.length) {
            html += '<div class="mb-3"><strong class="small text-muted">COMPETENCIAS DEL ÁREA</strong>';
            res.competencias.forEach(function(comp) {
                html += `<div class="d-flex justify-content-between align-items-center border-bottom py-1">
                    <span class="small">${escHtml(comp.name)}</span>
                    <button class="btn btn-xs btn-outline-primary btn-sm" onclick="addCompFromArea(${comp.id}, 0, ${JSON.stringify(escHtml(comp.name)).replace(/'/g,"&#39;")})">
                        <i class="fas fa-plus"></i>
                    </button>
                </div>`;
            });
            html += '</div>';
        }

        // Capacidades del área (para agregar a una competencia existente)
        if (res.capacidades.length) {
            html += '<div class="mb-3"><strong class="small text-muted">CAPACIDADES DEL ÁREA</strong>';
            html += '<p class="text-muted" style="font-size:0.7rem;">Haz clic en (+) para agregar a la última competencia seleccionada</p>';
            res.capacidades.forEach(function(cap) {
                html += `<div class="d-flex justify-content-between align-items-center border-bottom py-1">
                    <span class="small">${escHtml(cap.name)}</span>
                    <button class="btn btn-xs btn-outline-success btn-sm" onclick="addCapToLastComp(${cap.id}, 0, ${JSON.stringify(escHtml(cap.name)).replace(/'/g,"&#39;")})">
                        <i class="fas fa-plus"></i>
                    </button>
                </div>`;
            });
            html += '</div>';
        }

        // Competencias transversales
        if (res.transversales.length) {
            html += '<div class="mb-3"><strong class="small text-muted">COMPETENCIAS TRANSVERSALES</strong>';
            res.transversales.forEach(function(trans) {
                html += `<div class="border rounded p-2 mb-1">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="small font-weight-bold">${escHtml(trans.name)}</span>
                        <button class="btn btn-xs btn-outline-primary btn-sm" onclick="addCompFromArea(${trans.id}, 1, ${JSON.stringify(escHtml(trans.name)).replace(/'/g,"&#39;")})">
                            <i class="fas fa-plus"></i>
                        </button>
                    </div>`;
                if (trans.capacidades.length) {
                    html += '<div class="pl-2 mt-1">';
                    trans.capacidades.forEach(function(cap) {
                        html += `<div class="d-flex justify-content-between align-items-center border-bottom py-1">
                            <span class="small text-muted">${escHtml(cap.name)}</span>
                            <button class="btn btn-xs btn-outline-success btn-sm" onclick="addTransCapToComp(${trans.id}, ${cap.id}, ${JSON.stringify(escHtml(cap.name)).replace(/'/g,"&#39;")})">
                                <i class="fas fa-plus"></i>
                            </button>
                        </div>`;
                    });
                    html += '</div>';
                }
                html += '</div>';
            });
            html += '</div>';
        }

        if (!html) html = '<p class="text-muted small">No hay competencias ni capacidades para esta área.</p>';
        $('#availableComp').html(html);
    }, 'json').fail(function() {
        $('#availableComp').html('<p class="text-danger small">Error al cargar</p>');
    });
}

function addCompFromArea(compId, isTrans, name) {
    // Check not already added
    const exists = selectedComps.some(c => c.competencia_id == compId && c.is_transversal == isTrans);
    if (exists) {
        alert('Esta competencia ya fue añadida.');
        return;
    }
    selectedComps.push({
        rc_id: null,
        competencia_id: compId,
        is_transversal: isTrans,
        name: name,
        capacidades: []
    });
    renderSelectedComps();
}

function addCapToLastComp(capId, isTrans, name) {
    if (!selectedComps.length) {
        alert('Primero añade una competencia.');
        return;
    }
    const last = selectedComps[selectedComps.length - 1];
    const exists = last.capacidades.some(c => c.capacidad_id == capId && c.is_transversal == isTrans);
    if (exists) {
        alert('Esta capacidad ya fue añadida a la última competencia.');
        return;
    }
    last.capacidades.push({ aux_cap_id: null, capacidad_id: capId, is_transversal: isTrans, name: name });
    renderSelectedComps();
}

function addTransCapToComp(transId, capId, name) {
    // Find the transversal competencia in selected
    const comp = selectedComps.find(c => c.competencia_id == transId && c.is_transversal == 1);
    if (!comp) {
        alert('Primero añade la competencia transversal correspondiente.');
        return;
    }
    const exists = comp.capacidades.some(c => c.capacidad_id == capId && c.is_transversal == 1);
    if (exists) {
        alert('Esta capacidad ya fue añadida.');
        return;
    }
    comp.capacidades.push({ aux_cap_id: null, capacidad_id: capId, is_transversal: 1, name: name });
    renderSelectedComps();
}

function removeComp(ci) {
    if (!confirm('¿Eliminar esta competencia? Se perderán las notas asociadas a sus capacidades.')) return;
    selectedComps.splice(ci, 1);
    renderSelectedComps();
}

function removeCap(ci, ki) {
    selectedComps[ci].capacidades.splice(ki, 1);
    renderSelectedComps();
}

function addCustomCompetencia() {
    const name = prompt('Nombre de la competencia:');
    if (!name || !name.trim()) return;
    selectedComps.push({
        rc_id: null,
        competencia_id: 0,
        is_transversal: 0,
        name: name.trim(),
        capacidades: []
    });
    renderSelectedComps();
}

function saveCompetencias() {
    if (!selectedComps.length) {
        alert('Debes añadir al menos una competencia.');
        return;
    }
    for (let i = 0; i < selectedComps.length; i++) {
        if (!selectedComps[i].capacidades.length) {
            alert('La competencia "' + selectedComps[i].name + '" no tiene capacidades. Añade al menos una.');
            return;
        }
    }

    // Build payload
    const payload = selectedComps.map(c => ({
        competencia_id: c.competencia_id,
        is_transversal: c.is_transversal,
        capacidades: c.capacidades.map(cap => ({
            capacidad_id:  cap.capacidad_id,
            is_transversal: cap.is_transversal
        }))
    }));

    $('#btnSaveComp').prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i>');

    $.post(AJAX_URL, {
        action: 'save_competencias',
        registro_id: REGISTRO_ID,
        competencias: JSON.stringify(payload)
    }, function(res) {
        if (res.success) {
            location.reload();
        } else {
            alert(res.message || 'Error al guardar');
            $('#btnSaveComp').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar configuración');
        }
    }, 'json').fail(function() {
        alert('Error de comunicación');
        $('#btnSaveComp').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar configuración');
    });
}

function escHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

// Init: calculate averages on load
$(document).ready(function() {
    recalcAll();
    // Pre-load area curricula if area is set
    const areaId = parseInt('{{ registro.area_id }}');
    if (areaId > 0) {
        $('#filterArea').val(areaId);
    }
});
</script>
