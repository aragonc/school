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

<div class="card card-home">
    <div class="card-body">
        <div class="container">
            <div class="row">
                <div class="col">
                    Felicitaciones! Tienes todas
                    tus actividades al día
                </div>
                <div class="col">Calendario</div>
                <div class="col">Ver Ficha (PDF)</div>
                <div class="col">Material Complementario</div>
            </div>
        </div>
    </div>
</div>