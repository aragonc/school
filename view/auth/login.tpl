<div class="container d-flex align-items-center justify-content-center" style="min-height: 100vh;">
    <div class="row justify-content-center w-100">
        <div class="col-xl-10 col-lg-12 col-md-9">
            <div class="card o-hidden border-0 shadow-lg">
                <div class="card-body p-0">
                    <div class="row">
                        {% if login_card_image %}
                        <div class="col-lg-6 d-none d-lg-block" style="background: url('{{ login_card_image }}') no-repeat center center; background-size: cover;"></div>
                        {% else %}
                        <div class="col-lg-6 d-none d-lg-block bg-login-image"></div>
                        {% endif %}
                        <div class="col-lg-6">
                            <div class="p-5">
                                <div class="text-center mb-4">
                                    <img src="{{ logo_url }}" alt="{{ site_name }}" class="img-fluid mb-3" style="max-height: 80px;">
                                    <p class="text-gray-600">Bienvenidos al aula virtual</p>
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
                                <div class="text-center">
                                    <a class="small" href="{{ lost_password_url }}">
                                        {{ 'LostPassword'|get_lang }}
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
