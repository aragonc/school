{% include 'products/tabs.tpl' with {'active_tab': 'sales'} %}

<!-- Filters -->
<div class="card mb-3">
    <div class="card-body py-2">
        <form method="get" class="form-inline">
            <div class="form-group mr-2 mb-1">
                <label class="mr-1">{{ 'SelectProduct'|get_plugin_lang('SchoolPlugin') }}</label>
                <select name="product_id" class="form-control form-control-sm">
                    <option value="">{{ 'AllProducts'|get_plugin_lang('SchoolPlugin') }}</option>
                    {% for p in products %}
                    <option value="{{ p.id }}" {{ filters.product_id is defined and filters.product_id == p.id ? 'selected' : '' }}>{{ p.name }}</option>
                    {% endfor %}
                </select>
            </div>
            <div class="form-group mr-2 mb-1">
                <label class="mr-1">{{ 'DateFrom'|get_plugin_lang('SchoolPlugin') }}</label>
                <input type="date" name="date_from" class="form-control form-control-sm" value="{{ filters.date_from|default('') }}">
            </div>
            <div class="form-group mr-2 mb-1">
                <label class="mr-1">{{ 'DateTo'|get_plugin_lang('SchoolPlugin') }}</label>
                <input type="date" name="date_to" class="form-control form-control-sm" value="{{ filters.date_to|default('') }}">
            </div>
            <button type="submit" class="btn btn-primary btn-sm mb-1">
                <i class="fas fa-search"></i> {{ 'Filter'|get_plugin_lang('SchoolPlugin') }}
            </button>
        </form>
    </div>
</div>

<!-- Summary -->
<div class="row mb-3">
    <div class="col-md-4 col-6">
        <div class="card text-center">
            <div class="card-body py-2">
                <div class="h5 mb-0 font-weight-bold text-primary">{{ sales|length }}</div>
                <small class="text-muted">{{ 'TotalSalesCount'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
    <div class="col-md-4 col-6">
        <div class="card text-center">
            <div class="card-body py-2">
                <div class="h5 mb-0 font-weight-bold text-success">S/ {{ total_sales|number_format(2, '.', ',') }}</div>
                <small class="text-muted">{{ 'TotalCollected'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
    <div class="col-md-4 col-6">
        <div class="card text-center">
            <div class="card-body py-2">
                <div class="h5 mb-0 font-weight-bold text-warning">S/ {{ total_discount|number_format(2, '.', ',') }}</div>
                <small class="text-muted">{{ 'TotalDiscount'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
</div>

<!-- Sales Table -->
<div class="card">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-striped table-hover table-sm mb-0">
                <thead class="thead-light">
                    <tr>
                        <th>{{ 'Receipt'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Date'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Student'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'ProductName'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-center">{{ 'Quantity'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-right">{{ 'UnitPrice'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-right">{{ 'Discount'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-right">{{ 'Total'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-center">{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for sale in sales %}
                    <tr>
                        <td><span class="badge badge-secondary">{{ sale.receipt_number }}</span></td>
                        <td>{{ sale.created_at|date('d/m/Y H:i') }}</td>
                        <td>{{ sale.lastname }}, {{ sale.firstname }}</td>
                        <td>{{ sale.product_name }}</td>
                        <td class="text-center">{{ sale.quantity }}</td>
                        <td class="text-right">S/ {{ sale.unit_price|number_format(2, '.', ',') }}</td>
                        <td class="text-right text-warning">
                            {% if sale.discount > 0 %}- S/ {{ sale.discount|number_format(2, '.', ',') }}{% else %}-{% endif %}
                        </td>
                        <td class="text-right font-weight-bold text-success">S/ {{ sale.total_amount|number_format(2, '.', ',') }}</td>
                        <td class="text-center">
                            <a href="{{ _p.web }}products/receipt?id={{ sale.id }}" target="_blank" class="btn btn-info btn-sm" title="{{ 'PrintReceipt'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-print"></i>
                            </a>
                            <button class="btn btn-danger btn-sm" onclick="deleteSale({{ sale.id }})" title="{{ 'Delete'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                    {% else %}
                    <tr>
                        <td colspan="9" class="text-center text-muted py-4">
                            {{ 'NoSales'|get_plugin_lang('SchoolPlugin') }}
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
function deleteSale(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    $.ajax({
        url: '{{ ajax_url }}',
        type: 'POST',
        data: { action: 'delete_sale', id: id },
        success: function(response) {
            if (response.success) {
                location.reload();
            }
        }
    });
}
</script>
