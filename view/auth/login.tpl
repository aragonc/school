<div class="container d-flex align-items-center justify-content-center" style="min-height: 100vh;">
    <div class="row justify-content-center w-100">
        <div class="col-xl-10 col-lg-12 col-md-9">
            <div class="card o-hidden border-0 shadow-lg">
                <div class="card-body p-0">
                    <div class="row">
                        {% if vegas_images|length > 0 %}
                        <div class="col-lg-6 d-none d-lg-block p-0" id="vegas-container" style="min-height: 450px; position: relative;"></div>
                        {% endif %}
                        <div class="col-lg-6">
                            <div class="p-5">
                                <div class="text-center mb-4">
                                    <img src="{{ logo_url }}" alt="{{ site_name }}"  class="img-fluid" style="width: 200px; max-height: 110px;">
                                    <p class="text-gray-600  mt-3">Bienvenidos al aula virtual</p>
                                </div>

                                {% if error_message is not empty %}
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    {{ error_message }}
                                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>
                                {% endif %}

                                <form class="user" method="POST" action="">
                                    <div class="form-group">
                                        <input type="text"
                                               class="form-control form-control-user"
                                               name="login"
                                               id="login"
                                               aria-describedby="loginHelp"
                                               placeholder="{{ 'Username'|get_lang }}"
                                               required
                                               autofocus>
                                    </div>
                                    <div class="form-group">
                                        <input type="password"
                                               class="form-control form-control-user"
                                               name="password"
                                               id="password"
                                               placeholder="{{ 'Pass'|get_lang }}"
                                               required>
                                    </div>
                                    <button type="submit" class="btn btn-primary btn-user btn-block">
                                        {{ 'LoginEnter'|get_lang }}
                                    </button>
                                </form>
                                <hr>
                                <div class="text-center mb-3">
                                    <a href="{{ google_login_url }}" class="btn btn-outline-danger btn-user btn-block">
                                        <i class="fab fa-google fa-fw"></i> Iniciar sesión con Google
                                    </a>
                                </div>
                                <hr>
                                {% if allow_lost_password %}
                                <div class="text-center">
                                    <a class="small" href="{{ lost_password_url }}">
                                        {{ 'LostPassword'|get_lang }}
                                    </a>
                                </div>
                                {% endif %}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

{% if vegas_images|length > 0 %}
<link rel="stylesheet" href="{{ plugin_path }}js/vegas-3/src/vegas.css">
<script type="module">
import vegas from '{{ plugin_path }}js/vegas-3/src/vegas.js';
const el = document.getElementById('vegas-container');
if (el) {
    vegas(el, {
        slides: [
            {% for img in vegas_images %}
            { src: '{{ img }}' }{% if not loop.last %},{% endif %}
            {% endfor %}
        ],
        transition: 'fade',
        transitionDuration: 1000,
        delay: 5000,
        animation: 'kenburns',
        animationDuration: 6000,
        overlay: true
    });
}
</script>
{% endif %}
