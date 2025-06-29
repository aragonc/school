{% if categories %}
<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link" href="/dashboard">
            {{ 'Current'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_courses }}</span>
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link active" href="/previous" >
            {{ 'Previous'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_history }}</span>
        </a>
    </li>
</ul>
<div class="tab-content" id="tab_courses">
    <div class="tab-pane fade show active" id="current_courses" role="tabpanel" aria-labelledby="current_courses-tab">
        <div class="pt-0 pb-4">
        {% for category in categories %}
            <div id="category_{{ category.category_id }}" class="category">
                <div class="container-fluid">
                    <div class="row align-items-center pb-3 pt-3">
                        <div class="col">
                            <div class="d-flex flex-row align-items-center">
                                <div class="p-0 p-md-2">{{ category.category_image }}</div>
                                <div class="p-0 p-md-2"><h4 class="category-name">{{ category.category_name }}</h4></div>
                            </div>
                        </div>
                        <div class="col-md-auto d-none d-sm-block">
                            <div class="section-col-table">
                                {{ 'EndDate'|get_plugin_lang('SchoolPlugin') }}
                            </div>
                        </div>

                    </div>
                </div>
            </div>
            <div class="accordion" id="sessions_accordion_{{ category.category_id }}">
                {% for session in category.sessions %}
                    {% if session.number_courses <=1 %}
                        {% for course in session.courses %}
                            <div class="card pl-0 pr-0 pl-md-4 pr-md-4 mb-2 d-none d-md-block">
                                <div class="course-box box-{{ course.ribbon }} pt-1 pb-1 pr-3 pl-3">
                                    <div class="row align-items-center">
                                        <div class="col">
                                            <a class="course-link" href="{{ course.url }}" title="{{ course.title }}">
                                                {{ course.icon }} <span class="course-title">{{ session.name }}</span>
                                            </a>
                                        </div>
                                        <div class="col-md-auto text-right">
                                            <span class="row-date">{{ session.short_date }}</span>
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
                                                    <span class="course-title">{{ session.name }}</span>
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-2">
                                        <div class="date-mobile">
                                            {{ session.short_date }}
                                        </div>
                                    </div>
                                </div>
                            </div>
                {% endfor %}

                {% else %}
                <div class="card pl-0 pr-0 pl-md-4 pr-md-4">
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
                                <div class="col-md-auto text-right">
                                    <span class="row-date pr-3">{{ session.short_date }}</span>
                                </div>
                            </div>
                        </div>

                        <!-- version mobile -->

                        <div class="course-mobile d-md-none">
                            <div class="row align-items-center">
                                <div class="col-10 pr-0">
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
                                <div class="col-2">
                                    <div class="date-mobile">
                                        {{ session.short_date }}
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
    </div>
</div>
{% else %}
<div class="text-center">
    <h4>{{ 'NotCompletedCourses'|get_plugin_lang('SchoolPlugin') }}</h4>
    {{ img_section }}
</div>
{% endif %}


<div class="py-3">
    <a href="{{ _p.web }}certified" class="btn btn-primary btn-goto"><i class="fas fa-file-alt"></i> {{ 'GotoMyCertificates'|get_plugin_lang('SchoolPlugin') }}</a>
</div>



