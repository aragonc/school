{% include 'payments/tabs.tpl' with {'active_tab': 'discounts'} %}

<div class="card mb-4">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="fas fa-percentage"></i> {{ 'Discounts'|get_plugin_lang('SchoolPlugin') }}</span>
        <div>
            <form method="get" class="form-inline d-inline">
                <select name="period_id" class="form-control form-control-sm mr-2" onchange="this.form.submit()">
                    {% for p in periods %}
                    <option value="{{ p.id }}" {{ period_id == p.id ? 'selected' : '' }}>{{ p.name }} ({{ p.year }})</option>
                    {% endfor %}
                </select>
            </form>
            <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#discountModal" onclick="resetDiscountForm()">
                <i class="fas fa-plus"></i> {{ 'AddDiscount'|get_plugin_lang('SchoolPlugin') }}
            </button>
        </div>
    </div>
    <div class="card-body">
        {% if discounts|length > 0 %}
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead>
                    <tr>
                        <th>{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'DiscountType'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'DiscountValue'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'AppliesTo'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Reason'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for discount in discounts %}
                    <tr>
                        <td>{{ discount.lastname }}, {{ discount.firstname }}</td>
                        <td>
                            {% if discount.discount_type == 'percentage' %}
                                {{ 'Percentage'|get_plugin_lang('SchoolPlugin') }}
                            {% else %}
                                {{ 'FixedAmount'|get_plugin_lang('SchoolPlugin') }}
                            {% endif %}
                        </td>
                        <td>
                            {% if discount.discount_type == 'percentage' %}
                                {{ discount.discount_value }}%
                            {% else %}
                                S/ {{ discount.discount_value|number_format(2, '.', ',') }}
                            {% endif %}
                        </td>
                        <td>
                            {% if discount.applies_to == 'all' %}
                                {{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }}
                            {% elseif discount.applies_to == 'enrollment' %}
                                {{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}
                            {% else %}
                                {{ 'Monthly'|get_plugin_lang('SchoolPlugin') }}
                            {% endif %}
                        </td>
                        <td>{{ discount.reason }}</td>
                        <td>
                            <button class="btn btn-warning btn-sm" onclick="editDiscount({{ discount|json_encode }})">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-danger btn-sm" onclick="deleteDiscount({{ discount.id }})">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
        {% else %}
        <div class="alert alert-info">
            <i class="fas fa-info-circle"></i> No hay descuentos configurados para este periodo.
        </div>
        {% endif %}
    </div>
</div>

<!-- Discount Modal -->
<div class="modal fade" id="discountModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="discountModalTitle">{{ 'AddDiscount'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <form id="discountForm">
                    <input type="hidden" name="id" id="discount_id" value="0">
                    <div class="form-group">
                        <label>{{ 'SelectStudent'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <select class="form-control" name="user_id" id="discount_user" required>
                            <option value="">{{ 'SelectOption'|get_plugin_lang('SchoolPlugin') }}</option>
                            {% for s in students_list %}
                            <option value="{{ s.user_id }}">{{ s.lastname }}, {{ s.firstname }} ({{ s.username }})</option>
                            {% endfor %}
                        </select>
                    </div>
                    <div class="form-group">
                        <label>{{ 'DiscountType'|get_plugin_lang('SchoolPlugin') }}</label>
                        <select class="form-control" name="discount_type" id="discount_type">
                            <option value="percentage">{{ 'Percentage'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="fixed">{{ 'FixedAmount'|get_plugin_lang('SchoolPlugin') }}</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>{{ 'DiscountValue'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <input type="number" class="form-control" name="discount_value" id="discount_value" step="0.01" min="0" required>
                    </div>
                    <div class="form-group">
                        <label>{{ 'AppliesTo'|get_plugin_lang('SchoolPlugin') }}</label>
                        <select class="form-control" name="applies_to" id="discount_applies">
                            <option value="all">{{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }} ({{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }} + {{ 'Monthly'|get_plugin_lang('SchoolPlugin') }})</option>
                            <option value="enrollment">{{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="monthly">{{ 'Monthly'|get_plugin_lang('SchoolPlugin') }}</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>{{ 'Reason'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="text" class="form-control" name="reason" id="discount_reason" placeholder="Motivo del descuento">
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveDiscount()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';
var periodId = {{ period_id }};

function resetDiscountForm() {
    document.getElementById('discountModalTitle').textContent = '{{ 'AddDiscount'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('discount_id').value = 0;
    document.getElementById('discount_user').value = '';
    document.getElementById('discount_type').value = 'percentage';
    document.getElementById('discount_value').value = '';
    document.getElementById('discount_applies').value = 'all';
    document.getElementById('discount_reason').value = '';
}

function editDiscount(discount) {
    document.getElementById('discountModalTitle').textContent = '{{ 'EditPeriod'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('discount_id').value = discount.id;
    document.getElementById('discount_user').value = discount.user_id;
    document.getElementById('discount_type').value = discount.discount_type;
    document.getElementById('discount_value').value = discount.discount_value;
    document.getElementById('discount_applies').value = discount.applies_to;
    document.getElementById('discount_reason').value = discount.reason || '';
    $('#discountModal').modal('show');
}

function saveDiscount() {
    var formData = new FormData();
    formData.append('action', 'save_discount');
    formData.append('id', document.getElementById('discount_id').value);
    formData.append('period_id', periodId);
    formData.append('user_id', document.getElementById('discount_user').value);
    formData.append('discount_type', document.getElementById('discount_type').value);
    formData.append('discount_value', document.getElementById('discount_value').value);
    formData.append('applies_to', document.getElementById('discount_applies').value);
    formData.append('reason', document.getElementById('discount_reason').value);

    fetch(ajaxUrl, { method: 'POST', body: formData })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                location.reload();
            } else {
                alert(data.message || 'Error');
            }
        });
}

function deleteDiscount(id) {
    if (!confirm('{{ 'ConfirmDeletePayment'|get_plugin_lang('SchoolPlugin') }}')) return;

    var formData = new FormData();
    formData.append('action', 'delete_discount');
    formData.append('id', id);

    fetch(ajaxUrl, { method: 'POST', body: formData })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                location.reload();
            }
        });
}
</script>
