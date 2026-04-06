<div class="d-flex align-items-center justify-content-between mb-4 flex-wrap" style="gap:10px;">
    <div>
        <h4 class="mb-1 font-weight-bold text-dark">
            <i class="fab fa-google text-danger mr-2"></i>Sincronización Google Workspace
        </h4>
        {% if active_year %}
        <p class="mb-0 text-muted small">Año académico activo: <strong>{{ active_year.name }}</strong></p>
        {% endif %}
    </div>
    <a href="{{ settings_url }}" class="btn btn-sm btn-outline-secondary">
        <i class="fas fa-cog mr-1"></i> Configuración
    </a>
</div>

{% if not google_configured %}
<div class="alert alert-warning">
    <i class="fas fa-exclamation-triangle mr-2"></i>
    <strong>Google Workspace no está configurado.</strong>
    Configure las credenciales de Service Account en
    <a href="{{ settings_url }}">Configuración &rarr; Google Workspace</a>.
</div>
{% else %}

{# Info de dominio #}
<div class="alert alert-info py-2 mb-4" style="font-size:13px;">
    <i class="fab fa-google mr-1"></i>
    Dominio: <strong>{{ google_domain }}</strong> &mdash;
    Admin: <code>{{ google_admin_email }}</code>
</div>

{# Datos para filtros cascada (JSON) #}
<script>
var ALL_GRADES   = {{ grades|json_encode|raw }};
var ALL_SECTIONS = {{ sections|json_encode|raw }};
</script>

{# ===== PESTAÑAS ===== #}
<ul class="nav nav-tabs mb-0" id="gsTabs" role="tablist">
    <li class="nav-item">
        <a class="nav-link active" id="tab-alumnos-lnk" data-toggle="tab" href="#tab-alumnos" role="tab">
            <i class="fas fa-user-graduate mr-1"></i> Alumnos
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link" id="tab-personal-lnk" data-toggle="tab" href="#tab-personal" role="tab">
            <i class="fas fa-users mr-1"></i> Personal
        </a>
    </li>
</ul>

<div class="tab-content border border-top-0 rounded-bottom bg-white p-3 mb-4" id="gsTabContent">

    {# ===== TAB ALUMNOS ===== #}
    <div class="tab-pane fade show active" id="tab-alumnos" role="tabpanel">

        {# Filtros alumnos #}
        <div class="card shadow-sm border-0 mb-3 mt-2">
            <div class="card-body py-3">
                <div class="d-flex align-items-end flex-wrap" style="gap:12px;">
                    <div>
                        <label class="mb-1 small font-weight-bold text-muted">Nivel</label>
                        <select id="filter-level" class="form-control form-control-sm" style="min-width:150px;">
                            <option value="">— Todos —</option>
                            {% for l in levels %}
                            <option value="{{ l.id }}">{{ l.name }}</option>
                            {% endfor %}
                        </select>
                    </div>
                    <div>
                        <label class="mb-1 small font-weight-bold text-muted">Grado</label>
                        <select id="filter-grade" class="form-control form-control-sm" style="min-width:160px;">
                            <option value="">— Todos —</option>
                            {% for g in grades %}
                            <option value="{{ g.id }}" data-level="{{ g.level_id }}">{{ g.name }}</option>
                            {% endfor %}
                        </select>
                    </div>
                    <div>
                        <label class="mb-1 small font-weight-bold text-muted">Sección</label>
                        <select id="filter-section" class="form-control form-control-sm" style="min-width:130px;">
                            <option value="">— Todas —</option>
                            {% for s in sections %}
                            <option value="{{ s.id }}">{{ s.name }}</option>
                            {% endfor %}
                        </select>
                    </div>
                    <div class="align-self-end">
                        <button id="btn-check" class="btn btn-primary btn-sm" {% if not active_year %}disabled{% endif %}>
                            <i class="fas fa-search mr-1"></i> Verificar cuentas
                        </button>
                    </div>
                    <div class="align-self-end">
                        <button id="btn-create-missing" class="btn btn-success btn-sm d-none">
                            <i class="fab fa-google mr-1"></i> Crear cuentas faltantes
                        </button>
                    </div>
                    <div class="align-self-end">
                        <span id="check-spinner" class="d-none">
                            <i class="fas fa-spinner fa-spin text-primary"></i>
                            <span class="text-muted small ml-1">Verificando...</span>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        {# Resultados alumnos #}
        <div id="results-area" class="d-none">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-2 d-flex align-items-center justify-content-between flex-wrap" style="gap:8px;">
                    <span class="font-weight-bold text-dark small">
                        <i class="fas fa-list mr-1 text-muted"></i>
                        <span id="total-count">0</span> alumnos
                    </span>
                    <div class="d-flex align-items-center" style="gap:6px; font-size:12px;">
                        <span class="badge badge-success px-2 py-1"><i class="fas fa-check mr-1"></i><span id="cnt-yes">0</span></span>
                        <span class="badge badge-danger px-2 py-1"><i class="fas fa-times mr-1"></i><span id="cnt-no">0</span></span>
                        <span class="badge badge-secondary px-2 py-1"><i class="fas fa-exclamation mr-1"></i><span id="cnt-err">0</span></span>
                    </div>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover table-sm align-middle mb-0">
                            <thead class="thead-light">
                                <tr>
                                    <th>Alumno</th>
                                    <th>Grado / Sección</th>
                                    <th>Correo</th>
                                    <th class="text-center">Estado Google</th>
                                    <th class="text-center">Acción</th>
                                </tr>
                            </thead>
                            <tbody id="google-tbody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {# ===== TAB PERSONAL ===== #}
    <div class="tab-pane fade" id="tab-personal" role="tabpanel">

        {# Filtro personal #}
        <div class="card shadow-sm border-0 mb-3 mt-2">
            <div class="card-body py-3">
                <div class="d-flex align-items-end flex-wrap" style="gap:12px;">
                    <div>
                        <label class="mb-1 small font-weight-bold text-muted">Rol</label>
                        <select id="staff-filter-role" class="form-control form-control-sm" style="min-width:180px;">
                            <option value="">— Todos —</option>
                            <option value="docente">Docente</option>
                            <option value="administrativo">Administrativo</option>
                            <option value="secretaria">Secretaria</option>
                            <option value="auxiliar">Auxiliar</option>
                            <option value="admin">Administrador</option>
                        </select>
                    </div>
                    <div class="align-self-end">
                        <button id="btn-check-staff" class="btn btn-primary btn-sm">
                            <i class="fas fa-search mr-1"></i> Verificar cuentas
                        </button>
                    </div>
                    <div class="align-self-end">
                        <button id="btn-create-missing-staff" class="btn btn-success btn-sm d-none">
                            <i class="fab fa-google mr-1"></i> Crear cuentas faltantes
                        </button>
                    </div>
                    <div class="align-self-end">
                        <span id="check-spinner-staff" class="d-none">
                            <i class="fas fa-spinner fa-spin text-primary"></i>
                            <span class="text-muted small ml-1">Verificando...</span>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        {# Resultados personal #}
        <div id="results-area-staff" class="d-none">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-2 d-flex align-items-center justify-content-between flex-wrap" style="gap:8px;">
                    <span class="font-weight-bold text-dark small">
                        <i class="fas fa-list mr-1 text-muted"></i>
                        <span id="staff-total-count">0</span> usuarios
                    </span>
                    <div class="d-flex align-items-center" style="gap:6px; font-size:12px;">
                        <span class="badge badge-success px-2 py-1"><i class="fas fa-check mr-1"></i><span id="staff-cnt-yes">0</span></span>
                        <span class="badge badge-danger px-2 py-1"><i class="fas fa-times mr-1"></i><span id="staff-cnt-no">0</span></span>
                        <span class="badge badge-secondary px-2 py-1"><i class="fas fa-exclamation mr-1"></i><span id="staff-cnt-err">0</span></span>
                    </div>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover table-sm align-middle mb-0">
                            <thead class="thead-light">
                                <tr>
                                    <th>Nombre</th>
                                    <th>Rol</th>
                                    <th>Correo</th>
                                    <th class="text-center">Estado Google</th>
                                    <th class="text-center">Acción</th>
                                </tr>
                            </thead>
                            <tbody id="staff-tbody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>{# /tab-content #}

{# Modal: Crear cuenta (confirmación con opciones) #}
<div class="modal fade" id="createConfirmModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title font-weight-bold"><i class="fab fa-google mr-1 text-success"></i> Crear cuenta Google Workspace</h6>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <p class="mb-2">Se creará la cuenta para:</p>
                <div class="alert alert-light py-2 mb-3">
                    <strong id="cc-name"></strong><br>
                    <span class="text-muted" id="cc-email" style="font-size:13px;"></span>
                </div>
                <div class="form-group mb-2">
                    <label class="font-weight-bold">Contraseña inicial</label>
                    <div class="input-group input-group-sm">
                        <input type="text" class="form-control" id="cc-password" style="font-family:monospace;">
                        <div class="input-group-append">
                            <button type="button" class="btn btn-outline-secondary" id="cc-toggle-pw" title="Mostrar/ocultar">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>
                    <small class="form-text text-muted">Por defecto: <code>play@</code> + DNI del alumno.</small>
                </div>
                <div class="custom-control custom-switch mt-2">
                    <input type="checkbox" class="custom-control-input" id="cc-change-next" checked>
                    <label class="custom-control-label" for="cc-change-next">
                        Solicitar cambio de contraseña al primer inicio de sesión
                    </label>
                </div>
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-sm btn-success" id="cc-confirm-btn">
                    <i class="fab fa-google mr-1"></i> Crear cuenta
                </button>
            </div>
        </div>
    </div>
</div>

{# Modal: Resultado de creación #}
<div class="modal fade" id="createResultModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title font-weight-bold"><i class="fab fa-google mr-1 text-success"></i> Cuenta creada</h6>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body" id="createResultBody"></div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

{# Modal: Cambiar contraseña #}
<div class="modal fade" id="changePwModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title font-weight-bold"><i class="fas fa-key mr-1 text-warning"></i> Cambiar contraseña Google</h6>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="alert alert-light py-2 mb-3">
                    <strong id="cpw-name"></strong><br>
                    <span class="text-muted" id="cpw-email" style="font-size:13px;"></span>
                </div>
                <div class="form-group mb-2">
                    <label class="font-weight-bold">Nueva contraseña</label>
                    <div class="input-group input-group-sm">
                        <input type="password" class="form-control" id="cpw-password" placeholder="Mínimo 6 caracteres">
                        <div class="input-group-append">
                            <button type="button" class="btn btn-outline-secondary" id="cpw-toggle-pw" title="Mostrar/ocultar">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>
                </div>
                <div class="custom-control custom-switch mt-2">
                    <input type="checkbox" class="custom-control-input" id="cpw-change-next" checked>
                    <label class="custom-control-label" for="cpw-change-next">
                        Solicitar cambio de contraseña al próximo inicio de sesión
                    </label>
                </div>
                <div id="cpw-result" class="mt-3 d-none"></div>
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cerrar</button>
                <button type="button" class="btn btn-sm btn-warning" id="cpw-confirm-btn">
                    <i class="fas fa-save mr-1"></i> Guardar contraseña
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var AJAX_GOOGLE  = '{{ ajax_google_url }}';
var YEAR_ID      = {{ year_id }};
var allItems     = [];
var pendingUserId = null;
var pendingBtnEl  = null;
var pendingCb     = null;

// ---- Filtros cascada ----
document.getElementById('filter-level').addEventListener('change', function() {
    var levelId = this.value;
    var gradeEl = document.getElementById('filter-grade');
    var current = gradeEl.value;
    Array.from(gradeEl.options).forEach(function(opt) {
        if (!opt.value) return;
        opt.hidden = levelId ? opt.dataset.level !== levelId : false;
    });
    if (gradeEl.options[gradeEl.selectedIndex] && gradeEl.options[gradeEl.selectedIndex].hidden) {
        gradeEl.value = '';
    }
});

// ---- Verificar cuentas ----
document.getElementById('btn-check').addEventListener('click', function () {
    loadData(YEAR_ID,
        document.getElementById('filter-level').value,
        document.getElementById('filter-grade').value,
        document.getElementById('filter-section').value);
});

function loadData(yearId, levelId, gradeId, sectionId) {
    document.getElementById('btn-check').disabled = true;
    document.getElementById('check-spinner').classList.remove('d-none');
    document.getElementById('results-area').classList.add('d-none');
    document.getElementById('btn-create-missing').classList.add('d-none');

    ajaxPost({ action: 'check_accounts', year_id: yearId || '', level_id: levelId || '', grade_id: gradeId || '', section_id: sectionId || '' })
    .then(function(resp) {
        document.getElementById('btn-check').disabled = false;
        document.getElementById('check-spinner').classList.add('d-none');
        if (!resp.success) { alert('Error: ' + (resp.error || 'Error desconocido')); return; }
        allItems = resp.items || [];
        renderTable(allItems);
        document.getElementById('results-area').classList.remove('d-none');
        updateMissingBtn();
    })
    .catch(function(e) {
        document.getElementById('btn-check').disabled = false;
        document.getElementById('check-spinner').classList.add('d-none');
        alert('Error de conexión: ' + e.message);
    });
}

// ---- Render tabla ----
function renderTable(items) {
    var cntYes = 0, cntNo = 0, cntErr = 0;
    var html = '';
    items.forEach(function(item) {
        var statusBadge = '', actionBtn = '';
        if (item.google_exists === 'yes') {
            cntYes++;
            statusBadge = '<span class="badge badge-success"><i class="fas fa-check mr-1"></i>Activa</span>';
            actionBtn = '<button class="btn btn-xs btn-sm btn-outline-warning btn-change-pw" ' +
                        'data-user-id="' + item.user_id + '" ' +
                        'data-email="' + escHtml(item.email) + '" ' +
                        'data-name="' + escHtml(item.full_name) + '">' +
                        '<i class="fas fa-key mr-1"></i>Contraseña</button>';
        } else if (item.google_exists === 'no') {
            cntNo++;
            statusBadge = '<span class="badge badge-danger"><i class="fas fa-times mr-1"></i>Sin cuenta</span>';
            actionBtn = '<button class="btn btn-xs btn-sm btn-outline-success btn-create-one" ' +
                        'data-user-id="' + item.user_id + '" ' +
                        'data-email="' + escHtml(item.email) + '" ' +
                        'data-name="' + escHtml(item.full_name) + '" ' +
                        'data-dni="' + escHtml(item.dni || '') + '">' +
                        '<i class="fab fa-google mr-1"></i>Crear</button>';
        } else {
            cntErr++;
            statusBadge = '<span class="badge badge-secondary"><i class="fas fa-exclamation mr-1"></i>Error</span>';
        }
        var section = item.section ? ' Sec. ' + escHtml(item.section) : '';
        html += '<tr id="grow-' + item.user_id + '">' +
            '<td><div class="font-weight-bold" style="font-size:13px;">' + escHtml(item.full_name) + '</div>' +
                '<div class="text-muted" style="font-size:11px;">' + escHtml(item.username) + '</div></td>' +
            '<td style="font-size:12px;">' + escHtml(item.grade) + section + '</td>' +
            '<td style="font-size:12px;">' + escHtml(item.email) + '</td>' +
            '<td class="text-center" id="gstatus-' + item.user_id + '">' + statusBadge + '</td>' +
            '<td class="text-center" id="gaction-' + item.user_id + '">' + actionBtn + '</td>' +
            '</tr>';
    });
    document.getElementById('google-tbody').innerHTML = html ||
        '<tr><td colspan="5" class="text-center text-muted py-4">Sin alumnos.</td></tr>';
    document.getElementById('total-count').textContent = items.length;
    document.getElementById('cnt-yes').textContent = cntYes;
    document.getElementById('cnt-no').textContent  = cntNo;
    document.getElementById('cnt-err').textContent  = cntErr;
}

// ---- Click en tabla ----
document.getElementById('google-tbody').addEventListener('click', function(e) {
    var btnCreate = e.target.closest('.btn-create-one');
    var btnPw     = e.target.closest('.btn-change-pw');
    if (btnCreate) openCreateConfirm(btnCreate);
    if (btnPw)     openChangePw(btnPw);
});

// ---- Modal confirmar creación ----
function openCreateConfirm(btnEl) {
    var userId = btnEl.getAttribute('data-user-id');
    var email  = btnEl.getAttribute('data-email');
    var name   = btnEl.getAttribute('data-name');
    var dni    = btnEl.getAttribute('data-dni') || '';
    var defPw  = 'play@' + (dni || userId);

    document.getElementById('cc-name').textContent  = name;
    document.getElementById('cc-email').textContent = email;
    document.getElementById('cc-password').value    = defPw;
    document.getElementById('cc-password').type     = 'text';
    document.getElementById('cc-change-next').checked = true;

    pendingUserId = userId;
    pendingBtnEl  = btnEl;
    pendingCb     = null;
    $('#createConfirmModal').modal('show');
}

document.getElementById('cc-toggle-pw').addEventListener('click', function() {
    var inp = document.getElementById('cc-password');
    inp.type = inp.type === 'text' ? 'password' : 'text';
    this.querySelector('i').classList.toggle('fa-eye');
    this.querySelector('i').classList.toggle('fa-eye-slash');
});

document.getElementById('cc-confirm-btn').addEventListener('click', function() {
    var password       = document.getElementById('cc-password').value.trim();
    var changeNext     = document.getElementById('cc-change-next').checked;
    if (!password) { alert('Ingresa una contraseña.'); return; }
    $('#createConfirmModal').modal('hide');
    doCreateAccount(pendingUserId, password, changeNext, pendingBtnEl, pendingCb);
});

// ---- Bulk crear faltantes ----
document.getElementById('btn-create-missing').addEventListener('click', function() {
    var missing = allItems.filter(function(i) { return i.google_exists === 'no'; });
    if (!missing.length) { alert('No hay cuentas faltantes.'); return; }
    if (!confirm('¿Crear ' + missing.length + ' cuenta(s) con contraseña play@DNI?\n\nSe solicitará cambio de contraseña al primer login.')) return;
    var btn = this;
    btn.disabled = true;
    var idx = 0;
    function next() {
        if (idx >= missing.length) { btn.disabled = false; return; }
        var item = missing[idx++];
        var defPw = 'play@' + (item.dni || item.user_id);
        var rowBtn = document.querySelector('#gaction-' + item.user_id + ' .btn-create-one');
        doCreateAccount(item.user_id, defPw, true, rowBtn, next);
    }
    next();
});

// ---- Ejecutar creación ----
function doCreateAccount(userId, password, changeAtNextLogin, btnEl, callback) {
    if (btnEl) { btnEl.disabled = true; btnEl.innerHTML = '<i class="fas fa-spinner fa-spin"></i>'; }
    fetch(AJAX_GOOGLE, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            action: 'create_account',
            user_id: userId,
            password_override: password,
            change_at_next_login: changeAtNextLogin ? '1' : ''
        }).toString()
    })
    .then(function(r) { return r.json(); })
    .then(function(resp) {
        var statusEl = document.getElementById('gstatus-' + userId);
        var actionEl = document.getElementById('gaction-' + userId);
        if (resp.success) {
            if (statusEl) statusEl.innerHTML = '<span class="badge badge-success"><i class="fas fa-check mr-1"></i>Activa</span>';
            if (actionEl) {
                // Get item data for change-pw button
                var item = allItems.find(function(i) { return String(i.user_id) === String(userId); });
                actionEl.innerHTML = '<button class="btn btn-xs btn-sm btn-outline-warning btn-change-pw" ' +
                    'data-user-id="' + userId + '" ' +
                    'data-email="' + escHtml(resp.email || '') + '" ' +
                    'data-name="' + escHtml(item ? item.full_name : '') + '">' +
                    '<i class="fas fa-key mr-1"></i>Contraseña</button>';
            }
            allItems.forEach(function(i) { if (String(i.user_id) === String(userId)) i.google_exists = 'yes'; });
            var no  = Math.max(0, parseInt(document.getElementById('cnt-no').textContent)  - 1);
            var yes =             parseInt(document.getElementById('cnt-yes').textContent) + 1;
            document.getElementById('cnt-no').textContent  = no;
            document.getElementById('cnt-yes').textContent = yes;
            if (resp.created) showCreateResult(resp.email, resp.password, changeAtNextLogin);
        } else {
            if (btnEl) { btnEl.disabled = false; btnEl.innerHTML = '<i class="fab fa-google mr-1"></i>Crear'; }
            if (statusEl) statusEl.insertAdjacentHTML('beforeend',
                '<br><small class="text-danger">' + escHtml(resp.error || 'Error') + '</small>');
        }
        updateMissingBtn();
        if (callback) callback(resp, changeAtNextLogin);
    })
    .catch(function() {
        if (btnEl) { btnEl.disabled = false; btnEl.innerHTML = '<i class="fab fa-google mr-1"></i>Crear'; }
        if (callback) callback();
    });
}

function showCreateResult(email, password, changeNext) {
    document.getElementById('createResultBody').innerHTML =
        '<div class="text-center mb-3"><i class="fab fa-google fa-3x text-success"></i></div>' +
        '<div class="table-responsive"><table class="table table-sm table-bordered mb-2">' +
        '<tr><th style="width:40%">Correo</th><td><code>' + escHtml(email) + '</code></td></tr>' +
        '<tr><th>Contraseña</th><td><code class="text-danger font-weight-bold">' + escHtml(password) + '</code></td></tr>' +
        '<tr><th>Cambiar al entrar</th><td>' + (changeNext ? '<span class="badge badge-warning">Sí</span>' : '<span class="badge badge-secondary">No</span>') + '</td></tr>' +
        '</table></div>' +
        '<p class="text-muted small mb-0"><i class="fas fa-info-circle mr-1"></i>Guarda esta contraseña para entregársela al alumno.</p>';
    $('#createResultModal').modal('show');
}

// ---- Modal cambiar contraseña ----
function openChangePw(btnEl) {
    var userId = btnEl.getAttribute('data-user-id');
    var email  = btnEl.getAttribute('data-email');
    var name   = btnEl.getAttribute('data-name');
    document.getElementById('cpw-name').textContent  = name;
    document.getElementById('cpw-email').textContent = email;
    document.getElementById('cpw-password').value    = '';
    document.getElementById('cpw-password').type     = 'password';
    document.getElementById('cpw-change-next').checked = true;
    document.getElementById('cpw-result').classList.add('d-none');
    document.getElementById('cpw-confirm-btn').disabled = false;
    document.getElementById('cpw-confirm-btn').dataset.userId = userId;
    $('#changePwModal').modal('show');
}

document.getElementById('cpw-toggle-pw').addEventListener('click', function() {
    var inp = document.getElementById('cpw-password');
    inp.type = inp.type === 'password' ? 'text' : 'password';
    this.querySelector('i').classList.toggle('fa-eye');
    this.querySelector('i').classList.toggle('fa-eye-slash');
});

document.getElementById('cpw-confirm-btn').addEventListener('click', function() {
    var btn        = this;
    var userId     = btn.dataset.userId;
    var newPw      = document.getElementById('cpw-password').value.trim();
    var changeNext = document.getElementById('cpw-change-next').checked;
    if (newPw.length < 6) { alert('La contraseña debe tener al menos 6 caracteres.'); return; }
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i>Guardando...';
    ajaxPost({ action: 'change_password', user_id: userId, new_password: newPw, change_at_next_login: changeNext ? '1' : '' })
    .then(function(resp) {
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-save mr-1"></i> Guardar contraseña';
        var resultEl = document.getElementById('cpw-result');
        resultEl.classList.remove('d-none');
        if (resp.success) {
            resultEl.className = 'mt-3 alert alert-success py-2';
            resultEl.innerHTML = '<i class="fas fa-check mr-1"></i>' + (resp.message || 'Contraseña actualizada.');
        } else {
            resultEl.className = 'mt-3 alert alert-danger py-2';
            resultEl.innerHTML = '<i class="fas fa-times mr-1"></i>' + escHtml(resp.error || 'Error');
        }
    })
    .catch(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-save mr-1"></i> Guardar contraseña';
    });
});

// ---- Helpers ----
function updateMissingBtn() {
    var has = allItems.some(function(i) { return i.google_exists === 'no'; });
    document.getElementById('btn-create-missing').classList.toggle('d-none', !has);
}

function ajaxPost(params) {
    return fetch(AJAX_GOOGLE, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(params).toString()
    }).then(function(r) { return r.json(); });
}

function escHtml(str) {
    return String(str || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ================================================================
// TAB PERSONAL
// ================================================================
var staffItems = [];

document.getElementById('btn-check-staff').addEventListener('click', function() {
    loadStaffData(document.getElementById('staff-filter-role').value);
});

function loadStaffData(role) {
    var btn = document.getElementById('btn-check-staff');
    var spinner = document.getElementById('check-spinner-staff');
    btn.disabled = true;
    spinner.classList.remove('d-none');
    document.getElementById('results-area-staff').classList.add('d-none');
    document.getElementById('btn-create-missing-staff').classList.add('d-none');

    ajaxPost({ action: 'check_staff_accounts', role: role || '' })
    .then(function(resp) {
        btn.disabled = false;
        spinner.classList.add('d-none');
        if (!resp.success) { alert('Error: ' + (resp.error || 'Error desconocido')); return; }
        staffItems = resp.items || [];
        renderStaffTable(staffItems);
        document.getElementById('results-area-staff').classList.remove('d-none');
        updateStaffMissingBtn();
    })
    .catch(function(e) {
        btn.disabled = false;
        spinner.classList.add('d-none');
        alert('Error de conexión: ' + e.message);
    });
}

function renderStaffTable(items) {
    var yes = 0, no = 0, err = 0, html = '';
    items.forEach(function(item) {
        var statusBadge = '', actionBtn = '';
        if (item.google_exists === 'yes') {
            yes++;
            statusBadge = '<span class="badge badge-success"><i class="fas fa-check mr-1"></i>Activa</span>';
            actionBtn = '<button class="btn btn-xs btn-sm btn-outline-warning btn-change-pw" ' +
                'data-user-id="' + item.user_id + '" data-email="' + escHtml(item.email) + '" data-name="' + escHtml(item.full_name) + '">' +
                '<i class="fas fa-key mr-1"></i>Contraseña</button>';
        } else if (item.google_exists === 'no') {
            no++;
            statusBadge = '<span class="badge badge-danger"><i class="fas fa-times mr-1"></i>Sin cuenta</span>';
            actionBtn = '<button class="btn btn-xs btn-sm btn-outline-success btn-create-staff" ' +
                'data-user-id="' + item.user_id + '" data-email="' + escHtml(item.email) + '" data-name="' + escHtml(item.full_name) + '">' +
                '<i class="fab fa-google mr-1"></i>Crear</button>';
        } else {
            err++;
            statusBadge = '<span class="badge badge-secondary"><i class="fas fa-exclamation mr-1"></i>Error</span>';
        }
        html += '<tr id="srow-' + item.user_id + '">' +
            '<td><div class="font-weight-bold" style="font-size:13px;">' + escHtml(item.full_name) + '</div>' +
                '<div class="text-muted" style="font-size:11px;">' + escHtml(item.username) + '</div></td>' +
            '<td><span class="badge badge-secondary" style="font-size:11px;">' + escHtml(item.role_label) + '</span></td>' +
            '<td style="font-size:12px;">' + escHtml(item.email) + '</td>' +
            '<td class="text-center" id="sstatus-' + item.user_id + '">' + statusBadge + '</td>' +
            '<td class="text-center" id="saction-' + item.user_id + '">' + actionBtn + '</td>' +
            '</tr>';
    });
    document.getElementById('staff-tbody').innerHTML = html ||
        '<tr><td colspan="5" class="text-center text-muted py-4">Sin usuarios.</td></tr>';
    document.getElementById('staff-total-count').textContent = items.length;
    document.getElementById('staff-cnt-yes').textContent = yes;
    document.getElementById('staff-cnt-no').textContent  = no;
    document.getElementById('staff-cnt-err').textContent  = err;
}

// Click en tabla personal
document.getElementById('staff-tbody').addEventListener('click', function(e) {
    var btnCreate = e.target.closest('.btn-create-staff');
    var btnPw     = e.target.closest('.btn-change-pw');
    if (btnCreate) openCreateConfirmStaff(btnCreate);
    if (btnPw)     openChangePw(btnPw);
});

function openCreateConfirmStaff(btnEl) {
    var userId = btnEl.getAttribute('data-user-id');
    var email  = btnEl.getAttribute('data-email');
    var name   = btnEl.getAttribute('data-name');
    document.getElementById('cc-name').textContent  = name;
    document.getElementById('cc-email').textContent = email;
    // Default password: play@ + username for staff
    var item = staffItems.find(function(i) { return String(i.user_id) === String(userId); });
    document.getElementById('cc-password').value = 'play@' + (item ? item.username : userId);
    document.getElementById('cc-password').type  = 'text';
    document.getElementById('cc-change-next').checked = true;
    pendingUserId = userId;
    pendingBtnEl  = btnEl;
    pendingCb     = function(resp, changeNext) { onStaffCreated(userId, resp, changeNext); };
    $('#createConfirmModal').modal('show');
}

function onStaffCreated(userId, resp, changeNext) {
    var statusEl = document.getElementById('sstatus-' + userId);
    var actionEl = document.getElementById('saction-' + userId);
    if (resp.success) {
        if (statusEl) statusEl.innerHTML = '<span class="badge badge-success"><i class="fas fa-check mr-1"></i>Activa</span>';
        if (actionEl) {
            var item = staffItems.find(function(i) { return String(i.user_id) === String(userId); });
            actionEl.innerHTML = '<button class="btn btn-xs btn-sm btn-outline-warning btn-change-pw" ' +
                'data-user-id="' + userId + '" data-email="' + escHtml(resp.email || '') + '" data-name="' + escHtml(item ? item.full_name : '') + '">' +
                '<i class="fas fa-key mr-1"></i>Contraseña</button>';
        }
        staffItems.forEach(function(i) { if (String(i.user_id) === String(userId)) i.google_exists = 'yes'; });
        document.getElementById('staff-cnt-no').textContent  = Math.max(0, parseInt(document.getElementById('staff-cnt-no').textContent) - 1);
        document.getElementById('staff-cnt-yes').textContent = parseInt(document.getElementById('staff-cnt-yes').textContent) + 1;
        if (resp.created) showCreateResult(resp.email, resp.password, changeNext);
    }
    updateStaffMissingBtn();
}

// Bulk crear faltantes personal
document.getElementById('btn-create-missing-staff').addEventListener('click', function() {
    var missing = staffItems.filter(function(i) { return i.google_exists === 'no'; });
    if (!missing.length) return;
    if (!confirm('¿Crear ' + missing.length + ' cuenta(s) para el personal faltante?')) return;
    var btn = this; btn.disabled = true;
    var idx = 0;
    function next() {
        if (idx >= missing.length) { btn.disabled = false; return; }
        var item = missing[idx++];
        var defPw = 'play@' + item.username;
        var rowBtn = document.querySelector('#saction-' + item.user_id + ' .btn-create-staff');
        doCreateAccountStaff(item.user_id, defPw, true, rowBtn, next);
    }
    next();
});

function doCreateAccountStaff(userId, password, changeAtNextLogin, btnEl, callback) {
    if (btnEl) { btnEl.disabled = true; btnEl.innerHTML = '<i class="fas fa-spinner fa-spin"></i>'; }
    fetch(AJAX_GOOGLE, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ action: 'create_account', user_id: userId,
            password_override: password, change_at_next_login: changeAtNextLogin ? '1' : '' }).toString()
    })
    .then(function(r) { return r.json(); })
    .then(function(resp) {
        onStaffCreated(userId, resp, changeAtNextLogin);
        if (callback) callback();
    })
    .catch(function() { if (callback) callback(); });
}

function updateStaffMissingBtn() {
    var has = staffItems.some(function(i) { return i.google_exists === 'no'; });
    document.getElementById('btn-create-missing-staff').classList.toggle('d-none', !has);
}
</script>

{% endif %}
