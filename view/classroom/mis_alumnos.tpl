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
        <div class="col-6 col-md-3">
            <div class="card border-left-secondary shadow-sm h-100 py-2">
                <div class="card-body py-2">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-secondary text-uppercase mb-1">Sin registro</div>
                            <div class="h4 mb-0 font-weight-bold text-gray-800">{{ count_sin_registro }}</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-minus-circle fa-2x text-secondary" style="opacity:.4;"></i>
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
            <span class="text-muted small">
                <i class="fas fa-calendar-alt mr-1"></i>{{ selected_date }}
            </span>
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
                            <th>Asistencia</th>
                            <th>Hora entrada</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for s in students %}
                        <tr>
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

                            {# Estado asistencia #}
                            <td>
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
                            <td class="text-muted" style="font-size:12px;">
                                {% if s.att_time %}
                                <i class="fas fa-clock mr-1 text-muted" style="font-size:10px;"></i>{{ s.att_time }}
                                {% else %}
                                &mdash;
                                {% endif %}
                            </td>
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
