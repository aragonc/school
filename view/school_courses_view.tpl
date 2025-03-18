{% set session_image = '' %}
{% for extra_field in session.extra_fields %}
{% if extra_field.value.getField().getVariable() == 'image' %}
{% set session_image = _p.web_upload ~ extra_field.value.getValue() %}
{% endif %}
{% endfor %}

<div class="tab-content" id="tab_courses">
    <div class="tab-pane fade show active" id="current_courses" role="tabpanel" aria-labelledby="current_courses-tab">
        <div class="card">
            <div class="card-body">
                <div class="p-5">
                    <div class="container-fluid">
                        <div class="view-tags">{{ session.tags }}</div>
                        <h1 class="view-title-course">{{ session.name }}</h1>
                        <div class="row">
                            <div class="col">
                                <div class="media-image">
                                    <img class="img-responsive" width="550px" src="{{session_image}}" alt="{{ session.name }}">
                                </div>
                                <div class="view-price">
                                    CLP 60,000
                                </div>
                                <div class="view-mode">
                                    Modalidad 100% Online Asincrónico
                                </div>
                                <div class="view-duration">
                                    Duración: 30 horas.
                                </div>
                            </div>
                            <div class="col">
                                <div class="view-dates">
                                    <div class="start"><strong>Fecha de Inicio:</strong>  Martes 03 de Marzo 2025</div>
                                    <div class="end"><strong>Fecha de Termino:</strong> Martes 23 de Junio 2025</div>
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
                                    <a class="btn btn-default btn-block mb-2" href="#">Ver ficha (PDF)</a>
                                    <a class="btn btn-primary btn-block mb-2" href="#"> Comprar</a>
                                </div>
                                {{ img_section }}
                            </div>
                        </div>
                        <h3 class="view-sub-title">Calendario del Curso</h3>
                        <ul>
                            <li>martes, 25 de marzo de 2025: Inicio del curso e inicio Módulo I</li>
                            <li>martes, 1 de abril de 2025: Inicio del Módulo II</li>
                            <li>martes, 8 de abril de 2025: Inicio del Módulo III</li>
                            <li>martes, 15 de abril de 2025: Habilitación de Evaluación del Curso.</li>
                            <li>martes, 15 de abril de 2025: Inicio del Módulo IV</li>
                            <li>lunes, 21 de abril de 2025: Cierre de evaluaciones (a contar de este día se ocultará el icono de evaluaciones, calificaciones y el foro de consultas).</li>
                            <li>martes, 29 de abril de 2025: Habilitación de resultados de las evaluaciones, retroalimentaciones y certificados de aprobación.</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

