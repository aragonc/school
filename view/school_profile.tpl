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
        <div class="p-5">
            <div class="row">
                <div class="col">

                    {{ form }}
                </div>
                <div class="col">
                    <div class="text-center">
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
        //let messageError = '<?php echo custompages_get_lang('errorRUT'); ?>';
        let Rut = $("#extra_rol_unico_tributario");
        let Dni = $("#extra_identificador");
        let RutValue = null;
        let DniValue = null;
        let checkRut = true;
        let contentAdd = false;

        Rut.attr('placeholder','Ej: 11222333-K');
        Rut.attr('title','Ingresar RUN sin puntos, con guión y con dígito verificador. Ej: 11222333-K');
        Rut.attr('maxlength','10');

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
                countrySelect = $( this ).text();
                if(countrySelect!=='Chile'){
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


        $("#profile").submit(function(e){
            //console.log(RUT.val());
            RutValue = Rut.val();
            DniValue = Dni.val();
            let countrySelect;
            let formGroupRUT = $("#form_extra_rol_unico_tributario_group");
            let formGroupDNI = $("#form_extra_identificador_group");
            //alert($("input[type=radio]:checked").val());
            $( "#profile_country option:selected" ).each(function() {
                countrySelect = $( this ).text();
            });
            //console.log(countrySelect);

            if(checkRut){
                if(countrySelect==='Chile') {
                    if (!(RutValue.match('^[0-9]{7,9}[-|‐]{1}[0-9kK]{1}$'))) {
                        if (!contentAdd) {
                            formGroupRUT.addClass('error has-error');
                            formGroupRUT.append('<div class="help-info-form">'+messageError+'</div>');
                            contentAdd = true;
                        }
                        e.preventDefault();
                    }
                } else {
                    if(DniValue.trim() === ""){
                        if (!contentAdd) {
                            formGroupDNI.addClass('error has-error');
                            formGroupDNI.append('<div class="help-info-form">Debe de ingresar un Nº Documento o Cédula de Identidad válido</div>');
                            contentAdd = true;
                        }
                        e.preventDefault();
                    }
                }
            }
        });


    });
</script>