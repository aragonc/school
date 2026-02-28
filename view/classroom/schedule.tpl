<div class="container-fluid px-4 py-4">

    {# ---- Header ---- #}
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap" style="gap:10px;">
        <div>
            <h4 class="mb-1 font-weight-bold text-dark">
                <i class="fas fa-calendar-week text-primary mr-2"></i>Horario del Aula
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
        <div class="d-flex" style="gap:8px;">
            {% if can_edit %}
            <button type="button" class="btn btn-sm btn-primary" id="btnAddSlot">
                <i class="fas fa-plus mr-1"></i>Agregar hora
            </button>
            {% endif %}
            <a href="/my-aula" class="btn btn-sm btn-outline-secondary">
                <i class="fas fa-arrow-left mr-1"></i>Mi Aula
            </a>
        </div>
    </div>

    {# ---- Classroom selector (admin only) ---- #}
    {% if is_admin and classrooms_list %}
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body py-3">
            <form method="get" action="" class="d-flex align-items-end" style="gap:16px;">
                <div>
                    <label class="mb-1 small font-weight-bold text-muted">Aula</label>
                    <select name="classroom_id" class="form-control form-control-sm" onchange="this.form.submit()" style="min-width:240px;">
                        {% for cls in classrooms_list %}
                        <option value="{{ cls.id }}" {% if cls.id == classroom_id %}selected{% endif %}>
                            {{ cls.level_name }} — {{ cls.grade_name }}{% if cls.section_name %} Sec. {{ cls.section_name }}{% endif %}
                        </option>
                        {% endfor %}
                    </select>
                </div>
            </form>
        </div>
    </div>
    {% endif %}

    {% if not classroom %}
    <div class="alert alert-info">
        <i class="fas fa-info-circle mr-2"></i>
        No tienes un aula asignada en el año académico activo.
    </div>

    {% else %}

    {# ---- Schedule grid ---- #}
    <div class="card shadow-sm border-0">
        <div class="card-body p-0">
            {% if schedule_grid %}
            <div class="table-responsive">
                <table class="table table-bordered mb-0 schedule-table" id="scheduleTable">
                    <thead class="thead-primary">
                        <tr>
                            <th class="text-center align-middle" style="width:110px; background:#4e73df; color:#fff; font-size:12px;">Hora</th>
                            {% for day_num, day_label in day_names %}
                            <th class="text-center align-middle" style="background:#4e73df; color:#fff; font-size:12px; {% if day_num == 4 %}border-left:3px solid #2653d4;{% endif %}">
                                {{ day_label }}
                                {% if day_num == 4 %}<br><small style="font-size:10px; opacity:.8;">Full Day</small>{% endif %}
                            </th>
                            {% endfor %}
                            {% if can_edit %}<th style="width:40px; background:#4e73df;"></th>{% endif %}
                        </tr>
                    </thead>
                    <tbody>
                        {% for slot in schedule_grid %}
                        {% set rowStyle = slot.style %}

                        {# Row style classes #}
                        {% if rowStyle == 'break' %}
                        <tr class="schedule-break" data-slot="{{ slot.time_start }}|{{ slot.time_end }}|{{ slot.sort_order }}">
                        {% elseif rowStyle == 'pause' %}
                        <tr class="schedule-pause" data-slot="{{ slot.time_start }}|{{ slot.time_end }}|{{ slot.sort_order }}">
                        {% elseif rowStyle == 'exit' %}
                        <tr class="schedule-exit" data-slot="{{ slot.time_start }}|{{ slot.time_end }}|{{ slot.sort_order }}">
                        {% else %}
                        <tr data-slot="{{ slot.time_start }}|{{ slot.time_end }}|{{ slot.sort_order }}">
                        {% endif %}

                            {# Time cell #}
                            <td class="text-center align-middle schedule-time-cell" style="font-size:11px; font-weight:600; white-space:nowrap; background:#f8f9fc;">
                                {{ slot.time_start|slice(0,5) }}<br>
                                <span style="color:#aaa; font-weight:400;">{{ slot.time_end|slice(0,5) }}</span>
                            </td>

                            {# Day columns 1-5 #}
                            {% for day_num in 1..5 %}
                            {% set entry = slot.days[day_num] ?? slot.days[0] ?? null %}

                            {% if rowStyle == 'break' %}
                            <td class="schedule-break-cell text-center align-middle" style="background:#fff3cd; color:#856404; font-size:11px; font-style:italic;">
                                {% if entry %}<i class="fas fa-coffee mr-1"></i>{{ entry.subject ?: 'Recreo' }}{% else %}<i class="fas fa-coffee mr-1"></i>Recreo{% endif %}
                            </td>
                            {% elseif rowStyle == 'pause' %}
                            <td class="schedule-pause-cell text-center align-middle" style="background:#e2e3e5; color:#6c757d; font-size:11px; font-style:italic;">
                                {% if entry %}<i class="fas fa-pause-circle mr-1"></i>{{ entry.subject ?: 'Pausa' }}{% else %}<i class="fas fa-pause-circle mr-1"></i>Pausa{% endif %}
                            </td>
                            {% elseif rowStyle == 'exit' %}
                            <td class="schedule-exit-cell text-center align-middle" style="background:#d1ecf1; color:#0c5460; font-size:11px; font-style:italic;">
                                {% if entry %}<i class="fas fa-door-open mr-1"></i>{{ entry.subject ?: 'Salida' }}{% else %}<i class="fas fa-door-open mr-1"></i>Salida{% endif %}
                            </td>
                            {% else %}
                                {% if entry %}
                                <td class="schedule-subject-cell align-middle px-2 py-2{% if day_num == 4 %} schedule-fullday-cell{% endif %}"
                                    data-entry-id="{{ entry.id }}"
                                    data-day="{{ day_num }}"
                                    style="{% if day_num == 4 %}border-left:3px solid #2653d4;{% endif %} min-width:130px;">
                                    <div class="subject-name font-weight-bold" style="font-size:12px; color:#2e3a4e; line-height:1.3;">
                                        {{ entry.subject }}
                                    </div>
                                    {% if entry.teacher_name %}
                                    <div class="teacher-name text-muted" style="font-size:11px; margin-top:2px;">
                                        <i class="fas fa-user-tie mr-1" style="font-size:9px;"></i>{{ entry.teacher_name }}
                                    </div>
                                    {% endif %}
                                    {% if can_edit %}
                                    <div class="entry-actions mt-1" style="display:none;">
                                        <button class="btn btn-xs btn-outline-primary btn-edit-entry py-0 px-1"
                                                data-id="{{ entry.id }}"
                                                data-classroom="{{ classroom_id }}"
                                                data-day="{{ day_num }}"
                                                data-time-start="{{ entry.time_start }}"
                                                data-time-end="{{ entry.time_end }}"
                                                data-subject="{{ entry.subject }}"
                                                data-teacher-id="{{ entry.teacher_id }}"
                                                data-teacher-name="{{ entry.teacher_name }}"
                                                data-style="{{ entry.style }}"
                                                data-sort-order="{{ entry.sort_order }}"
                                                style="font-size:10px;">
                                            <i class="fas fa-pen"></i>
                                        </button>
                                        <button class="btn btn-xs btn-outline-danger btn-delete-entry py-0 px-1"
                                                data-id="{{ entry.id }}"
                                                style="font-size:10px;">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                    {% endif %}
                                </td>
                                {% else %}
                                <td class="schedule-empty-cell align-middle text-center{% if day_num == 4 %} schedule-fullday-cell{% endif %}"
                                    style="{% if day_num == 4 %}border-left:3px solid #2653d4;{% endif %} color:#ccc; font-size:20px; min-width:130px;">
                                    {% if can_edit %}
                                    <button class="btn btn-sm btn-link text-muted btn-add-day-entry p-0"
                                            data-classroom="{{ classroom_id }}"
                                            data-day="{{ day_num }}"
                                            data-time-start="{{ slot.time_start }}"
                                            data-time-end="{{ slot.time_end }}"
                                            data-sort-order="{{ slot.sort_order }}"
                                            title="Agregar"
                                            style="font-size:18px; opacity:.3;">
                                        <i class="fas fa-plus-circle"></i>
                                    </button>
                                    {% else %}
                                    &mdash;
                                    {% endif %}
                                </td>
                                {% endif %}
                            {% endif %}
                            {% endfor %}

                            {# Row actions (delete whole time slot) #}
                            {% if can_edit %}
                            <td class="align-middle text-center p-0" style="background:#f8f9fc;">
                                <button class="btn btn-sm btn-link text-danger btn-delete-slot p-1"
                                        data-classroom="{{ classroom_id }}"
                                        data-time-start="{{ slot.time_start }}"
                                        data-time-end="{{ slot.time_end }}"
                                        title="Eliminar fila completa"
                                        style="font-size:12px;">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            </td>
                            {% endif %}
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
            </div>
            {% else %}
            <div class="p-5 text-center text-muted">
                <i class="fas fa-calendar-week fa-3x mb-3 d-block" style="opacity:.2;"></i>
                <p class="mb-3">No hay horario registrado para esta aula.</p>
                {% if can_edit %}
                <button type="button" class="btn btn-primary" id="btnAddSlotEmpty">
                    <i class="fas fa-plus mr-1"></i>Agregar primera hora
                </button>
                {% endif %}
            </div>
            {% endif %}
        </div>
    </div>

    {% endif %}{# end if classroom #}

</div>{# end container-fluid #}

{# ---- Modal: Add / Edit Schedule Entry ---- #}
{% if can_edit %}
<div class="modal fade" id="modalScheduleEntry" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:480px;">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white py-3">
                <h6 class="modal-title mb-0 font-weight-bold">
                    <i class="fas fa-calendar-week mr-2"></i><span id="modalEntryTitle">Nueva hora</span>
                </h6>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <form id="formScheduleEntry">
                    <input type="hidden" id="entryId" name="entry_id" value="0">
                    <input type="hidden" id="entryClassroom" name="classroom_id" value="{{ classroom_id }}">

                    <div class="row">
                        <div class="col-6">
                            <div class="form-group">
                                <label class="small font-weight-bold">Hora inicio <span class="text-danger">*</span></label>
                                <input type="time" class="form-control form-control-sm" id="entryTimeStart" name="time_start" required>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="form-group">
                                <label class="small font-weight-bold">Hora fin <span class="text-danger">*</span></label>
                                <input type="time" class="form-control form-control-sm" id="entryTimeEnd" name="time_end" required>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="small font-weight-bold">Tipo de fila</label>
                        <select class="form-control form-control-sm" id="entryStyle" name="style">
                            <option value="">Clase normal</option>
                            <option value="break">Recreo / Descanso</option>
                            <option value="pause">Pausa</option>
                            <option value="exit">Salida</option>
                        </select>
                    </div>

                    <div id="entryDayGroup" class="form-group">
                        <label class="small font-weight-bold">Día(s) <span class="text-danger">*</span></label>
                        <div class="d-flex flex-wrap" style="gap:8px;">
                            <label class="d-flex align-items-center mb-0" style="gap:4px; font-size:13px; cursor:pointer;">
                                <input type="checkbox" name="days[]" value="0" id="dayAll"> Todos
                            </label>
                            {% for day_num, day_label in day_names %}
                            <label class="d-flex align-items-center mb-0" style="gap:4px; font-size:13px; cursor:pointer;">
                                <input type="checkbox" name="days[]" value="{{ day_num }}" class="day-check"> {{ day_label }}
                            </label>
                            {% endfor %}
                        </div>
                    </div>

                    <div id="entrySubjectGroup">
                        <div class="form-group">
                            <label class="small font-weight-bold">Curso / Materia <span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-sm" id="entrySubject" name="subject" placeholder="Ej: Matemáticas" maxlength="255">
                        </div>

                        <div class="form-group mb-0">
                            <label class="small font-weight-bold">Docente</label>
                            <select class="form-control form-control-sm" id="entryTeacherId" name="teacher_id">
                                <option value="">-- Sin docente --</option>
                                {% for t in teachers_list %}
                                <option value="{{ t.user_id }}">{{ t.lastname }}, {{ t.firstname }}</option>
                                {% endfor %}
                            </select>
                        </div>
                    </div>

                    <div class="form-group mt-3 mb-0">
                        <label class="small font-weight-bold">Orden</label>
                        <input type="number" class="form-control form-control-sm" id="entrySortOrder" name="sort_order" value="0" min="0" max="999" style="width:80px;">
                    </div>
                </form>
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-sm btn-primary" id="btnSaveEntry">
                    <i class="fas fa-save mr-1"></i>Guardar
                </button>
            </div>
        </div>
    </div>
</div>
{% endif %}

<style>
.schedule-table th, .schedule-table td { vertical-align: middle !important; }
.schedule-subject-cell:hover .entry-actions { display: block !important; }
.schedule-break-cell, .schedule-pause-cell, .schedule-exit-cell { font-size: 11px; }
.schedule-fullday-cell { background: #f0f4ff !important; }
.schedule-table .schedule-break tr, tr.schedule-break td { background: #fff3cd !important; }
tr.schedule-pause td { background: #f2f2f2 !important; }
tr.schedule-exit td { background: #d1ecf1 !important; }
.btn-xs { padding: 0.1rem 0.3rem; font-size: 0.7rem; line-height: 1.2; }
</style>

{% if can_edit %}
<script>
(function () {
    var ajaxUrl = '{{ ajax_url }}';
    var classroomId = {{ classroom_id }};

    function openModal(data) {
        data = data || {};
        $('#entryId').val(data.id || 0);
        $('#entryClassroom').val(classroomId);
        $('#entryTimeStart').val(data.time_start || '');
        $('#entryTimeEnd').val(data.time_end || '');
        $('#entryStyle').val(data.style || '');
        $('#entrySortOrder').val(data.sort_order || 0);
        $('#entrySubject').val(data.subject || '');
        $('#entryTeacherId').val(data.teacher_id || '');

        // Days
        $('input[name="days[]"]').prop('checked', false);
        if (data.day != null && data.day !== undefined) {
            $('input[name="days[]"][value="' + data.day + '"]').prop('checked', true);
        }
        if (data.id) {
            $('#modalEntryTitle').text('Editar hora');
        } else {
            $('#modalEntryTitle').text('Nueva hora');
        }
        toggleSubjectGroup($('#entryStyle').val());
        $('#modalScheduleEntry').modal('show');
    }

    function toggleSubjectGroup(style) {
        if (style === 'break' || style === 'pause' || style === 'exit') {
            $('#entryDayGroup').hide();
            $('#entrySubjectGroup').hide();
            // For special rows, subject field is optional label; show it
            $('#entrySubjectGroup').show();
            $('#entrySubject').removeAttr('required');
        } else {
            $('#entryDayGroup').show();
            $('#entrySubjectGroup').show();
            $('#entrySubject').attr('required', 'required');
        }
    }

    $('#entryStyle').on('change', function () {
        toggleSubjectGroup($(this).val());
    });

    // "All days" checkbox logic
    $('#dayAll').on('change', function () {
        if ($(this).is(':checked')) {
            $('.day-check').prop('checked', false);
        }
    });
    $('.day-check').on('change', function () {
        if ($(this).is(':checked')) {
            $('#dayAll').prop('checked', false);
        }
    });

    // Open modal for new slot
    $(document).on('click', '#btnAddSlot, #btnAddSlotEmpty', function () {
        openModal({});
    });

    // Open modal pre-filled for a specific day/time
    $(document).on('click', '.btn-add-day-entry', function () {
        var btn = $(this);
        openModal({
            day:        btn.data('day'),
            time_start: btn.data('time-start'),
            time_end:   btn.data('time-end'),
            sort_order: btn.data('sort-order')
        });
    });

    // Open modal for editing existing entry
    $(document).on('click', '.btn-edit-entry', function () {
        var btn = $(this);
        openModal({
            id:           btn.data('id'),
            day:          btn.data('day'),
            time_start:   btn.data('time-start'),
            time_end:     btn.data('time-end'),
            subject:      btn.data('subject'),
            teacher_id:   btn.data('teacher-id'),
            style:        btn.data('style'),
            sort_order:   btn.data('sort-order')
        });
    });

    // Save entry
    $('#btnSaveEntry').on('click', function () {
        var form = $('#formScheduleEntry');

        var timeStart = $('#entryTimeStart').val().trim();
        var timeEnd   = $('#entryTimeEnd').val().trim();
        var style     = $('#entryStyle').val();
        var subject   = $('#entrySubject').val().trim();
        var entryId   = parseInt($('#entryId').val()) || 0;

        if (!timeStart || !timeEnd) {
            alert('Ingresa hora inicio y fin.');
            return;
        }

        // Collect selected days
        var days = [];
        $('input[name="days[]"]:checked').each(function () {
            days.push($(this).val());
        });
        if (!style && days.length === 0 && entryId === 0) {
            alert('Selecciona al menos un día.');
            return;
        }
        if (!style && !subject && entryId === 0) {
            alert('Ingresa el nombre del curso.');
            return;
        }

        var payload = {
            action:       'save_schedule_entry',
            entry_id:     entryId,
            classroom_id: classroomId,
            time_start:   timeStart,
            time_end:     timeEnd,
            style:        style,
            subject:      subject,
            teacher_id:   $('#entryTeacherId').val() || '',
            sort_order:   parseInt($('#entrySortOrder').val()) || 0,
            days:         days
        };

        $.post(ajaxUrl, payload, function (resp) {
            if (resp && resp.success) {
                $('#modalScheduleEntry').modal('hide');
                location.reload();
            } else {
                alert((resp && resp.error) ? resp.error : 'Error al guardar.');
            }
        }, 'json').fail(function () {
            alert('Error de conexión.');
        });
    });

    // Delete single entry
    $(document).on('click', '.btn-delete-entry', function () {
        if (!confirm('¿Eliminar esta entrada del horario?')) return;
        var id = $(this).data('id');
        $.post(ajaxUrl, { action: 'delete_schedule_entry', entry_id: id }, function (resp) {
            if (resp && resp.success) {
                location.reload();
            } else {
                alert((resp && resp.error) ? resp.error : 'Error al eliminar.');
            }
        }, 'json');
    });

    // Delete full time-slot row
    $(document).on('click', '.btn-delete-slot', function () {
        if (!confirm('¿Eliminar toda la fila de este horario?')) return;
        var btn = $(this);
        $.post(ajaxUrl, {
            action:       'delete_schedule_slot',
            classroom_id: classroomId,
            time_start:   btn.data('time-start'),
            time_end:     btn.data('time-end')
        }, function (resp) {
            if (resp && resp.success) {
                location.reload();
            } else {
                alert((resp && resp.error) ? resp.error : 'Error al eliminar.');
            }
        }, 'json');
    });

}());
</script>
{% endif %}
