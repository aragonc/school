<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link active" href="/dashboard">
            {{ 'Current'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_courses }}</span>
        </a>
    </li>
    {% if total_history > 0 %}
    <li class="nav-item">
        <a class="nav-link " href="/previous" >
            {{ 'Previous'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_history }}</span>
        </a>
    </li>
    {% endif %}
</ul>

<div class="tab-content" id="tab_courses">
    <div class="tab-pane fade show active" id="current_courses" role="tabpanel" aria-labelledby="current_courses-tab">
        {% if categories %}
        <div class="pt-4 pb-4">
        {% for category in categories %}
            <div id="category_{{ category.category_id }}" class="category">
                <div class="container-fluid">
                    <div class="row align-items-center pb-3">
                        <div class="col">
                            <div class="d-flex flex-row align-items-center">
                                <div class="p-2">{{ category.category_image }}</div>
                                <div class="p-2"><h4 class="category-name">{{ category.category_name }}</h4></div>
                            </div>
                        </div>
                        <div class="col-md-auto">
                            <div class="section-col-table">
                                {{ 'RegistrationDate'|get_plugin_lang('SchoolPlugin') }}
                            </div>
                        </div>
                        <div class="col col-lg-2">
                            <div class="section-col-table">
                                {{ 'CertificateRegularStudent'|get_plugin_lang('SchoolPlugin') }}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="accordion" id="sessions_accordion">
                {% for session in category.sessions %}
                <div class="card pl-4 pr-4">
                    <div class="card-header" id="heading_session_{{ session.id }}">
                        <div class="row align-items-center">
                            <div class="col">
                                <h2 class="mb-0">
                                    <button class="btn btn-link btn-block text-left" type="button" data-toggle="collapse" data-target="#collapse_session_{{ session.id }}" aria-expanded="true" aria-controls="collapse_session_{{ session.id }}">
                                        {{ session.session_image }} {{ session.name }}
                                    </button>
                                </h2>
                            </div>
                            <div class="col-md-auto text-center">
                                <span class="row-date">{{ session.registered_at }}</span>
                            </div>
                            <div class="col col-lg-2 text-center">
                                <a class="btn btn-primary" href="#" role="button">
                                    <i class="fas fa-download"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                    <div id="collapse_session_{{ session.id }}" class="collapse" aria-labelledby="heading_session_{{ session.id }}" data-parent="#sessions_accordion">
                        <div class="card-body">
                            <ul class="list-courses">
                                {% for course in session.courses %}
                                <li class="course-box box-{{ course.ribbon }}">
                                    <a class="course-link" href="{{ course.url }}" title="{{ course.title }}">
                                        {% if course.number != 0 %}
                                        <span class="badge badge-warning">{{ course.number }}</span>
                                        {% endif %}
                                        {{ course.icon }} {{ course.title }}
                                    </a>
                                </li>
                                {% endfor %}
                            </ul>
                        </div>
                    </div>
                </div>
                {% endfor %}
            </div>
        {% endfor %}
        </div>
        {% else %}
            <div class="p-5 text-center">

                <h4>{{ 'NoTrainingInProgress'|get_plugin_lang('SchoolPlugin') }}</h4>
                <p>{{ 'CompletedTrainings'|get_plugin_lang('SchoolPlugin') }} <a href="/previous">{{ 'ClickHere'|get_plugin_lang('SchoolPlugin') }}</a></p>
                {{ img_section }}

            </div>
        {% endif %}
    </div>
</div>




