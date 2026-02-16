<style>
    /* ==========================================
       ESTILOS TIPO GOOGLE PARA FORMULARIO EXISTENTE
       ========================================== */

    /* Contenedor del grupo de formulario */
    .form-group {
        position: relative;
        margin-bottom: 24px;
    }

    /* Label normal (antes de focus) */
    .form-group .form-label {
        position: absolute;
        left: 16px;
        top: 16px;
        color: #5f6368;
        font-size: 13px;
        font-weight: normal;
        pointer-events: none;
        transition: all 0.2s ease;
        background-color: transparent;
        z-index: 1;
        padding: 0;
        margin: 0;
    }

    /* Input de contraseña */
    .form-group input[type="password"],
    .form-group input[type="text"] {
        width: 100%;
        padding: 16px 48px 8px 16px !important; /* Espacio para el botón de ojo */
        font-size: 16px !important;
        border: 1px solid #dadce0 !important;
        border-radius: 4px !important;
        outline: none !important;
        transition: all 0.2s ease;
        background-color: transparent !important;
        height: auto !important;
        box-shadow: none !important;
    }

    /* Input en focus */
    .form-group input[type="password"]:focus,
    .form-group input[type="text"]:focus {
        border: 2px solid #1a73e8 !important;
        padding: 15px 47px 7px 15px !important;
        box-shadow: none !important;
    }

    /* Label flotante cuando hay focus o contenido */
    .form-group.has-content .form-label,
    .form-group input:focus + .form-label {
        top: 4px;
        left: 12px;
        font-size: 12px;
        color: #1a73e8;
        background-color: white;
        padding: 0 4px;
    }

    /* Asterisco requerido  */
    .form-group .form_required {
        color: #d93025;
    }

    .form-group .btn-primary{
        background-color: #737FE7;
        border: 1px solid #737FE7;
    }
    /* Botón de mostrar/ocultar contraseña (inyectado con JS) */
    .toggle-password-btn {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        cursor: pointer;
        padding: 8px;
        color: #5f6368;
        transition: color 0.2s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 2;
        width: 40px;
        height: 40px;
    }

    .toggle-password-btn:hover {
        color: #202124;
    }

    .toggle-password-btn svg {
        width: 24px;
        height: 24px;
        fill: currentColor;
    }

    /* Ajustar el botón de submit */
    .btn-primary {
        padding: 12px 24px !important;
        font-size: 14px !important;
        font-weight: 500 !important;
        border-radius: 4px !important;
        transition: all 0.2s ease !important;
    }

    .btn-primary:hover {
        box-shadow: 0 1px 3px rgba(0,0,0,0.3) !important;
        transform: translateY(-1px);
    }

    .btn-primary:active {
        transform: translateY(0);
    }

    /* Estilos para error (opcional) */
    .form-group.has-error input {
        border-color: #d93025 !important;
    }

    .form-group.has-error .form-label {
        color: #d93025 !important;
    }
</style>
<section class="ftco-section">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 text-center mb-5">
                <a href="{{ _p.web }}">
                    <img src="{{ _p.web }}custompages/images/logo-educacion-chile.svg" class="img-fluid logo" alt="Educación Chile - Registro ATE - Ministerio de Educación">
                </a>
            </div>
        </div>
        <div class="row justify-content-center">
            <div class="col-md-12 col-lg-6">
                <div class="wrap d-md-flex card" style="border-radius: 20px;">
                    <div class="card-body py-4 px-5" >
                        <div class="login-wrap lost-password">
                            <div class="padding-login">
                                <div class="text-center">
                                    <img src="{{ _p.web }}plugin/school/img/icons/locked_icon.svg" alt="" width="128px" height="128px">
                                </div>
                                <h2 class="title">
                                    <span>Actualiza</span> tu contraseña
                                </h2>
                                <p class="help-block">Ingresa y confirma tu nueva contraseña para actualizar el acceso a tu aula virtual.</p>
                                {{ form }}

                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</section>

<!-- Modal de Error -->
<div id="errorModal" class="custom-error-modal" style="display: none;">
    <div class="modal-overlay"></div>
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title" id="modalTitle"></h3>
            <svg class="modal-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
            </svg>
        </div>
        <div class="modal-body">
            <p id="modalMessage"></p>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-modal-close btn-block" id="btnCloseModal">
                <span id="btnCloseText">{{ 'Accept'|get_plugin_lang('SchoolPlugin') }}</span>
            </button>
        </div>
    </div>
</div>

<!-- Modal de Éxito -->
<div id="successModal" class="custom-success-modal" style="display: none;">
    <div class="modal-overlay"></div>
    <div class="modal-content">
        <div class="modal-header">
            <svg class="modal-icon-success" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
            <h3 class="modal-title" id="successModalTitle"></h3>
        </div>
        <div class="modal-body">
            <p id="successModalMessage"></p>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-modal-primary btn-block" id="btnGoToLogin">
                <span id="btnGoToLoginText"></span>
            </button>
        </div>
    </div>
</div>

