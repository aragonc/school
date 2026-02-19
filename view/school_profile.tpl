<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link active" href="/profile">
            {{ 'PersonalData'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link " href="/password" >
            {{ 'ChangePassword'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link " href="/avatar" >
            {{ 'EditAvatar'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>

<div class="card">
    <div class="card-body">
        <div class="p-0 p-md-5">
            <div class="row">
                <div class="col-12 col-lg-6">
                    {{ form }}
                </div>
                <div class="col-12 col-lg-6">
                    <div class="d-none d-md-block text-center">
                        <div class="bd-callout bd-callout-info">
                            <p>{{ 'UsernameHelp'|get_plugin_lang('SchoolPlugin') }}
                            <a href="mailto: {{ administrator_mail }}">{{ administrator_mail }}</a></p>
                        </div>
                        {{ img_section }}
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(function() {
        let countryCode = $("#form_profile_country").val();
        let messageError = '{{ error_rut }}';
        let Rut = $("#extra_rol_unico_tributario");
        let Dni = $("#extra_identificador");
        let RutValue = null;
        let DniValue = null;
        let checkRut = true;
        let contentAdd = false;
        let rutValidated = false;

        Rut.attr('placeholder','Ej: 11222333-K');
        Rut.attr('title','Ingresar RUN sin puntos, con guión y con dígito verificador. Ej: 11222333-K');
        Rut.attr('maxlength','10');

        // Función para validar RUT chileno
        function validateRUT(rut) {
            rut = rut.replace(/[^0-9kK]/g, '').toUpperCase();
            if (rut.length < 8 || rut.length > 9) {
                return false;
            }
            let body = rut.slice(0, -1);
            let dv = rut.slice(-1);
            let suma = 0;
            let multiplo = 2;

            for (let i = body.length - 1; i >= 0; i--) {
                suma += parseInt(body.charAt(i)) * multiplo;
                multiplo = multiplo < 7 ? multiplo + 1 : 2;
            }
            let dvEsperado = 11 - (suma % 11);
            let dvCalculado = dvEsperado === 11 ? '0' : dvEsperado === 10 ? 'K' : dvEsperado.toString();
            return dv === dvCalculado;
        }

        // Formatear RUT automáticamente (solo para Chile) - SIN PUNTOS
        $(Rut).on('input', function () {
            rutValidated = false; // 👈 Resetear bandera cuando cambia el RUT
            let value = $(this).val().toUpperCase().replace(/[^0-9K]/g, '');

            if (value.length > 1) {
                let body = value.slice(0, -1);
                let dv = value.slice(-1);
                $(this).val(body + '-' + dv);
            } else if (value.length === 1) {
                $(this).val(value);
            }
        });

        if(countryCode==='CL'){
            $("#form_extra_rol_unico_tributario_group").show();
            Rut.prop('required', true);
            $("#form_extra_identificador_group").hide();
            //Rut.val('');
        } else {
            $("#form_extra_rol_unico_tributario_group").hide();
            $("#form_extra_identificador_group").show();
            Dni.prop('required', true);
            //Rut.val('');
        }

        $("#form_profile_country").change(function () {
            //checkRut = isCountryForRut($(this));
            //console.log(checkRut);
            let countrySelect;
            $( "#form_profile_country option:selected" ).each(function() {
                countrySelect = $( this ).val();
                if(countrySelect!=='CL'){
                    $("#form_extra_rol_unico_tributario_group").hide();
                    $("#form_extra_identificador_group").show();
                    Dni.prop('required', true);
                    Rut.prop('required', false);
                    Rut.val('');
                } else {
                    $("#form_extra_rol_unico_tributario_group").show();
                    $("#form_extra_identificador_group").hide();
                    Dni.prop('required', false);
                    Rut.prop('required', true);
                    Rut.val('');
                }
            });
        });


        $("#form_profile").submit(function(e){
            RutValue = Rut.val();
            DniValue = Dni.val();
            let countrySelect;
            let formGroupRUT = $("#form_extra_rol_unico_tributario_group");
            let formGroupDNI = $("#form_extra_identificador_group");

            // Limpiar errores previos en cada intento
            formGroupRUT.removeClass('flat-error flat-has-error');
            formGroupRUT.find('.help-info-form').remove();
            formGroupDNI.removeClass('flat-error flat-has-error');
            formGroupDNI.find('.help-info-form').remove();
            contentAdd = false;

            $( "#form_profile_country option:selected" ).each(function() {
                countrySelect = $( this ).val();
            });

            if(checkRut){
                if(countrySelect==='CL') {
                    if (!validateRUT(RutValue)) {
                        formGroupRUT.addClass('flat-error flat-has-error');
                        formGroupRUT.append('<div class="help-info-form">'+messageError+'</div>');
                        contentAdd = true;
                        e.preventDefault();
                    }
                } else {
                    if(DniValue.trim() === ""){
                        formGroupDNI.addClass('flat-error flat-has-error');
                        formGroupDNI.append('<div class="help-info-form">Debe de ingresar un Nº Documento o Cédula de Identidad válido</div>');
                        contentAdd = true;
                        e.preventDefault();
                    }
                }
            }
        });


    });
</script>