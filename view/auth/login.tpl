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

{# ===== Botón flotante de soporte ===== #}
<button id="btnOpenSupport" data-toggle="modal" data-target="#supportModal"
        title="¿Necesitas ayuda?"
        style="position:fixed;bottom:28px;right:28px;z-index:1050;
               background:#fff;
               color:#1a1a2e;border:none;border-radius:50px;
               padding:14px 22px;font-size:15px;font-weight:700;
               box-shadow:0 6px 24px rgba(0,0,0,.22);
               cursor:pointer;display:flex;align-items:center;gap:10px;
               animation:sp-pulse 2s ease-in-out infinite;">
    <i class="fas fa-headset" style="font-size:20px;color:#4e73df;"></i>
    <span>¿Necesitas ayuda?</span>
</button>

<style>
@keyframes sp-pulse {
    0%,100% { box-shadow:0 6px 24px rgba(0,0,0,.20); transform:scale(1); }
    50%      { box-shadow:0 10px 32px rgba(0,0,0,.35); transform:scale(1.04); }
}
#btnOpenSupport:hover {
    animation: none;
    transform: scale(1.06);
    box-shadow: 0 10px 36px rgba(0,0,0,.30);
    transition: transform .15s, box-shadow .15s;
}
</style>

{# ===== Modal de Soporte Público ===== #}
<div class="modal fade" id="supportModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content shadow-lg border-0">
            <div class="modal-header bg-primary text-white py-3">
                <h6 class="modal-title mb-0">
                    <i class="fas fa-headset mr-2"></i>Soporte técnico
                </h6>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body px-4 py-3" id="supportFormWrapper">
                {% if support_attention_message %}
                <div class="alert mb-3 py-2 px-3 d-flex align-items-start"
                     style="background:#fff8e1;border-left:4px solid #f7931e;font-size:13px;">
                    <i class="fas fa-clock mr-2 mt-1" style="color:#f7931e;flex-shrink:0;"></i>
                    <span>{{ support_attention_message }}</span>
                </div>
                {% endif %}
                <p class="text-muted small mb-3">
                    Completa el formulario y nuestro equipo se pondrá en contacto contigo.
                </p>

                <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">Nombre completo *</label>
                    <input type="text" id="sp_name" class="form-control form-control-sm"
                           placeholder="Tu nombre" maxlength="150">
                    <div class="invalid-feedback" id="sp_name_err"></div>
                </div>

                <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">Correo electrónico *</label>
                    <input type="email" id="sp_email" class="form-control form-control-sm"
                           placeholder="tu@correo.com" maxlength="150">
                    <div class="invalid-feedback" id="sp_email_err"></div>
                </div>

                <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">
                        <i class="fab fa-whatsapp text-success mr-1"></i>WhatsApp
                        <span class="text-muted font-weight-normal">(opcional)</span>
                    </label>
                    <input type="tel" id="sp_whatsapp" class="form-control form-control-sm"
                           placeholder="Ej: +51987654321" maxlength="20">
                </div>

                <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">Categoría</label>
                    <select id="sp_category" class="form-control form-control-sm">
                        {% for cat in support_categories %}
                        <option value="{{ cat.name|lower|replace({' ': '_', '/': '', 'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u'}) }}"
                                data-template="{{ cat.template|default('')|e }}">{{ cat.name }}</option>
                        {% endfor %}
                    </select>
                </div>

                <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">Asunto *</label>
                    <input type="text" id="sp_subject" class="form-control form-control-sm"
                           placeholder="Describe brevemente el problema" maxlength="255">
                    <div class="invalid-feedback" id="sp_subject_err"></div>
                </div>

                <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">Mensaje *</label>
                    <textarea id="sp_body" name="sp_body"></textarea>
                    <div class="text-danger small mt-1 d-none" id="sp_body_err"></div>
                </div>

                <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1" id="sp_captcha_label">
                        Cargando verificación...
                    </label>
                    <input type="number" id="sp_captcha" class="form-control form-control-sm"
                           placeholder="Respuesta" min="0" max="99" style="max-width:110px;">
                    <div class="invalid-feedback" id="sp_captcha_err"></div>
                </div>

                <div id="sp_global_err" class="alert alert-danger py-2 d-none small"></div>
            </div>

            <div class="modal-body text-center py-5 d-none" id="supportSuccessWrapper">
                <i class="fas fa-check-circle fa-3x text-success mb-3 d-block"></i>
                <h6 class="font-weight-bold">¡Ticket enviado!</h6>
                <p class="text-muted small mb-0">
                    Hemos recibido tu solicitud. Te responderemos al correo indicado a la brevedad.
                </p>
            </div>

            <div class="modal-footer py-2" id="supportFooter">
                {% if support_whatsapp %}
                <a href="https://wa.me/{{ support_whatsapp|replace({'+': ''}) }}"
                   target="_blank" rel="noopener"
                   class="btn btn-sm btn-success mr-auto"
                   style="background:#25D366;border-color:#25D366;">
                    <i class="fab fa-whatsapp mr-1"></i>WhatsApp directo
                </a>
                {% endif %}
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-sm btn-primary" id="btnSubmitSupport">
                    <i class="fas fa-paper-plane mr-1"></i>Enviar
                </button>
            </div>
        </div>
    </div>
</div>

<script src="{{ web_path }}web/assets/ckeditor/ckeditor.js"></script>
<script>
var spAjaxUrl = '{{ support_public_ajax_url }}';

function spInitEditor() {
    if (CKEDITOR.instances.sp_body) return;
    CKEDITOR.replace('sp_body', {
        language: 'es',
        toolbar: [
            { name: 'basicstyles', items: ['Bold','Italic','Underline','Strike','RemoveFormat'] },
            { name: 'paragraph',   items: ['NumberedList','BulletedList','Blockquote'] },
            { name: 'links',       items: ['Link','Unlink'] },
            { name: 'colors',      items: ['TextColor','BGColor'] },
        ],
        height: 130,
        resize_enabled: false,
        removePlugins: 'elementspath',
    });
}

function spLoadTemplate() {
    var sel = document.getElementById('sp_category');
    var opt = sel.options[sel.selectedIndex];
    var tpl = (opt ? opt.getAttribute('data-template') : '') || '';
    if (tpl && CKEDITOR.instances.sp_body) {
        var current = CKEDITOR.instances.sp_body.getData().replace(/<[^>]+>/g,'').trim();
        if (!current) CKEDITOR.instances.sp_body.setData(tpl.replace(/\n/g,'<br>'));
    }
}

$('#supportModal').on('shown.bs.modal', function () {
    spInitEditor();
    loadCaptcha();
    setTimeout(spLoadTemplate, 300);
});

document.getElementById('sp_category').addEventListener('change', function () {
    if (CKEDITOR.instances.sp_body) {
        var sel = this;
        var tpl = (sel.options[sel.selectedIndex].getAttribute('data-template') || '').replace(/\n/g,'<br>');
        CKEDITOR.instances.sp_body.setData(tpl);
    }
});

$('#supportModal').on('hidden.bs.modal', function () {
    document.getElementById('supportFormWrapper').classList.remove('d-none');
    document.getElementById('supportSuccessWrapper').classList.add('d-none');
    document.getElementById('supportFooter').classList.remove('d-none');
    ['sp_name','sp_email','sp_subject','sp_captcha'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) { el.value = ''; el.classList.remove('is-invalid'); }
    });
    if (CKEDITOR.instances.sp_body) CKEDITOR.instances.sp_body.setData('');
    document.getElementById('sp_body_err').classList.add('d-none');
    document.getElementById('sp_global_err').classList.add('d-none');
    loadCaptcha();
});

