
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
                <div class="container-fluid ">
                    <div class="row align-items-center pb-3 pt-3">
                        <div class="col">
                            <div class="d-flex flex-row align-items-center">
                              
                                <div class="p-0 p-md-2">
                                <h4 class="category-name">
                                {{ 'MyCoursesCurrent'|get_plugin_lang('SchoolPlugin') }}
                                </h4>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="accordion" id="sessions_accordion_{{ category.category_id }}">
                {% for session in category.sessions %}
                    {% if session.number_courses <=1 %}
                        {% for course in session.courses %}

                        <div class="card pl-0 pr-0 pl-lg-4 pr-lg-4 mb-2 d-none d-md-block">
                            <div class="course-box box-{{ course.ribbon }} pt-1 pb-1 pr-3 pl-3">
                                <div class="row align-items-center">
                                    <div class="col">
                                        <a class="course-link" href="{{ course.url }}" title="{{ course.title }}">
                                            {{ course.icon }} <span class="course-title">{{ session.name }}</span>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="course-mobile d-md-none">
                            <div class="row align-items-center">
                                <div class="col pr-0">
                                    <div class="d-flex justify-content-start">
                                        <div class="icon-mobile">
                                            {{ course.icon_mobile }}
                                        </div>
                                        <div class="mobile-title">
                                            <a class="course-link" href="{{ course.url }}" title="{{ course.title }}">
                                                <span class="course-title">{{ session.name }}</span>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    {% endfor %}
                {% else %}

                <div class="card pl-0 pr-0 pl-lg-4 pr-lg-4">
                    <div class="card-header" id="heading_session_{{ session.id }}">
                        <div class="d-none d-md-block">
                            <div class="row align-items-center">
                                <div class="col">
                                    <h2 class="mb-0">
                                        <button class="btn btn-link btn-block text-left" type="button" data-toggle="collapse" data-target="#collapse_session_{{ session.id }}" aria-expanded="true" aria-controls="collapse_session_{{ session.id }}">
                                            {{ session.session_image }} <span class="course-title">{{ session.name }}</span>
                                        </button>
                                    </h2>
                                </div>
                            </div>
                        </div>

                        <!-- version mobile -->
                        <div class="course-mobile d-md-none">
                            <div class="row align-items-center">
                                <div class="col pr-0">
                                    <div class="d-flex justify-content-start">
                                        <div class="icon-mobile">
                                            {{ session.session_image_mobile }}
                                        </div>
                                        <div class="mobile-title">
                                            <button class="btn btn-link btn-block text-left" type="button" data-toggle="collapse" data-target="#collapse_session_{{ session.id }}" aria-expanded="true" aria-controls="collapse_session_{{ session.id }}">
                                                 <span class="course-title">{{ session.name }}</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                    <div id="collapse_session_{{ session.id }}" class="collapse mb-2 mb-md-0" aria-labelledby="heading_session_{{ session.id }}" data-parent="#sessions_accordion_{{ category.category_id }}">

                        {% for course in session.courses %}
                        <div class="course-box box-{{ course.ribbon }} pt-1 pb-1 pr-3 pl-5">
                            <div class="row align-items-center">
                                <div class="col">
                                    <div class="d-flex flex-row pb-1 pt-1">

                                        {% if course.position_number != 0 %}
                                            <span class="badge badge-warning">{{ course.position_number }}</span>
                                        {% else %}
                                            <span class="badge badge-transparent"></span>
                                        {% endif %}

                                        <div class="pr-1 pl-1">
                                            {{ course.icon }}
                                        </div>
                                    <a class="course-link" href="{{ course.url }}" title="{{ course.title }}">
                                        {{ course.title }}
                                    </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        {% endfor %}

                    </div>
                </div>

                {% endif %}
                {% endfor %}
            </div>
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
            {% if session.number_courses <= 1 and session.courses[0] is defined %}
            <a href="{{ session.courses[0].url }}" class="course-card-header bg-gc-{{ gidx }}">
            {% else %}
            <div class="course-card-header bg-gc-{{ gidx }} course-card-header-multi"
                 data-anchor="category_{{ category.category_id }}">
            {% endif %}
                {% if session.number_courses <= 1 and session.courses[0].image_url %}
                <img class="card-course-img" src="{{ session.courses[0].image_url }}" alt="{{ session.name }}"
                     onerror="this.parentNode.classList.add('img-fallback'); this.style.display='none';">
                {% endif %}
                <div class="card-course-placeholder {% if session.number_courses <= 1 and session.courses[0].image_url %}d-none img-show-fallback{% endif %}">
                    {{ session.session_image }}
                </div>
            {% if session.number_courses <= 1 and session.courses[0] is defined %}
            </a>
            {% else %}
            </div>
            {% endif %}
            <div class="card-body">
                <div class="card-title">
                    {% if session.number_courses <= 1 %}
                        {{ session.courses[0].title ?? session.name }}
                    {% else %}
                        {{ session.name }}
                    {% endif %}
                </div>
                {% if session.number_courses > 1 %}
                <div class="course-count-badge">
                    <i class="fas fa-book mr-1"></i>{{ session.number_courses }} cursos
                </div>
                {% endif %}
            </div>
            <div class="card-footer">
                {% if session.number_courses <= 1 %}
                    {% if session.courses[0] is defined %}
                    <a href="{{ session.courses[0].url }}" class="btn btn-primary btn-sm btn-block">
                        <i class="fas fa-play-circle mr-1"></i> Acceder
                    </a>
                    {% endif %}
                {% else %}
                <button type="button" class="btn btn-primary btn-sm btn-block btn-grid-goto-list"
                        data-anchor="category_{{ category.category_id }}">
                    <i class="fas fa-list mr-1"></i> Ver cursos
                </button>
                {% endif %}
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

    // When an image loads but errors → show placeholder
    document.querySelectorAll('.course-card-header img.card-course-img').forEach(function (img) {
        img.addEventListener('error', function () {
            var placeholder = img.parentNode.querySelector('.card-course-placeholder');
            if (placeholder) {
                placeholder.classList.remove('d-none');
            }
        });
    });
})();
</script>
