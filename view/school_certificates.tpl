{% if categories %}
<div class="card">
    <div class="card-body">

        {% for category in categories %}
        <div id="category_{{ category.category_id }}" class="category">
            <div class="container-fluid">
                <div class="row align-items-center pb-3">
                    <div class="col">
                        <div class="d-flex flex-row align-items-center">
                            <div class="p-1">{{ category.category_image }}</div>
                            <div class="p-1"><h4 class="category-name">{{ category.category_name }}</h4></div>
                        </div>
                    </div>
                    <div class="col-md-auto">
                        <div class="section-col-table pl-4 pr-4">
                            {{ 'IssueDate'|get_plugin_lang('SchoolPlugin') }}
                        </div>
                    </div>
                    <div class="col-md-auto">
                        <div class="section-col-table pl-4 pr-4">
                            {{ 'Certificate'|get_plugin_lang('SchoolPlugin') }}
                        </div>
                    </div>
                    <div class="col-md-auto">
                        <div class="section-col-table">
                            {{ 'Share'|get_plugin_lang('SchoolPlugin') }}
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="sessions_accordion_{{ category.category_id }}" class="accordion pb-4">

            {% for session in category.sessions %}

            {% if session.number_courses <=1 %}

                    {% for course in session.courses %}
                    <div class="card pl-4 pr-4">
                        <div class="course-box box-{{ course.ribbon }} pt-1 pb-1 pr-3 pl-3">
                            <div class="row align-items-center">
                                <div class="col">
                                    {{ course.icon }} <span class="course-title">{{ session.name }}</span>
                                </div>

                                <div class="col-md-auto text-center">
                                    <span class="row-date">{{ course.certificate.date }}</span>
                                </div>
                                <div class="col-md-auto text-center">
                                    <a class="btn btn-primary btn-download" href="{{ course.certificate.link_html }}" target="_blank" role="button">
                                        <i class="fas fa-download"></i> {{ 'DownloadPDF'|get_plugin_lang('SchoolPlugin') }}
                                    </a>
                                </div>
                                <div class="col-md-auto text-center">
                                    <a class="btn btn-primary btn-share" href="{{ course.certificate.link_share }}" role="button">
                                        <i class="fas fa-share-alt"></i> <span class="circle-linkedin"><i class="fab fa-linkedin-in"></i></span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    {% endfor %}

            {% else %}
                <div class="card pl-4 pr-4">
                    <div class="card-header pt-1 pb-1" id="heading_session_{{ session.id }}">
                        <div class="row align-items-center">
                            <div class="col">
                                <h2 class="mb-0">
                                    <button class="btn btn-link btn-block text-left" type="button" data-toggle="collapse" data-target="#collapse_session_{{ session.id }}" aria-expanded="true" aria-controls="collapse_session_{{ session.id }}">
                                        {{ session.session_image }} {{ session.name }}
                                    </button>
                                </h2>
                            </div>
                            <div class="col-md-auto text-center">

                            </div>
                            <div class="col-md-auto text-center">

                            </div>
                            <div class="col-md-auto text-center">

                            </div>
                        </div>
                    </div>

                    <div id="collapse_session_{{ session.id }}" class="collapse show" aria-labelledby="heading_session_{{ session.id }}" data-parent="#sessions_accordion_{{ category.category_id }}">

                            {% for course in session.courses %}

                            <div class="course-box box-{{ course.ribbon }} pt-1 pb-1 pr-3 pl-5">
                                <div class="row align-items-center">
                                    <div class="col">
                                        {{ course.icon }} {{ course.title }}
                                    </div>

                                    <div class="col-md-auto text-center">
                                        <span class="row-date">{{ course.certificate.date }}</span>
                                    </div>
                                    <div class="col-md-auto text-center">
                                        <a class="btn btn-primary btn-download" href="{{ course.certificate.link_html }}" target="_blank" role="button">
                                            <i class="fas fa-download"></i> {{ 'DownloadPDF'|get_plugin_lang('SchoolPlugin') }}
                                        </a>
                                    </div>
                                    <div class="col-md-auto text-center">
                                        <a class="btn btn-primary btn-share" href="{{ course.certificate.link_share }}" role="button">
                                            <i class="fas fa-share-alt"></i> <span class="circle-linkedin"><i class="fab fa-linkedin-in"></i></span>
                                        </a>
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
{% else %}
    <div class="p-5 text-center">
        <h3>{{ 'HereAreYourCertificates'|get_plugin_lang('SchoolPlugin') }}</h3>
        {{ img_section }}
    </div>
{% endif %}
