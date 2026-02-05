<section class="ftco-section">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 text-center mb-5">
                <a href="{{ redirect_url }}">
                    <img src="{{ _p.web }}custompages/images/logo-otec.svg" class="img-fluid logo"
                         alt="Educación Chile - Registro ATE - Ministerio de Educación">
                </a>
            </div>
        </div>
        <div class="row justify-content-center">
            <div class="col-md-12 col-lg-7">
                <div class="padding-login text-center">
                    <div class="text-center">
                        <img src="{{ _p.web }}plugin/school/img/icons/logout.svg" alt="" width="280px" height="280px">
                    </div>
                    <h1 class="title"><span>Sesión cerrada por </span> inactividad</h1>
                    <p>Te direccionarás en <span id="contador">{{ redirect_seconds }}</span> segundos para iniciar sesión...</p>
                    <a href="{{ redirect_url }}" class="btn btn-primary btn-block">
                        Clic para iniciar sesión
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<script>
    (function () {
        let segundos = {{ redirect_seconds }};
        const contador = document.getElementById("contador");
        const urlBase = "{{ redirect_url }}";

        const intervalo = setInterval(function () {
            segundos--;
            if (contador) {
                contador.textContent = segundos;
            }

            if (segundos <= 0) {
                clearInterval(intervalo);
                window.location.replace(urlBase);
            }
        }, 1000);
        })
    ();
</script>