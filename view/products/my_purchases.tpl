<h4><i class="fas fa-shopping-bag"></i> {{ 'MyPurchases'|get_plugin_lang('SchoolPlugin') }}</h4>

{% if sales|length > 0 %}
<div class="alert alert-info">
    <strong>{{ 'TotalSpent'|get_plugin_lang('SchoolPlugin') }}:</strong> S/ {{ total_spent|number_format(2, '.', ',') }}
</div>

<div class="table-responsive">
    <table class="table table-striped table-hover">
        <thead class="thead-light">
            <tr>
                <th>{{ 'Receipt'|get_plugin_lang('SchoolPlugin') }}</th>
                <th>{{ 'Date'|get_plugin_lang('SchoolPlugin') }}</th>
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
                <td>{{ sale.created_at|date('d/m/Y') }}</td>
                <td>{{ sale.product_name }}</td>
                <td class="text-center">{{ sale.quantity }}</td>
                <td class="text-right">S/ {{ sale.unit_price|number_format(2, '.', ',') }}</td>
                <td class="text-right">
                    {% if sale.discount > 0 %}- S/ {{ sale.discount|number_format(2, '.', ',') }}{% else %}-{% endif %}
                </td>
                <td class="text-right font-weight-bold">S/ {{ sale.total_amount|number_format(2, '.', ',') }}</td>
                <td class="text-center">
                    <a href="{{ _p.web }}products/receipt?id={{ sale.id }}" target="_blank" class="btn btn-info btn-sm">
                        <i class="fas fa-print"></i>
                    </a>
                </td>
            </tr>
            {% endfor %}
        </tbody>
    </table>
</div>
{% else %}
<div class="alert alert-light text-center py-4">
    <i class="fas fa-shopping-bag fa-2x mb-2 d-block text-muted"></i>
    {{ 'NoPurchases'|get_plugin_lang('SchoolPlugin') }}
</div>
{% endif %}
