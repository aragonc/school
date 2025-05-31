{% set session_image = '' %}
    {% for extra_field in session.extra_fields %}
        {% if extra_field.value.getField().getVariable() == 'image' %}
        {% set session_image = _p.web_upload ~ extra_field.value.getValue() %}
    {% endif %}
{% endfor %}

<div class="card card-home">
    <div class="card-header">
       {{ icon_course }} {{ session.display_category }}
    </div>
    <div class="card-body py-4 px-0">
        <div class="container p-0">
            <div class="row">
                <div class="col-12 col-lg-6">
                    <img class="img-responsive rounded-md" width="100%" src="{{session_image}}" alt="{{ session.name }}">
                </div>
                <div class="col-12 col-lg-6">
                    <div class="d-none d-lg-block h-25"></div>
                    {% if session.n_courses > 1 %}
                    <div class="is_graduates">{{ session.name }}</div>
                    {% endif %}
                    <h1 class="course-home-title">{{ course.title }}</h1>
                    <div class="h-25 d-none d-md-block"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card card- mt-3">
    <div class="card-body p-1 p-md-4">
        <div class="container-fluid mobile-fluid">
            <div class="row">
                <div class="col-12 col-lg-3">
                    <div class="alert alert-success alert-welcome" role="alert">
                        <div class="message-home m-0 mb-md-2 mt-md-2 d-flex justify-content-center">
                            <div class="icon">
                                {{ icon_smile }}
                            </div>
                            <div class="label pl-2 pr-2 align-self-center">
                                {{ 'WelcomeHome'|get_plugin_lang('SchoolPlugin') }}
                            </div>
                        </div>
                    </div>
                </div>
                {% for tool in tools_one %}
                    <div class="col-6 col-lg-3">
                            {% if tool.label == 'tool_chip' %}
                                <a class="link_tool open-pdf bg-icon-home mb-3" id="{{ tool.name }}" href="{{ tool.link }}" data-toggle="modal" data-target="#generalModal">
                                {% else %}
                                    {% if tool.label == 'tool_calendar' %}
                                            <a class="link_tool open-calendar bg-icon-home mb-3" id="{{ tool.name }}" href="{{ tool.link }}" data-toggle="modal" data-target="#generalModal">
                                        {% else %}
                                            <a class="link_tool bg-icon-home mb-3" id="{{ tool.name }}" href="{{ tool.link }}">
                                    {% endif %}
                            {% endif %}

                            <div class="tool d-block d-md-flex justify-content-center">
                                <div class="icon">
                                    {{ tool.icon }}
                                </div>
                                <div class="label pt-2 px-md-2 align-self-center">
                                    {{ tool.name }}
                                </div>
                                {{ tool.data }}
                            </div>
                        </a>
                    </div>
                {% endfor %}
            </div>
        </div>
    </div>
</div>
{% if tools_two is not empty %}
<div class="card pb-md-3 mt-mb-3">
    <div class="card-body p-1 p-md-4">
        <h3 class="pt-3 pb-3 title-tool-section">{{ 'Contents'|get_plugin_lang('SchoolPlugin') }}</h3>
        <div class="container-fluid mobile-fluid">
            <div class="row">
                {% for tool in tools_two %}
                <div class="col-6 col-lg-2 d-flex align-items-stretch">
                    <a class="link_scorm mb-3" id="{{ tool.name }}" href="{{ tool.link }}">
                        <div class="tool">
                            <div class="icon">
                                {{ tool.icon }}
                            </div>
                            <div class="label pt-2 p-md-2 align-self-center">
                                {{ tool.name }}
                            </div>
                        </div>
                    </a>
                </div>
                {% endfor %}
            </div>
        </div>
    </div>
</div>
{% endif %}
{% if tools_tree is not empty %}
<div class="card pb-md-3 mt-md-3">
    <div class="card-body p-1 p-md-4 ">
        <h3 class="pt-3 pb-3 title-tool-section">{{ 'MyActivities'|get_plugin_lang('SchoolPlugin') }}</h3>
        <div class="container-fluid mobile-fluid">
            <div class="row">
                {% for tool in tools_tree %}
                <div class="col-6 col-lg-2 d-flex align-items-stretch">
                    <a class="link_tool mb-3" id="{{ tool.name }}" href="{{ tool.link }}">
                        <div class="tool">
                            <div class="icon">
                                {{ tool.icon }}
                            </div>
                            <div class="label pt-2 p-md-2 align-self-center">
                                {{ tool.name }}
                            </div>
                        </div>
                    </a>
                </div>
                {% endfor %}
            </div>
        </div>
    </div>
</div>
{% endif %}