<!-- Loading Overlay -->
<div id="loadingOverlay" class="loading-overlay" style="display: none;">
    <div class="loading-spinner">
        <div class="spinner"></div>
        <p id="loadingText">{{ 'Processing'|get_plugin_lang('SchoolPlugin') }}</p>
    </div>
</div>


<script>

    const LANG_STRINGS = {
        validationError: "",
        passwordFieldsEmpty: "{{ 'PasswordFieldsCannotBeEmpty'|get_plugin_lang('SchoolPlugin') }}",
        passwordsDoNotMatch: "{{ 'PasswordsDoNotMatch'|get_plugin_lang('SchoolPlugin') }}",
        passwordMinLength: "{{ 'PasswordMinLength'|get_plugin_lang('SchoolPlugin') }}",
        passwordSuccessTitle: "{{ 'PasswordSuccessTitle'|get_plugin_lang('SchoolPlugin') }}",
        passwordSuccess: "{{ 'PasswordSuccessfullyChanged'|get_plugin_lang('SchoolPlugin') }}",
        passwordFailed: "{{ 'PasswordUpdateFailed'|get_plugin_lang('SchoolPlugin') }}",
        accept: "{{ 'Accept'|get_plugin_lang('SchoolPlugin') }}",
        close: "{{ 'Close'|get_plugin_lang('SchoolPlugin') }}",
        processing: "{{ 'Processing'|get_plugin_lang('SchoolPlugin') }}",
        goToLogin: "{{ 'GoToLogin'|get_plugin_lang('SchoolPlugin') }}",
    };

    // URL del endpoint AJAX
    const AJAX_URL = "{{ _p.web_plugin }}school/src/ajax.php";
    const LOGIN_URL = "{{ _p.web }}";


    function showErrorModal(title, message) {
        const modal = document.getElementById('errorModal');
        document.getElementById('modalTitle').textContent = title;
        document.getElementById('modalMessage').textContent = message;
        document.getElementById('btnCloseText').textContent = LANG_STRINGS.accept;
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
        setTimeout(() => document.getElementById('btnCloseModal').focus(), 100);
    }

    function showSuccessModal(title, message) {
        const modal = document.getElementById('successModal');
        document.getElementById('successModalTitle').textContent = title;
        document.getElementById('successModalMessage').textContent = message;
        document.getElementById('btnGoToLoginText').textContent = LANG_STRINGS.goToLogin;
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
        setTimeout(() => document.getElementById('btnGoToLogin').focus(), 100);
    }

    function closeErrorModal() {
        const modal = document.getElementById('errorModal');
        const modalIcon = modal.querySelector('.modal-icon');

        modal.style.display = 'none';
        document.body.style.overflow = '';

        // Restaurar color rojo del icono
        modalIcon.style.fill = '#E9A306';
    }

    function closeSuccessModal() {
        document.getElementById('successModal').style.display = 'none';
        document.body.style.overflow = '';
    }

    // ==========================================
    // FUNCIONES DE LOADING
    // ==========================================

    function showLoading() {
        const loadingOverlay = document.getElementById('loadingOverlay');
        document.getElementById('loadingText').textContent = LANG_STRINGS.processing;
        loadingOverlay.style.display = 'flex';
    }

    function hideLoading() {
        document.getElementById('loadingOverlay').style.display = 'none';
    }

    function updatePassword(formData) {
        showLoading();

        // Agregar el action al FormData
        formData.append('action', 'update_password');

        // Usar fetch API
        fetch(AJAX_URL, {
            method: 'POST',
            body: formData,
            credentials: 'same-origin' // Importante para enviar cookies de sesión
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                hideLoading();

                if (data.success) {
                    // Mostrar modal de éxito
                    showSuccessModal(
                        LANG_STRINGS.passwordSuccessTitle,
                        LANG_STRINGS.passwordSuccess
                    );
                } else {
                    // Mostrar modal de error con el mensaje del servidor
                    showErrorModal(
                        LANG_STRINGS.validationError,
                        data.message || LANG_STRINGS.passwordFailed
                    );
                }
            })
            .catch(error => {
                hideLoading();
                console.error('Error:', error);
                showErrorModal(
                    LANG_STRINGS.validationError,
                    LANG_STRINGS.passwordFailed
                );
            });
    }

    document.addEventListener('DOMContentLoaded', function() {

        // ==========================================
        // EVENTOS DEL MODAL
        // ==========================================

        const btnClose = document.getElementById('btnCloseModal');
        if (btnClose) {
            btnClose.addEventListener('click', closeErrorModal);
        }

        const modal = document.getElementById('errorModal');
        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target.classList.contains('modal-overlay')) {
                    closeErrorModal();
                }
            });
        }

        // Modal de éxito
        const btnGoToLogin = document.getElementById('btnGoToLogin');
        if (btnGoToLogin) {
            btnGoToLogin.addEventListener('click', function() {
                window.location.href = LOGIN_URL;
            });
        }

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                const modal = document.getElementById('errorModal');
                if (modal && modal.style.display === 'flex') {
                    closeErrorModal();
                }
            }
        });
        // Buscar todos los inputs de contraseña
        const passwordInputs = document.querySelectorAll('input[type="password"]');

        passwordInputs.forEach(function(input) {
            const formGroup = input.closest('.form-group');

            if (!formGroup) return;

            // Crear el botón de mostrar/ocultar
            const toggleBtn = document.createElement('button');
            toggleBtn.type = 'button';
            toggleBtn.className = 'toggle-password-btn';
            toggleBtn.setAttribute('aria-label', 'Mostrar contraseña');

            // Icono de ojo cerrado (password oculto)
            const eyeOffIcon = `
            <svg class="eye-off" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                <path d="M12 7c2.76 0 5 2.24 5 5 0 .65-.13 1.26-.36 1.83l2.92 2.92c1.51-1.26 2.7-2.89 3.43-4.75-1.73-4.39-6-7.5-11-7.5-1.4 0-2.74.25-3.98.7l2.16 2.16C10.74 7.13 11.35 7 12 7zM2 4.27l2.28 2.28.46.46C3.08 8.3 1.78 10.02 1 12c1.73 4.39 6 7.5 11 7.5 1.55 0 3.03-.3 4.38-.84l.42.42L19.73 22 21 20.73 3.27 3 2 4.27zM7.53 9.8l1.55 1.55c-.05.21-.08.43-.08.65 0 1.66 1.34 3 3 3 .22 0 .44-.03.65-.08l1.55 1.55c-.67.33-1.41.53-2.2.53-2.76 0-5-2.24-5-5 0-.79.2-1.53.53-2.2zm4.31-.78l3.15 3.15.02-.16c0-1.66-1.34-3-3-3l-.17.01z"/>
            </svg>
        `;

            // Icono de ojo abierto (password visible)
            const eyeOnIcon = `
            <svg class="eye-on" style="display: none;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>
            </svg>
        `;

            toggleBtn.innerHTML = eyeOffIcon + eyeOnIcon;

            // Insertar el botón después del input
            input.parentNode.insertBefore(toggleBtn, input.nextSibling);

            // Agregar evento click al botón
            toggleBtn.addEventListener('click', function() {
                const eyeOff = this.querySelector('.eye-off');
                const eyeOn = this.querySelector('.eye-on');

                if (input.type === 'password') {
                    input.type = 'text';
                    eyeOff.style.display = 'none';
                    eyeOn.style.display = 'block';
                    this.setAttribute('aria-label', 'Ocultar contraseña');
                } else {
                    input.type = 'password';
                    eyeOff.style.display = 'block';
                    eyeOn.style.display = 'none';
                    this.setAttribute('aria-label', 'Mostrar contraseña');
                }
            });
        });

        // ==========================================
        // MOVER LABELS DENTRO DEL FORM-GROUP
        // ==========================================

        const allFormGroups = document.querySelectorAll('.form-group');

        allFormGroups.forEach(function(formGroup) {
            const label = formGroup.querySelector('.form-label');
            const input = formGroup.querySelector('input[type="password"], input[type="text"]');

            if (label && input) {
                // Mover el label después del input (para que funcione el CSS)
                input.parentNode.insertBefore(label, input.nextSibling);

                // Agregar clase cuando el input tiene contenido
                function checkContent() {
                    if (input.value.trim() !== '') {
                        formGroup.classList.add('has-content');
                    } else {
                        formGroup.classList.remove('has-content');
                    }
                }

                // Verificar al cargar
                checkContent();

                // Verificar cuando cambia el input
                input.addEventListener('input', checkContent);
                input.addEventListener('change', checkContent);
            }
        });

        // ==========================================
        // VALIDACIÓN OPCIONAL (puedes remover si no la necesitas)
        // ==========================================

        const form = document.getElementById('reset');
        if (form) {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                const pass1 = document.getElementById('reset_pass1');
                const pass2 = document.getElementById('pass2');

                // Limpiar errores previos
                document.querySelectorAll('.form-group').forEach(function(group) {
                    group.classList.remove('has-error');
                });

                let isValid = true;
                let errorMessage = '';

                // Validar que los campos no estén vacíos
                if (!pass1 || !pass1.value.trim()) {
                    if (pass1) pass1.closest('.form-group').classList.add('has-error');
                    errorMessage = LANG_STRINGS.passwordFieldsEmpty;
                    isValid = false;
                }
                else if (!pass2 || !pass2.value.trim()) {
                    if (pass2) pass2.closest('.form-group').classList.add('has-error');
                    errorMessage = LANG_STRINGS.passwordFieldsEmpty;
                    isValid = false;
                }
                // Validar longitud mínima
                else if (pass1.value.length < 4) {
                    pass1.closest('.form-group').classList.add('has-error');
                    errorMessage = LANG_STRINGS.passwordMinLength;
                    isValid = false;
                }
                // Validar que coincidan
                else if (pass1.value !== pass2.value) {
                    pass2.closest('.form-group').classList.add('has-error');
                    errorMessage = LANG_STRINGS.passwordsDoNotMatch;
                    isValid = false;
                }

                if (!isValid) {
                    showErrorModal(LANG_STRINGS.validationError, errorMessage);
                    return false;
                }
                // Si la validación pasa, enviar formulario con AJAX
                const formData = new FormData(form);
                updatePassword(formData);
            });
        }
    });
</script>



