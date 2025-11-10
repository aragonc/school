{% if show_profile_completion_modal %}
<!-- Modal de Completar Perfil - País primero, luego identificación -->
<div id="profileCompletionModal" class="modal fade" data-backdrop="static" data-keyboard="false" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h4 class="modal-title">
                    <i class="fa fa-user-check"></i>
                    Completa tu información de perfil
                </h4>
            </div>
            <div class="modal-body">
                <div class="alert alert-info">
                    <i class="fa fa-info-circle"></i>
                    <strong>Importante:</strong> Para continuar usando la plataforma, necesitamos que completes los siguientes datos obligatorios.
                </div>

                <form id="profileCompletionForm">

                    <!-- País (PRIMERO y OBLIGATORIO) -->
                    <div class="form-group">
                        <label for="country">
                            <i class="fa fa-globe"></i>
                            País
                            <span class="text-danger">*</span>
                        </label>
                        <select class="form-control form-control-lg" id="country" name="country" required>
                            <option value="">-- Selecciona tu país --</option>
                            <option value="CL" {% if current_profile_data.country == 'CL' %}selected{% endif %}>🇨🇱 Chile</option>
                            <option value="AR" {% if current_profile_data.country == 'AR' %}selected{% endif %}>🇦🇷 Argentina</option>
                            <option value="BO" {% if current_profile_data.country == 'BO' %}selected{% endif %}>🇧🇴 Bolivia</option>
                            <option value="BR" {% if current_profile_data.country == 'BR' %}selected{% endif %}>🇧🇷 Brasil</option>
                            <option value="CO" {% if current_profile_data.country == 'CO' %}selected{% endif %}>🇨🇴 Colombia</option>
                            <option value="CR" {% if current_profile_data.country == 'CR' %}selected{% endif %}>🇨🇷 Costa Rica</option>
                            <option value="EC" {% if current_profile_data.country == 'EC' %}selected{% endif %}>🇪🇨 Ecuador</option>
                            <option value="SV" {% if current_profile_data.country == 'SV' %}selected{% endif %}>🇸🇻 El Salvador</option>
                            <option value="GT" {% if current_profile_data.country == 'GT' %}selected{% endif %}>🇬🇹 Guatemala</option>
                            <option value="HN" {% if current_profile_data.country == 'HN' %}selected{% endif %}>🇭🇳 Honduras</option>
                            <option value="MX" {% if current_profile_data.country == 'MX' %}selected{% endif %}>🇲🇽 México</option>
                            <option value="NI" {% if current_profile_data.country == 'NI' %}selected{% endif %}>🇳🇮 Nicaragua</option>
                            <option value="PA" {% if current_profile_data.country == 'PA' %}selected{% endif %}>🇵🇦 Panamá</option>
                            <option value="PY" {% if current_profile_data.country == 'PY' %}selected{% endif %}>🇵🇾 Paraguay</option>
                            <option value="PE" {% if current_profile_data.country == 'PE' %}selected{% endif %}>🇵🇪 Perú</option>
                            <option value="DO" {% if current_profile_data.country == 'DO' %}selected{% endif %}>🇩🇴 República Dominicana</option>
                            <option value="UY" {% if current_profile_data.country == 'UY' %}selected{% endif %}>🇺🇾 Uruguay</option>
                            <option value="VE" {% if current_profile_data.country == 'VE' %}selected{% endif %}>🇻🇪 Venezuela</option>
                            <option value="ES" {% if current_profile_data.country == 'ES' %}selected{% endif %}>🇪🇸 España</option>
                            <option value="US" {% if current_profile_data.country == 'US' %}selected{% endif %}>🇺🇸 Estados Unidos</option>
                            <option value="OTHER">🌍 Otro</option>
                        </select>
                        <small class="form-text text-muted">
                            Primero selecciona tu país para mostrar el campo de identificación correspondiente
                        </small>
                    </div>

                    <!-- RUT (Solo para Chile) -->
                    <div class="form-group" id="rut-group" style="display: none;">
                        <label for="rut">
                            <i class="fa fa-id-card"></i>
                            RUT (Rol Único Tributario)
                            <span class="text-danger">*</span>
                        </label>
                        <input type="text"
                               class="form-control form-control-lg"
                               id="rut"
                               name="rut"
                               placeholder="12.345.678-9"
                               value="{{ current_profile_data.rut }}">
                        <small class="form-text text-muted">
                            Ingresa tu RUT con o sin puntos y con guión. Ejemplo: 12.345.678-9
                        </small>
                    </div>

                    <!-- Identificador (Para otros países) -->
                    <div class="form-group" id="identificador-group" style="display: none;">
                        <label for="identificador">
                            <i class="fa fa-id-card"></i>
                            Documento de Identidad / Pasaporte
                            <span class="text-danger">*</span>
                        </label>
                        <input type="text"
                               class="form-control form-control-lg"
                               id="identificador"
                               name="identificador"
                               placeholder="Número de documento"
                               value="{{ current_profile_data.identificador }}">
                        <small class="form-text text-muted">
                            Ingresa tu número de documento de identidad o pasaporte
                        </small>
                    </div>

                    <!-- Teléfono/WhatsApp (OPCIONAL) -->
                    <div class="form-group">
                        <label for="phone">
                            <i class="fa fa-whatsapp"></i>
                            Teléfono / WhatsApp
                            <span class="text-muted">(Opcional)</span>
                        </label>
                        <input type="tel"
                               class="form-control form-control-lg"
                               id="phone"
                               name="phone"
                               placeholder="+56 9 1234 5678"
                               value="{{ current_profile_data.phone }}">
                        <small class="form-text text-muted">
                            Si deseas, incluye tu número con código de país. Ejemplo: +56 9 1234 5678
                        </small>
                    </div>

                    <div id="formMessage" class="alert" style="display: none;"></div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button"
                        class="btn btn-primary btn-lg btn-block"
                        id="submitProfile">
                    <i class="fa fa-save"></i> Guardar y Continuar
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        // Mostrar el modal automáticamente
        $('#profileCompletionModal').modal('show');

        // Función para mostrar el campo correcto según el país
        function toggleIdentificationField() {
            var selectedCountry = $('#country').val();

            if (selectedCountry === 'CL') {
                // Chile: Mostrar RUT
                $('#rut-group').show();
                $('#rut').prop('required', true);
                $('#identificador-group').hide();
                $('#identificador').prop('required', false);
            } else if (selectedCountry !== '') {
                // Otro país: Mostrar Identificador
                $('#identificador-group').show();
                $('#identificador').prop('required', true);
                $('#rut-group').hide();
                $('#rut').prop('required', false);
            } else {
                // No hay país seleccionado: Ocultar ambos
                $('#rut-group').hide();
                $('#rut').prop('required', false);
                $('#identificador-group').hide();
                $('#identificador').prop('required', false);
            }
        }

        // Ejecutar al cargar la página
        toggleIdentificationField();

        // Ejecutar cuando cambia el país
        $('#country').change(function() {
            toggleIdentificationField();
        });

        // Formatear RUT automáticamente (solo para Chile)
        $('#rut').on('input', function() {
            let value = $(this).val().replace(/[^0-9kK]/g, '');
            if (value.length > 1) {
                let body = value.slice(0, -1);
                let dv = value.slice(-1).toUpperCase();
                body = body.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
                $(this).val(body + '-' + dv);
            }
        });

        // Enviar formulario
        $('#submitProfile').click(function() {
            let form = $('#profileCompletionForm')[0];

            // Validar formulario HTML5
            if (!form.checkValidity()) {
                form.reportValidity();
                return;
            }

            let submitBtn = $(this);
            let originalText = submitBtn.html();
            submitBtn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Guardando datos...');

            $('#formMessage').hide();

            $.ajax({
                url: '{{ _p.web_main }}auth/external_login/update_profile_completion.php',
                method: 'POST',
                data: $('#profileCompletionForm').serialize(),
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        $('#formMessage')
                            .removeClass('alert-danger')
                            .addClass('alert-success')
                            .html('<i class="fa fa-check-circle"></i> <strong>¡Perfecto!</strong> ' + response.message + ' Redirigiendo...')
                            .show();

                        setTimeout(function() {
                            location.reload();
                        }, 2000);
                    } else {
                        $('#formMessage')
                            .removeClass('alert-success')
                            .addClass('alert-danger')
                            .html('<i class="fa fa-exclamation-triangle"></i> <strong>Error:</strong> ' + response.message)
                            .show();

                        submitBtn.prop('disabled', false).html(originalText);
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error AJAX:', error);
                    console.error('Response:', xhr.responseText);

                    $('#formMessage')
                        .removeClass('alert-success')
                        .addClass('alert-danger')
                        .html('<i class="fa fa-exclamation-triangle"></i> <strong>Error de conexión:</strong> No se pudieron guardar los datos. Por favor, intenta nuevamente.')
                        .show();

                    submitBtn.prop('disabled', false).html(originalText);
                }
            });
        });

        // Prevenir cerrar modal
        $('#profileCompletionModal').on('hide.bs.modal', function (e) {
            e.preventDefault();
            return false;
        });
    });
