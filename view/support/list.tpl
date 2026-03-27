<div class="d-flex align-items-center justify-content-between mb-4 flex-wrap" style="gap:10px;">
    <div>
        <h4 class="mb-1 font-weight-bold text-dark">
            <i class="fas fa-headset text-primary mr-2"></i>{{ 'SupportTickets'|get_plugin_lang('SchoolPlugin') }}
        </h4>
        <p class="mb-0 text-muted small">{{ 'SupportTicketsDesc'|get_plugin_lang('SchoolPlugin') }}</p>
    </div>
    <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#newTicketModal">
        <i class="fas fa-plus mr-1"></i>{{ 'NewTicket'|get_plugin_lang('SchoolPlugin') }}
    </button>
</div>

{# Filtros de estado #}
<div class="mb-3 d-flex flex-wrap" style="gap:6px;">
    <a href="/support" class="btn btn-sm {{ filter_status == '' ? 'btn-primary' : 'btn-outline-secondary' }}">
        {{ 'AllStatuses'|get_plugin_lang('SchoolPlugin') }}
    </a>
    <a href="/support?status=open" class="btn btn-sm {{ filter_status == 'open' ? 'btn-primary' : 'btn-outline-secondary' }}">
        <i class="fas fa-circle text-primary mr-1" style="font-size:8px;"></i>{{ 'StatusOpen'|get_plugin_lang('SchoolPlugin') }}
    </a>
    <a href="/support?status=in_progress" class="btn btn-sm {{ filter_status == 'in_progress' ? 'btn-warning' : 'btn-outline-secondary' }}">
        <i class="fas fa-circle text-warning mr-1" style="font-size:8px;"></i>{{ 'StatusInProgress'|get_plugin_lang('SchoolPlugin') }}
    </a>
    <a href="/support?status=resolved" class="btn btn-sm {{ filter_status == 'resolved' ? 'btn-success' : 'btn-outline-secondary' }}">
        <i class="fas fa-circle text-success mr-1" style="font-size:8px;"></i>{{ 'StatusResolved'|get_plugin_lang('SchoolPlugin') }}
    </a>
    <a href="/support?status=closed" class="btn btn-sm {{ filter_status == 'closed' ? 'btn-secondary' : 'btn-outline-secondary' }}">
        <i class="fas fa-circle text-secondary mr-1" style="font-size:8px;"></i>{{ 'StatusClosed'|get_plugin_lang('SchoolPlugin') }}
    </a>
</div>

{% if tickets %}
<div class="card shadow-sm border-0">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="thead-light">
                    <tr>
                        <th style="width:60px;">#</th>
                        {% if is_admin %}<th>{{ 'TicketUser'|get_plugin_lang('SchoolPlugin') }}</th>{% endif %}
                        <th>{{ 'TicketSubject'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'TicketCategory'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'TicketPriority'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'TicketStatus'|get_plugin_lang('SchoolPlugin') }}</th>
                        {% if is_admin %}<th>Asignados</th>{% endif %}
                        <th>{{ 'TicketDate'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    {% for t in tickets %}
                    <tr>
                        <td class="text-muted small">#{{ t.id }}</td>
                        {% if is_admin %}
                        <td style="font-size:12px;">
                            <span class="font-weight-bold">{{ t.lastname }}</span>, {{ t.firstname }}
                        </td>
                        {% endif %}
                        <td>
                            <a href="/support/view?id={{ t.id }}" class="font-weight-bold text-dark">
                                {{ t.subject }}
                            </a>
                        </td>
                        <td class="text-muted small">{{ t.category }}</td>
                        <td>
                            <span class="badge {{ t.priority_badge }}">{{ t.priority_label }}</span>
                        </td>
                        <td>
                            <span class="badge {{ t.status_badge }}">{{ t.status_label }}</span>
                        </td>
                        {% if is_admin %}
                        <td>
                            {% if t.assignees %}
                            <div class="d-flex flex-wrap" style="gap:4px;">
                                {% for a in t.assignees %}
                                <span class="rounded-circle bg-primary d-inline-flex align-items-center justify-content-center text-white"
                                      style="width:26px;height:26px;font-size:10px;font-weight:700;"
                                      title="{{ a.lastname }}, {{ a.firstname }}">
                                    {{ a.firstname|slice(0,1)|upper }}{{ a.lastname|slice(0,1)|upper }}
                                </span>
                                {% endfor %}
                            </div>
                            {% else %}
                            <span class="text-muted small">—</span>
                            {% endif %}
                        </td>
                        {% endif %}
                        <td class="text-muted small">{{ t.created_at_local|slice(0,16) }}</td>
                        <td>
                            <a href="/support/view?id={{ t.id }}" class="btn btn-sm btn-outline-primary">
                                <i class="fas fa-eye"></i>
                            </a>
                            {% if is_admin %}
                            <button type="button" class="btn btn-sm btn-outline-danger ml-1 btn-delete-ticket"
                                    data-id="{{ t.id }}" data-subject="{{ t.subject|e }}"
                                    title="Eliminar ticket">
                                <i class="fas fa-trash"></i>
                            </button>
                            {% endif %}
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</div>
{% else %}
<div class="card shadow-sm border-0">
    <div class="card-body text-center py-5 text-muted">
        <i class="fas fa-headset fa-3x mb-3 d-block" style="opacity:.25;"></i>
        <p class="mb-2">{{ 'NoTickets'|get_plugin_lang('SchoolPlugin') }}</p>
        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#newTicketModal">
            <i class="fas fa-plus mr-1"></i>{{ 'NewTicket'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
</div>
{% endif %}

{# Modal nuevo ticket #}
<div class="modal fade" id="newTicketModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-plus-circle mr-2"></i>{{ 'NewTicket'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'TicketSubject'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" id="nt_subject" class="form-control" maxlength="255"
                           placeholder="{{ 'TicketSubjectPlaceholder'|get_plugin_lang('SchoolPlugin') }}">
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="font-weight-bold">{{ 'TicketCategory'|get_plugin_lang('SchoolPlugin') }}</label>
                            <select id="nt_category" class="form-control">
                                {% for cat in support_categories %}
                                <option value="{{ cat.name|lower|replace({' ': '_', '/': '', 'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u'}) }}">{{ cat.name }}</option>
                                {% endfor %}
                            </select>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="font-weight-bold">{{ 'TicketPriority'|get_plugin_lang('SchoolPlugin') }}</label>
                            <select id="nt_priority" class="form-control">
                                <option value="low">{{ 'PriorityLow'|get_plugin_lang('SchoolPlugin') }}</option>
                                <option value="medium" selected>{{ 'PriorityMedium'|get_plugin_lang('SchoolPlugin') }}</option>
                                <option value="high">{{ 'PriorityHigh'|get_plugin_lang('SchoolPlugin') }}</option>
                                <option value="critical">{{ 'PriorityCritical'|get_plugin_lang('SchoolPlugin') }}</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'TicketMessage'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <textarea id="nt_body" name="nt_body"></textarea>
                </div>
                <div id="nt_error" class="alert alert-danger d-none"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" id="btnCreateTicket">
                    <i class="fas fa-paper-plane mr-1"></i>{{ 'SendTicket'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<script src="{{ _p.web }}web/assets/ckeditor/ckeditor.js"></script>
<script>
var supportAjaxUrl = '{{ ajax_url }}';

// Iniciar CKEditor al abrir el modal
$('#newTicketModal').on('shown.bs.modal', function () {
    if (!CKEDITOR.instances.nt_body) {
        CKEDITOR.replace('nt_body', {
            language: 'es',
            toolbar: [
                { name: 'basicstyles', items: ['Bold','Italic','Underline','Strike','RemoveFormat'] },
                { name: 'paragraph',   items: ['NumberedList','BulletedList','Blockquote'] },
                { name: 'links',       items: ['Link','Unlink'] },
                { name: 'styles',      items: ['Format'] },
                { name: 'colors',      items: ['TextColor','BGColor'] },
            ],
            height: 160,
            resize_enabled: false,
            removePlugins: 'elementspath',
        });
    }
});
$('#newTicketModal').on('hidden.bs.modal', function () {
    if (CKEDITOR.instances.nt_body) {
        CKEDITOR.instances.nt_body.setData('');
    }
});

document.getElementById('btnCreateTicket').addEventListener('click', function () {
    var subject  = document.getElementById('nt_subject').value.trim();
    var category = document.getElementById('nt_category').value;
    var priority = document.getElementById('nt_priority').value;
    var body     = (CKEDITOR.instances.nt_body ? CKEDITOR.instances.nt_body.getData() : '').trim();
    var errEl    = document.getElementById('nt_error');

    if (!subject || !body || body === '<p>&nbsp;</p>' || body === '<p></p>') {
        errEl.textContent = '{{ 'TicketRequiredFields'|get_plugin_lang('SchoolPlugin') }}';
        errEl.classList.remove('d-none');
        return;
    }
    errEl.classList.add('d-none');

    var btn = this;
    btn.disabled = true;

    var fd = new FormData();
    fd.append('action',   'create_ticket');
    fd.append('subject',  subject);
    fd.append('category', category);
    fd.append('priority', priority);
    fd.append('body',     body);

    fetch(supportAjaxUrl, { method: 'POST', body: fd })
        .then(function (r) { return r.json(); })
        .then(function (data) {
            if (data.success) {
                window.location.href = '/support/view?id=' + data.ticket_id;
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

{% if is_admin %}
document.querySelectorAll('.btn-delete-ticket').forEach(function (btn) {
    btn.addEventListener('click', function () {
        var id      = this.getAttribute('data-id');
        var subject = this.getAttribute('data-subject');
        if (!confirm('¿Eliminar el ticket #' + id + ' "' + subject + '"?\n\nEsta acción no se puede deshacer.')) return;
        var row = this.closest('tr');
        var fd  = new FormData();
        fd.append('action',    'delete_ticket');
        fd.append('ticket_id', id);
        fetch(supportAjaxUrl, { method: 'POST', body: fd })
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.success) {
                    row.remove();
                } else {
                    alert(d.message || 'Error al eliminar.');
                }
            });
    });
});
{% endif %}
</script>
