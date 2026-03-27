{# Encabezado #}
<div class="d-flex align-items-center justify-content-between mb-3 flex-wrap" style="gap:10px;">
    <div>
        <a href="/support" class="btn btn-sm btn-outline-secondary mr-2">
            <i class="fas fa-arrow-left"></i>
        </a>
        <span class="font-weight-bold text-dark" style="font-size:16px;">
            #{{ ticket.id }} — {{ ticket.subject }}
        </span>
    </div>
    <div class="d-flex align-items-center" style="gap:8px;">
        <span class="badge {{ ticket.priority_badge }} px-2 py-1">{{ ticket.priority_label }}</span>
        <span class="badge {{ ticket.status_badge }} px-2 py-1" id="statusBadge">{{ ticket.status_label }}</span>
        {% if is_admin %}
        <div class="dropdown">
            <button class="btn btn-sm btn-outline-secondary dropdown-toggle" data-toggle="dropdown">
                <i class="fas fa-cog"></i> Estado
            </button>
            <div class="dropdown-menu dropdown-menu-right">
                <a class="dropdown-item" href="#" onclick="changeStatus('open')"><i class="fas fa-circle text-primary mr-1"></i> Abierto</a>
                <a class="dropdown-item" href="#" onclick="changeStatus('in_progress')"><i class="fas fa-circle text-warning mr-1"></i> En proceso</a>
                <a class="dropdown-item" href="#" onclick="changeStatus('resolved')"><i class="fas fa-circle text-success mr-1"></i> Resuelto</a>
                <a class="dropdown-item" href="#" onclick="changeStatus('closed')"><i class="fas fa-circle text-secondary mr-1"></i> Cerrado</a>
            </div>
        </div>
        {% endif %}
    </div>
</div>

{# Info del ticket #}
<div class="card shadow-sm border-0 mb-4">
    <div class="card-body py-2 px-3">
        <div class="row text-muted small" style="row-gap:4px;">
            <div class="col-auto">
                <i class="fas fa-user mr-1"></i>
                <strong>{{ ticket.lastname }}{% if ticket.firstname %}, {{ ticket.firstname }}{% endif %}</strong>
            </div>
            {% if ticket.guest_email %}
            <div class="col-auto">
                <i class="fas fa-envelope mr-1"></i>
                <a href="mailto:{{ ticket.guest_email }}" class="text-muted">{{ ticket.guest_email }}</a>
            </div>
            {% endif %}
            {% if ticket.guest_whatsapp %}
            <div class="col-auto">
                <a href="https://wa.me/{{ ticket.guest_whatsapp|replace({'+': ''}) }}"
                   target="_blank" class="text-success font-weight-bold" style="text-decoration:none;">
                    <i class="fab fa-whatsapp mr-1"></i>{{ ticket.guest_whatsapp }}
                </a>
            </div>
            {% endif %}
            <div class="col-auto">
                <i class="fas fa-tag mr-1"></i>{{ ticket.category }}
            </div>
            <div class="col-auto">
                <i class="fas fa-clock mr-1"></i>{{ ticket.created_at_local|slice(0,16) }}
            </div>
        </div>
    </div>
</div>

{# Panel de asignados (solo admin) #}
{% if is_admin %}
<div class="card shadow-sm border-0 mb-4">
    <div class="card-header bg-white py-2 px-3 d-flex align-items-center justify-content-between">
        <span>
            <i class="fas fa-user-shield text-muted mr-1"></i>
            <strong>Asignados</strong>
            <span class="badge badge-secondary ml-1" id="assigneeCount">{{ assignees|length }}</span>
        </span>
        <button class="btn btn-sm btn-outline-primary" id="btnAddAssignee">
            <i class="fas fa-plus mr-1"></i>Agregar administrador
        </button>
    </div>
    <div class="card-body py-2 px-3" id="assigneeList">
        {% if assignees %}
        {% for a in assignees %}
        <div class="d-flex align-items-center justify-content-between py-1 assignee-row" data-uid="{{ a.user_id }}">
            <div class="d-flex align-items-center" style="gap:8px;">
                <div class="rounded-circle bg-primary d-flex align-items-center justify-content-center text-white"
                     style="width:30px;height:30px;font-size:11px;flex-shrink:0;">
                    {{ a.firstname|slice(0,1)|upper }}{{ a.lastname|slice(0,1)|upper }}
                </div>
                <div>
                    <div style="font-size:13px;font-weight:600;">{{ a.lastname }}, {{ a.firstname }}</div>
                    <div class="text-muted" style="font-size:11px;">{{ a.email }}</div>
                </div>
            </div>
            <button class="btn btn-sm btn-outline-danger btn-remove-assignee" data-uid="{{ a.user_id }}"
                    title="Quitar asignación">
                <i class="fas fa-times"></i>
            </button>
        </div>
        {% endfor %}
        {% else %}
        <p class="text-muted small mb-0 py-1" id="noAssigneeMsg">Sin administradores asignados.</p>
        {% endif %}
    </div>

    {# Selector de admin (oculto) #}
    <div class="card-footer bg-light py-2 px-3 d-none" id="addAssigneeForm">
        <div class="d-flex align-items-center" style="gap:8px;">
            <select id="adminSelector" class="form-control form-control-sm" style="max-width:280px;">
                <option value="">— Seleccionar administrador —</option>
            </select>
            <button class="btn btn-sm btn-primary" id="btnConfirmAssignee">
                <i class="fas fa-check mr-1"></i>Asignar
            </button>
            <button class="btn btn-sm btn-secondary" id="btnCancelAssignee">Cancelar</button>
        </div>
    </div>
</div>
{% endif %}

{# Hilo de mensajes #}
<div class="card shadow-sm border-0 mb-4">
    <div class="card-header bg-white py-2 px-3">
        <i class="fas fa-comments text-muted mr-1"></i>
        <strong>Conversación</strong>
        <span class="badge badge-secondary ml-1">{{ messages|length }}</span>
    </div>
    <div class="card-body p-3" id="messageThread" style="max-height:520px;overflow-y:auto;">
        {% if messages %}
            {% for msg in messages %}
            {% set isAdminMsg = msg.user_status == 1 %}
            <div class="d-flex mb-3 {% if isAdminMsg %}flex-row-reverse{% endif %}">
                <div class="rounded-circle bg-{{ isAdminMsg ? 'primary' : 'secondary' }} d-flex align-items-center justify-content-center text-white flex-shrink-0"
                     style="width:36px;height:36px;font-size:13px;{{ isAdminMsg ? 'margin-left:10px;' : 'margin-right:10px;' }}">
                    {{ msg.firstname|slice(0,1)|upper }}{{ msg.lastname|slice(0,1)|upper }}
                </div>
                <div style="max-width:75%;">
                    <div class="rounded p-3 shadow-sm {% if isAdminMsg %}bg-primary text-white{% else %}bg-light{% endif %}"
                         {% if msg.is_internal %}style="border-left:3px solid #ffc107;"{% endif %}>
                        <div class="small font-weight-bold mb-1">
                            {{ msg.firstname }} {{ msg.lastname }}
                            {% if msg.is_internal %}
                            <span class="badge badge-warning ml-1" style="font-size:9px;">Nota interna</span>
                            {% endif %}
                        </div>
                        <div class="ck-body-content" style="word-break:break-word;">{{ msg.body|raw }}</div>
                    </div>
                    <div class="text-muted mt-1" style="font-size:11px;{% if isAdminMsg %}text-align:right;{% endif %}">
                        {{ msg.created_at_local|slice(0,16) }}
                    </div>
                </div>
            </div>
            {% endfor %}
        {% else %}
        <p class="text-muted text-center py-3">No hay mensajes aún.</p>
        {% endif %}
    </div>
</div>

{# Caja de respuesta #}
{% if ticket.status != 'closed' %}
<div class="card shadow-sm border-0">
    <div class="card-header bg-white py-2 px-3">
        <i class="fas fa-reply text-muted mr-1"></i>
        <strong>{{ 'ReplyTicket'|get_plugin_lang('SchoolPlugin') }}</strong>
    </div>
    <div class="card-body p-3">
        <textarea id="replyBody" name="replyBody"></textarea>
        {% if is_admin %}
        <div class="form-check mt-2 mb-2">
            <input class="form-check-input" type="checkbox" id="chkInternal">
            <label class="form-check-label small text-muted" for="chkInternal">
                {{ 'InternalNote'|get_plugin_lang('SchoolPlugin') }}
            </label>
        </div>
        {% endif %}
        <div id="replyError" class="alert alert-danger d-none py-2 mt-2"></div>
        <button class="btn btn-primary btn-sm mt-1" id="btnReply">
            <i class="fas fa-paper-plane mr-1"></i>{{ 'SendReply'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
</div>
{% else %}
<div class="alert alert-secondary text-center">
    <i class="fas fa-lock mr-1"></i> {{ 'TicketClosed'|get_plugin_lang('SchoolPlugin') }}
</div>
{% endif %}

<script src="{{ _p.web }}web/assets/ckeditor/ckeditor.js"></script>
<script>
var supportAjaxUrl = '{{ ajax_url }}';
var ticketId       = {{ ticket.id }};

{% if ticket.status != 'closed' %}
CKEDITOR.replace('replyBody', {
    language: 'es',
    toolbar: [
        { name: 'basicstyles', items: ['Bold','Italic','Underline','Strike','RemoveFormat'] },
        { name: 'paragraph',   items: ['NumberedList','BulletedList','Blockquote'] },
        { name: 'links',       items: ['Link','Unlink'] },
        { name: 'styles',      items: ['Format'] },
        { name: 'colors',      items: ['TextColor','BGColor'] },
    ],
    height: 180,
    resize_enabled: false,
    removePlugins: 'elementspath',
    extraPlugins: '',
});

document.getElementById('btnReply').addEventListener('click', function () {
    var body  = CKEDITOR.instances.replyBody.getData().trim();
    var errEl = document.getElementById('replyError');
    {% if is_admin %}
    var internal = document.getElementById('chkInternal').checked ? '1' : '0';
    {% else %}
    var internal = '0';
    {% endif %}

    if (!body || body === '<p>&nbsp;</p>' || body === '<p></p>') {
        errEl.textContent = '{{ 'TicketMessageRequired'|get_plugin_lang('SchoolPlugin') }}';
        errEl.classList.remove('d-none');
        return;
    }
    errEl.classList.add('d-none');

    var btn = this;
    btn.disabled = true;

    var fd = new FormData();
    fd.append('action',      'add_message');
    fd.append('ticket_id',   ticketId);
    fd.append('body',        body);
    fd.append('is_internal', internal);

    fetch(supportAjaxUrl, { method: 'POST', body: fd })
        .then(function (r) { return r.json(); })
        .then(function (data) {
            if (data.success) {
                location.reload();
            } else {
                errEl.textContent = data.message || '{{ 'ErrorGeneric'|get_plugin_lang('SchoolPlugin') }}';
                errEl.classList.remove('d-none');
                btn.disabled = false;
            }
        })
        .catch(function () {
            errEl.textContent = '{{ 'ErrorGeneric'|get_plugin_lang('SchoolPlugin') }}';
            errEl.classList.remove('d-none');
            btn.disabled = false;
        });
});
{% endif %}

{% if is_admin %}
// ---- Asignados ----
var assignedIds = [{% for a in assignees %}{{ a.user_id }}{% if not loop.last %},{% endif %}{% endfor %}];

document.getElementById('btnAddAssignee').addEventListener('click', function () {
    var form = document.getElementById('addAssigneeForm');
    if (form.classList.contains('d-none')) {
        form.classList.remove('d-none');
        loadAdmins();
    } else {
        form.classList.add('d-none');
    }
});

document.getElementById('btnCancelAssignee').addEventListener('click', function () {
    document.getElementById('addAssigneeForm').classList.add('d-none');
});

function loadAdmins() {
    var sel = document.getElementById('adminSelector');
    if (sel.options.length > 1) return; // ya cargado
    var fd = new FormData();
    fd.append('action', 'get_admins');
    fetch(supportAjaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (!d.success) return;
            d.admins.forEach(function(a) {
                if (assignedIds.indexOf(parseInt(a.user_id)) !== -1) return;
                var opt = document.createElement('option');
                opt.value = a.user_id;
                opt.textContent = a.lastname + ', ' + a.firstname + ' (' + a.email + ')';
                sel.appendChild(opt);
            });
        });
}

document.getElementById('btnConfirmAssignee').addEventListener('click', function () {
    var sel = document.getElementById('adminSelector');
    var uid = parseInt(sel.value);
    if (!uid) return;
    var btn = this;
    btn.disabled = true;
    var fd = new FormData();
    fd.append('action',      'add_assignee');
    fd.append('ticket_id',   ticketId);
    fd.append('assignee_id', uid);
    fetch(supportAjaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            btn.disabled = false;
            if (d.success) { location.reload(); }
        });
});

document.querySelectorAll('.btn-remove-assignee').forEach(function(btn) {
    btn.addEventListener('click', function() {
        var uid = parseInt(this.getAttribute('data-uid'));
        if (!confirm('¿Quitar la asignación de este administrador?')) return;
        var fd = new FormData();
        fd.append('action',      'remove_assignee');
        fd.append('ticket_id',   ticketId);
        fd.append('assignee_id', uid);
        fetch(supportAjaxUrl, { method: 'POST', body: fd })
            .then(function(r) { return r.json(); })
            .then(function(d) {
                if (d.success) { location.reload(); }
            });
    });
});

// ---- Estado ----
var statusLabels = {
    open:        'Abierto',
    in_progress: 'En proceso',
    resolved:    'Resuelto',
    closed:      'Cerrado'
};
var statusBadges = {
    open:        'badge-primary',
    in_progress: 'badge-warning',
    resolved:    'badge-success',
    closed:      'badge-secondary'
};

function changeStatus(status) {
    var fd = new FormData();
    fd.append('action',    'change_status');
    fd.append('ticket_id', ticketId);
    fd.append('status',    status);

    fetch(supportAjaxUrl, { method: 'POST', body: fd })
        .then(function (r) { return r.json(); })
        .then(function (data) {
            if (data.success) { location.reload(); }
        });
}
{% endif %}

// Scroll al fondo del hilo
(function () {
    var thread = document.getElementById('messageThread');
    if (thread) thread.scrollTop = thread.scrollHeight;
})();
</script>
