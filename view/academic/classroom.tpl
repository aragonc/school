{% include 'academic/tabs.tpl' with {'active_tab': 'classrooms', 'is_admin': is_admin} %}

<div class="mb-3">
    <a href="{{ _p.web }}academic?year_id={{ classroom.academic_year_id }}" class="btn btn-outline-secondary btn-sm">
        <i class="fas fa-arrow-left"></i> {{ 'BackToClassrooms'|get_plugin_lang('SchoolPlugin') }}
    </a>
</div>

<!-- Classroom Info -->
<div class="card mb-4">
    <div class="card-header">
        <i class="fas fa-chalkboard"></i>
        <strong>{{ classroom.year_name }} — {{ classroom.level_name }} — {{ classroom.grade_name }} "{{ classroom.section_name }}"</strong>
    </div>
    <div class="card-body">
        <div class="row">
            <div class="col-md-6">
                <!-- Tutor -->
                <div class="card mb-3">
                    <div class="card-body d-flex align-items-center">
                        {% if classroom.tutor_avatar %}
                            <img src="{{ classroom.tutor_avatar }}" class="rounded-circle mr-3" width="50" height="50" alt="Tutor">
                        {% else %}
                            <div class="rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center mr-3" style="width:50px;height:50px;">
                                <i class="fas fa-user-tie"></i>
                            </div>
                        {% endif %}
                        <div>
                            <small class="text-muted">{{ 'Tutor'|get_plugin_lang('SchoolPlugin') }}</small>
                            <div class="font-weight-bold">
                                {% if classroom.tutor_name %}
                                    {{ classroom.tutor_name }}
                                {% else %}
                                    <span class="text-muted">{{ 'NoTutor'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% endif %}
                            </div>
                        </div>
                        <button class="btn btn-outline-primary btn-sm ml-auto" data-toggle="modal" data-target="#tutorModal">
                            <i class="fas fa-exchange-alt"></i> {{ 'ChangeTutor'|get_plugin_lang('SchoolPlugin') }}
                        </button>
                    </div>
                </div>
                <!-- Supervisor -->
                <div class="card mb-3">
                    <div class="card-body d-flex align-items-center">
                        {% if classroom.supervisor_avatar %}
                            <img src="{{ classroom.supervisor_avatar }}" class="rounded-circle mr-3" width="50" height="50" alt="Supervisor">
                        {% else %}
                            <div class="rounded-circle bg-info text-white d-flex align-items-center justify-content-center mr-3" style="width:50px;height:50px;">
                                <i class="fas fa-user-shield"></i>
                            </div>
                        {% endif %}
                        <div>
                            <small class="text-muted">Supervisor</small>
                            <div class="font-weight-bold">
                                {% if classroom.supervisor_name %}
                                    {{ classroom.supervisor_name }}
                                {% else %}
                                    <span class="text-muted">Sin supervisor</span>
                                {% endif %}
                            </div>
                        </div>
                        <button class="btn btn-outline-info btn-sm ml-auto" data-toggle="modal" data-target="#supervisorModal">
                            <i class="fas fa-exchange-alt"></i> Cambiar
                        </button>
                    </div>
                </div>
                <!-- Auxiliaries -->
                <div class="card mb-3">
                    <div class="card-header d-flex justify-content-between align-items-center py-2">
                        <small class="font-weight-bold text-muted"><i class="fas fa-chalkboard-teacher mr-1"></i>Auxiliares de aula</small>
                        {% if auxiliaries|length < 3 %}
                        <button class="btn btn-outline-primary btn-sm" data-toggle="modal" data-target="#auxiliaryModal">
                            <i class="fas fa-plus"></i> Agregar
                        </button>
                        {% endif %}
                    </div>
                    <div class="card-body p-0" id="auxiliary_list_wrapper">
                        {% if auxiliaries|length > 0 %}
                            {% for aux in auxiliaries %}
                            <div class="d-flex align-items-center px-3 py-2 border-bottom aux-row" id="aux-row-{{ aux.user_id }}">
                                {% if aux.avatar %}
                                    <img src="{{ aux.avatar }}" class="rounded-circle mr-2" width="36" height="36" alt="">
                                {% else %}
                                    <div class="rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center mr-2" style="width:36px;height:36px;font-size:13px;">
                                        <i class="fas fa-user"></i>
                                    </div>
                                {% endif %}
                                <div class="flex-grow-1">
                                    <strong>{{ aux.lastname }}, {{ aux.firstname }}</strong>
                                    <br><small class="text-muted">{{ aux.username }}</small>
                                </div>
                                <button class="btn btn-outline-danger btn-sm" onclick="removeAuxiliary({{ aux.user_id }})" title="Quitar">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                            {% endfor %}
                        {% else %}
                            <div class="p-3 text-muted text-center" id="no_auxiliaries_msg">
                                <small>Sin auxiliares asignados</small>
                            </div>
                        {% endif %}
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card text-center">
                    <div class="card-body py-2">
                        <small class="text-muted">{{ 'Students'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div class="h4 mb-0">{{ students|length }} / {{ classroom.capacity }}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card text-center">
                    <div class="card-body py-2">
                        <small class="text-muted">{{ 'Capacity'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div class="h4 mb-0">{{ classroom.capacity }}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card text-center">
                    <div class="card-body py-2">
                        <small class="text-muted">Auxiliares</small>
                        <div class="h4 mb-0">{{ auxiliaries|length }}/3</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Session Assignment -->
<div class="card mb-4">
    <div class="card-header d-flex justify-content-between align-items-center py-2">
        <span><i class="fas fa-graduation-cap mr-1"></i> Sesión de Chamilo</span>
        {% if not classroom.session_id %}
        <button class="btn btn-outline-primary btn-sm" data-toggle="modal" data-target="#sessionModal">
            <i class="fas fa-plus mr-1"></i> Asignar sesión
        </button>
        {% endif %}
    </div>
    <div class="card-body py-3">
        {% if classroom.session_id and classroom.session_name %}
        <div class="d-flex align-items-center">
            <i class="fas fa-chalkboard text-primary mr-3" style="font-size:1.5rem;"></i>
            <div>
                <div class="font-weight-bold">{{ classroom.session_name }}</div>
                <small class="text-muted">ID sesión: {{ classroom.session_id }}</small>
            </div>
            <div class="ml-auto d-flex align-items-center">
                <button class="btn btn-success btn-sm mr-2" id="btn-enroll-session" onclick="enrollToSession()">
                    <i class="fas fa-user-plus mr-1"></i> Inscribir alumnos
                </button>
                <button class="btn btn-outline-danger btn-sm" onclick="removeSession()">
                    <i class="fas fa-unlink mr-1"></i> Quitar sesión
                </button>
            </div>
        </div>
        <div id="enroll-result" class="mt-2" style="display:none;"></div>
        {% else %}
        <p class="text-muted mb-0" style="font-size:13px;">
            <i class="fas fa-info-circle mr-1"></i> Sin sesión asignada. Asigna una sesión de Chamilo para luego inscribir a los alumnos del aula.
        </p>
        {% endif %}
    </div>
</div>

{% if session_courses %}
<!-- Session Courses -->
<div class="card mb-4">
    <div class="card-header py-2">
        <i class="fas fa-book-open mr-1 text-primary"></i>
        <strong>Cursos de la sesión</strong>
        <span class="badge badge-primary ml-2">{{ session_courses|length }}</span>
    </div>
    <div class="card-body p-0">
        <table class="table table-sm mb-0" id="courses-table">
            <thead class="thead-light">
                <tr>
                    <th style="width:36px;" class="pl-3">#</th>
                    <th>Curso</th>
                    <th style="width:110px;">Código</th>
                    <th>Docente(s)</th>
                    <th style="width:110px;" class="text-center">Acceso</th>
                </tr>
            </thead>
            <tbody>
                {% for i, course in session_courses %}
                <tr id="course-row-{{ course.id }}">
                    <td class="pl-3 text-muted align-middle" style="font-size:12px;">{{ i + 1 }}</td>
                    <td class="align-middle">
                        <span class="font-weight-bold" style="font-size:13px;">{{ course.title }}</span>
                    </td>
                    <td class="text-muted align-middle" style="font-size:12px; letter-spacing:.3px;">{{ course.code }}</td>
                    <td>
                        {# Lista de docentes asignados #}
                        <div id="teachers-{{ course.id }}" class="mb-1">
                            {% if course.teachers %}
                                {% for t in course.teachers %}
                                <div class="d-flex align-items-center mb-1" id="trow-{{ course.id }}-{{ t.user_id }}">
                                    {% if t.avatar %}
                                    <img src="{{ t.avatar }}" class="rounded-circle mr-2 flex-shrink-0" width="26" height="26" alt="">
                                    {% else %}
                                    <div class="rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center mr-2 flex-shrink-0"
                                         style="width:26px;height:26px;font-size:10px;">
                                        <i class="fas fa-user-tie"></i>
                                    </div>
                                    {% endif %}
                                    <div class="flex-grow-1">
                                        <span style="font-size:12px; font-weight:600;">{{ t.lastname }}, {{ t.firstname }}</span>
                                        {% if t.email %}
                                        <br><a href="mailto:{{ t.email }}" class="text-muted" style="font-size:10px;">{{ t.email }}</a>
                                        {% endif %}
                                    </div>
                                    <button class="btn btn-outline-danger btn-sm ml-2 flex-shrink-0"
                                            style="padding:1px 6px; font-size:11px;"
                                            title="Quitar docente"
                                            onclick="removeCourseTeacher({{ course.id }}, {{ t.user_id }}, this)">
                                        <i class="fas fa-times"></i>
                                    </button>
                                </div>
                                {% endfor %}
                            {% else %}
                            <span class="text-muted" style="font-size:12px;" id="no-teacher-{{ course.id }}">
                                <i class="fas fa-minus mr-1"></i>Sin docente
                            </span>
                            {% endif %}
                        </div>
                        {# Buscador inline para agregar docente #}
                        <div class="mt-1">
                            <div class="input-group input-group-sm" style="max-width:280px;">
                                <input type="text"
                                       class="form-control form-control-sm ct-search"
                                       data-course-id="{{ course.id }}"
                                       placeholder="Agregar docente..."
                                       autocomplete="off"
                                       style="font-size:11px;">
                                <div class="input-group-append">
                                    <span class="input-group-text" style="font-size:11px;">
                                        <i class="fas fa-search"></i>
                                    </span>
                                </div>
                            </div>
                            <div class="ct-results border rounded bg-white shadow-sm"
                                 id="ctres-{{ course.id }}"
                                 style="display:none; max-height:180px; overflow-y:auto; position:absolute; z-index:999; min-width:280px;"></div>
                        </div>
                    </td>
                    <td class="text-center align-middle">
                        <a href="{{ web_course_path }}{{ course.code }}/index.php?id_session={{ classroom.session_id }}"
                           target="_blank"
                           class="btn btn-outline-primary btn-sm"
                           title="Abrir curso">
                            <i class="fas fa-external-link-alt"></i>
                        </a>
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
</div>

<!-- JS para gestión de docentes en cursos -->
<script>
(function () {
    var ajaxUrl   = '{{ ajax_url }}';
    var sessionId = {{ classroom.session_id }};
    var ctTimers  = {};

    // ---- Buscador de docentes por curso ----
    document.querySelectorAll('.ct-search').forEach(function (input) {
        var courseId = input.dataset.courseId;
        var resBox   = document.getElementById('ctres-' + courseId);

        input.addEventListener('input', function () {
            clearTimeout(ctTimers[courseId]);
            var q = this.value.trim();
            if (q.length < 2) { resBox.style.display = 'none'; return; }
            ctTimers[courseId] = setTimeout(function () {
                fetch(ajaxUrl + '?action=search_teachers&q=' + encodeURIComponent(q))
                    .then(function(r){ return r.json(); })
                    .then(function (data) {
                        var html = '';
                        if (data.data && data.data.length) {
                            data.data.forEach(function (t) {
                                html += '<div class="d-flex align-items-center px-2 py-1 border-bottom ct-item" style="cursor:pointer;font-size:12px;"'
                                      + ' onclick="assignCourseTeacher(' + courseId + ',' + t.user_id + ',\'' + escHtml(t.lastname) + '\',\'' + escHtml(t.firstname) + '\',\'' + escHtml(t.email||'') + '\')">'
                                      + '<i class="fas fa-user-tie text-muted mr-2"></i>'
                                      + '<div><strong>' + escHtml(t.lastname) + ', ' + escHtml(t.firstname) + '</strong>'
                                      + '<br><small class="text-muted">' + escHtml(t.username) + '</small></div>'
                                      + '</div>';
                            });
                        } else {
                            html = '<div class="p-2 text-muted" style="font-size:12px;">Sin resultados</div>';
                        }
                        resBox.innerHTML = html;
                        resBox.style.display = '';
                    });
            }, 280);
        });

        // Cerrar al hacer clic fuera
        document.addEventListener('click', function (e) {
            if (!input.contains(e.target) && !resBox.contains(e.target)) {
                resBox.style.display = 'none';
            }
        });
    });

    // ---- Asignar docente ----
    window.assignCourseTeacher = function (courseId, teacherId, lastname, firstname, email) {
        var fd = new FormData();
        fd.append('action',     'assign_course_teacher');
        fd.append('session_id', sessionId);
        fd.append('course_id',  courseId);
        fd.append('teacher_id', teacherId);

        fetch(ajaxUrl, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function (d) {
                if (!d.success) return;

                // Quitar "sin docente" si existe
                var noT = document.getElementById('no-teacher-' + courseId);
                if (noT) noT.remove();

                // Agregar fila del docente
                var existing = document.getElementById('trow-' + courseId + '-' + teacherId);
                if (!existing) {
                    var wrap  = document.getElementById('teachers-' + courseId);
                    var div   = document.createElement('div');
                    div.id    = 'trow-' + courseId + '-' + teacherId;
                    div.className = 'd-flex align-items-center mb-1';
                    var av = d.avatar
                        ? '<img src="' + escHtml(d.avatar) + '" class="rounded-circle mr-2 flex-shrink-0" width="26" height="26">'
                        : '<div class="rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center mr-2 flex-shrink-0" style="width:26px;height:26px;font-size:10px;"><i class="fas fa-user-tie"></i></div>';
                    var emailHtml = d.email ? '<br><a href="mailto:' + escHtml(d.email) + '" class="text-muted" style="font-size:10px;">' + escHtml(d.email) + '</a>' : '';
                    div.innerHTML = av
                        + '<div class="flex-grow-1"><span style="font-size:12px;font-weight:600;">' + escHtml(d.lastname) + ', ' + escHtml(d.firstname) + '</span>' + emailHtml + '</div>'
                        + '<button class="btn btn-outline-danger btn-sm ml-2 flex-shrink-0" style="padding:1px 6px;font-size:11px;" title="Quitar" onclick="removeCourseTeacher(' + courseId + ',' + teacherId + ',this)">'
                        + '<i class="fas fa-times"></i></button>';
                    wrap.appendChild(div);
                }

                // Limpiar buscador
                var inp = document.querySelector('.ct-search[data-course-id="' + courseId + '"]');
                if (inp) inp.value = '';
                var res = document.getElementById('ctres-' + courseId);
                if (res) res.style.display = 'none';
            });
    };

    // ---- Quitar docente ----
    window.removeCourseTeacher = function (courseId, teacherId, btn) {
        if (!confirm('¿Quitar este docente del curso?')) return;
        var fd = new FormData();
        fd.append('action',     'remove_course_teacher');
        fd.append('session_id', sessionId);
        fd.append('course_id',  courseId);
        fd.append('teacher_id', teacherId);

        fetch(ajaxUrl, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function (d) {
                if (!d.success) return;
                var row = document.getElementById('trow-' + courseId + '-' + teacherId);
                if (row) row.remove();
                // Si no quedan docentes, mostrar "sin docente"
                var wrap = document.getElementById('teachers-' + courseId);
                if (wrap && wrap.querySelectorAll('[id^="trow-"]').length === 0) {
                    var span = document.createElement('span');
                    span.id = 'no-teacher-' + courseId;
                    span.className = 'text-muted';
                    span.style.fontSize = '12px';
                    span.innerHTML = '<i class="fas fa-minus mr-1"></i>Sin docente';
                    wrap.appendChild(span);
                }
            });
    };

    function escHtml(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }
})();
</script>
{% endif %}

{% if pending_count > 0 %}
<div class="alert alert-warning d-flex align-items-center justify-content-between mb-3" role="alert">
    <div>
        <i class="fas fa-exclamation-triangle mr-2"></i>
        <strong>{{ pending_count }}</strong>
        {{ 'PendingStudentsAlert'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <button class="btn btn-warning btn-sm ml-3" data-toggle="modal" data-target="#addStudentModal">
        <i class="fas fa-user-plus mr-1"></i>{{ 'AddStudent'|get_plugin_lang('SchoolPlugin') }}
    </button>
</div>
{% endif %}

<!-- Students -->
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="fas fa-users"></i> {{ 'Students'|get_plugin_lang('SchoolPlugin') }} ({{ students|length }})</span>
        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addStudentModal">
            <i class="fas fa-user-plus"></i> {{ 'AddStudent'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
    <div class="card-body p-0">
        {% if students|length > 0 %}
        <table class="table table-hover table-sm mb-0">
            <thead class="thead-light">
                <tr>
                    <th style="width:50px">#</th>
                    <th style="width:50px"></th>
                    <th>{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Username'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Email'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'EnrolledAt'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th style="width:80px">{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                </tr>
            </thead>
            <tbody>
                {% for i, student in students %}
                <tr{% if student.matricula_alert %} class="table-warning"{% endif %}>
                    <td>{{ i + 1 }}</td>
                    <td>
                        {% if student.avatar %}
                            <img src="{{ student.avatar }}" class="rounded-circle" width="30" height="30" alt="">
                        {% else %}
                            <div class="rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center" style="width:30px;height:30px;font-size:12px;">
                                <i class="fas fa-user"></i>
                            </div>
                        {% endif %}
                    </td>
                    <td>
                        <strong>{{ student.lastname }}, {{ student.firstname }}</strong>
                        {% if student.matricula_alert == 'moved' %}
                            <br><span class="badge badge-warning">
                                <i class="fas fa-exchange-alt"></i>
                                {{ 'MatriculaMovedTo'|get_plugin_lang('SchoolPlugin') }}:
                                {{ student.mat_grade_name }} &quot;{{ student.mat_section_name }}&quot;
                            </span>
                        {% elseif student.matricula_alert == 'retirado' %}
                            <br><span class="badge badge-danger">
                                <i class="fas fa-user-times"></i>
                                {{ 'MatriculaRetirado'|get_plugin_lang('SchoolPlugin') }}
                            </span>
                        {% elseif student.matricula_alert == 'no_matricula' %}
                            <br><span class="badge badge-secondary">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ 'MatriculaNotFound'|get_plugin_lang('SchoolPlugin') }}
                            </span>
                        {% endif %}
                    </td>
                    <td>{{ student.username }}</td>
                    <td>{{ student.email }}</td>
                    <td>{{ student.enrolled_at|date('d/m/Y') }}</td>
                    <td>
                        <button class="btn btn-danger btn-sm" id="btn_remove_{{ student.user_id }}" onclick="removeStudent({{ student.user_id }}, this)" title="{{ 'Remove'|get_plugin_lang('SchoolPlugin') }}">
                            <i class="fas fa-user-minus"></i>
                        </button>
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
        {% else %}
        <div class="p-3">
            <div class="alert alert-info mb-0">
                <i class="fas fa-info-circle"></i> {{ 'NoStudentsInClassroom'|get_plugin_lang('SchoolPlugin') }}
            </div>
        </div>
        {% endif %}
    </div>
</div>

<!-- Assign Session Modal -->
<div class="modal fade" id="sessionModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-graduation-cap mr-2"></i>Asignar sesión de Chamilo</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>Buscar sesión por nombre</label>
                    <input type="text" class="form-control" id="session_search" placeholder="{{ 'TypeToSearch'|get_plugin_lang('SchoolPlugin') }}" autocomplete="off">
                </div>
                <div id="session_results" style="max-height:300px; overflow-y:auto;"></div>
            </div>
        </div>
    </div>
</div>

<!-- Change Tutor Modal -->
<div class="modal fade" id="tutorModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">{{ 'ChangeTutor'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>{{ 'SearchTeacher'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" class="form-control" id="tutor_search" placeholder="{{ 'TypeToSearch'|get_plugin_lang('SchoolPlugin') }}" autocomplete="off">
                </div>
                <div id="tutor_results" style="max-height:250px; overflow-y:auto;"></div>
                <hr>
                <button class="btn btn-outline-secondary btn-sm" onclick="saveTutor(0)">
                    <i class="fas fa-user-slash"></i> {{ 'RemoveTutor'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Change Supervisor Modal -->
<div class="modal fade" id="supervisorModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-user-shield mr-2"></i>Cambiar supervisor</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>Buscar docente</label>
                    <input type="text" class="form-control" id="supervisor_search" placeholder="{{ 'TypeToSearch'|get_plugin_lang('SchoolPlugin') }}" autocomplete="off">
                </div>
                <div id="supervisor_results" style="max-height:250px; overflow-y:auto;"></div>
                <hr>
                <button class="btn btn-outline-secondary btn-sm" onclick="saveSupervisor(0)">
                    <i class="fas fa-user-slash"></i> Quitar supervisor
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Add Auxiliary Modal -->
<div class="modal fade" id="auxiliaryModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-chalkboard-teacher mr-2"></i>Agregar auxiliar de aula</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>Buscar docente o auxiliar</label>
                    <input type="text" class="form-control" id="aux_search" placeholder="{{ 'TypeToSearch'|get_plugin_lang('SchoolPlugin') }}" autocomplete="off">
                </div>
                <div id="aux_results" style="max-height:280px; overflow-y:auto;"></div>
            </div>
        </div>
    </div>
</div>

<!-- Add Student Modal -->
<div class="modal fade" id="addStudentModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-user-plus mr-2"></i>{{ 'AddStudent'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <!-- Filter -->
                <div class="form-group mb-2">
                    <input type="text" class="form-control" id="candidate_filter" placeholder="{{ 'TypeToSearch'|get_plugin_lang('SchoolPlugin') }}" autocomplete="off">
                </div>
                <!-- Select all bar -->
                <div class="d-flex align-items-center justify-content-between mb-2 px-1" id="candidate_toolbar" style="display:none!important">
                    <div class="custom-control custom-checkbox">
                        <input type="checkbox" class="custom-control-input" id="select_all_candidates">
                        <label class="custom-control-label font-weight-bold" for="select_all_candidates">{{ 'SelectAll'|get_plugin_lang('SchoolPlugin') }}</label>
                    </div>
                    <small class="text-muted" id="candidate_count_label"></small>
                </div>
                <!-- Loading -->
                <div id="candidate_loading" class="text-center py-4">
                    <i class="fas fa-spinner fa-spin fa-2x text-muted"></i>
                </div>
                <!-- Empty state -->
                <div id="candidate_empty" class="alert alert-info mb-0" style="display:none">
                    <i class="fas fa-info-circle"></i> {{ 'NoEnrolledStudentsAvailable'|get_plugin_lang('SchoolPlugin') }}
                </div>
                <!-- List -->
                <div id="candidate_list" style="max-height:380px; overflow-y:auto; display:none"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Cancel'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" id="btn_add_selected" disabled onclick="addSelectedStudents()">
                    <i class="fas fa-user-plus mr-1"></i>
                    <span id="btn_add_label">{{ 'AddSelected'|get_plugin_lang('SchoolPlugin') }}</span>
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';
var classroomId = {{ classroom.id }};
var searchTimeout;

// =========================================================================
// TUTOR SEARCH
// =========================================================================
document.getElementById('tutor_search').addEventListener('input', function() {
    clearTimeout(searchTimeout);
    var query = this.value.trim();
    if (query.length < 2) {
        document.getElementById('tutor_results').innerHTML = '';
        return;
    }
    searchTimeout = setTimeout(function() {
        fetch(ajaxUrl + '?action=search_teachers&q=' + encodeURIComponent(query))
            .then(r => r.json())
            .then(data => {
                var html = '';
                if (data.data && data.data.length > 0) {
                    data.data.forEach(function(t) {
                        html += '<div class="d-flex align-items-center p-2 border-bottom" style="cursor:pointer" onclick="saveTutor(' + t.user_id + ')">';
                        html += '<i class="fas fa-user-tie text-muted mr-2"></i>';
                        html += '<div><strong>' + t.lastname + ', ' + t.firstname + '</strong><br><small class="text-muted">' + t.username + '</small></div>';
                        html += '</div>';
                    });
                } else {
                    html = '<div class="text-muted p-2">{{ 'NoResults'|get_plugin_lang('SchoolPlugin') }}</div>';
                }
                document.getElementById('tutor_results').innerHTML = html;
            });
    }, 300);
});

function saveTutor(tutorId) {
    var fd = new FormData();
    fd.append('action', 'update_tutor');
    fd.append('classroom_id', classroomId);
    fd.append('tutor_id', tutorId);
    fetch(ajaxUrl, {method:'POST', body:fd}).then(r=>r.json()).then(d=>{if(d.success)location.reload();});
}

// =========================================================================
// SUPERVISOR SEARCH
// =========================================================================
document.getElementById('supervisor_search').addEventListener('input', function() {
    clearTimeout(searchTimeout);
    var query = this.value.trim();
    if (query.length < 2) {
        document.getElementById('supervisor_results').innerHTML = '';
        return;
    }
    searchTimeout = setTimeout(function() {
        fetch(ajaxUrl + '?action=search_teachers&q=' + encodeURIComponent(query))
            .then(r => r.json())
            .then(data => {
                var html = '';
                if (data.data && data.data.length > 0) {
                    data.data.forEach(function(t) {
                        html += '<div class="d-flex align-items-center p-2 border-bottom" style="cursor:pointer" onclick="saveSupervisor(' + t.user_id + ')">';
                        html += '<i class="fas fa-user-shield text-info mr-2"></i>';
                        html += '<div><strong>' + t.lastname + ', ' + t.firstname + '</strong><br><small class="text-muted">' + t.username + '</small></div>';
                        html += '</div>';
                    });
                } else {
                    html = '<div class="text-muted p-2">{{ 'NoResults'|get_plugin_lang('SchoolPlugin') }}</div>';
                }
                document.getElementById('supervisor_results').innerHTML = html;
            });
    }, 300);
});

function saveSupervisor(supervisorId) {
    var fd = new FormData();
    fd.append('action', 'update_supervisor');
    fd.append('classroom_id', classroomId);
    fd.append('supervisor_id', supervisorId);
    fetch(ajaxUrl, {method:'POST', body:fd}).then(r=>r.json()).then(d=>{if(d.success)location.reload();});
}

// =========================================================================
// ADD STUDENTS (bulk, from matrícula candidates)
// =========================================================================
var allCandidates = [];

$('#addStudentModal').on('show.bs.modal', function() {
    allCandidates = [];
    document.getElementById('candidate_loading').style.display = '';
    document.getElementById('candidate_empty').style.display = 'none';
    document.getElementById('candidate_list').style.display = 'none';
    document.getElementById('candidate_toolbar').style.display = 'none !important';
    document.getElementById('candidate_filter').value = '';
    document.getElementById('select_all_candidates').checked = false;
    document.getElementById('btn_add_selected').disabled = true;

    fetch(ajaxUrl + '?action=get_classroom_candidates&classroom_id=' + classroomId)
        .then(r => r.json())
        .then(function(data) {
            document.getElementById('candidate_loading').style.display = 'none';
            if (data.data && data.data.length > 0) {
                allCandidates = data.data;
                document.getElementById('candidate_toolbar').removeAttribute('style');
                document.getElementById('candidate_list').style.display = '';
                renderCandidates(allCandidates);
            } else {
                document.getElementById('candidate_empty').style.display = '';
            }
        })
        .catch(function() {
            document.getElementById('candidate_loading').style.display = 'none';
            document.getElementById('candidate_empty').style.display = '';
        });
});

function renderCandidates(list) {
    var html = '';
    if (list.length === 0) {
        html = '<div class="text-muted p-3 text-center">{{ 'NoResults'|get_plugin_lang('SchoolPlugin') }}</div>';
    } else {
        list.forEach(function(s) {
            var fullname = s.apellido_paterno + (s.apellido_materno ? ' ' + s.apellido_materno : '') + ', ' + s.nombres;
            html += '<div class="d-flex align-items-center p-2 border-bottom candidate-row">';
            html += '<div class="custom-control custom-checkbox mr-3">';
            html += '<input type="checkbox" class="custom-control-input candidate-check" id="chk_' + s.user_id + '" value="' + s.user_id + '">';
            html += '<label class="custom-control-label" for="chk_' + s.user_id + '"></label>';
            html += '</div>';
            html += '<div class="flex-grow-1">';
            html += '<strong>' + fullname + '</strong>';
            html += '<br><small class="text-muted">' + s.username + ' &bull; ' + s.email + '</small>';
            html += '</div>';
            html += '</div>';
        });
    }
    document.getElementById('candidate_list').innerHTML = html;
    // Attach change listeners
    document.querySelectorAll('.candidate-check').forEach(function(chk) {
        chk.addEventListener('change', updateAddButton);
    });
    updateAddButton();
}

function updateAddButton() {
    var checked = document.querySelectorAll('.candidate-check:checked').length;
    var total   = document.querySelectorAll('.candidate-check').length;
    var btn     = document.getElementById('btn_add_selected');
    var label   = document.getElementById('btn_add_label');
    btn.disabled = checked === 0;
    label.textContent = checked > 0
        ? '{{ 'AddSelected'|get_plugin_lang('SchoolPlugin') }} (' + checked + ')'
        : '{{ 'AddSelected'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('select_all_candidates').checked = total > 0 && checked === total;
    document.getElementById('candidate_count_label').textContent = checked + ' / ' + total + ' seleccionados';
}

document.getElementById('select_all_candidates').addEventListener('change', function() {
    var checked = this.checked;
    document.querySelectorAll('.candidate-check').forEach(function(chk) {
        chk.checked = checked;
    });
    updateAddButton();
});

document.getElementById('candidate_filter').addEventListener('input', function() {
    var q = this.value.toLowerCase().trim();
    if (!q) {
        renderCandidates(allCandidates);
        return;
    }
    var filtered = allCandidates.filter(function(s) {
        var fullname = (s.apellido_paterno + ' ' + (s.apellido_materno || '') + ' ' + s.nombres).toLowerCase();
        return fullname.indexOf(q) !== -1 || s.username.toLowerCase().indexOf(q) !== -1;
    });
    renderCandidates(filtered);
});

function addSelectedStudents() {
    var checked = document.querySelectorAll('.candidate-check:checked');
    if (checked.length === 0) return;
    var count = checked.length;
    var btn   = document.getElementById('btn_add_selected');
    var label = document.getElementById('btn_add_label');
    btn.disabled = true;
    label.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i> Procesando ' + count + ' alumno(s)...';

    var fd = new FormData();
    fd.append('action', 'add_students_bulk');
    fd.append('classroom_id', classroomId);
    checked.forEach(function(chk) { fd.append('user_ids[]', chk.value); });

    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(function(d) {
            if (d.success) {
                location.reload();
            } else {
                alert(d.message || 'Error');
                btn.disabled = false;
                label.textContent = '{{ 'AddSelected'|get_plugin_lang('SchoolPlugin') }}';
            }
        })
        .catch(function() {
            btn.disabled = false;
            label.textContent = '{{ 'AddSelected'|get_plugin_lang('SchoolPlugin') }}';
        });
}

function removeStudent(userId, btn) {
    if (!confirm('{{ 'ConfirmRemoveStudent'|get_plugin_lang('SchoolPlugin') }}')) return;
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>'; }
    var fd = new FormData();
    fd.append('action', 'remove_student');
    fd.append('classroom_id', classroomId);
    fd.append('user_id', userId);
    fetch(ajaxUrl, {method:'POST', body:fd}).then(r=>r.json()).then(d=>{
        if(d.success) { location.reload(); }
        else { if(btn){btn.disabled=false;btn.innerHTML='<i class="fas fa-user-minus"></i>';} }
    });
}

// =========================================================================
// AUXILIARIES
// =========================================================================
var auxSearchTimeout;

document.getElementById('aux_search').addEventListener('input', function() {
    clearTimeout(auxSearchTimeout);
    var query = this.value.trim();
    if (query.length < 2) {
        document.getElementById('aux_results').innerHTML = '';
        return;
    }
    auxSearchTimeout = setTimeout(function() {
        fetch(ajaxUrl + '?action=search_auxiliaries&q=' + encodeURIComponent(query))
            .then(r => r.json())
            .then(function(data) {
                var html = '';
                if (data.data && data.data.length > 0) {
                    data.data.forEach(function(t) {
                        var role = (t.status == 26) ? '<span class="badge badge-secondary ml-1">Auxiliar</span>' : '<span class="badge badge-info ml-1">Docente</span>';
                        html += '<div class="d-flex align-items-center p-2 border-bottom" style="cursor:pointer" onclick="addAuxiliary(' + t.user_id + ')">';
                        html += '<i class="fas fa-user-tie text-muted mr-2"></i>';
                        html += '<div><strong>' + t.lastname + ', ' + t.firstname + '</strong>' + role + '<br><small class="text-muted">' + t.username + '</small></div>';
                        html += '</div>';
                    });
                } else {
                    html = '<div class="text-muted p-2">{{ 'NoResults'|get_plugin_lang('SchoolPlugin') }}</div>';
                }
                document.getElementById('aux_results').innerHTML = html;
            });
    }, 300);
});

function addAuxiliary(userId) {
    var fd = new FormData();
    fd.append('action', 'add_auxiliary');
    fd.append('classroom_id', classroomId);
    fd.append('user_id', userId);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(function(d) {
            if (d.success) {
                location.reload();
            } else {
                alert(d.message || 'Error al agregar auxiliar');
            }
        });
}

function removeAuxiliary(userId) {
    if (!confirm('¿Quitar este auxiliar del aula?')) return;
    var fd = new FormData();
    fd.append('action', 'remove_auxiliary');
    fd.append('classroom_id', classroomId);
    fd.append('user_id', userId);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(function(d) { if (d.success) location.reload(); });
}

$('#auxiliaryModal').on('hidden.bs.modal', function() {
    document.getElementById('aux_search').value = '';
    document.getElementById('aux_results').innerHTML = '';
});

// =========================================================================
// SESSION ASSIGNMENT
// =========================================================================
var sessionSearchTimeout;

document.getElementById('session_search').addEventListener('input', function() {
    clearTimeout(sessionSearchTimeout);
    var query = this.value.trim();
    if (query.length < 2) {
        document.getElementById('session_results').innerHTML = '';
        return;
    }
    sessionSearchTimeout = setTimeout(function() {
        fetch(ajaxUrl + '?action=search_sessions&q=' + encodeURIComponent(query))
            .then(r => r.json())
            .then(function(data) {
                var html = '';
                if (data.data && data.data.length > 0) {
                    data.data.forEach(function(s) {
                        var dates = '';
                        if (s.display_start_date) {
                            dates = '<small class="text-muted"> · ' + s.display_start_date.substring(0, 10) +
                                (s.display_end_date ? ' → ' + s.display_end_date.substring(0, 10) : '') + '</small>';
                        }
                        html += '<div class="d-flex align-items-center p-2 border-bottom" style="cursor:pointer" onclick="assignSession(' + s.id + ')">';
                        html += '<i class="fas fa-chalkboard text-primary mr-2"></i>';
                        html += '<div><strong>' + s.name + '</strong>' + dates;
                        html += '<br><small class="text-muted">' + (s.nbr_courses || 0) + ' cursos &bull; ' + (s.nbr_users || 0) + ' inscritos</small></div>';
                        html += '</div>';
                    });
                } else {
                    html = '<div class="text-muted p-2">{{ 'NoResults'|get_plugin_lang('SchoolPlugin') }}</div>';
                }
                document.getElementById('session_results').innerHTML = html;
            });
    }, 300);
});

function assignSession(sessionId) {
    var fd = new FormData();
    fd.append('action', 'assign_session');
    fd.append('classroom_id', classroomId);
    fd.append('session_id', sessionId);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(function(d) { if (d.success) location.reload(); else alert('Error al asignar sesión'); });
}

function removeSession() {
    if (!confirm('¿Quitar la sesión de este aula?\n\nLos alumnos del aula serán removidos de esa sesión en Chamilo.')) return;
    var fd = new FormData();
    fd.append('action', 'remove_session');
    fd.append('classroom_id', classroomId);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(function(d) {
            if (d.success) {
                location.reload();
            } else {
                alert(d.message || 'Error al quitar la sesión');
            }
        });
}

function enrollToSession() {
    var btn = document.getElementById('btn-enroll-session');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i> Inscribiendo...';
    var fd = new FormData();
    fd.append('action', 'enroll_to_session');
    fd.append('classroom_id', classroomId);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(function(d) {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-user-plus mr-1"></i> Inscribir alumnos';
            var resultDiv = document.getElementById('enroll-result');
            if (!resultDiv) return;
            if (d.success) {
                resultDiv.style.display = '';
                resultDiv.innerHTML = '<div class="alert alert-success py-2 mb-0">' +
                    '<i class="fas fa-check-circle mr-1"></i>' +
                    '<strong>' + d.enrolled + '</strong> alumnos inscritos. ' +
                    (d.skipped > 0 ? '<span class="text-muted">(' + d.skipped + ' ya estaban inscritos)</span>' : '') +
                    '</div>';
            } else {
                resultDiv.style.display = '';
                resultDiv.innerHTML = '<div class="alert alert-danger py-2 mb-0">' +
                    '<i class="fas fa-exclamation-circle mr-1"></i>' + (d.message || 'Error') + '</div>';
            }
        });
}

$('#sessionModal').on('hidden.bs.modal', function() {
    document.getElementById('session_search').value = '';
    document.getElementById('session_results').innerHTML = '';
});
</script>
