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

                                {% if not google_only_login %}
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
                                {% endif %}

                                {% if login_info_message is not empty %}
                                <div class="alert alert-info d-flex align-items-start mb-3" role="alert" style="border-left:4px solid #17a2b8;font-size:13.5px;">
                                    <i class="fas fa-info-circle mr-2 mt-1" style="flex-shrink:0;"></i>
                                    <span>{{ login_info_message }}</span>
                                </div>
                                {% endif %}

                                <div class="text-center mb-3">
                                    <a href="{{ google_login_url }}" class="btn btn-google-login btn-block d-flex align-items-center justify-content-center" style="background:#fff;border:2px solid #4285F4;color:#4285F4;border-radius:6px;padding:12px 20px;font-size:16px;font-weight:600;gap:12px;text-decoration:none;transition:background .2s,color .2s;" onmouseover="this.style.background='#4285F4';this.style.color='#fff';this.style.animation='none';" onmouseout="this.style.background='#fff';this.style.color='#4285F4';this.style.animation='';">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="width:24px;height:24px;flex-shrink:0;">
                                            <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                                            <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                                            <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                                            <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.18 1.48-4.97 2.31-8.16 2.31-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                                            <path fill="none" d="M0 0h48v48H0z"/>
                                        </svg>
                                        Iniciar sesión con Google
                                    </a>
                                </div>

                                {% if not google_only_login %}
                                <hr>
                                {% if allow_lost_password %}
                                <div class="text-center">
                                    <a class="small" href="{{ lost_password_url }}">
                                        {{ 'LostPassword'|get_lang }}
                                    </a>
                                </div>
                                {% endif %}
                                {% endif %}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
@keyframes google-btn-pulse {
    0%   { box-shadow: 0 0 0 0 rgba(66,133,244,0.55); transform: scale(1); }
    50%  { box-shadow: 0 0 0 10px rgba(66,133,244,0); transform: scale(1.02); }
    100% { box-shadow: 0 0 0 0 rgba(66,133,244,0); transform: scale(1); }
}
.btn-google-login {
    animation: google-btn-pulse 1.8s ease-in-out infinite;
}
.btn-google-login:hover {
    animation: none;
}
</style>

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
