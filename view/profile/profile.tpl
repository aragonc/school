<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link active" href="/profile">
            {{ 'PersonalData'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>

    <li class="nav-item">
        {% if is_student %}
        <a class="nav-link" href="/extra-profile">Ficha de Matrícula</a>
        {% else %}
        <a class="nav-link" href="/datos-adicionales">Datos Adicionales</a>
        {% endif %}
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
                    <div class="d-md-block text-center">
                        {% if qr_image %}
                        <div class="mb-4">
                            <img src="data:image/png;base64,{{ qr_image }}" alt="QR Code" style="width:150px;height:150px;">
                            <p class="mt-2 mb-1"><strong>{{ username_qr }}</strong></p>
                            <button type="button" class="btn btn-warning btn-sm mt-1" id="btn-ver-tarjeta"
                                    data-user-id="{{ current_user_id }}">
                                <i class="fas fa-id-card mr-1"></i> Ver Tarjeta
                            </button>
                        </div>
                        {% endif %}
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

{# ===== MODAL TARJETA ===== #}
<div class="modal fade" id="modalTarjetaPerfil" tabindex="-1" role="dialog">
    <div class="modal-dialog" style="max-width:420px;" role="document">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title font-weight-bold">
                    {% if is_student %}
                    <i class="fas fa-id-card mr-1"></i> Tarjeta de Identificación
                    {% else %}
                    <i class="fas fa-id-badge mr-1"></i> Carnet de Personal
                    {% endif %}
                </h6>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body p-3">
                <div id="tp-loading" class="text-center py-5">
                    <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                </div>
                <div id="tp-contenido" style="display:none;">

                    {% if is_student %}
                    {# ---- TARJETA ALUMNO (azul) ---- #}
                    <div id="tp-card" style="
                        width:100%;
                        background:linear-gradient(160deg,#1a3a6b 0%,#2563aa 55%,#0ea5e9 100%);
                        color:#fff;
                        font-family:Arial,sans-serif;
                        border-radius:16px;
                        overflow:hidden;
                        position:relative;
                    ">
                        <div style="display:flex;align-items:center;padding:16px 20px 12px;background:rgba(255,255,255,0.12);">
                            <img id="tp-logo" src="{{ logo_url }}" alt="Logo"
                                 style="height:44px;max-width:80px;object-fit:contain;background:#fff;border-radius:6px;padding:3px;margin-right:12px;flex-shrink:0;">
                            <div>
                                <div style="font-size:10px;font-weight:700;letter-spacing:1px;text-transform:uppercase;opacity:.85;line-height:1.3;">{{ institution_name }}</div>
                                <div style="font-size:12px;font-weight:800;letter-spacing:1.5px;line-height:1.3;">TARJETA DE IDENTIFICACIÓN</div>
                            </div>
                        </div>
                        <div style="text-align:center;padding:20px 20px 12px;">
                            <div style="width:120px;height:150px;background:rgba(255,255,255,0.2);border-radius:10px;overflow:hidden;border:3px solid rgba(255,255,255,0.6);display:inline-block;">
                                <img id="tp-foto" src="" alt="Foto" style="width:100%;height:100%;object-fit:cover;display:none;">
                                <div id="tp-foto-placeholder" style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;">
                                    <i class="fas fa-user" style="font-size:56px;opacity:.4;"></i>
                                </div>
                            </div>
                        </div>
                        <div style="text-align:center;padding:0 20px 16px;">
                            <div style="font-size:9px;opacity:.7;text-transform:uppercase;letter-spacing:1px;margin-bottom:4px;">Apellidos y Nombres</div>
                            <div id="tp-nombre" style="font-size:17px;font-weight:800;line-height:1.3;"></div>
                        </div>
                        <div style="display:flex;margin:0 20px 10px;background:rgba(255,255,255,0.12);border-radius:8px;overflow:hidden;">
                            <div style="flex:1;padding:10px 14px;border-right:1px solid rgba(255,255,255,0.2);">
                                <div style="font-size:9px;opacity:.7;text-transform:uppercase;letter-spacing:1px;">DNI</div>
                                <div id="tp-dni" style="font-size:15px;font-weight:700;letter-spacing:2px;"></div>
                            </div>
                            <div style="flex:1;padding:10px 14px;">
                                <div style="font-size:9px;opacity:.7;text-transform:uppercase;letter-spacing:1px;">Nivel</div>
                                <div id="tp-level" style="font-size:15px;font-weight:700;"></div>
                            </div>
                        </div>
                        <div style="display:flex;margin:0 20px 18px;background:rgba(255,255,255,0.12);border-radius:8px;overflow:hidden;">
                            <div style="flex:1;padding:10px 14px;border-right:1px solid rgba(255,255,255,0.2);">
                                <div style="font-size:9px;opacity:.7;text-transform:uppercase;letter-spacing:1px;">Grado</div>
                                <div id="tp-grade" style="font-size:15px;font-weight:700;"></div>
                            </div>
                            <div style="flex:1;padding:10px 14px;">
                                <div style="font-size:9px;opacity:.7;text-transform:uppercase;letter-spacing:1px;">Sección</div>
                                <div id="tp-section" style="font-size:15px;font-weight:700;"></div>
                            </div>
                        </div>
                        <div style="text-align:center;padding:0 20px 18px;">
                            <div id="tp-qr" style="background:#fff;padding:8px;border-radius:8px;display:inline-block;"></div>
                            <div id="tp-email" style="font-size:9px;opacity:.75;margin-top:6px;word-break:break-all;"></div>
                        </div>
                        <div style="background:rgba(0,0,0,0.25);text-align:center;padding:8px;font-size:9px;letter-spacing:1.5px;opacity:.8;">
                            DOCUMENTO DE IDENTIFICACIÓN ESTUDIANTIL
                        </div>
                    </div>

                    {% else %}
                    {# ---- CARNET PERSONAL (blanco) ---- #}
                    <div id="tp-card" style="
                        width:100%;
                        background:#ffffff;
                        color:#2d3748;
                        font-family:Arial,sans-serif;
                        border-radius:14px;
                        overflow:hidden;
                        border:1px solid #e2e8f0;
                        box-shadow:0 2px 12px rgba(0,0,0,0.08);
                    ">
                        <div style="display:flex;align-items:center;padding:14px 18px 12px;background:#1a3558;border-bottom:3px solid #0f2040;">
                            <img id="tp-logo" src="{{ logo_url }}" alt="Logo"
                                 style="height:42px;max-width:76px;object-fit:contain;background:#fff;border-radius:6px;padding:3px;margin-right:12px;flex-shrink:0;">
                            <div>
                                <div style="font-size:9px;font-weight:700;letter-spacing:1px;text-transform:uppercase;color:#a8c4e0;line-height:1.3;">{{ institution_name }}</div>
                                <div style="font-size:11px;font-weight:800;letter-spacing:1px;color:#fff;line-height:1.4;">CARNET DE PERSONAL</div>
                            </div>
                        </div>
                        <div style="text-align:center;padding:20px 20px 10px;">
                            <div style="width:110px;height:140px;background:#f0f4f8;border-radius:10px;overflow:hidden;border:2px solid #cbd5e0;display:inline-block;">
                                <img id="tp-foto" src="" alt="Foto" style="width:100%;height:100%;object-fit:cover;display:none;">
                                <div id="tp-foto-placeholder" style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;">
                                    <i class="fas fa-user" style="font-size:50px;color:#a0aec0;"></i>
                                </div>
                            </div>
                        </div>
                        <div style="text-align:center;padding:0 18px 12px;">
                            <div style="font-size:8px;color:#718096;text-transform:uppercase;letter-spacing:1px;margin-bottom:3px;">Apellidos y Nombres</div>
                            <div id="tp-nombre" style="font-size:16px;font-weight:800;color:#1a202c;line-height:1.3;"></div>
                        </div>
                        <div style="display:flex;margin:0 16px 12px;background:#f7f8fa;border-radius:8px;border:1px solid #e2e8f0;overflow:hidden;" id="tp-info-row">
                            <div style="flex:1;padding:10px 12px;border-right:1px solid #e2e8f0;">
                                <div style="font-size:8px;color:#718096;text-transform:uppercase;letter-spacing:1px;">Cargo</div>
                                <div id="tp-cargo" style="font-size:13px;font-weight:700;color:#2d3748;"></div>
                            </div>
                            <div id="tp-nivel-col" style="flex:1;padding:10px 12px;">
                                <div style="font-size:8px;color:#718096;text-transform:uppercase;letter-spacing:1px;">Nivel</div>
                                <div id="tp-nivel" style="font-size:13px;font-weight:700;color:#2d3748;"></div>
                            </div>
                        </div>
                        <div style="text-align:center;padding:0 18px 16px;">
                            <div id="tp-qr" style="background:#f7f8fa;border:1px solid #e2e8f0;padding:8px;border-radius:8px;display:inline-block;"></div>
                            <div id="tp-email" style="font-size:9px;color:#718096;margin-top:5px;word-break:break-all;"></div>
                        </div>
                        <div style="background:#1a3558;border-top:3px solid #0f2040;text-align:center;padding:7px;font-size:8px;letter-spacing:1.2px;color:#fff;font-weight:700;">
                            DOCUMENTO DE IDENTIFICACIÓN — PERSONAL
                        </div>
                    </div>
                    {% endif %}

                </div>
            </div>
            <div class="modal-footer py-2" id="tp-footer" style="display:none!important;">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-dismiss="modal">Cerrar</button>
                <button type="button" class="btn {% if is_student %}btn-primary{% else %}btn-dark{% endif %} btn-sm" id="btn-imprimir-tarjeta-perfil">
                    <i class="fas fa-print mr-1"></i> Imprimir
                </button>
            </div>
        </div>
    </div>
</div>

<script src="{{ qrcode_js }}"></script>
<script>
$(document).ready(function () {
    var isStudent = {{ is_student ? 'true' : 'false' }};

    $('#btn-ver-tarjeta').on('click', function () {
        var userId = $(this).data('user-id');
        $('#tp-loading').show().html('<i class="fas fa-spinner fa-spin fa-2x text-primary"></i>');
        $('#tp-contenido').hide();
        $('#tp-footer').css('display', 'none');
        $('#modalTarjetaPerfil').modal('show');

        if (isStudent) {
            $.get('{{ ajax_url }}', { action: 'get_tarjeta_data', user_id: userId }, function (resp) {
                $('#tp-loading').hide();
                if (!resp.success) {
                    $('#tp-loading').html('<p class="text-danger p-3">' + (resp.error || 'Error') + '</p>').show();
                    return;
                }
                $('#tp-nombre').html(resp.apellidos + '<br><span style="font-weight:400;font-size:15px;">' + resp.nombres + '</span>');
                $('#tp-dni').text(resp.dni || '—');
                $('#tp-level').text(resp.level || '—');
                $('#tp-grade').text(resp.grade || '—');
                $('#tp-section').text(resp.section || '—');
                $('#tp-email').text(resp.email || '');
                if (resp.foto_url) {
                    $('#tp-foto').attr('src', resp.foto_url).show();
                    $('#tp-foto-placeholder').hide();
                } else {
                    $('#tp-foto').hide();
                    $('#tp-foto-placeholder').show();
                }
                $('#tp-qr').empty();
                if (resp.email) {
                    new QRCode(document.getElementById('tp-qr'), {
                        text: resp.email, width: 98, height: 98,
                        colorDark: '#1a3a6b', colorLight: '#ffffff',
                        correctLevel: QRCode.CorrectLevel.M
                    });
                }
                $('#tp-contenido').show();
                $('#tp-footer').css('display', 'flex');
            }, 'json').fail(function () {
                $('#tp-loading').html('<p class="text-danger p-3">Error de conexión.</p>').show();
            });
        } else {
            $.get('{{ ajax_admin_url }}', { action: 'get_staff_card_data', user_id: userId }, function (resp) {
                $('#tp-loading').hide();
                if (!resp.success) {
                    $('#tp-loading').html('<p class="text-danger p-3">' + (resp.error || 'Error') + '</p>').show();
                    return;
                }
                $('#tp-nombre').html(resp.apellidos + '<br><span style="font-weight:400;font-size:15px;">' + resp.nombres + '</span>');
                $('#tp-cargo').text(resp.cargo || '—');
                $('#tp-email').text(resp.email || '');
                if (resp.nivel) {
                    $('#tp-nivel').text(resp.nivel);
                    $('#tp-nivel-col').show();
                    $('#tp-info-row > div:first-child').css('border-right', '1px solid #e2e8f0');
                } else {
                    $('#tp-nivel-col').hide();
                    $('#tp-info-row > div:first-child').css('border-right', 'none');
                }
                if (resp.foto_url) {
                    $('#tp-foto').attr('src', resp.foto_url).show();
                    $('#tp-foto-placeholder').hide();
                } else {
                    $('#tp-foto').hide();
                    $('#tp-foto-placeholder').show();
                }
                $('#tp-qr').empty();
                if (resp.email) {
                    new QRCode(document.getElementById('tp-qr'), {
                        text: resp.email, width: 90, height: 90,
                        colorDark: '#2d3748', colorLight: '#f7f8fa',
                        correctLevel: QRCode.CorrectLevel.M
                    });
                }
                $('#tp-contenido').show();
                $('#tp-footer').css('display', 'flex');
            }, 'json').fail(function () {
                $('#tp-loading').html('<p class="text-danger p-3">Error de conexión.</p>').show();
            });
        }
    });

    $('#btn-imprimir-tarjeta-perfil').on('click', function () {
        var cardHtml = document.getElementById('tp-card').outerHTML;
        var cardId   = isStudent ? 'tp-card' : 'tp-card';
        var w = window.open('', '_blank');
        w.document.write([
            '<!DOCTYPE html><html><head>',
            '<meta charset="utf-8">',
            '<title>' + (isStudent ? 'Tarjeta de Identificación' : 'Carnet de Personal') + '</title>',
            '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">',
            '<style>',
            '* { box-sizing: border-box; }',
            '@page { size: A4 portrait; margin: 0; }',
            'html { margin: 0; padding: 0; background: #fff; }',
            'body { margin:0; padding:0; width:21cm; height:29.7cm; display:flex; align-items:center; justify-content:center; background:#fff; }',
            '#tp-card { width:9cm !important; border-radius:12px !important; -webkit-print-color-adjust:exact; print-color-adjust:exact; }',
            '</style>',
            '</head><body>',
            cardHtml,
            '<script>window.addEventListener("load",function(){setTimeout(function(){window.print();window.close();},400);});<\/script>',
            '</body></html>'
        ].join(''));
        w.document.close();
    });
});
</script>

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
            //console.log(RUT.val());
            RutValue = Rut.val();
            validateRUT(RutValue);
            DniValue = Dni.val();
            let countrySelect;
            let formGroupRUT = $("#form_extra_rol_unico_tributario_group");
            let formGroupDNI = $("#form_extra_identificador_group");
            //alert($("input[type=radio]:checked").val());
            $( "#form_profile_country option:selected" ).each(function() {
                countrySelect = $( this ).val();
            });

            if(checkRut){
                if(countrySelect==='CL') {
                    if (!(RutValue.match('^[0-9]{7,9}[-|‐]{1}[0-9kK]{1}$'))) {
                        if (!contentAdd) {
                            formGroupRUT.addClass('flat-error flat-has-error');
                            formGroupRUT.append('<div class="help-info-form">'+messageError+'</div>');
                            contentAdd = true;
                        }
                        e.preventDefault();
                    }
                } else {
                    if(DniValue.trim() === ""){
                        if (!contentAdd) {
                            formGroupDNI.addClass('flat-error flat-has-error');
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