
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
                        <div class="card course-inner-card"
                             data-session-id="{{ session.id }}"
                             data-course-id="{{ course.real_id }}"
                             data-coach-name="{{ course.course_coach_name|e('html_attr') }}">
                            <a href="{{ course.url }}" class="course-inner-header bg-gc-{{ cidx }}">
                                {% if course.image_url %}
                                <img class="card-course-img" src="{{ course.image_url }}" alt="{{ course.title }}"
                                     onerror="this.style.display='none'; this.nextElementSibling.classList.remove('d-none');">
                                {% endif %}
                                <div class="card-course-placeholder {% if course.image_url %}d-none{% endif %}">
                                    {{ course.icon }}
                                </div>
                            </a>
                            <div class="card-body p-2">
                                <a href="{{ course.url }}" class="course-inner-title" title="{{ course.title }}">
                                    {{ course.title }}
                                </a>
                                {% if course.course_coach_name %}
                                <div class="course-inner-coach mt-1 d-flex align-items-center justify-content-between">
                                    <span><i class="fas fa-chalkboard-teacher"></i> <span class="coach-name-text">{{ course.course_coach_name }}</span></span>
                                    {% if session.coach == 'true' %}
                                    <button type="button" class="btn-assign-coach btn btn-link p-0 ml-1" title="Cambiar tutor">
                                        <i class="fas fa-pencil-alt" style="font-size:10px;color:#2563aa;"></i>
                                    </button>
                                    {% endif %}
                                </div>
                                {% else %}
                                <div class="course-inner-no-coach mt-1 d-flex align-items-center justify-content-between">
                                    <span><i class="fas fa-exclamation-triangle"></i> Sin tutor asignado</span>
                                    {% if session.coach == 'true' %}
                                    <button type="button" class="btn-assign-coach btn btn-link p-0 ml-1" title="Asignar tutor">
                                        <i class="fas fa-user-plus" style="font-size:10px;color:#dd6b20;"></i>
                                    </button>
                                    {% endif %}
                                </div>
                                {% endif %}
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

{# ── Modal: asignar / cambiar tutor de curso ── #}
<div class="modal fade" id="modalAssignCoach" tabindex="-1" role="dialog" aria-labelledby="modalAssignCoachLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:linear-gradient(135deg,#1a3558 0%,#2563aa 100%);color:#fff;">
                <h5 class="modal-title" id="modalAssignCoachLabel">
                    <i class="fas fa-chalkboard-teacher mr-2"></i>
                    <span id="modalAssignCoachAction">Asignar tutor</span>
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
            <div class="modal-footer d-flex justify-content-between">
                <button type="button" class="btn btn-sm btn-outline-danger" id="btnRemoveCoach">
                    <i class="fas fa-user-times mr-1"></i> Quitar tutor
                </button>
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
    var COACH_ENDPOINT = '{{ _p.web_plugin }}school/src/courses/assign_course_coach.php';
    var _activeCard    = null;
    var _selectedUserId   = null;
    var _selectedUserName = null;

    var $modal          = document.getElementById('modalAssignCoach');
    var $searchInput    = document.getElementById('coachSearchInput');
    var $searchBtn      = document.getElementById('btnSearchCoach');
    var $results        = document.getElementById('coachSearchResults');
    var $selected       = document.getElementById('coachSelected');
    var $selectedName   = document.getElementById('coachSelectedName');
    var $saveBtn        = document.getElementById('btnSaveCoach');
    var $removeBtn      = document.getElementById('btnRemoveCoach');
    var $actionLabel    = document.getElementById('modalAssignCoachAction');
    var $courseName     = document.getElementById('modalCourseName');

    function resetModal() {
        $searchInput.value = '';
        $results.innerHTML = '';
        $selected.classList.add('d-none');
        $saveBtn.disabled  = true;
        _selectedUserId    = null;
        _selectedUserName  = null;
    }

    function openAssignModal(card) {
        _activeCard = card;
        var sessionId  = card.getAttribute('data-session-id');
        var courseId   = card.getAttribute('data-course-id');
        var coachName  = card.getAttribute('data-coach-name');
        var courseTitle = card.querySelector('.course-inner-title')
                             ? card.querySelector('.course-inner-title').textContent.trim()
                             : '';

        resetModal();
        $courseName.textContent  = 'Curso: ' + courseTitle;
        $actionLabel.textContent = coachName ? 'Cambiar tutor' : 'Asignar tutor';
        $removeBtn.style.display = coachName ? '' : 'none';

        $('#modalAssignCoach').modal('show');
    }

    document.querySelectorAll('.btn-assign-coach').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            openAssignModal(btn.closest('.course-inner-card'));
        });
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
                    html += '<li class="list-group-item list-group-item-action py-1 px-2 coach-result-item" '
                          + 'data-id="' + u.id + '" data-name="' + u.name.replace(/"/g,'&quot;') + '" '
                          + 'style="cursor:pointer;font-size:13px;">'
                          + '<i class="fas fa-user mr-1 text-muted"></i>'
                          + u.name + ' <small class="text-muted">(' + u.username + ')</small>'
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
                    // Update card UI without reload
                    _activeCard.setAttribute('data-coach-name', data.coach_name);
                    var coachDiv = _activeCard.querySelector('.course-inner-coach, .course-inner-no-coach');
                    if (coachDiv) {
                        coachDiv.className = 'course-inner-coach mt-1 d-flex align-items-center justify-content-between';
                        var editBtn = coachDiv.querySelector('.btn-assign-coach');
                        var editBtnHtml = editBtn ? editBtn.outerHTML : '';
                        coachDiv.innerHTML = '<span><i class="fas fa-chalkboard-teacher"></i> <span class="coach-name-text">' + data.coach_name + '</span></span>' + editBtnHtml;
                        if (!editBtnHtml) {
                            // Re-bind if button was recreated
                            var newBtn = coachDiv.querySelector('.btn-assign-coach');
                            if (newBtn) {
                                newBtn.addEventListener('click', function(e) {
                                    e.preventDefault(); e.stopPropagation();
                                    openAssignModal(newBtn.closest('.course-inner-card'));
                                });
                            }
                        }
                    }
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

    $removeBtn.addEventListener('click', function() {
        if (!_activeCard) return;
        if (!confirm('¿Quitar el tutor asignado a este curso?')) return;

        var sessionId = _activeCard.getAttribute('data-session-id');
        var courseId  = _activeCard.getAttribute('data-course-id');

        var fd = new FormData();
        fd.append('action',     'remove');
        fd.append('session_id', sessionId);
        fd.append('course_id',  courseId);

        fetch(COACH_ENDPOINT, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(data) {
                if (data.success) {
                    _activeCard.setAttribute('data-coach-name', '');
                    var coachDiv = _activeCard.querySelector('.course-inner-coach, .course-inner-no-coach');
                    if (coachDiv) {
                        var editBtn = coachDiv.querySelector('.btn-assign-coach');
                        var editBtnHtml = editBtn ? editBtn.outerHTML : '';
                        coachDiv.className = 'course-inner-no-coach mt-1 d-flex align-items-center justify-content-between';
                        coachDiv.innerHTML = '<span><i class="fas fa-exclamation-triangle"></i> Sin tutor asignado</span>' + editBtnHtml;
                    }
                    $('#modalAssignCoach').modal('hide');
                } else {
                    alert('Error: ' + (data.message || 'No se pudo quitar'));
                }
            });
    });

    // Reset modal state on close
    $($modal).on('hidden.bs.modal', function() { resetModal(); _activeCard = null; });
})();
</script>
