{% include 'products/tabs.tpl' with {'active_tab': 'catalog'} %}

<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="fas fa-boxes"></i> {{ 'ProductCatalog'|get_plugin_lang('SchoolPlugin') }}</span>
        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#productModal" onclick="openProductModal()">
            <i class="fas fa-plus"></i> {{ 'AddProduct'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
                <thead class="thead-light">
                    <tr>
                        <th>{{ 'ProductName'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Description'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Category'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-right">{{ 'Price'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-center">{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-center">{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for product in products %}
                    <tr>
                        <td><strong>{{ product.name }}</strong></td>
                        <td>{{ product.description|default('-') }}</td>
                        <td>
                            {% if product.category_name %}
                                <span class="badge badge-info">{{ product.category_name }}</span>
                            {% else %}
                                -
                            {% endif %}
                        </td>
                        <td class="text-right font-weight-bold">S/ {{ product.price|number_format(2, '.', ',') }}</td>
                        <td class="text-center">
                            {% if product.active %}
                                <span class="badge badge-success">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% else %}
                                <span class="badge badge-secondary">{{ 'Inactive'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% endif %}
                        </td>
                        <td class="text-center">
                            <button class="btn btn-warning btn-sm" onclick="editProduct({{ product|json_encode|e('html_attr') }})">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-danger btn-sm" onclick="deleteProduct({{ product.id }})">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                    {% else %}
                    <tr>
                        <td colspan="6" class="text-center text-muted py-4">
                            <i class="fas fa-box-open fa-2x mb-2 d-block"></i>
                            {{ 'NoProducts'|get_plugin_lang('SchoolPlugin') }}
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Product Modal -->
<div class="modal fade" id="productModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="productModalTitle">{{ 'AddProduct'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="product_id" value="0">
                <div class="form-group">
                    <label>{{ 'ProductName'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" id="product_name" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>{{ 'Description'|get_plugin_lang('SchoolPlugin') }}</label>
                    <textarea id="product_description" class="form-control" rows="2"></textarea>
                </div>
                <div class="form-group">
                    <label>{{ 'Category'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select id="product_category_id" class="form-control">
                        <option value="">-- {{ 'NoCategory'|get_plugin_lang('SchoolPlugin') }} --</option>
                        {% for cat in categories %}
                        <option value="{{ cat.id }}">{{ cat.name }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group">
                    <label>{{ 'Price'|get_plugin_lang('SchoolPlugin') }} (S/) *</label>
                    <input type="number" id="product_price" class="form-control" step="0.01" min="0" required>
                </div>
                <div class="form-group">
                    <label>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select id="product_active" class="form-control">
                        <option value="1">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="0">{{ 'Inactive'|get_plugin_lang('SchoolPlugin') }}</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Cancel'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveProduct()">
                    <i class="fas fa-save"></i> {{ 'Save'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';

function openProductModal() {
    document.getElementById('product_id').value = 0;
    document.getElementById('product_name').value = '';
    document.getElementById('product_description').value = '';
    document.getElementById('product_category_id').value = '';
    document.getElementById('product_price').value = '';
    document.getElementById('product_active').value = '1';
    document.getElementById('productModalTitle').textContent = '{{ 'AddProduct'|get_plugin_lang('SchoolPlugin') }}';
    $('#productModal').modal('show');
}

function editProduct(product) {
    document.getElementById('product_id').value = product.id;
    document.getElementById('product_name').value = product.name;
    document.getElementById('product_description').value = product.description || '';
    document.getElementById('product_category_id').value = product.category_id || '';
    document.getElementById('product_price').value = product.price;
    document.getElementById('product_active').value = product.active;
    document.getElementById('productModalTitle').textContent = '{{ 'EditProduct'|get_plugin_lang('SchoolPlugin') }}';
    $('#productModal').modal('show');
}

function saveProduct() {
    var name = document.getElementById('product_name').value.trim();
    var price = document.getElementById('product_price').value;

    if (!name || !price) {
        alert('{{ 'FillRequiredFields'|get_plugin_lang('SchoolPlugin') }}');
        return;
    }

    $.ajax({
        url: ajaxUrl,
        type: 'POST',
        data: {
            action: 'save_product',
            id: document.getElementById('product_id').value,
            name: name,
            description: document.getElementById('product_description').value,
            category_id: document.getElementById('product_category_id').value,
            price: price,
            active: document.getElementById('product_active').value
        },
        success: function(response) {
            if (response.success) {
                location.reload();
            } else {
                alert(response.message || 'Error');
            }
        }
    });
}

function deleteProduct(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    $.ajax({
        url: ajaxUrl,
        type: 'POST',
        data: { action: 'delete_product', id: id },
        success: function(response) {
            if (response.success) {
                location.reload();
            }
        }
    });
}
</script>
