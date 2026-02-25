{% set day_cols = ['Lunes','Martes','Miércoles','Jueves','Viernes'] %}

<style>
/* ---- Mi Aula: Calendario Mensual ---- */
.miAulaHeader {
    display: flex; align-items: center; justify-content: space-between;
    flex-wrap: wrap; gap: 10px; margin-bottom: 16px;
}
.miAulaNav { display: flex; align-items: center; gap: 8px; }
.miAulaNav .month-title {
    font-size: 1.25rem; font-weight: 700; min-width: 220px; text-align: center;
}
.miAulaMeta {
    font-size: 0.85rem; color: #555; margin-bottom: 12px;
    display: flex; gap: 16px; flex-wrap: wrap; align-items: center;
}

/* Calendar table */
.cal-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
.cal-table th {
    background: #1a4a8a; color: #fff; text-align: center;
    padding: 8px 4px; font-size: 0.85rem; text-transform: uppercase;
    letter-spacing: 0.5px;
}
.cal-table td {
    border: 1px solid #dee2e6; vertical-align: top;
    padding: 6px; min-height: 90px; width: 20%; font-size: 0.8rem;
}
.cal-day-num {
    font-weight: 700; font-size: 0.95rem; color: #1a4a8a;
    margin-bottom: 4px; display: block;
}
.cal-empty { background: #f8f9fa; }

/* Subject badges */
.plan-entry {
    background: #e8f0fe; border-left: 3px solid #1a4a8a;
    border-radius: 4px; padding: 3px 6px; margin-bottom: 4px;
    font-size: 0.75rem; cursor: pointer; transition: background 0.15s;
}
.plan-entry:hover { background: #cfe2ff; }
.plan-entry .pe-subject { font-weight: 700; color: #1a4a8a; }
.plan-entry .pe-topic   { color: #333; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%; display: block; }
.plan-entry .pe-teacher { color: #888; font-size: 0.7rem; }

.btn-add-plan {
    display: block; width: 100%; text-align: center;
    margin-top: 4px; padding: 2px; font-size: 0.7rem;
    color: #aaa; border: 1px dashed #ccc; border-radius: 4px;
    background: none; cursor: pointer; transition: all 0.15s;
}
.btn-add-plan:hover { color: #1a4a8a; border-color: #1a4a8a; background: #f0f5ff; }

/* Print styles */
@media print {
    .no-print, .sidebar-wrapper, nav, .btn, button { display: none !important; }
    body { font-size: 10px; }
    .print-header { display: block !important; margin-bottom: 8px; text-align: center; }
    .cal-table th { background: #1a4a8a !important; -webkit-print-color-adjust: exact; }
    .cal-table td { min-height: 60px; }
    .plan-entry { background: #e8f0fe !important; -webkit-print-color-adjust: exact; }
    .content-wrapper { margin: 0 !important; padding: 0 !important; }
}
.print-header { display: none; }
</style>

<!-- Print-only header -->
<div class="print-header">
    {% if logo %}<img src="{{ logo }}" style="max-height:50px;margin-bottom:4px;" alt=""><br>{% endif %}
    <strong>{{ institution_name }}</strong><br>
    {% if classroom %}
    <strong>{{ classroom.level_name }} — {{ classroom.grade_name }} "{{ classroom.section_name }}"</strong>
    &nbsp;|&nbsp; Tutor(a): {{ classroom.tutor_name|default('—') }}
    {% endif %}
    <br>{{ month_name }} {{ current_year }}
</div>

<!-- ===== HEADER: selector + navegación ===== -->
<div class="miAulaHeader no-print">
    <div class="d-flex align-items-center" style="gap:12px;">
        {% if classrooms_list|length > 0 %}
        <form method="get" class="form-inline">
            <select name="classroom_id" class="form-control form-control-sm" onchange="this.form.submit()" title="Seleccionar aula">
                {% for c in classrooms_list %}
                <option value="{{ c.id }}" {{ classroom_id == c.id ? 'selected' : '' }}>
                    {{ c.level_name }} — {{ c.grade_name }} "{{ c.section_name }}"
                </option>
                {% endfor %}
            </select>
            <input type="hidden" name="year"  value="{{ current_year }}">
            <input type="hidden" name="month" value="{{ current_month }}">
        </form>
        {% elseif classroom %}
        <span class="font-weight-bold text-primary" style="font-size:1.1rem;">
            {{ classroom.level_name }} — {{ classroom.grade_name }} "{{ classroom.section_name }}"
        </span>
        {% endif %}
    </div>

    <div class="miAulaNav">
        <a href="{{ prev_month_url }}" class="btn btn-outline-secondary btn-sm">&laquo;</a>
        <span class="month-title">{{ month_name }} {{ current_year }}</span>
        <a href="{{ next_month_url }}" class="btn btn-outline-secondary btn-sm">&raquo;</a>
    </div>

    <div class="d-flex" style="gap:8px;">
        <button class="btn btn-outline-secondary btn-sm" onclick="window.print()">
            <i class="fas fa-print"></i> Imprimir
        </button>
    </div>
</div>

{% if classroom %}
<div class="miAulaMeta no-print">
    <span><i class="fas fa-chalkboard-teacher text-primary"></i>
        Tutor(a): <strong>{{ classroom.tutor_name|default('—') }}</strong>
    </span>
    {% if is_student %}
    <span class="badge badge-secondary"><i class="fas fa-eye"></i> Solo lectura</span>
    {% endif %}
    {% if is_tutor %}
    <span class="badge badge-success"><i class="fas fa-star"></i> Eres tutor de esta aula</span>
    {% endif %}
</div>

<!-- ===== CALENDAR TABLE ===== -->
<div class="table-responsive">
<table class="cal-table">
    <thead>
        <tr>
            {% for d in day_cols %}
            <th>{{ d }}</th>
            {% endfor %}
        </tr>
    </thead>
    <tbody>
        {% for week in calendar_weeks %}
        <tr>
            {% for col in 1..5 %}
            {% set dayData = null %}
            {% for dayItem in week %}
                {% if loop.index0 + 1 == col %}{# align by index #}
                    {% set dayData = dayItem %}
                {% endif %}
            {% endfor %}

            {# Twig doesn't have direct key access on sequential array; use attribute() #}
            {% set dayData = week[col] ?? null %}

            {% if dayData %}
            <td>
                <span class="cal-day-num">{{ dayData.day_num }}</span>
                {% for plan in dayData.plans %}
                <div class="plan-entry"
                     {% if can_edit %}
                     onclick="openEditPlan({{ plan.id }}, '{{ plan.plan_date }}', '{{ plan.subject|e('js') }}', '{{ plan.topic|e('js') }}', '{{ plan.notes|e('js') }}', {{ plan.teacher_id }}, {{ is_tutor or is_admin_or_secretary ? 'true' : 'false' }}, {{ current_user_id }})"
                     {% endif %}
                     title="{{ plan.subject }}: {{ plan.topic }}{% if plan.notes %} — {{ plan.notes }}{% endif %}">
                    <span class="pe-subject">{{ plan.subject }}</span>
                    <span class="pe-topic">{{ plan.topic }}</span>
                    <span class="pe-teacher"><i class="fas fa-user-tie"></i> {{ plan.teacher_name|default('—') }}</span>
                </div>
                {% endfor %}
                {% if can_edit %}
                <button class="btn-add-plan no-print"
                        onclick="openAddPlan('{{ dayData.date }}')">
                    <i class="fas fa-plus"></i> Agregar
                </button>
                {% endif %}
            </td>
            {% else %}
            <td class="cal-empty"></td>
            {% endif %}
            {% endfor %}
        </tr>
        {% endfor %}
    </tbody>
</table>
</div>

{% else %}
<div class="alert alert-info mt-3">
    <i class="fas fa-info-circle"></i>
    {% if is_student %}
        No estás asignado a ningún aula para el año académico activo.
    {% else %}
        No hay aulas disponibles para el año académico activo.
        <a href="{{ _p.web }}academic/classroom" class="alert-link">Configura las aulas aquí</a>.
    {% endif %}
</div>
{% endif %}

<!-- ===== MODAL: Agregar / Editar Tema ===== -->
{% if can_edit %}
<div class="modal fade no-print" id="planModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="planModalTitle">
                    <i class="fas fa-book-open mr-1"></i> Agregar Tema
                </h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="plan_id" value="0">
                <input type="hidden" id="plan_classroom_id" value="{{ classroom_id }}">

                <div class="form-group">
                    <label class="font-weight-bold">Fecha</label>
                    <input type="text" class="form-control" id="plan_date_display" readonly>
                    <input type="hidden" id="plan_date">
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">Materia *</label>
                    <input type="text" class="form-control" id="plan_subject"
                           list="subjects_datalist" placeholder="Ej: Matemática, Ciencias, Inglés...">
                    <datalist id="subjects_datalist">
                        <option value="Gramática">
                        <option value="Aritmética">
                        <option value="Geometría">
                        <option value="Ciencias">
                        <option value="Historia">
                        <option value="Geografía">
                        <option value="Inglés">
                        <option value="Educación Física">
                        <option value="Arte">
                        <option value="Música">
                        <option value="Religión">
                        <option value="Ed. Cívica">
                        <option value="Computación">
                        <option value="Razonamiento Verbal">
                        <option value="Razonamiento Matemático">
                        <option value="Ed. Emocional">
                        <option value="F. Ciudadana">
                        <option value="Ed. Financiera">
                        <option value="Caligrafía">
                        <option value="Baile">
                    </datalist>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">Tema / Contenido *</label>
                    <textarea class="form-control" id="plan_topic" rows="3"
                              placeholder="Descripción del tema de clase..."></textarea>
                </div>
                <div class="form-group">
                    <label>Notas adicionales <small class="text-muted">(opcional)</small></label>
                    <textarea class="form-control" id="plan_notes" rows="2"
                              placeholder="Ej: Salida 1°-2° → 1:00 pm, Examen, etc."></textarea>
                </div>
                <div id="plan_modal_error" class="alert alert-danger" style="display:none;"></div>
            </div>
            <div class="modal-footer d-flex justify-content-between">
                <div>
                    <button type="button" class="btn btn-danger btn-sm" id="btn_delete_plan"
                            style="display:none;" onclick="deletePlan()">
                        <i class="fas fa-trash"></i> Eliminar
                    </button>
                </div>
                <div>
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-primary" id="btn_save_plan" onclick="savePlan()">
                        <i class="fas fa-save"></i> Guardar
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
{% endif %}

<script>
var ajaxUrl         = '{{ ajax_url }}';
var isTutorOrAdmin  = {{ (is_tutor or is_admin_or_secretary) ? 'true' : 'false' }};
var currentUserId   = {{ current_user_id }};

function formatDate(dateStr) {
    // '2026-03-15' → '15/03/2026'
    var p = dateStr.split('-');
    return p[2] + '/' + p[1] + '/' + p[0];
}

function openAddPlan(date) {
    document.getElementById('plan_id').value = 0;
    document.getElementById('plan_date').value = date;
    document.getElementById('plan_date_display').value = formatDate(date);
    document.getElementById('plan_subject').value = '';
    document.getElementById('plan_topic').value = '';
    document.getElementById('plan_notes').value = '';
    document.getElementById('plan_modal_error').style.display = 'none';
    document.getElementById('btn_delete_plan').style.display = 'none';
    document.getElementById('planModalTitle').innerHTML = '<i class="fas fa-book-open mr-1"></i> Agregar Tema';
    $('#planModal').modal('show');
}

function openEditPlan(id, date, subject, topic, notes, teacherId, canDelete, myId) {
    document.getElementById('plan_id').value = id;
    document.getElementById('plan_date').value = date;
    document.getElementById('plan_date_display').value = formatDate(date);
    document.getElementById('plan_subject').value = subject;
    document.getElementById('plan_topic').value = topic;
    document.getElementById('plan_notes').value = notes;
    document.getElementById('plan_modal_error').style.display = 'none';

    // Show delete button if user is tutor/admin OR if it's their own entry
    var showDelete = canDelete || (teacherId == myId);
    document.getElementById('btn_delete_plan').style.display = showDelete ? 'inline-block' : 'none';
    document.getElementById('planModalTitle').innerHTML = '<i class="fas fa-edit mr-1"></i> Editar Tema';
    $('#planModal').modal('show');
}

function savePlan() {
    var btn = document.getElementById('btn_save_plan');
    var err = document.getElementById('plan_modal_error');
    var subject = document.getElementById('plan_subject').value.trim();
    var topic   = document.getElementById('plan_topic').value.trim();

    if (!subject || !topic) {
        err.textContent = 'Materia y tema son obligatorios.';
        err.style.display = '';
        return;
    }

    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
    err.style.display = 'none';

    var fd = new FormData();
    fd.append('action',       'save_plan');
    fd.append('id',           document.getElementById('plan_id').value);
    fd.append('classroom_id', document.getElementById('plan_classroom_id').value);
    fd.append('plan_date',    document.getElementById('plan_date').value);
    fd.append('subject',      subject);
    fd.append('topic',        topic);
    fd.append('notes',        document.getElementById('plan_notes').value.trim());

    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success) {
                $('#planModal').modal('hide');
                location.reload();
            } else {
                err.textContent = d.message || 'Error al guardar.';
                err.style.display = '';
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-save"></i> Guardar';
            }
        })
        .catch(function() {
            err.textContent = 'Error de conexión.';
            err.style.display = '';
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-save"></i> Guardar';
        });
}

function deletePlan() {
    if (!confirm('¿Eliminar este tema? Esta acción no se puede deshacer.')) return;
    var fd = new FormData();
    fd.append('action', 'delete_plan');
    fd.append('id', document.getElementById('plan_id').value);
    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success) {
                $('#planModal').modal('hide');
                location.reload();
            } else {
                alert(d.message || 'Error al eliminar.');
            }
        });
}
</script>