function loadCaptcha() {
    var lbl = document.getElementById('sp_captcha_label');
    if (lbl) lbl.textContent = 'Cargando...';
    document.getElementById('sp_captcha').value = '';
    var fd = new FormData();
    fd.append('action', 'get_captcha');
    fetch(spAjaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success && lbl) lbl.textContent = d.question;
        });
}

document.getElementById('btnSubmitSupport').addEventListener('click', function () {
    var btn = this;
    clearSpErrors();

    var name      = document.getElementById('sp_name').value.trim();
    var email     = document.getElementById('sp_email').value.trim();
    var whatsapp  = document.getElementById('sp_whatsapp').value.trim();
    var subject   = document.getElementById('sp_subject').value.trim();
    var category  = document.getElementById('sp_category').value;
    var body      = CKEDITOR.instances.sp_body ? CKEDITOR.instances.sp_body.getData().trim() : '';
    var captcha   = document.getElementById('sp_captcha').value.trim();
    var emptyBody = !body || body === '<p>&nbsp;</p>' || body === '<p></p>';

    var valid = true;
    if (!name)    { setSpError('sp_name',    'sp_name_err',    'Ingresa tu nombre.');                  valid = false; }
    if (!email)   { setSpError('sp_email',   'sp_email_err',   'Ingresa tu correo.');                  valid = false; }
    if (!subject) { setSpError('sp_subject', 'sp_subject_err', 'El asunto es obligatorio.');           valid = false; }
    if (emptyBody){ setSpError('sp_body',    'sp_body_err',    'El mensaje es obligatorio.');          valid = false; }
    if (!captcha) { setSpError('sp_captcha', 'sp_captcha_err', 'Responde la pregunta de seguridad.'); valid = false; }
    if (!valid) return;

    btn.disabled = true;
    var fd = new FormData();
    fd.append('action',           'submit_public_ticket');
    fd.append('guest_name',      name);
    fd.append('guest_email',     email);
    fd.append('guest_whatsapp',  whatsapp);
    fd.append('subject',         subject);
    fd.append('category',        category);
    fd.append('body',            body);
    fd.append('captcha',         captcha);

    fetch(spAjaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            btn.disabled = false;
            if (d.success) {
                document.getElementById('supportFormWrapper').classList.add('d-none');
                document.getElementById('supportSuccessWrapper').classList.remove('d-none');
                document.getElementById('supportFooter').classList.add('d-none');
            } else {
                var fieldMap = {
                    captcha:      ['sp_captcha', 'sp_captcha_err'],
                    guest_name:   ['sp_name',    'sp_name_err'],
                    guest_email:  ['sp_email',   'sp_email_err'],
                    subject:      ['sp_subject', 'sp_subject_err'],
                    body:         ['sp_body',    'sp_body_err'],
                };
                if (d.field && fieldMap[d.field]) {
                    setSpError(fieldMap[d.field][0], fieldMap[d.field][1], d.message);
                    if (d.field === 'captcha') loadCaptcha();
                } else {
                    var gl = document.getElementById('sp_global_err');
                    gl.textContent = d.message || 'Error al enviar. Intenta de nuevo.';
                    gl.classList.remove('d-none');
                }
            }
        })
        .catch(function() {
            btn.disabled = false;
            var gl = document.getElementById('sp_global_err');
            gl.textContent = 'Error de conexión. Intenta de nuevo.';
            gl.classList.remove('d-none');
        });
});

function setSpError(inputId, errId, msg) {
    var el = document.getElementById(inputId);
    if (el) el.classList.add('is-invalid');
    var err = document.getElementById(errId);
    if (err) { err.textContent = msg; err.classList.remove('d-none'); }
    // Para CKEditor: borde rojo en el iframe
    if (inputId === 'sp_body' && CKEDITOR.instances.sp_body) {
        var ckBox = CKEDITOR.instances.sp_body.container.$;
        if (ckBox) ckBox.style.border = '1px solid #dc3545';
    }
}

function clearSpErrors() {
    ['sp_name','sp_email','sp_subject','sp_captcha'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) el.classList.remove('is-invalid');
    });
    var bodyErr = document.getElementById('sp_body_err');
    if (bodyErr) bodyErr.classList.add('d-none');
    if (CKEDITOR.instances.sp_body) {
        var ckBox = CKEDITOR.instances.sp_body.container.$;
        if (ckBox) ckBox.style.border = '';
    }
    document.getElementById('sp_global_err').classList.add('d-none');
}
</script>

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
