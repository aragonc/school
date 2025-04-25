{% set session_image = '' %}
{% for extra_field in session.extra_fields %}
{% if extra_field.value.getField().getVariable() == 'image' %}
{% set session_image = _p.web_upload ~ extra_field.value.getValue() %}
{% endif %}
{% endfor %}

<div class="tab-content" id="tab_courses">
    <div class="tab-pane fade show active" id="current_courses" role="tabpanel" aria-labelledby="current_courses-tab">
        <div class="card">
            <div class="card-body card-section">
                <div class="p-0 p-lg-5">
                    <div class="container-fluid">
                        <div class="d-flex justify-content-end">
                            {% if session.n_courses <= 1 %}
                                <a href="{{ _p.web }}shopping" class="btn btn-primary btn-download">
                                    <i class="fas fa-arrow-left"></i> Volver
                                </a>
                            {% else %}
                                <a href="{{ _p.web }}shopping?view=graduates" class="btn btn-primary btn-download">
                                    <i class="fas fa-arrow-left"></i> Volver
                                </a>
                            {% endif %}

                        </div>

                        <div class="view-tags">{{ session.tags }}</div>
                        <h1 class="view-title-course">{{ session.name }}</h1>
                        <div class="row">
                            <div class="col-12 col-lg-6">
                                <div class="view-media-image">
                                    <img class="img-responsive rounded" width="100%" src="{{session_image}}" alt="{{ session.name }}">
                                    <div class="view-price">
                                        {{ item.price_view }}
                                    </div>
                                </div>

                                <div class="view-mode">
                                    {{ 'OnlineAsynchronousModality'|get_plugin_lang('SchoolPlugin') }}
                                </div>
                                <div class="view-duration">
                                    {% if session.n_courses <= 1 %}
                                        {{ 'Duration'|get_plugin_lang('SchoolPlugin') }}: 30 horas.
                                    {% else %}
                                        {{ 'Duration'|get_plugin_lang('SchoolPlugin') }}: 200 horas.
                                    {% endif %}
                                </div>
                            </div>
                            <div class="col-12 col-lg-6">
                                <div class="view-dates rounded-lg">
                                    <div class="start"><strong>{{ 'StartDate'|get_plugin_lang('SchoolPlugin') }}:</strong> {{ session.display_start_date_text }}</div>
                                    <div class="end"><strong>{{ 'EndDate'|get_plugin_lang('SchoolPlugin') }}:</strong> {{ session.display_end_date_text }}</div>
                                </div>
                                <div class="description">
                                    <h3 class="view-sub-title">Caracteristicas</h3>
                                    <ul>
                                        <li>Contenidos validados por el registro ATE del Mineduc.</li>
                                        <li>Sin horarios fijos de conexión.</li>
                                        <li>Evaluación obligatoria para obtener certificado.</li>
                                        <li>Debe cumplir con actividades y fechas establecidas.</li>
                                        <li>Acompañamiento de tutor a través del foro.</li>
                                    </ul>
                                </div>
                                <div class="view-buttons">
                                    <a class="btn btn-default btn-block mb-2" target="_blank" href="{{ url_pdf }}"><i class="far fa-file-pdf"></i> {{ 'SeeFile'|get_plugin_lang('SchoolPlugin') }}</a>
                                    <a class="btn btn-primary btn-block mb-2" href="{{ _p.web_plugin ~ 'payments/process-check.php?' ~ {'item': session.id, 'type': 2}|url_encode() }}"> <em class="fa fa-shopping-cart"></em> {{ 'Buy'|get_plugin_lang('BuyCoursesPlugin') }}</a>
                                </div>
                                <div class="view-pay-icon">
                                    {{ img_section }}
                                </div>

                            </div>
                        </div>
                        <div class="border-calendar mt-5">
                            {% if session.n_courses <= 1 %}
                            <h3 class="view-sub-title">{{ 'CourseCalendar'|get_plugin_lang('SchoolPlugin') }}</h3>
                            {{ session.calendar_course.content }}
                            {% else %}
                            <h3 class="view-sub-title">{{ 'DiplomaSchedule'|get_plugin_lang('SchoolPlugin') }}</h3>
                            <ul>
                                {% for course in session.courses %}
                                <li class="course-name"><div class="title">{{ course.name }}</div>
                                    {% if course.calendar.content %}
                                        <div class="course-list-calendar">
                                            {{ course.calendar.content }}
                                        </div>
                                    {% endif %}
                                </li>

                                {% endfor %}
                            </ul>
                            {% endif %}
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

