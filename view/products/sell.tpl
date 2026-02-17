{% include 'products/tabs.tpl' with {'active_tab': 'sell'} %}

<div class="card">
    <div class="card-header">
        <i class="fas fa-cash-register"></i> {{ 'SellProduct'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body">
        <!-- Student Search -->
        <div class="form-group">
            <label><strong>{{ 'SearchStudent'|get_plugin_lang('SchoolPlugin') }}</strong></label>
            <div class="input-group">
                <input type="text" id="student_search" class="form-control" placeholder="{{ 'SearchStudentPlaceholder'|get_plugin_lang('SchoolPlugin') }}"
                       value="{{ student ? student.complete_name : '' }}">
                <input type="hidden" id="selected_user_id" value="{{ student_id }}">
                <div class="input-group-append">
                    <button class="btn btn-outline-primary" type="button" onclick="searchStudent()">
                        <i class="fas fa-search"></i>
                    </button>
                </div>
            </div>
            <div id="student_results" class="list-group mt-1" style="position:absolute;z-index:100;max-height:200px;overflow-y:auto;display:none;"></div>
        </div>

        {% if student %}
        <div class="alert alert-info">
            <i class="fas fa-user"></i> <strong>{{ student.complete_name }}</strong> ({{ student.username }})
        </div>
        {% endif %}

        <!-- Product Selection -->
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label>{{ 'SelectProduct'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <select id="sale_product" class="form-control" onchange="updatePrice()">
                        <option value="">-- {{ 'SelectProduct'|get_plugin_lang('SchoolPlugin') }} --</option>
                        {% for product in products %}
                        <option value="{{ product.id }}" data-price="{{ product.price }}">
                            {{ product.name }} {% if product.category_name %}({{ product.category_name }}){% endif %} - S/ {{ product.price|number_format(2, '.', ',') }}
                        </option>
                        {% endfor %}
                    </select>
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label>{{ 'Quantity'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="number" id="sale_quantity" class="form-control" value="1" min="1" onchange="calculateTotal()">
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label>{{ 'UnitPrice'|get_plugin_lang('SchoolPlugin') }} (S/)</label>
                    <input type="number" id="sale_unit_price" class="form-control" step="0.01" min="0" value="0" onchange="calculateTotal()">
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-4">
                <div class="form-group">
                    <label>{{ 'Discount'|get_plugin_lang('SchoolPlugin') }} (S/)</label>
                    <input type="number" id="sale_discount" class="form-control" step="0.01" min="0" value="0" onchange="calculateTotal()">
                </div>
            </div>
            <div class="col-md-4">
                <div class="form-group">
                    <label>{{ 'PaymentMethod'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select id="sale_method" class="form-control">
                        <option value="cash">{{ 'Cash'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="transfer">{{ 'Transfer'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="yape">Yape</option>
                        <option value="plin">Plin</option>
                    </select>
                </div>
            </div>
            <div class="col-md-4">
                <div class="form-group">
                    <label>{{ 'Reference'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" id="sale_reference" class="form-control">
                </div>
            </div>
        </div>

        <div class="form-group">
            <label>{{ 'Notes'|get_plugin_lang('SchoolPlugin') }}</label>
            <textarea id="sale_notes" class="form-control" rows="2"></textarea>
        </div>

        <!-- Total -->
        <div class="alert alert-success text-center">
            <strong>{{ 'TotalToCharge'|get_plugin_lang('SchoolPlugin') }}:</strong>
            <span id="sale_total" class="h4 ml-2">S/ 0.00</span>
        </div>

        <div class="text-center">
            <button class="btn btn-primary btn-lg" onclick="saveSale()" id="btnSaveSale" disabled>
                <i class="fas fa-check-circle"></i> {{ 'RegisterSale'|get_plugin_lang('SchoolPlugin') }}
            </button>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';

function updatePrice() {
    var select = document.getElementById('sale_product');
    var option = select.options[select.selectedIndex];
    var price = option.getAttribute('data-price') || 0;
    document.getElementById('sale_unit_price').value = parseFloat(price).toFixed(2);
    calculateTotal();
}

function calculateTotal() {
    var unitPrice = parseFloat(document.getElementById('sale_unit_price').value) || 0;
    var quantity = parseInt(document.getElementById('sale_quantity').value) || 1;
    var discount = parseFloat(document.getElementById('sale_discount').value) || 0;
    var total = (unitPrice * quantity) - discount;
    if (total < 0) total = 0;
    document.getElementById('sale_total').textContent = 'S/ ' + total.toFixed(2);

    var canSave = document.getElementById('selected_user_id').value > 0 &&
                  document.getElementById('sale_product').value > 0 &&
                  total > 0;
    document.getElementById('btnSaveSale').disabled = !canSave;
}

function searchStudent() {
    var query = document.getElementById('student_search').value.trim();
    if (query.length < 2) return;

    $.ajax({
        url: ajaxUrl,
        data: { action: 'search_students', q: query },
        success: function(data) {
            var container = document.getElementById('student_results');
            container.innerHTML = '';
            if (data && data.items) {
                data.items.forEach(function(user) {
                    var item = document.createElement('a');
                    item.className = 'list-group-item list-group-item-action py-1';
                    item.textContent = user.text;
                    item.href = '#';
                    item.onclick = function(e) {
                        e.preventDefault();
                        document.getElementById('selected_user_id').value = user.id;
                        document.getElementById('student_search').value = user.text;
                        container.style.display = 'none';
                        calculateTotal();
                    };
                    container.appendChild(item);
                });
                container.style.display = 'block';
            }
        }
    });
}

document.getElementById('student_search').addEventListener('keyup', function(e) {
    if (this.value.length >= 2) {
        searchStudent();
    } else {
        document.getElementById('student_results').style.display = 'none';
    }
});

document.addEventListener('click', function(e) {
    if (!e.target.closest('#student_results') && !e.target.closest('#student_search')) {
        document.getElementById('student_results').style.display = 'none';
    }
});

function saveSale() {
    var userId = document.getElementById('selected_user_id').value;
    var productId = document.getElementById('sale_product').value;

    if (!userId || !productId) {
        alert('{{ 'FillRequiredFields'|get_plugin_lang('SchoolPlugin') }}');
        return;
    }

    $.ajax({
        url: ajaxUrl,
        type: 'POST',
        data: {
            action: 'save_sale',
            product_id: productId,
            user_id: userId,
            quantity: document.getElementById('sale_quantity').value,
            unit_price: document.getElementById('sale_unit_price').value,
            discount: document.getElementById('sale_discount').value,
            payment_method: document.getElementById('sale_method').value,
            reference: document.getElementById('sale_reference').value,
            notes: document.getElementById('sale_notes').value
        },
        success: function(response) {
            if (response.success) {
                if (confirm('{{ 'PrintReceiptQuestion'|get_plugin_lang('SchoolPlugin') }}')) {
                    window.open('{{ _p.web }}products/receipt?id=' + response.sale_id, '_blank');
                }
                location.href = '{{ _p.web }}products/sales';
            } else {
                alert(response.message || 'Error');
            }
        }
    });
}
</script>
