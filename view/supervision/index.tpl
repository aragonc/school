<div class="container-fluid px-4 py-4">

    {# ---- Encabezado ---- #}
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap" style="gap:10px;">
        <div>
            <h4 class="mb-1 font-weight-bold text-dark">
                <i class="fas fa-user-shield text-info mr-2"></i>Supervisión
            </h4>
            {% if year_name %}
            <p class="mb-0 text-muted small">
                <i class="fas fa-calendar-alt mr-1"></i>Año académico: <strong>{{ year_name }}</strong>
            </p>
            {% endif %}
        </div>
    </div>

    {% if not classrooms %}
    <div class="alert alert-info">
        <i class="fas fa-info-circle mr-2"></i>
        No tienes aulas asignadas para supervisar en el año académico activo.
    </div>

    {% else %}

    {# ---- Tarjetas de aulas supervisadas ---- #}
    {% for cls in classrooms %}
    <div class="card shadow-sm border-0 mb-4">

        {# Cabecera del aula #}
        <div class="card-header py-3 d-flex align-items-center justify-content-between flex-wrap" style="gap:8px; background:#1a3558;">
            <div>
                <span class="text-white font-weight-bold" style="font-size:15px;">
                    <i class="fas fa-chalkboard mr-2"></i>
                    {{ cls.level_name }} &mdash; {{ cls.grade_name }}
                    {% if cls.section_name %} &mdash; Sección {{ cls.section_name }}{% endif %}
                </span>
            </div>
            <div class="d-flex align-items-center" style="gap:10px;">
                <span class="badge badge-light text-dark px-3 py-2" style="font-size:12px;">
                    <i class="fas fa-users mr-1"></i>{{ cls.student_count }} alumnos
                </span>
                <a href="{{ _p.web }}my-aula/mis-alumnos{% if cls.id %}?classroom_id={{ cls.id }}{% endif %}"
                   class="btn btn-sm btn-outline-light">
                    <i class="fas fa-user-graduate mr-1"></i>Ver alumnos
                </a>
            </div>
        </div>

        <div class="card-body">
            <div class="row">

                {# Info del tutor #}
                <div class="col-md-4 mb-3">
                    <div class="d-flex align-items-center p-3 rounded" style="background:#f8f9fa; border:1px solid #e2e8f0;">
                        <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center mr-3 flex-shrink-0"
                             style="width:42px;height:42px;">
                            <i class="fas fa-user-tie"></i>
                        </div>
                        <div>
                            <small class="text-muted d-block" style="font-size:11px; text-transform:uppercase; letter-spacing:.5px;">Tutor</small>
                            <span class="font-weight-bold text-dark" style="font-size:13px;">
                                {% if cls.tutor_full_name %}
                                    {{ cls.tutor_full_name }}
                                {% else %}
                                    <span class="text-muted">Sin tutor asignado</span>
                                {% endif %}
                            </span>
                        </div>
                    </div>
                </div>

                {# Sesión vinculada #}
                <div class="col-md-8 mb-3">
                    {% if cls.session_name %}
                    <div class="p-3 rounded" style="background:#f0f7ff; border:1px solid #bee3f8;">
                        <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-layer-group text-primary mr-2"></i>
                            <span class="font-weight-bold text-primary" style="font-size:13px;">Sesión: {{ cls.session_name }}</span>
                        </div>
                        {% if cls.session_courses %}
                        <div class="row" style="row-gap:6px;">
                            {% for course in cls.session_courses %}
                            <div class="col-sm-6">
                                <a href="{{ web_course_path }}{{ course.code }}/index.php?id_session={{ cls.session_id }}"
                                   target="_blank"
                                   class="d-flex align-items-center px-2 py-2 rounded bg-white text-decoration-none"
                                   style="border:1px solid #d0e8fb; transition:background .15s;"
                                   onmouseover="this.style.background='#e8f4fd'" onmouseout="this.style.background='#fff'">
                                    <i class="fas fa-book-open text-info mr-2 flex-shrink-0" style="font-size:13px;"></i>
                                    <div style="min-width:0;">
                                        <span class="d-block text-truncate" style="font-size:12px; font-weight:600; color:#2d3748;">{{ course.title }}</span>
                                        <span class="text-muted" style="font-size:10px;">{{ course.code }}</span>
                                    </div>
                                    <i class="fas fa-external-link-alt text-muted ml-auto pl-2" style="font-size:10px; flex-shrink:0;"></i>
                                </a>
                            </div>
                            {% endfor %}
                        </div>
                        {% else %}
                        <p class="mb-0 text-muted small"><i class="fas fa-exclamation-circle mr-1"></i>Esta sesión no tiene cursos asignados.</p>
                        {% endif %}
                    </div>
                    {% else %}
                    <div class="p-3 rounded d-flex align-items-center" style="background:#f7f8fa; border:1px solid #e2e8f0; min-height:72px;">
                        <i class="fas fa-unlink text-muted mr-2"></i>
                        <span class="text-muted small">Esta aula no tiene una sesión de Chamilo vinculada.</span>
                    </div>
                    {% endif %}
                </div>

            </div>{# /row #}
        </div>{# /card-body #}
    </div>{# /card #}
    {% endfor %}

    {% endif %}

</div>
