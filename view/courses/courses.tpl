
{# ---- View toggle ---- #}
<div class="d-flex justify-content-end align-items-center mb-2 pt-1">
    <div class="btn-group btn-group-sm" role="group" id="view-toggle-group">
        <button type="button" class="btn btn-outline-secondary active" id="btn-view-list" title="Vista lista">
            <i class="fas fa-list"></i>
        </button>
        <button type="button" class="btn btn-outline-secondary" id="btn-view-grid" title="Vista tarjetas">
            <i class="fas fa-th-large"></i>
        </button>
    </div>
</div>

{# ================================================================
   VISTA LISTA (original)
   ================================================================ #}
<div id="view-list">

<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link active" href="/courses">
            {{ 'Current'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_courses + total_base_courses }}</span>
        </a>
    </li>
    {% if show_previous_tab and total_history > 0 %}
    <li class="nav-item">
        <a class="nav-link " href="/previous" >
            {{ 'Previous'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_history }}</span>
        </a>
    </li>
    {% endif %}
</ul>
<div class="tab-content" id="tab_courses">
    <div class="tab-pane fade show active" id="current_courses" role="tabpanel" aria-labelledby="current_courses-tab">

        {% if show_base_courses and total_base_courses > 0 %}
        <div class="pt-0 pb-4">
            <div id="category_base_courses" class="category">
                <div class="container-fluid">
                    <div class="row align-items-center pb-3 pt-3">
                        <div class="col">
                            <div class="d-flex flex-row align-items-center">
                                <div class="p-0 p-md-2"><h4 class="category-name">{{ 'GeneralCourses'|get_plugin_lang('SchoolPlugin') }}</h4></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            {% for course in base_courses %}
            <div class="card pl-0 pr-0 pl-lg-4 pr-lg-4 mb-2 d-none d-md-block">
                <div class="course-box box-{{ course.ribbon }} pt-1 pb-1 pr-3 pl-3">
                    <div class="row align-items-center">
                        <div class="col">
                            <a class="course-link" href="{{ course.url }}" title="{{ course.title }}">
                                {{ course.icon }} <span class="course-title">{{ course.title }}</span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="course-mobile d-md-none">
                <div class="row align-items-center">
                    <div class="col-10 pr-0">
                        <div class="d-flex justify-content-start">
                            <div class="icon-mobile">
                                {{ course.icon_mobile }}
                            </div>
                            <div class="mobile-title">
                                <a class="course-link" href="{{ course.url }}" title="{{ course.title }}">
                                    <span class="course-title">{{ course.title }}</span>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            {% endfor %}
        </div>
        {% endif %}

        {% if categories %}
        <div class="pt-0 pb-4">
        {% for category in categories %}
            <div id="category_{{ category.category_id }}" class="category">
                <div class="container-fluid">
                    <div class="row align-items-center pb-2 pt-3">
                        <div class="col">
                            <h4 class="category-name">
                                {{ 'MyCoursesCurrent'|get_plugin_lang('SchoolPlugin') }}
                            </h4>
                        </div>
                    </div>
                </div>
            </div>

            {% for session in category.sessions %}
            <div class="card session-card mb-3">
                <div class="card-header session-card-header d-flex align-items-center">
                    <span class="session-header-icon d-none d-md-inline-flex">{{ session.session_image }}</span>
                    <span class="session-header-icon d-md-none">{{ session.session_image_mobile }}</span>
                    <span class="session-header-name ml-2">{{ session.name }}</span>
                    <span class="ml-auto d-flex align-items-center" style="gap:10px;">
                        <span class="badge badge-light session-count-badge">
                            <i class="fas fa-book-open mr-1"></i>{{ session.number_courses }}
                        </span>
                        <div class="btn-group btn-group-sm card-size-toggle" role="group" title="Tamaño de cards">
                            <button type="button" class="btn btn-outline-light btn-card-size" data-size="sm" title="Pequeño">S</button>
                            <button type="button" class="btn btn-outline-light btn-card-size" data-size="md" title="Mediano">M</button>
                            <button type="button" class="btn btn-outline-light btn-card-size" data-size="lg" title="Grande">L</button>
                        </div>
                    </span>
                </div>
                <div class="card-body session-courses-body">
                    {% if session.courses %}
                    <div class="session-courses-grid">
                        {% for course in session.courses %}
                        {% set cidx = loop.index0 % 8 %}
                        {% set can_upload = (session.coach == 'true') or (course.course_coach_user_id == current_user_id) %}
                        <div class="card course-inner-card"
                             data-session-id="{{ session.id }}"
                             data-course-id="{{ course.real_id }}"
                             data-course-code="{{ course.course_code }}"
                             data-coaches="{{ course.course_coaches|json_encode|e('html_attr') }}"
                             data-is-coach="{{ session.coach }}">
                            <a href="{{ course.url }}" class="course-inner-header bg-gc-{{ cidx }}">
                                {% if course.image_url %}
                                <img class="card-course-img" src="{{ course.image_url }}" alt="{{ course.title }}"
                                     onerror="this.style.display='none'; this.nextElementSibling.classList.remove('d-none');">
                                {% endif %}
                                <div class="card-course-placeholder {% if course.image_url %}d-none{% endif %}">
                                    {{ course.icon }}
                                </div>
                            </a>
                            {% if can_upload %}
                            <button type="button" class="btn-upload-img" title="Cambiar imagen del curso">
                                <i class="fas fa-camera"></i>
                            </button>
                            {% endif %}
                            <div class="card-body p-2">
                                <a href="{{ course.url }}" class="course-inner-title" title="{{ course.title }}">
                                    {{ course.title }}
                                </a>
                                <div class="course-coaches-list mt-1">
                                    {% if course.course_coaches %}
                                        {% for coach in course.course_coaches %}
                                        <div class="course-inner-coach d-flex align-items-center justify-content-between">
                                            <span><i class="fas fa-chalkboard-teacher"></i> <span class="coach-name-text">{{ coach.name }}</span></span>
                                            {% if session.coach == 'true' %}
                                            <button type="button" class="btn-remove-coach btn btn-link p-0 ml-1"
                                                    data-coach-id="{{ coach.id }}"
                                                    data-coach-name="{{ coach.name|e('html_attr') }}"
                                                    title="Quitar docente">
                                                <i class="fas fa-times" style="font-size:10px;color:#e53e3e;"></i>
                                            </button>
                                            {% endif %}
                                        </div>
                                        {% endfor %}
                                        {% if session.coach == 'true' %}
                                        <button type="button" class="btn-assign-coach btn btn-link p-0 mt-1" title="Agregar docente" style="font-size:10px;color:#2563aa;">
                                            <i class="fas fa-user-plus mr-1"></i>Agregar docente
                                        </button>
                                        {% endif %}
                                    {% else %}
                                        <div class="course-inner-no-coach d-flex align-items-center justify-content-between">
                                            <span><i class="fas fa-exclamation-triangle"></i> Sin docente asignado</span>
                                            {% if session.coach == 'true' %}
                                            <button type="button" class="btn-assign-coach btn btn-link p-0 ml-1" title="Asignar docente">
                                                <i class="fas fa-user-plus" style="font-size:10px;color:#dd6b20;"></i>
                                            </button>
                                            {% endif %}
                                        </div>
                                    {% endif %}
                                </div>
                            </div>
                            <div class="card-footer p-2">
                                <a href="{{ course.url }}" class="btn btn-primary btn-sm btn-block">
                                    <i class="fas fa-play-circle mr-1"></i> Acceder
                                </a>
                            </div>
                        </div>
                        {% endfor %}
                    </div>
                    {% else %}
                    <p class="text-muted mb-0"><em>Sin cursos disponibles.</em></p>
                    {% endif %}
                </div>
            </div>
            {% endfor %}

        {% endfor %}
        </div>

        {% else %}
            {% if not show_base_courses or total_base_courses == 0 %}
            <div class="p-5 text-center">
                <h3>{{ 'NoTrainingInProgress'|get_plugin_lang('SchoolPlugin') }}</h3>
                <p>{{ 'CompletedTrainings'|get_plugin_lang('SchoolPlugin') }} <a href="/previous">{{ 'ClickHere'|get_plugin_lang('SchoolPlugin') }}</a></p>
                {{ img_section }}
            </div>
            {% endif %}
        {% endif %}
    </div>
</div>

</div>{# /view-list #}

{# ================================================================
   VISTA TARJETAS (grid)
   ================================================================ #}
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.css">
<style>
/* ---- Session card (list view) ---- */
.session-card {
    border: 1px solid #dde3ec;
    border-radius: 10px !important;
    overflow: hidden;
}
.session-card-header {
    background: linear-gradient(135deg, #1a3558 0%, #2563aa 100%);
    color: #fff;
    padding: 10px 16px;
    gap: 6px;
}
.session-header-name {
    font-size: 15px;
    font-weight: 700;
    flex: 1;
}
.session-count-badge {
    font-size: 11px;
    color: #4a5568;
    white-space: nowrap;
}
.session-courses-body {
    background: #f7f9fc;
    padding: 16px !important;
}
.session-courses-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 14px;
}
.session-courses-grid[data-size="sm"] { grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 10px; }
.session-courses-grid[data-size="md"] { grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 14px; }
.session-courses-grid[data-size="lg"] { grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 18px; }
.card-size-toggle .btn-card-size {
    font-size: 10px;
    font-weight: 700;
    padding: 1px 7px;
    line-height: 1.6;
    border-color: rgba(255,255,255,.4);
    color: rgba(255,255,255,.8);
}
.card-size-toggle .btn-card-size.active,
.card-size-toggle .btn-card-size:hover {
    background: rgba(255,255,255,.25);
    border-color: rgba(255,255,255,.8);
    color: #fff;
}
.course-inner-card {
    border-radius: 8px !important;
    overflow: hidden;
    border: 1px solid #e2e8f0 !important;
    transition: transform .15s, box-shadow .15s;
}
.course-inner-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 4px 14px rgba(0,0,0,.15) !important;
}
.course-inner-header {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 90px;
    overflow: hidden;
    text-decoration: none !important;
    position: relative;
}
.course-inner-header .card-course-img {
    width: 100%; height: 100%;
    object-fit: cover;
}
.course-inner-header .card-course-placeholder {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%; height: 100%;
}
.course-inner-header .card-course-placeholder svg,
.course-inner-header .card-course-placeholder img {
    width: 40px; height: 40px;
}
.course-inner-title {
    font-size: 12px;
    font-weight: 600;
    line-height: 1.3;
    color: #1a202c;
    display: block;
}
.course-inner-title:hover {
    color: #2563aa;
    text-decoration: none;
}
.course-inner-coach {
    font-size: 11px;
    color: #718096;
    line-height: 1.3;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.course-inner-coach i {
    color: #2563aa;
}
.course-inner-no-coach {
    font-size: 11px;
    color: #c05621;
    line-height: 1.3;
}
.course-inner-no-coach i {
    color: #dd6b20;
}
.course-inner-card .card-footer {
    background: transparent;
    border-top: 1px solid #e2e8f0;
}
/* ---- Upload image button ---- */
.course-inner-card {
    position: relative;
}
.btn-upload-img {
    position: absolute;
    top: 6px;
    right: 6px;
    width: 28px;
    height: 28px;
    border-radius: 50%;
    background: rgba(0,0,0,.55);
    border: none;
    color: #fff;
    font-size: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    opacity: 0;
    transition: opacity .18s;
    z-index: 10;
}
.course-inner-card:hover .btn-upload-img {
    opacity: 1;
}
.btn-upload-img:hover {
    background: rgba(37,99,170,.9);
}

/* ---- courses-grid (existing) ---- */
.courses-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
    gap: 18px;
    padding: 16px 0 24px;
}
.course-card {
    border-radius: 12px !important;
    overflow: hidden;
    transition: transform .18s, box-shadow .18s;
    cursor: pointer;
}
.course-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 .6rem 1.8rem rgba(0,0,0,.22) !important;
}
.course-card-header {
    height: 110px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    overflow: hidden;
    text-decoration: none !important;
    cursor: pointer;
}
a.course-card-header:hover {
    opacity: .88;
}
.course-card-header-multi {
    cursor: pointer;
}
.course-card-header .card-course-img {
    width: 100%; height: 100%;
    object-fit: cover;
    display: block;
}
.course-card-header .card-course-placeholder {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%; height: 100%;
}
.course-card-header .card-course-placeholder img,
.course-card-header .card-course-placeholder svg {
    width: 52px; height: 52px;
}
.course-card .card-body {
    padding: 12px 14px 6px;
}
.course-card .card-title {
    font-size: 13px;
    font-weight: 700;
    line-height: 1.35;
    margin-bottom: 6px;
    color: #1a202c;
}
.course-card .card-footer {
    background: transparent;
    border-top: 1px solid rgba(0,0,0,.07);
    padding: 8px 14px;
}
.course-cat-badge {
    font-size: 10px;
    padding: 2px 8px;
    border-radius: 20px;
    background: #eef1f6;
    color: #4a5568;
    font-weight: 600;
    display: inline-block;
    margin-bottom: 4px;
}
.course-count-badge {
    font-size: 11px;
    color: #718096;
}
/* 8 gradient backgrounds for cards */
.bg-gc-0 { background: linear-gradient(135deg,#667eea 0%,#764ba2 100%); }
.bg-gc-1 { background: linear-gradient(135deg,#f093fb 0%,#f5576c 100%); }
.bg-gc-2 { background: linear-gradient(135deg,#4facfe 0%,#00c9ff 100%); }
.bg-gc-3 { background: linear-gradient(135deg,#43e97b 0%,#38f9d7 100%); }
.bg-gc-4 { background: linear-gradient(135deg,#fa709a 0%,#fee140 100%); }
.bg-gc-5 { background: linear-gradient(135deg,#a18cd1 0%,#fbc2eb 100%); }
.bg-gc-6 { background: linear-gradient(135deg,#f77062 0%,#fe5196 100%); }
.bg-gc-7 { background: linear-gradient(135deg,#1a3558 0%,#2563aa 100%); }

.grid-category-heading {
    font-size: 14px;
    font-weight: 700;
    color: #1a3558;
    padding: 8px 0 4px;
    border-bottom: 2px solid #e2e8f0;
    margin-bottom: 4px;
    display: flex;
    align-items: center;
    gap: 8px;
}
</style>

<div id="view-grid" style="display:none;">

    {# Base courses #}
    {% if show_base_courses and total_base_courses > 0 %}
    <div class="grid-category-heading">
        <span>{{ 'GeneralCourses'|get_plugin_lang('SchoolPlugin') }}</span>
        <span class="badge badge-info">{{ total_base_courses }}</span>
    </div>
    <div class="courses-grid">
        {% for course in base_courses %}
        {% set gidx = loop.index0 % 8 %}
        <div class="card course-card">
            <a href="{{ course.url }}" class="course-card-header bg-gc-{{ gidx }}">
                {% if course.image_url %}
                <img class="card-course-img" src="{{ course.image_url }}" alt="{{ course.title }}"
                     onerror="this.parentNode.classList.add('img-fallback'); this.style.display='none';">
                {% endif %}
                <div class="card-course-placeholder {% if course.image_url %}d-none img-show-fallback{% endif %}">
                    {{ course.icon }}
                </div>
            </a>
            <div class="card-body">
                <div class="card-title">{{ course.title }}</div>
            </div>
            <div class="card-footer">
                <a href="{{ course.url }}" class="btn btn-primary btn-sm btn-block">
                    <i class="fas fa-play-circle mr-1"></i> Acceder
                </a>
            </div>
        </div>
        {% endfor %}
    </div>
    {% endif %}

    {# Session cards grouped by category #}
    {% if categories %}
    {% set cardCounter = 0 %}
    {% for category in categories %}
    <div class="grid-category-heading mt-3">
        <span>{{ 'MyCoursesCurrent'|get_plugin_lang('SchoolPlugin') }}</span>
        <span class="badge badge-info">{{ category.sessions|length }}</span>
    </div>
    <div class="courses-grid">
        {% for session in category.sessions %}
        {% set gidx = (loop.index0 + category.category_id) % 8 %}
        <div class="card course-card">
            <div class="course-card-header bg-gc-{{ gidx }} course-card-header-multi"
                 data-anchor="category_{{ category.category_id }}">
                <div class="card-course-placeholder">
                    {{ session.session_image }}
                </div>
            </div>
            <div class="card-body">
                <div class="card-title">{{ session.name }}</div>
                <div class="course-count-badge">
                    <i class="fas fa-book mr-1"></i>{{ session.number_courses }} curso(s)
                </div>
            </div>
            <div class="card-footer">
                <button type="button" class="btn btn-primary btn-sm btn-block btn-grid-goto-list"
                        data-anchor="category_{{ category.category_id }}">
                    <i class="fas fa-list mr-1"></i> Ver cursos
                </button>
            </div>
        </div>
        {% endfor %}
    </div>
    {% endfor %}
    {% endif %}

    {% if not categories and (not show_base_courses or total_base_courses == 0) %}
    <div class="p-5 text-center">
        <h3>{{ 'NoTrainingInProgress'|get_plugin_lang('SchoolPlugin') }}</h3>
        {{ img_section }}
    </div>
    {% endif %}

</div>{# /view-grid #}

{% if show_certificates %}
<div class="py-3">
    <a href="{{ _p.web }}certified" class="btn btn-primary btn-goto"><i class="fas fa-file-alt"></i> {{ 'GotoMyCertificates'|get_plugin_lang('SchoolPlugin') }}</a>
</div>
{% endif %}

{% if show_profile_completion_modal %}
{% include 'profile/completion_modal.tpl' %}
{% endif %}

{# ── Modal: agregar docente al curso ── #}
<div class="modal fade" id="modalAssignCoach" tabindex="-1" role="dialog" aria-labelledby="modalAssignCoachLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:linear-gradient(135deg,#1a3558 0%,#2563aa 100%);color:#fff;">
                <h5 class="modal-title" id="modalAssignCoachLabel">
                    <i class="fas fa-chalkboard-teacher mr-2"></i>
                    Agregar docente
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p class="text-muted mb-2" id="modalCourseName" style="font-size:13px;"></p>

                <div class="form-group mb-2">
                    <label style="font-size:12px;font-weight:600;">Buscar docente</label>
                    <div class="input-group input-group-sm">
                        <input type="text" id="coachSearchInput" class="form-control"
                               placeholder="Nombre, apellido o usuario...">
                        <div class="input-group-append">
                            <button class="btn btn-outline-secondary" type="button" id="btnSearchCoach">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <div id="coachSearchResults" style="max-height:220px;overflow-y:auto;"></div>

                <div id="coachSelected" class="alert alert-success py-2 px-3 mb-0 mt-2 d-none" style="font-size:13px;">
                    <i class="fas fa-check-circle mr-1"></i>
                    Seleccionado: <strong id="coachSelectedName"></strong>
                </div>
            </div>
            <div class="modal-footer d-flex justify-content-end">
                <div>
                    <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-sm btn-primary" id="btnSaveCoach" disabled>
                        <i class="fas fa-save mr-1"></i> Guardar
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

{# ── Modal: recortar imagen de curso ── #}
<div class="modal fade" id="modalCropImage" tabindex="-1" role="dialog" aria-hidden="true" data-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:linear-gradient(135deg,#1a3558 0%,#2563aa 100%);color:#fff;">
                <h5 class="modal-title">
                    <i class="fas fa-crop-alt mr-2"></i> Recortar imagen del curso
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body p-0" style="background:#1a1a2e;min-height:300px;">
                <div style="max-height:420px;">
                    <img id="cropperImg" src="" alt="" style="max-width:100%;display:block;">
                </div>
            </div>
            <div class="modal-footer d-flex justify-content-between align-items-center flex-wrap" style="gap:8px;">
                <div class="d-flex align-items-center flex-wrap" style="gap:6px;">
                    <small class="text-muted mr-1">Proporción:</small>
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-outline-secondary btn-crop-ratio active" data-ratio="1" title="Cuadrado">1:1</button>
                        <button class="btn btn-outline-secondary btn-crop-ratio" data-ratio="1.7778" title="Panorámico">16:9</button>
                        <button class="btn btn-outline-secondary btn-crop-ratio" data-ratio="free" title="Sin restricción">Libre</button>
                    </div>
                    <div class="btn-group btn-group-sm ml-1">
                        <button class="btn btn-outline-secondary" id="btnCropRotateL" title="Rotar -90°"><i class="fas fa-undo"></i></button>
                        <button class="btn btn-outline-secondary" id="btnCropRotateR" title="Rotar +90°"><i class="fas fa-redo"></i></button>
                        <button class="btn btn-outline-secondary" id="btnCropFlipH" title="Voltear horizontal"><i class="fas fa-arrows-alt-h"></i></button>
                    </div>
                </div>
                <div class="d-flex" style="gap:6px;">
                    <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-sm btn-primary" id="btnCropConfirm">
                        <i class="fas fa-check mr-1"></i> Recortar y subir
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.js"></script>
<script>
(function () {
    var PREF_KEY = 'school_courses_view';

    var listDiv  = document.getElementById('view-list');
    var gridDiv  = document.getElementById('view-grid');
    var btnList  = document.getElementById('btn-view-list');
    var btnGrid  = document.getElementById('btn-view-grid');

    function showView(mode) {
        if (mode === 'grid') {
            listDiv.style.display = 'none';
            gridDiv.style.display = '';
            btnList.classList.remove('active');
            btnGrid.classList.add('active');
        } else {
            gridDiv.style.display = 'none';
            listDiv.style.display = '';
            btnGrid.classList.remove('active');
            btnList.classList.add('active');
        }
        try { localStorage.setItem(PREF_KEY, mode); } catch(e) {}
    }

    // Restore saved preference (default: grid)
    var saved = 'grid';
    try { saved = localStorage.getItem(PREF_KEY) || 'grid'; } catch(e) {}
    showView(saved);

    btnList.addEventListener('click', function () { showView('list'); });
    btnGrid.addEventListener('click', function () { showView('grid'); });

    // "Ver cursos" button + multi-course header → switch to list view and scroll to category
    function gotoList(anchor) {
        showView('list');
        var target = document.getElementById(anchor);
        if (target) {
            setTimeout(function () {
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }, 80);
        }
    }
    document.querySelectorAll('.btn-grid-goto-list').forEach(function (btn) {
        btn.addEventListener('click', function () { gotoList(btn.getAttribute('data-anchor')); });
    });
    document.querySelectorAll('.course-card-header-multi').forEach(function (div) {
        div.addEventListener('click', function () { gotoList(div.getAttribute('data-anchor')); });
    });

    // ---- Card size toggle ----
    var SIZE_KEY = 'school_card_size';
    var savedSize = 'md';
    try { savedSize = localStorage.getItem(SIZE_KEY) || 'md'; } catch(e) {}

    function applyCardSize(size) {
        document.querySelectorAll('.session-courses-grid').forEach(function(grid) {
            grid.setAttribute('data-size', size);
        });
        document.querySelectorAll('.btn-card-size').forEach(function(btn) {
            btn.classList.toggle('active', btn.getAttribute('data-size') === size);
        });
        try { localStorage.setItem(SIZE_KEY, size); } catch(e) {}
    }

    applyCardSize(savedSize);

    document.querySelectorAll('.btn-card-size').forEach(function(btn) {
        btn.addEventListener('click', function() {
            applyCardSize(btn.getAttribute('data-size'));
        });
    });

    // When an image loads but errors → show placeholder
    document.querySelectorAll('.course-card-header img.card-course-img').forEach(function (img) {
        img.addEventListener('error', function () {
            var placeholder = img.parentNode.querySelector('.card-course-placeholder');
            if (placeholder) {
                placeholder.classList.remove('d-none');
            }
        });
    });

    // ── Assign coach modal ────────────────────────────────────────────────────
    var COACH_ENDPOINT    = '{{ _p.web_plugin }}school/src/courses/assign_course_coach.php';
    var _activeCard       = null;
    var _selectedUserId   = null;
    var _selectedUserName = null;

    var $modal        = document.getElementById('modalAssignCoach');
    var $searchInput  = document.getElementById('coachSearchInput');
    var $searchBtn    = document.getElementById('btnSearchCoach');
    var $results      = document.getElementById('coachSearchResults');
    var $selected     = document.getElementById('coachSelected');
    var $selectedName = document.getElementById('coachSelectedName');
    var $saveBtn      = document.getElementById('btnSaveCoach');
    var $courseName   = document.getElementById('modalCourseName');

    function resetModal() {
        $searchInput.value = '';
        $results.innerHTML = '';
        $selected.classList.add('d-none');
        $saveBtn.disabled = true;
        _selectedUserId   = null;
        _selectedUserName = null;
    }

    /**
     * Re-render the coaches list inside a card and re-bind all coach buttons.
     * @param {Element} card     - .course-inner-card element
     * @param {Array}   coaches  - [{id, name}, ...] from backend
     */
    function renderCoachesList(card, coaches) {
        // Update JSON attribute
        card.setAttribute('data-coaches', JSON.stringify(coaches));

        var list = card.querySelector('.course-coaches-list');
        if (!list) return;

        var isCoach = card.getAttribute('data-is-coach') === 'true';
        var html = '';

        if (coaches.length) {
            coaches.forEach(function(c) {
                html += '<div class="course-inner-coach d-flex align-items-center justify-content-between">'
                      + '<span><i class="fas fa-chalkboard-teacher"></i> <span class="coach-name-text">'
                      + escHtml(c.name) + '</span></span>';
                if (isCoach) {
                    html += '<button type="button" class="btn-remove-coach btn btn-link p-0 ml-1"'
                          + ' data-coach-id="' + c.id + '"'
                          + ' data-coach-name="' + escHtml(c.name) + '"'
                          + ' title="Quitar docente">'
                          + '<i class="fas fa-times" style="font-size:10px;color:#e53e3e;"></i>'
                          + '</button>';
                }
                html += '</div>';
            });
            if (isCoach) {
                html += '<button type="button" class="btn-assign-coach btn btn-link p-0 mt-1"'
                      + ' title="Agregar docente" style="font-size:10px;color:#2563aa;">'
                      + '<i class="fas fa-user-plus mr-1"></i>Agregar docente</button>';
            }
        } else {
            html += '<div class="course-inner-no-coach d-flex align-items-center justify-content-between">'
                  + '<span><i class="fas fa-exclamation-triangle"></i> Sin docente asignado</span>';
            if (isCoach) {
                html += '<button type="button" class="btn-assign-coach btn btn-link p-0 ml-1"'
                      + ' title="Asignar docente">'
                      + '<i class="fas fa-user-plus" style="font-size:10px;color:#dd6b20;"></i>'
                      + '</button>';
            }
            html += '</div>';
        }

        list.innerHTML = html;
        bindCoachButtons(card);
    }

    function escHtml(str) {
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function bindCoachButtons(card) {
        card.querySelectorAll('.btn-assign-coach').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                openAssignModal(card);
            });
        });

        card.querySelectorAll('.btn-remove-coach').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                var coachId   = btn.getAttribute('data-coach-id');
                var coachName = btn.getAttribute('data-coach-name');
                if (!confirm('¿Quitar a ' + coachName + ' de este curso?')) return;

                var sessionId = card.getAttribute('data-session-id');
                var courseId  = card.getAttribute('data-course-id');

                var fd = new FormData();
                fd.append('action',        'remove');
                fd.append('session_id',    sessionId);
                fd.append('course_id',     courseId);
                fd.append('coach_user_id', coachId);

                fetch(COACH_ENDPOINT, { method: 'POST', body: fd })
                    .then(function(r){ return r.json(); })
                    .then(function(data) {
                        if (data.success) {
                            renderCoachesList(card, data.coaches);
                        } else {
                            alert('Error: ' + (data.message || 'No se pudo quitar'));
                        }
                    })
                    .catch(function() {
                        alert('Error de conexión');
                    });
            });
        });
    }

    function openAssignModal(card) {
        _activeCard = card;
        var courseTitle = card.querySelector('.course-inner-title')
                            ? card.querySelector('.course-inner-title').textContent.trim()
                            : '';
        resetModal();
        $courseName.textContent = 'Curso: ' + courseTitle;
        $('#modalAssignCoach').modal('show');
    }

    // Initial binding for all cards
    document.querySelectorAll('.course-inner-card').forEach(function(card) {
        bindCoachButtons(card);
    });

    function doSearch() {
        var q = $searchInput.value.trim();
        if (q.length < 2) {
            $results.innerHTML = '<p class="text-muted px-1" style="font-size:12px;">Escribe al menos 2 caracteres.</p>';
            return;
        }
        var sessionId = _activeCard ? _activeCard.getAttribute('data-session-id') : 0;
        $results.innerHTML = '<p class="text-muted px-1" style="font-size:12px;"><i class="fas fa-spinner fa-spin mr-1"></i>Buscando...</p>';

        fetch(COACH_ENDPOINT + '?action=search_users&session_id=' + sessionId + '&q=' + encodeURIComponent(q))
            .then(function(r){ return r.json(); })
            .then(function(data) {
                if (!data.success || !data.users.length) {
                    $results.innerHTML = '<p class="text-muted px-1" style="font-size:12px;">Sin resultados.</p>';
                    return;
                }
                var html = '<ul class="list-group list-group-flush">';
                data.users.forEach(function(u) {
                    html += '<li class="list-group-item list-group-item-action py-1 px-2 coach-result-item"'
                          + ' data-id="' + u.id + '" data-name="' + escHtml(u.name) + '"'
                          + ' style="cursor:pointer;font-size:13px;">'
                          + '<i class="fas fa-user mr-1 text-muted"></i>'
                          + escHtml(u.name) + ' <small class="text-muted">(' + escHtml(u.username) + ')</small>'
                          + '</li>';
                });
                html += '</ul>';
                $results.innerHTML = html;

                $results.querySelectorAll('.coach-result-item').forEach(function(item) {
                    item.addEventListener('click', function() {
                        _selectedUserId   = item.getAttribute('data-id');
                        _selectedUserName = item.getAttribute('data-name');
                        $selectedName.textContent = _selectedUserName;
                        $selected.classList.remove('d-none');
                        $saveBtn.disabled = false;
                        $results.querySelectorAll('.coach-result-item').forEach(function(i){
                            i.classList.remove('active');
                        });
                        item.classList.add('active');
                    });
                });
            })
            .catch(function() {
                $results.innerHTML = '<p class="text-danger px-1" style="font-size:12px;">Error al buscar.</p>';
            });
    }

    $searchBtn.addEventListener('click', doSearch);
    $searchInput.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') { e.preventDefault(); doSearch(); }
    });

    $saveBtn.addEventListener('click', function() {
        if (!_activeCard || !_selectedUserId) return;
        var sessionId = _activeCard.getAttribute('data-session-id');
        var courseId  = _activeCard.getAttribute('data-course-id');

        $saveBtn.disabled = true;
        $saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i>Guardando...';

        var fd = new FormData();
        fd.append('action',        'assign');
        fd.append('session_id',    sessionId);
        fd.append('course_id',     courseId);
        fd.append('coach_user_id', _selectedUserId);

        fetch(COACH_ENDPOINT, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(data) {
                $saveBtn.innerHTML = '<i class="fas fa-save mr-1"></i>Guardar';
                if (data.success) {
                    renderCoachesList(_activeCard, data.coaches);
                    $('#modalAssignCoach').modal('hide');
                } else {
                    alert('Error: ' + (data.message || 'No se pudo guardar'));
                    $saveBtn.disabled = false;
                }
            })
            .catch(function() {
                $saveBtn.innerHTML = '<i class="fas fa-save mr-1"></i>Guardar';
                alert('Error de conexión');
                $saveBtn.disabled = false;
            });
    });

    // Reset modal state on close
    $($modal).on('hidden.bs.modal', function() { resetModal(); _activeCard = null; });

    // ── Upload course image with Cropper.js ──────────────────────────────────
    var UPLOAD_ENDPOINT  = '{{ _p.web_plugin }}school/src/courses/upload_course_image.php';
    var _cropperInstance = null;
    var _uploadCard      = null;

    var $fileInput = document.createElement('input');
    $fileInput.type    = 'file';
    $fileInput.accept  = 'image/jpeg,image/png,image/gif,image/webp';
    $fileInput.style.display = 'none';
    document.body.appendChild($fileInput);

    var $cropModal      = document.getElementById('modalCropImage');
    var $cropImg        = document.getElementById('cropperImg');
    var $btnCropConfirm = document.getElementById('btnCropConfirm');

    // Open file picker on camera button click
    document.querySelectorAll('.btn-upload-img').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            _uploadCard = btn.closest('.course-inner-card');
            $fileInput.value = '';
            $fileInput.click();
        });
    });

    // File selected → read → open crop modal
    $fileInput.addEventListener('change', function() {
        if (!$fileInput.files.length || !_uploadCard) return;
        var reader = new FileReader();
        reader.onload = function(ev) {
            $cropImg.src = ev.target.result;
            $('#modalCropImage').modal('show');
        };
        reader.readAsDataURL($fileInput.files[0]);
    });

    // Init Cropper when modal is shown
    $($cropModal).on('shown.bs.modal', function() {
        if (_cropperInstance) { _cropperInstance.destroy(); _cropperInstance = null; }
        _cropperInstance = new Cropper($cropImg, {
            aspectRatio: 1,
            viewMode: 1,
            dragMode: 'move',
            autoCropArea: 0.85,
            restore: false,
            guides: true,
            center: true,
            highlight: false,
            cropBoxMovable: true,
            cropBoxResizable: true,
            toggleDragModeOnDblclick: false
        });
        // Reset confirm button
        $btnCropConfirm.disabled = false;
        $btnCropConfirm.innerHTML = '<i class="fas fa-check mr-1"></i> Recortar y subir';
        // Reset ratio buttons
        document.querySelectorAll('.btn-crop-ratio').forEach(function(b) {
            b.classList.toggle('active', b.getAttribute('data-ratio') === '1');
        });
    });

    // Destroy Cropper when modal is hidden
    $($cropModal).on('hidden.bs.modal', function() {
        if (_cropperInstance) { _cropperInstance.destroy(); _cropperInstance = null; }
        $cropImg.src = '';
    });

    // Ratio buttons
    document.querySelectorAll('.btn-crop-ratio').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.btn-crop-ratio').forEach(function(b){ b.classList.remove('active'); });
            btn.classList.add('active');
            if (_cropperInstance) {
                var r = btn.getAttribute('data-ratio');
                _cropperInstance.setAspectRatio(r === 'free' ? NaN : parseFloat(r));
            }
        });
    });

    // Rotate & flip
    document.getElementById('btnCropRotateL').addEventListener('click', function() {
        if (_cropperInstance) _cropperInstance.rotate(-90);
    });
    document.getElementById('btnCropRotateR').addEventListener('click', function() {
        if (_cropperInstance) _cropperInstance.rotate(90);
    });
    document.getElementById('btnCropFlipH').addEventListener('click', function() {
        if (!_cropperInstance) return;
        var d = _cropperInstance.getData();
        _cropperInstance.scaleX(d.scaleX === -1 ? 1 : -1);
    });

    // Confirm: get cropped canvas → upload
    $btnCropConfirm.addEventListener('click', function() {
        if (!_cropperInstance || !_uploadCard) return;

        $btnCropConfirm.disabled = true;
        $btnCropConfirm.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i> Subiendo...';

        var canvas = _cropperInstance.getCroppedCanvas({
            maxWidth: 600, maxHeight: 600,
            imageSmoothingEnabled: true,
            imageSmoothingQuality: 'high'
        });

        canvas.toBlob(function(blob) {
            var sessionId  = _uploadCard.getAttribute('data-session-id');
            var courseId   = _uploadCard.getAttribute('data-course-id');
            var courseCode = _uploadCard.getAttribute('data-course-code');

            var fd = new FormData();
            fd.append('session_id',  sessionId);
            fd.append('course_id',   courseId);
            fd.append('course_code', courseCode);
            fd.append('file',        blob, 'course-pic.png');

            fetch(UPLOAD_ENDPOINT, { method: 'POST', body: fd })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    $btnCropConfirm.disabled = false;
                    $btnCropConfirm.innerHTML = '<i class="fas fa-check mr-1"></i> Recortar y subir';

                    if (data.success) {
                        var header      = _uploadCard.querySelector('.course-inner-header');
                        var img         = _uploadCard.querySelector('.card-course-img');
                        var placeholder = _uploadCard.querySelector('.card-course-placeholder');

                        if (img) {
                            img.src = data.image_url;
                            img.style.display = '';
                            if (placeholder) placeholder.classList.add('d-none');
                        } else if (header) {
                            var newImg = document.createElement('img');
                            newImg.className = 'card-course-img';
                            newImg.src       = data.image_url;
                            newImg.alt       = '';
                            header.insertBefore(newImg, header.firstChild);
                            if (placeholder) placeholder.classList.add('d-none');
                        }
                        $('#modalCropImage').modal('hide');
                    } else {
                        alert('Error: ' + (data.message || 'No se pudo subir'));
                    }
                })
                .catch(function() {
                    $btnCropConfirm.disabled = false;
                    $btnCropConfirm.innerHTML = '<i class="fas fa-check mr-1"></i> Recortar y subir';
                    alert('Error de conexión al subir la imagen');
                });
        }, 'image/png');
    });
})();
</script>