</script>

<style>
    #profileCompletionModal .modal-content {
        border: none;
        border-radius: 12px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    }

    #profileCompletionModal .modal-header {
        background: #737FE7;
        border-radius: 9px 9px 0 0;
        padding: 15px 25px;
    }

    #profileCompletionModal .modal-body {
        padding: 30px;
    }

    #profileCompletionModal .form-group label {
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
    }

    #profileCompletionModal .modal-title{
        font-size: 16px;
    }

    #profileCompletionModal .form-group label i {
        margin-right: 5px;
        color: #667eea;
    }

    #profileCompletionModal .form-control-lg {
        border: 2px solid #e0e0e0;
        border-radius: 8px;
        font-size: 16px;
        transition: all 0.3s;
    }

    #profileCompletionModal .form-control-lg:focus {
        border-color: #667eea;
        box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
    }

    #profileCompletionModal .btn-primary {
        background: #737FE7;
        border: none;
        border-radius: 8px;
        padding: 14px;
        font-weight: 600;
        font-size: 16px;
        transition: all 0.3s;
    }

    #profileCompletionModal .btn-primary:hover:not(:disabled) {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
    }

    #profileCompletionModal .btn-primary:disabled {
        opacity: 0.7;
    }

    #profileCompletionModal .alert-info {
        background-color: #e3f2fd;
        border-color: #90caf9;
        color: #1565c0;
        border-radius: 8px;
    }

    #profileCompletionModal .text-muted {
        color: #999 !important;
        font-weight: normal;
    }
</style>
{% endif %}
