{% set session_image = '' %}
    {% for extra_field in session.extra_fields %}
        {% if extra_field.value.getField().getVariable() == 'image' %}
        {% set session_image = _p.web_upload ~ extra_field.value.getValue() %}
    {% endif %}
{% endfor %}

<div class="card card-home">
    <div class="card-header">
       {{ icon_course }} {{ session.name }}
    </div>
    <div class="card-body">
        <div class="container">
            <div class="row">
                <div class="col">
                    <img class="img-responsive rounded" width="100%" src="{{session_image}}" alt="{{ session.name }}">
                </div>
                <div class="col">
                    <div class="h-25"></div>
                    <h1 class="course-home-title">{{ course.title }}</h1>
                    <div class="h-25"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card card- mt-3">
    <div class="card-body">
        <div class="container-fluid">
            <div class="row">
                <div class="col">
                    Felicitaciones! Tienes todas
                    tus actividades al día
                </div>
                {% for tool in tools_one %}
                    <div class="col">
                        <a class="link_home" id="{{ tool.name }}" href="{{ tool.link }}">
                            <div class="tool d-flex justify-content-center">
                                <div class="icon">
                                    {{ tool.icon }}
                                </div>
                                <div class="label pl-2 pr-2 align-self-center">
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

<div class="card card- mt-3">
    <div class="card-body">
        <h3>Contenidos</h3>
        <div class="container-fluid">
            <div class="row">
                {% for tool in tools_two %}
                <div class="col-2 d-flex align-items-stretch">
                    <a class="link_scorm" id="{{ tool.name }}" href="{{ tool.link }}">
                        <div class="tool">
                            <div class="icon">
                                {{ tool.icon }}
                            </div>
                            <div class="label pl-2 pr-2 align-self-center">
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

<div class="card card- mt-3">
    <div class="card-body">
        <h3>Mis Actividades</h3>
        <div class="container-fluid">
            <div class="row">
                {% for tool in tools_tree %}
                <div class="col-2 d-flex align-items-stretch">
                    <a class="link_tool" id="{{ tool.name }}" href="{{ tool.link }}">
                        <div class="tool">
                            <div class="icon">
                                {{ tool.icon }}
                            </div>
                            <div class="label pl-2 pr-2 align-self-center">
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