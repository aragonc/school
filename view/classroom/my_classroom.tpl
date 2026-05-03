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
.plan-entry .pe-subject { font-weight: 700; color: #1a4a8a; display: block; }
.plan-entry .pe-topic   { color: #333; display: block; font-size: 0.72rem; }
.plan-entry .pe-teacher { color: #888; font-size: 0.7rem; }
/* Tipo: Consolidado */
.plan-entry.pe-consolidado { background: #e8f5e9; border-left-color: #388e3c; }
.plan-entry.pe-consolidado:hover { background: #c8e6c9; }
.plan-entry.pe-consolidado .pe-subject { color: #388e3c; }
/* Tipo: Actividad */
.plan-entry.pe-actividad { background: #fff3e0; border-left-color: #f57c00; }
.plan-entry.pe-actividad:hover { background: #ffe0b2; }
.plan-entry.pe-actividad .pe-subject { color: #e65100; }

.btn-add-plan {
    display: block; width: 100%; text-align: center;
    margin-top: 4px; padding: 2px; font-size: 0.7rem;
    color: #aaa; border: 1px dashed #ccc; border-radius: 4px;
    background: none; cursor: pointer; transition: all 0.15s;
}
.btn-add-plan:hover { color: #1a4a8a; border-color: #1a4a8a; background: #f0f5ff; }

/* Print styles */
.print-header { display: none; }

/* Day image thumbnail */
.cal-day-img-wrap { display: flex; margin-bottom: 4px; }
.cal-day-img-wrap.align-left   { justify-content: flex-start; }
.cal-day-img-wrap.align-center { justify-content: center; }
.cal-day-img-wrap.align-right  { justify-content: flex-end; }
.cal-day-img { height: auto; object-fit: contain; border-radius: 4px; cursor: pointer; display: block; }
.btn-add-img {
    display: block; width: 100%; text-align: center;
    margin-top: 3px; padding: 2px; font-size: 0.7rem;
    color: #888; border: 1px dashed #bbb; border-radius: 4px;
    background: none; cursor: pointer; transition: all 0.15s;
}
.btn-add-img:hover { color: #e65100; border-color: #e65100; background: #fff3e0; }
.btn-del-img {
    display: block; width: 100%; text-align: center;
    margin-top: 2px; padding: 2px; font-size: 0.7rem;
    color: #c0392b; border: 1px dashed #e57373; border-radius: 4px;
    background: none; cursor: pointer; transition: all 0.15s;
}
.btn-del-img:hover { color: #fff; border-color: #c0392b; background: #c0392b; }

/* Non-working days */
.cal-holiday  { background: #fff8e1; }
.cal-vacation { background: #e3f2fd; }
.cal-nw-label {
    display: block; font-size: 0.68rem; font-weight: 600;
    border-radius: 3px; padding: 2px 5px; margin-bottom: 3px;
}
.cal-holiday  .cal-nw-label { background: #ffc107; color: #333; }
.cal-vacation .cal-nw-label { background: #29b6f6; color: #fff; }
</style>

<!-- Área de impresión (header + calendario) -->
<div class="cal-print-area">
<div class="print-header">
    {% if logo %}<img src="{{ logo }}" style="max-height:50px;margin-bottom:4px;" alt=""><br>{% endif %}
    <strong>{{ institution_name }}</strong><br>
    {% if classroom %}
    <strong>{{ classroom.level_name }} — {{ classroom.grade_name }} "{{ classroom.section_name }}"</strong>
    &nbsp;|&nbsp; Tutor(a): {{ classroom.tutor_name|default('—') }}
    {% endif %}
    <span class="mes-titulo">{{ month_name }} {{ current_year }}</span>
</div>

<!-- ===== HEADER: selector + navegación ===== -->
<div class="miAulaHeader no-print">
    <div class="d-flex align-items-center" style="gap:12px;">
        {% if classrooms_list|length > 0 %}
        <form method="get" class="form-inline" style="gap:10px;">
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
        {% if is_admin_or_secretary %}
        <span class="badge badge-primary px-2 py-1" style="font-size:0.75rem;">
            <i class="fas fa-shield-alt mr-1"></i>Administrador — acceso total
        </span>
        {% elseif is_tutor %}
        <span class="badge badge-success px-2 py-1" style="font-size:0.75rem;">
            <i class="fas fa-star mr-1"></i>Eres tutor(a) — puedes editar
        </span>
        {% elseif not is_student %}
        <span class="badge badge-secondary px-2 py-1" style="font-size:0.75rem;">
            <i class="fas fa-eye mr-1"></i>Solo lectura
        </span>
        {% endif %}
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
        <button class="btn btn-outline-secondary btn-sm" onclick="printCalendar()">
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
    {% if classroom.tutor_name %}
    <span class="badge badge-success">
        <i class="fas fa-star"></i>
        {% if is_tutor and not is_admin_or_secretary %}Eres tutor de esta aula{% else %}Es tutor de esta aula{% endif %}
    </span>
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
            <td{% if dayData.nonworking %} class="cal-{{ dayData.nonworking.type }}"{% endif %}>
                <span class="cal-day-num">{{ dayData.day_num }}</span>
                {% if dayData.nonworking %}
                <span class="cal-nw-label">
                    <i class="fas fa-{% if dayData.nonworking.type == 'vacation' %}umbrella-beach{% else %}flag{% endif %} mr-1"></i>{{ dayData.nonworking.description }}
                </span>
                {% set dayImg = day_images_map[dayData.date] ?? null %}
                {% if dayImg %}
                {% set imgMeta = day_images_meta[dayData.date] ?? {} %}
                {% set imgW = imgMeta.width ?? 150 %}
                {% set imgA = imgMeta.align ?? 'left' %}
                <div class="cal-day-img-wrap align-{{ imgA }}">
                    <img src="{{ dayImg }}" class="cal-day-img"
                         title="Clic para ajustar tamaño y alineación"
                         style="width:{{ imgW }}px;"
                         onclick="openDayImageView('{{ dayData.date }}', '{{ dayImg }}', '{{ classroom_id }}')" alt="">
                </div>
                {% endif %}
                {% if can_image %}
                <button class="btn-add-img no-print"
                        data-date="{{ dayData.date }}"
                        data-classroom="{{ classroom_id }}"
                        onclick="openDayImageModal(this.dataset.date, this.dataset.classroom)">
                    <i class="fas fa-image"></i> {% if dayImg %}Cambiar imagen{% else %}Añadir imagen{% endif %}
                </button>
                {% if dayImg %}
                <button class="btn-del-img no-print"
                        data-date="{{ dayData.date }}"
                        data-classroom="{{ classroom_id }}"
                        onclick="deleteDayImage(this.dataset.date, this.dataset.classroom)">
                    <i class="fas fa-trash-alt"></i> Eliminar imagen
                </button>
                {% endif %}
                {% endif %}
                {% else %}
                {% for plan in dayData.plans %}
                {% set pe_class = plan.subject == 'Consolidado de Aprendizajes' ? 'pe-consolidado' : (plan.subject == 'Actividad' ? 'pe-actividad' : '') %}
                <div class="plan-entry {{ pe_class }}"
                     {% if can_edit %}
                     data-id="{{ plan.id }}"
                     data-date="{{ plan.plan_date }}"
                     data-subject="{{ plan.subject|e('html_attr') }}"
                     data-topic="{{ plan.topic|e('html_attr') }}"
                     data-notes="{{ plan.notes|e('html_attr') }}"
                     data-teacher-id="{{ plan.teacher_id }}"
                     data-can-delete="{{ (is_tutor or is_admin_or_secretary) ? '1' : '0' }}"
                     data-schedule="{{ dayData.schedule|json_encode|e('html_attr') }}"
                     data-plans="{{ dayData.plans|json_encode|e('html_attr') }}"
                     onclick="openEditPlanBtn(this)"
                     {% endif %}
                     title="{{ plan.subject }}: {{ plan.topic }}{% if plan.notes %} — {{ plan.notes }}{% endif %}">
                    <span class="pe-subject">{{ plan.subject }}</span>
                    {% if plan.topic %}<span class="pe-topic">{{ plan.topic }}</span>{% endif %}
                </div>
                {% endfor %}
                {% if can_edit %}
                <button class="btn-add-plan no-print"
                        data-date="{{ dayData.date }}"
                        data-schedule="{{ dayData.schedule|json_encode|e('html_attr') }}"
                        data-plans="{{ dayData.plans|json_encode|e('html_attr') }}"
                        onclick="openAddPlanBtn(this)">
                    <i class="fas fa-plus"></i> Agregar
                </button>
                {% endif %}
                {% set dayImg = day_images_map[dayData.date] ?? null %}
                {% if dayImg %}
                {% set imgMeta = day_images_meta[dayData.date] ?? {} %}
                {% set imgW = imgMeta.width ?? 150 %}
                {% set imgA = imgMeta.align ?? 'left' %}
                <div class="cal-day-img-wrap align-{{ imgA }}">
                    <img src="{{ dayImg }}" class="cal-day-img"
                         title="Clic para ajustar tamaño y alineación"
                         style="width:{{ imgW }}px;"
                         onclick="openDayImageView('{{ dayData.date }}', '{{ dayImg }}', '{{ classroom_id }}')" alt="">
                </div>
                {% endif %}
                {% if can_image %}
                <button class="btn-add-img no-print"
                        data-date="{{ dayData.date }}"
                        data-classroom="{{ classroom_id }}"
                        onclick="openDayImageModal(this.dataset.date, this.dataset.classroom)">
                    <i class="fas fa-image"></i> {% if dayImg %}Cambiar imagen{% else %}Añadir imagen{% endif %}
                </button>
                {% if dayImg %}
                <button class="btn-del-img no-print"
                        data-date="{{ dayData.date }}"
                        data-classroom="{{ classroom_id }}"
                        onclick="deleteDayImage(this.dataset.date, this.dataset.classroom)">
                    <i class="fas fa-trash-alt"></i> Eliminar imagen
                </button>
                {% endif %}
                {% endif %}
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

<!-- Leyenda -->
<div class="d-flex flex-wrap align-items-center mt-2 no-print" style="gap:12px;font-size:0.75rem;">
<span><span style="display:inline-block;width:12px;height:12px;background:#e8f0fe;border-left:3px solid #1a4a8a;border-radius:2px;margin-right:4px;"></span>Curso</span>
    <span><span style="display:inline-block;width:12px;height:12px;background:#e8f5e9;border-left:3px solid #388e3c;border-radius:2px;margin-right:4px;"></span>Consolidado</span>
    <span><span style="display:inline-block;width:12px;height:12px;background:#fff3e0;border-left:3px solid #f57c00;border-radius:2px;margin-right:4px;"></span>Actividad</span>
    <span><span style="display:inline-block;width:12px;height:12px;background:#ffc107;border-radius:2px;margin-right:4px;"></span>Feriado</span>
    <span><span style="display:inline-block;width:12px;height:12px;background:#29b6f6;border-radius:2px;margin-right:4px;"></span>Vacaciones / Descanso</span>
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
</div>{# /cal-print-area #}

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
                <input type="hidden" id="plan_teacher_id" value="0">
                <div class="form-group">
                    <label class="font-weight-bold">Tipo *</label>
                    <select class="form-control" id="plan_tipo" onchange="planTipoChanged()">
                        <option value="curso">Curso</option>
                        <option value="consolidado">Consolidado de Aprendizajes</option>
                        <option value="actividad">Actividad</option>
                    </select>
                </div>
                <div id="plan_curso_row" class="form-group">
                    <label class="font-weight-bold">Curso *</label>
                    {% if classroom_courses|length > 0 %}
                    <select class="form-control" id="plan_subject" onchange="planCourseChanged()">
                        <option value="">-- Seleccionar curso --</option>
                        {% for c in classroom_courses %}
                        <option value="{{ c.subject }}"
                                data-teacher-id="{{ c.teacher_id }}"
                                data-teacher-name="{{ c.teacher_name }}">
                            {{ c.subject }}{% if c.teacher_name %} — {{ c.teacher_name }}{% endif %}
                        </option>
                        {% endfor %}
                    </select>
                    {% else %}
                    <input type="text" class="form-control" id="plan_subject"
                           placeholder="Ej: Matemática, Ciencias, Inglés...">
                    {% endif %}
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">Tema / Contenido *</label>
                    <textarea class="form-control" id="plan_topic" rows="3"
                              placeholder="Descripción del tema de clase..."></textarea>
                </div>
                <input type="hidden" id="plan_notes" value="">
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

<!-- ===== MODAL: Imagen del día ===== -->
{% if can_image %}
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.css">

{# Modal recortador #}
<div class="modal fade no-print" id="dayImageModal" tabindex="-1" data-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header" style="background:linear-gradient(135deg,#1a3558 0%,#2563aa 100%);color:#fff;">
                <h5 class="modal-title">
                    <i class="fas fa-crop-alt mr-2"></i> Imagen del día — <span id="dayImgDateLabel"></span>
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body p-0" style="background:#1a1a2e;min-height:300px;">
                <div style="max-height:420px;">
                    <img id="dayImg_cropperImg" src="" alt="" style="max-width:100%;display:block;">
                </div>
            </div>
            <div class="modal-footer d-flex justify-content-between align-items-center flex-wrap" style="gap:8px;">
                <div class="d-flex align-items-center flex-wrap" style="gap:6px;">
                    <small class="text-muted mr-1">Proporción:</small>
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-outline-secondary btn-dayimg-ratio active" data-ratio="free">Libre</button>
                        <button class="btn btn-outline-secondary btn-dayimg-ratio" data-ratio="1">1:1</button>
                        <button class="btn btn-outline-secondary btn-dayimg-ratio" data-ratio="1.7778">16:9</button>
                    </div>
                    <div class="btn-group btn-group-sm ml-1">
                        <button class="btn btn-outline-secondary" id="dayImg_rotateL" title="Rotar -90°"><i class="fas fa-undo"></i></button>
                        <button class="btn btn-outline-secondary" id="dayImg_rotateR" title="Rotar +90°"><i class="fas fa-redo"></i></button>
                    </div>
                </div>
                <div class="d-flex" style="gap:6px;">
                    <button type="button" class="btn btn-danger btn-sm" id="dayImg_btn_delete" style="display:none;">
                        <i class="fas fa-trash"></i> Eliminar
                    </button>
                    <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-sm btn-primary" id="dayImg_btn_save">
                        <i class="fas fa-check mr-1"></i> Recortar y guardar
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

{# Modal estilo de imagen (ancho + alineación) #}
<div class="modal fade no-print" id="dayImgStyleModal" tabindex="-1" data-backdrop="static">
    <div class="modal-dialog modal-dialog-centered" style="max-width:480px;">
        <div class="modal-content">
            <div class="modal-header" style="background:linear-gradient(135deg,#1a3558 0%,#2563aa 100%);color:#fff;">
                <h5 class="modal-title"><i class="fas fa-sliders-h mr-2"></i> Ajustar imagen</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="dayImgStyle_date">
                <input type="hidden" id="dayImgStyle_classroom">

                <div class="form-group mb-3">
                    <label class="font-weight-bold">Ancho: <span id="dayImgStyle_widthVal">150px</span></label>
                    <input type="range" id="dayImgStyle_width" class="form-control-range"
                           min="50" max="600" step="10" value="150">
                    <div class="d-flex justify-content-between" style="font-size:0.75rem;color:#888;">
                        <span>50px</span><span>600px</span>
                    </div>
                </div>

                <div class="form-group mb-3">
                    <label class="font-weight-bold d-block mb-1">Alineación</label>
                    <div class="btn-group w-100">
                        <button class="btn btn-outline-secondary btn-img-align active" data-align="left">
                            <i class="fas fa-align-left"></i> Izquierda
                        </button>
                        <button class="btn btn-outline-secondary btn-img-align" data-align="center">
                            <i class="fas fa-align-center"></i> Centro
                        </button>
                        <button class="btn btn-outline-secondary btn-img-align" data-align="right">
                            <i class="fas fa-align-right"></i> Derecha
                        </button>
                    </div>
                </div>

                <div id="dayImgStyle_previewWrap" style="border:1px dashed #ccc;border-radius:6px;padding:8px;min-height:80px;background:#f8f8f8;">
                    <img id="dayImgStyle_preview" src="" alt="" style="width:150px;height:auto;border-radius:4px;display:inline-block;">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="dayImgStyle_btnSave">
                    <i class="fas fa-save mr-1"></i> Guardar
                </button>
            </div>
        </div>
    </div>
</div>
{% endif %}

<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.js"></script>
<script>
var ajaxUrl              = '{{ ajax_url }}';
var isTutorOrAdmin       = {{ (is_tutor or is_admin_or_secretary) ? 'true' : 'false' }};
var currentUserId        = {{ current_user_id }};
var allClassroomCourses  = {{ classroom_courses_json|raw }};
var currentDaySchedule   = [];

function formatDate(dateStr) {
    // '2026-03-15' → '15/03/2026'
    var p = dateStr.split('-');
    return p[2] + '/' + p[1] + '/' + p[0];
}

var TIPO_LABELS = {
    'consolidado': 'Consolidado de Aprendizajes',
    'actividad':   'Actividad'
};

function getTipoFromSubject(subject) {
    if (subject === 'Consolidado de Aprendizajes') return 'consolidado';
    if (subject === 'Actividad')                   return 'actividad';
    return 'curso';
}

function rebuildCourseSelect(schedSubjects, usedSubjects) {
    var sel = document.getElementById('plan_subject');
    if (!sel || sel.tagName !== 'SELECT') return;

    var coursesToShow;
    if (schedSubjects && schedSubjects.length > 0) {
        coursesToShow = allClassroomCourses.filter(function(c) {
            return schedSubjects.indexOf(c.subject) !== -1;
        });
        if (coursesToShow.length === 0) {
            coursesToShow = allClassroomCourses;
        }
    } else {
        coursesToShow = allClassroomCourses;
    }

    // Exclude courses already added for this day
    if (usedSubjects && usedSubjects.length > 0) {
        var specialSubjects = ['Consolidado de Aprendizajes', 'Actividad'];
        coursesToShow = coursesToShow.filter(function(c) {
            if (specialSubjects.indexOf(c.subject) !== -1) return true;
            return usedSubjects.indexOf(c.subject) === -1;
        });
    }

    sel.innerHTML = '<option value="">-- Seleccionar curso --</option>';
    coursesToShow.forEach(function(c) {
        var opt = document.createElement('option');
        opt.value = c.subject;
        opt.setAttribute('data-teacher-id', c.teacher_id);
        opt.setAttribute('data-teacher-name', c.teacher_name);
        opt.textContent = c.subject + (c.teacher_name ? ' — ' + c.teacher_name : '');
        sel.appendChild(opt);
    });
}

function openAddPlanBtn(btn) {
    var date         = btn.dataset.date;
    var schedule     = JSON.parse(btn.dataset.schedule);
    var plans        = JSON.parse(btn.dataset.plans);
    var usedSubjects = plans.map(function(p) { return p.subject; });
    openAddPlan(date, schedule, usedSubjects);
}

function planTipoChanged() {
    var tipo = document.getElementById('plan_tipo').value;
    var row  = document.getElementById('plan_curso_row');
    row.style.display = (tipo === 'curso') ? '' : 'none';
    if (tipo !== 'curso') {
        document.getElementById('plan_teacher_id').value = '0';
    }
}

function planCourseChanged() {
    var sel = document.getElementById('plan_subject');
    var opt = sel ? sel.options[sel.selectedIndex] : null;
    var tid = opt ? (opt.getAttribute('data-teacher-id') || '0') : '0';
    document.getElementById('plan_teacher_id').value = tid;
}

function openAddPlan(date, scheduleSubjects, usedSubjects) {
    currentDaySchedule = scheduleSubjects || [];
    document.getElementById('plan_id').value = 0;
    document.getElementById('plan_date').value = date;
    document.getElementById('plan_date_display').value = formatDate(date);
    document.getElementById('plan_tipo').value = 'curso';
    document.getElementById('plan_teacher_id').value = '0';
    document.getElementById('plan_topic').value = '';
    document.getElementById('plan_notes').value = '';
    document.getElementById('plan_modal_error').style.display = 'none';
    document.getElementById('btn_delete_plan').style.display = 'none';
    document.getElementById('planModalTitle').innerHTML = '<i class="fas fa-book-open mr-1"></i> Agregar Tema';
    rebuildCourseSelect(currentDaySchedule, usedSubjects || []);
    planTipoChanged();
    $('#planModal').modal('show');
}

function openEditPlanBtn(el) {
    var plans = JSON.parse(el.dataset.plans);
    openEditPlan(
        el.dataset.id,
        el.dataset.date,
        el.dataset.subject,
        el.dataset.topic,
        el.dataset.notes,
        el.dataset.teacherId,
        el.dataset.canDelete === '1',
        currentUserId,
        JSON.parse(el.dataset.schedule),
        plans
    );
}

function openEditPlan(id, date, subject, topic, notes, teacherId, canDelete, myId, scheduleSubjects, dayPlans) {
    document.getElementById('plan_id').value = id;
    document.getElementById('plan_date').value = date;
    document.getElementById('plan_date_display').value = formatDate(date);
    document.getElementById('plan_teacher_id').value = teacherId || '0';
    document.getElementById('plan_topic').value = topic;
    document.getElementById('plan_notes').value = notes;
    document.getElementById('plan_modal_error').style.display = 'none';

    // Detect tipo from subject
    var tipo = getTipoFromSubject(subject);
    document.getElementById('plan_tipo').value = tipo;
    planTipoChanged();

    // Set subject field only for "curso" type
    if (tipo === 'curso') {
        // Same filter as add: exclude courses already used by OTHER plans today
        var usedByOthers = (dayPlans || [])
            .filter(function(p) { return String(p.id) !== String(id); })
            .map(function(p) { return p.subject; });
        rebuildCourseSelect(scheduleSubjects || [], usedByOthers);
        var subjectEl = document.getElementById('plan_subject');
        if (subjectEl.tagName === 'SELECT') {
            var matched = false;
            for (var i = 0; i < subjectEl.options.length; i++) {
                if (subjectEl.options[i].value === subject) {
                    subjectEl.selectedIndex = i;
                    planCourseChanged();
                    matched = true;
                    break;
                }
            }
            if (!matched) { subjectEl.selectedIndex = 0; }
        } else {
            subjectEl.value = subject;
        }
    }

    // Show delete button if user is tutor/admin OR if it's their own entry
    var showDelete = canDelete || (teacherId == myId);
    document.getElementById('btn_delete_plan').style.display = showDelete ? 'inline-block' : 'none';
    document.getElementById('planModalTitle').innerHTML = '<i class="fas fa-edit mr-1"></i> Editar Tema';
    $('#planModal').modal('show');
}

function savePlan() {
    var btn   = document.getElementById('btn_save_plan');
    var err   = document.getElementById('plan_modal_error');
    var tipo  = document.getElementById('plan_tipo').value;
    var topic = document.getElementById('plan_topic').value.trim();

    // Determine final subject from tipo
    var subject;
    if (tipo === 'curso') {
        subject = document.getElementById('plan_subject').value.trim();
        if (!subject) {
            err.textContent = 'Selecciona un curso.';
            err.style.display = '';
            return;
        }
    } else {
        subject = TIPO_LABELS[tipo] || tipo;
    }

    if (!topic) {
        err.textContent = 'El tema / contenido es obligatorio.';
        err.style.display = '';
        return;
    }

    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
    err.style.display = 'none';

    var teacherId = document.getElementById('plan_teacher_id').value || '0';

    var fd = new FormData();
    fd.append('action',       'save_plan');
    fd.append('id',           document.getElementById('plan_id').value);
    fd.append('classroom_id', document.getElementById('plan_classroom_id').value);
    fd.append('plan_date',    document.getElementById('plan_date').value);
    fd.append('subject',      subject);
    fd.append('topic',        topic);
    fd.append('teacher_id',   teacherId);
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

// ===== Day Image Modal =====
var dayImgCropper  = null;
var dayImagesMap   = {{ day_images_map_json|raw }};
var dayImagesMeta  = {{ day_images_meta_json|raw }};
var _dayImgDate    = '';
var _dayImgClass   = '';

// Hidden file input (same pattern as courses.tpl)
var _dayImgFileInput = document.createElement('input');
_dayImgFileInput.type    = 'file';
_dayImgFileInput.accept  = 'image/jpeg,image/png,image/gif,image/webp';
_dayImgFileInput.style.display = 'none';
document.body.appendChild(_dayImgFileInput);

var _dayImgCropModal = document.getElementById('dayImageModal');
var _dayImgCropImg   = document.getElementById('dayImg_cropperImg');
var _dayImgBtnSave   = document.getElementById('dayImg_btn_save');
var _dayImgBtnDel    = document.getElementById('dayImg_btn_delete');

function openDayImageModal(date, classroomId) {
    _dayImgDate  = date;
    _dayImgClass = classroomId;
    document.getElementById('dayImgDateLabel').textContent = formatDate(date);
    var hasImg = dayImagesMap.hasOwnProperty(date);
    if (_dayImgBtnDel) _dayImgBtnDel.style.display = hasImg ? 'inline-block' : 'none';
    _dayImgFileInput.value = '';
    _dayImgFileInput.click();
}

function openDayImageView(date, url, classroomId) {
    var meta  = dayImagesMeta[date] || {};
    var w     = meta.width || 150;
    var align = meta.align || 'left';
    document.getElementById('dayImgStyle_date').value      = date;
    document.getElementById('dayImgStyle_classroom').value = classroomId;
    document.getElementById('dayImgStyle_width').value     = w;
    document.getElementById('dayImgStyle_widthVal').textContent = w + 'px';
    document.getElementById('dayImgStyle_preview').src     = url;
    document.getElementById('dayImgStyle_preview').style.width = w + 'px';
    applyImgStylePreviewAlign(align);
    document.querySelectorAll('.btn-img-align').forEach(function(b) {
        b.classList.toggle('active', b.dataset.align === align);
    });
    $('#dayImgStyleModal').modal('show');
}

function applyImgStylePreviewAlign(align) {
    var wrap = document.getElementById('dayImgStyle_previewWrap');
    wrap.style.textAlign = align;
}

// File selected → read → open crop modal
_dayImgFileInput.addEventListener('change', function() {
    if (!_dayImgFileInput.files.length) return;
    var reader = new FileReader();
    reader.onload = function(ev) {
        _dayImgCropImg.src = ev.target.result;
        $('#dayImageModal').modal('show');
    };
    reader.readAsDataURL(_dayImgFileInput.files[0]);
});

// Init Cropper when modal shown
$(_dayImgCropModal).on('shown.bs.modal', function() {
    if (dayImgCropper) { dayImgCropper.destroy(); dayImgCropper = null; }
    dayImgCropper = new Cropper(_dayImgCropImg, {
        aspectRatio: NaN,
        viewMode: 1,
        dragMode: 'move',
        autoCropArea: 0.9,
        restore: false,
        guides: true,
        center: true,
        highlight: false,
        cropBoxMovable: true,
        cropBoxResizable: true,
        toggleDragModeOnDblclick: false
    });
    if (_dayImgBtnSave) {
        _dayImgBtnSave.disabled = false;
        _dayImgBtnSave.innerHTML = '<i class="fas fa-check mr-1"></i> Recortar y guardar';
    }
    document.querySelectorAll('.btn-dayimg-ratio').forEach(function(b) {
        b.classList.toggle('active', b.getAttribute('data-ratio') === 'free');
    });
});

// Destroy Cropper when modal hidden
$(_dayImgCropModal).on('hidden.bs.modal', function() {
    if (dayImgCropper) { dayImgCropper.destroy(); dayImgCropper = null; }
    _dayImgCropImg.src = '';
});

// Ratio buttons
document.querySelectorAll('.btn-dayimg-ratio').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.btn-dayimg-ratio').forEach(function(b){ b.classList.remove('active'); });
        btn.classList.add('active');
        if (dayImgCropper) {
            var r = btn.getAttribute('data-ratio');
            dayImgCropper.setAspectRatio(r === 'free' ? NaN : parseFloat(r));
        }
    });
});

// Rotate buttons
document.getElementById('dayImg_rotateL').addEventListener('click', function() {
    if (dayImgCropper) dayImgCropper.rotate(-90);
});
document.getElementById('dayImg_rotateR').addEventListener('click', function() {
    if (dayImgCropper) dayImgCropper.rotate(90);
});

// Confirm: crop → toBlob → upload
if (_dayImgBtnSave) {
    _dayImgBtnSave.addEventListener('click', function() {
        if (!dayImgCropper) return;
        _dayImgBtnSave.disabled = true;
        _dayImgBtnSave.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i> Guardando...';

        var canvas = dayImgCropper.getCroppedCanvas({
            maxWidth: 1200, maxHeight: 1200,
            imageSmoothingEnabled: true,
            imageSmoothingQuality: 'high'
        });

        canvas.toBlob(function(blob) {
            var fd = new FormData();
            fd.append('action',       'save_day_image');
            fd.append('classroom_id', _dayImgClass);
            fd.append('day_date',     _dayImgDate);
            fd.append('file',         blob, 'day-image.jpg');

            fetch(ajaxUrl, { method: 'POST', body: fd })
                .then(function(r) { return r.json(); })
                .then(function(d) {
                    _dayImgBtnSave.disabled = false;
                    _dayImgBtnSave.innerHTML = '<i class="fas fa-check mr-1"></i> Recortar y guardar';
                    if (d.success) {
                        $('#dayImageModal').modal('hide');
                        location.reload();
                    } else {
                        alert(d.message || 'Error al guardar.');
                    }
                })
                .catch(function() {
                    _dayImgBtnSave.disabled = false;
                    _dayImgBtnSave.innerHTML = '<i class="fas fa-check mr-1"></i> Recortar y guardar';
                    alert('Error de conexión.');
                });
        }, 'image/jpeg', 0.88);
    });
}

// Delete button
if (_dayImgBtnDel) {
    _dayImgBtnDel.addEventListener('click', function() {
        if (!confirm('¿Eliminar la imagen de este día?')) return;
        var fd = new FormData();
        fd.append('action',       'delete_day_image');
        fd.append('classroom_id', _dayImgClass);
        fd.append('day_date',     _dayImgDate);
        fetch(ajaxUrl, { method: 'POST', body: fd })
            .then(function(r) { return r.json(); })
            .then(function(d) {
                if (d.success) { $('#dayImageModal').modal('hide'); location.reload(); }
                else { alert(d.message || 'Error al eliminar.'); }
            });
    });
}

// ===== Image style modal logic =====
(function() {
    var widthInput = document.getElementById('dayImgStyle_width');
    var widthVal   = document.getElementById('dayImgStyle_widthVal');
    var preview    = document.getElementById('dayImgStyle_preview');

    if (widthInput) {
        widthInput.addEventListener('input', function() {
            widthVal.textContent = this.value + 'px';
            preview.style.width  = this.value + 'px';
        });
    }

    document.querySelectorAll('.btn-img-align').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.btn-img-align').forEach(function(b) { b.classList.remove('active'); });
            this.classList.add('active');
            applyImgStylePreviewAlign(this.dataset.align);
        });
    });

    var saveBtn = document.getElementById('dayImgStyle_btnSave');
    if (saveBtn) {
        saveBtn.addEventListener('click', function() {
            var date        = document.getElementById('dayImgStyle_date').value;
            var classroomId = document.getElementById('dayImgStyle_classroom').value;
            var width       = document.getElementById('dayImgStyle_width').value;
            var activeAlign = document.querySelector('.btn-img-align.active');
            var align       = activeAlign ? activeAlign.dataset.align : 'left';

            saveBtn.disabled = true;
            var fd = new FormData();
            fd.append('action',       'save_day_image_meta');
            fd.append('classroom_id', classroomId);
            fd.append('day_date',     date);
            fd.append('width',        width);
            fd.append('align',        align);
            fetch(ajaxUrl, { method: 'POST', body: fd })
                .then(function(r) { return r.json(); })
                .then(function(d) {
                    saveBtn.disabled = false;
                    if (d.success) { $('#dayImgStyleModal').modal('hide'); location.reload(); }
                    else { alert(d.message || 'Error al guardar.'); }
                })
                .catch(function() { saveBtn.disabled = false; alert('Error de conexión.'); });
        });
    }
})();

function deleteDayImage(dayDate, classroomId) {
    if (!confirm('¿Eliminar la imagen de este día?')) return;
    var fd = new FormData();
    fd.append('action',       'delete_day_image');
    fd.append('classroom_id', classroomId);
    fd.append('day_date',     dayDate);
    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success) { location.reload(); }
            else { alert(d.message || 'Error al eliminar.'); }
        })
        .catch(function() { alert('Error de conexión.'); });
}

function printCalendar() {
    var area = document.querySelector('.cal-print-area');
    if (!area) { window.print(); return; }

    var clone = area.cloneNode(true);
    clone.querySelectorAll('.miAulaHeader, .miAulaMeta, .no-print').forEach(function(el){ el.remove(); });

    var w = window.open('', '_blank');
    w.document.write([
        '<!DOCTYPE html><html><head>',
        '<meta charset="utf-8">',
        '<title>Calendario</title>',
        '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">',
        '<style>',
        '@page { size: A4 landscape; margin: 10mm; }',
        '* { box-sizing: border-box; }',
        'body { font-family: Arial, sans-serif; font-size: 9px; margin: 0; padding: 0; background: #fff; color: #222; }',
        '.print-header { display: block !important; text-align: center; margin-bottom: 10px; }',
        '.print-header .mes-titulo { font-size: 20px; font-weight: 800; text-transform: uppercase; letter-spacing: 2px; display: block; margin-top: 4px; }',
        '.cal-table { width: 100%; border-collapse: collapse; table-layout: fixed; }',
        '.cal-table th { background: #1a4a8a; color: #fff; padding: 5px 3px; text-align: center; font-size: 10px; -webkit-print-color-adjust: exact; print-color-adjust: exact; }',
        '.cal-table td { border: 1px solid #ccc; vertical-align: top; padding: 3px; min-height: 55px; height: 55px; }',
        '.cal-day-num { font-weight: 700; font-size: 10px; margin-bottom: 2px; }',
        '.cal-sched-list { list-style: none; padding: 0; margin: 0; }',
        '.cal-sched-item { font-size: 7.5px; color: #444; padding: 1px 3px; border-left: 2px solid #90caf9; margin-bottom: 1px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; -webkit-print-color-adjust: exact; print-color-adjust: exact; }',
        '.cal-holiday  { background: #fff8e1; -webkit-print-color-adjust: exact; print-color-adjust: exact; }',
        '.cal-vacation { background: #e3f2fd; -webkit-print-color-adjust: exact; print-color-adjust: exact; }',
        '.cal-nw-label { display: block; font-size: 7px; font-weight: 600; border-radius: 3px; padding: 1px 4px; margin-bottom: 2px; }',
        '.cal-holiday  .cal-nw-label { background: #ffc107; color: #333; -webkit-print-color-adjust: exact; }',
        '.cal-vacation .cal-nw-label { background: #29b6f6; color: #fff; -webkit-print-color-adjust: exact; }',
        '.plan-entry { font-size: 7.5px; background: none; border: none; border-radius: 0; padding: 1px 0; margin-top: 2px; }',
        '.plan-entry .pe-subject { font-weight: 700; color: #000; display: block; }',
        '.plan-entry .pe-topic   { font-weight: 400; color: #333; display: block; font-size: 7px; }',
        '.cal-day-img { max-width: 100%; height: auto; display: block; }',
        '.cal-day-img-wrap { display: block; margin-bottom: 3px; }',
        '.table-responsive { overflow: visible !important; }',
        'button, .btn, a.btn { display: none !important; }',
        '</style>',
        '</head><body>',
        clone.innerHTML,
        '<script>',
        'window.addEventListener("load", function () {',
        '  setTimeout(function () { window.print(); window.close(); }, 400);',
        '});',
        '<\/script>',
        '</body></html>'
    ].join(''));
    w.document.close();
}
</script>
