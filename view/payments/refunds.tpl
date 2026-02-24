{% include 'payments/tabs.tpl' with {'active_tab': 'refunds'} %}

<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="fas fa-undo-alt"></i> Devoluciones de Cuota de Ingreso <small class="text-muted">(Norma Minedu)</small></span>
        <div>
            <a href="{{ _p.web }}payments/refunds" class="btn btn-sm {{ status_filter == '' ? 'btn-secondary' : 'btn-outline-secondary' }}">Todas</a>
            <a href="{{ _p.web }}payments/refunds?status=pending" class="btn btn-sm {{ status_filter == 'pending' ? 'btn-warning' : 'btn-outline-warning' }}">Pendientes</a>
            <a href="{{ _p.web }}payments/refunds?status=processed" class="btn btn-sm {{ status_filter == 'processed' ? 'btn-success' : 'btn-outline-success' }}">Procesadas</a>
        </div>
    </div>
    <div class="card-body p-0">
        {% if refunds|length > 0 %}
        <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
                <thead class="thead-light">
                    <tr>
                        <th>Alumno</th>
                        <th>Nivel / Grado</th>
                        <th class="text-center">Años pactados</th>
                        <th class="text-center">Años cursados</th>
                        <th class="text-center">Años restantes</th>
                        <th class="text-right">Cuota pagada</th>
                        <th class="text-right">A devolver</th>
                        <th class="text-center">Estado</th>
                        <th class="text-center">Fecha</th>
                        <th class="text-center">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    {% for r in refunds %}
                    <tr>
                        <td>
                            <strong>{{ r.full_name }}</strong>
                            {% if r.dni %}<br><small class="text-muted">DNI: {{ r.dni }}</small>{% endif %}
                        </td>
                        <td>
                            {% if r.level_name %}<span class="badge badge-info">{{ r.level_name }}</span>{% endif %}
                            {% if r.grade_name %}<br><small>{{ r.grade_name }}</small>{% endif %}
                        </td>
                        <td class="text-center">{{ r.years_contracted }}</td>
                        <td class="text-center">{{ r.years_attended }}</td>
                        <td class="text-center">{{ r.years_remaining }}</td>
                        <td class="text-right">S/ {{ r.admission_paid|number_format(2, '.', ',') }}</td>
                        <td class="text-right font-weight-bold {% if r.refund_amount > 0 %}text-danger{% else %}text-muted{% endif %}">
                            S/ {{ r.refund_amount|number_format(2, '.', ',') }}
                        </td>
                        <td class="text-center">
                            {% if r.status == 'processed' %}
                                <span class="badge badge-success"><i class="fas fa-check"></i> Procesada</span>
                                {% if r.processed_date %}<br><small class="text-muted">{{ r.processed_date }}</small>{% endif %}
                            {% else %}
                                <span class="badge badge-warning"><i class="fas fa-clock"></i> Pendiente</span>
                            {% endif %}
                        </td>
                        <td class="text-center">
                            <small class="text-muted">{{ r.created_at|date('d/m/Y') }}</small>
                        </td>
                        <td class="text-center">
                            <a href="{{ _p.web }}payments/refund-receipt?id={{ r.id }}" target="_blank" class="btn btn-secondary btn-sm" title="Imprimir constancia">
                                <i class="fas fa-print"></i>
                            </a>
                            {% if r.status == 'pending' %}
                            <button class="btn btn-success btn-sm" onclick="markRefundProcessed({{ r.id }})" title="Marcar como procesada">
                                <i class="fas fa-check"></i>
                            </button>
                            {% endif %}
                            {% if r.notes %}
                            <button class="btn btn-info btn-sm" onclick="alert('{{ r.notes|e('js') }}')" title="Ver notas">
                                <i class="fas fa-sticky-note"></i>
                            </button>
                            {% endif %}
                            {% if is_admin %}
                            <button class="btn btn-danger btn-sm" onclick="deleteRefund({{ r.id }})" title="Eliminar">
                                <i class="fas fa-trash"></i>
                            </button>
                            {% endif %}
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
        {% else %}
        <div class="p-4 text-center text-muted">
            <i class="fas fa-undo-alt fa-2x mb-2"></i>
            <p>No hay devoluciones registradas{% if status_filter %} con estado "{{ status_filter }}"{% endif %}.</p>
            <small>Las devoluciones se generan automáticamente al retirar un alumno desde el módulo de matrículas.</small>
        </div>
        {% endif %}
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';

function markRefundProcessed(id) {
    if (!confirm('¿Marcar esta devolución como procesada (entregada al apoderado)?')) return;
    var fd = new FormData();
    fd.append('action', 'update_refund_status');
    fd.append('id', id);
    fd.append('status', 'processed');
    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success) location.reload();
            else alert(d.message || 'Error');
        });
}

function deleteRefund(id) {
    if (!confirm('¿Eliminar este registro de devolución? Esta acción no se puede deshacer.')) return;
    var fd = new FormData();
    fd.append('action', 'delete_refund');
    fd.append('id', id);
    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success) location.reload();
            else alert(d.message || 'Error');
        });
}
</script>
