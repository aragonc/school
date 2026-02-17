{% include 'payments/tabs.tpl' with {'active_tab': 'periods'} %}

<div class="mb-3">
    <a href="{{ _p.web }}payments/students?period_id={{ period_id }}" class="btn btn-outline-secondary btn-sm">
        <i class="fas fa-arrow-left"></i> {{ 'StudentPayments'|get_plugin_lang('SchoolPlugin') }}
    </a>
</div>

<div class="card mb-4">
    <div class="card-header">
        <i class="fas fa-user"></i> {{ student.complete_name }} — {{ period.name }}
    </div>
    <div class="card-body">
        <!-- Summary -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card bg-light">
                    <div class="card-body py-2 text-center">
                        <small class="text-muted">{{ 'TotalPaid'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div class="h5 text-success mb-0">S/ {{ payment_data.total_paid|number_format(2, '.', ',') }}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-light">
                    <div class="card-body py-2 text-center">
                        <small class="text-muted">{{ 'TotalPending'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div class="h5 text-danger mb-0">S/ {{ payment_data.total_pending|number_format(2, '.', ',') }}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-light">
                    <div class="card-body py-2 text-center">
                        <small class="text-muted">{{ 'TotalDiscount'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div class="h5 text-warning mb-0">S/ {{ payment_data.total_discount|number_format(2, '.', ',') }}</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Enrollment -->
        <h5><i class="fas fa-graduation-cap"></i> {{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}</h5>
        {% set enroll = payment_data.enrollment %}
        {% set enroll_effective = enroll.original_amount - enroll.discount %}
        {% set enroll_paid = enroll.amount|default(0) %}
        {% set enroll_balance = enroll_effective - enroll_paid %}
        <table class="table table-bordered table-sm mb-4">
            <thead class="thead-light">
                <tr>
                    <th>{{ 'Type'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'OriginalAmount'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Discount'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'AmountToPay'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'AmountPaid'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Balance'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>{{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}</td>
                    <td>S/ {{ enroll.original_amount|number_format(2, '.', ',') }}</td>
                    <td>S/ {{ enroll.discount|number_format(2, '.', ',') }}</td>
                    <td>S/ {{ enroll_effective|number_format(2, '.', ',') }}</td>
                    <td class="text-success font-weight-bold">S/ {{ enroll_paid|number_format(2, '.', ',') }}</td>
                    <td class="{% if enroll_balance > 0 %}text-danger font-weight-bold{% else %}text-success{% endif %}">
                        S/ {{ enroll_balance|number_format(2, '.', ',') }}
                    </td>
                    <td>
                        {% if enroll.status == 'paid' %}
                            <span class="badge badge-success">{{ 'Paid'|get_plugin_lang('SchoolPlugin') }}</span>
                        {% elseif enroll.status == 'partial' %}
                            <span class="badge badge-warning">{{ 'Partial'|get_plugin_lang('SchoolPlugin') }}</span>
                        {% else %}
                            <span class="badge badge-danger">{{ 'Pending'|get_plugin_lang('SchoolPlugin') }}</span>
                        {% endif %}
                    </td>
                    <td>
                        {% if enroll.status != 'paid' %}
                        <button class="btn btn-success btn-sm" onclick="openPaymentModal('enrollment', null, {{ enroll_effective }}, {{ enroll_paid }}, {{ enroll_balance }})">
                            <i class="fas fa-money-bill-wave"></i> {% if enroll.status == 'partial' %}{{ 'CompletePayment'|get_plugin_lang('SchoolPlugin') }}{% else %}{{ 'RegisterPayment'|get_plugin_lang('SchoolPlugin') }}{% endif %}
                        </button>
                        {% endif %}
                        {% if enroll.id is defined and enroll.id %}
                        {% if enroll.voucher is defined and enroll.voucher %}
                        <button class="btn btn-warning btn-sm" onclick="viewVoucher('{{ enroll.voucher }}')" title="{{ 'ViewVoucher'|get_plugin_lang('SchoolPlugin') }}">
                            <i class="fas fa-image"></i>
                        </button>
                        {% endif %}
                        <a href="{{ _p.web }}payments/receipt?id={{ enroll.id }}" target="_blank" class="btn btn-info btn-sm" title="{{ 'PrintReceipt'|get_plugin_lang('SchoolPlugin') }}">
                            <i class="fas fa-print"></i>
                        </a>
                        <button class="btn btn-danger btn-sm" onclick="deletePayment({{ enroll.id }})">
                            <i class="fas fa-trash"></i>
                        </button>
                        {% endif %}
                    </td>
                </tr>
            </tbody>
        </table>

        <!-- Monthly Payments -->
        <h5><i class="fas fa-calendar"></i> {{ 'Monthly'|get_plugin_lang('SchoolPlugin') }}</h5>
        <table class="table table-bordered table-sm">
            <thead class="thead-light">
                <tr>
                    <th>{{ 'Months'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'OriginalAmount'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Discount'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'AmountToPay'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'AmountPaid'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Balance'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'PaymentDate'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                </tr>
            </thead>
            <tbody>
                {% for m, payment in payment_data.monthly %}
                {% set effective = payment.original_amount - payment.discount %}
                {% set paid_amount = payment.amount|default(0) %}
                {% set balance = effective - paid_amount %}
                <tr>
                    <td><strong>{{ month_names[m] }}</strong></td>
                    <td>S/ {{ payment.original_amount|number_format(2, '.', ',') }}</td>
                    <td>S/ {{ payment.discount|number_format(2, '.', ',') }}</td>
                    <td>S/ {{ effective|number_format(2, '.', ',') }}</td>
                    <td class="text-success font-weight-bold">S/ {{ paid_amount|number_format(2, '.', ',') }}</td>
                    <td class="{% if balance > 0 %}text-danger font-weight-bold{% else %}text-success{% endif %}">
                        S/ {{ balance|number_format(2, '.', ',') }}
                    </td>
                    <td>
                        {% if payment.status == 'paid' %}
                            <span class="badge badge-success">{{ 'Paid'|get_plugin_lang('SchoolPlugin') }}</span>
                        {% elseif payment.status == 'partial' %}
                            <span class="badge badge-warning">{{ 'Partial'|get_plugin_lang('SchoolPlugin') }}</span>
                        {% else %}
                            <span class="badge badge-danger">{{ 'Pending'|get_plugin_lang('SchoolPlugin') }}</span>
                        {% endif %}
                    </td>
                    <td>{{ payment.payment_date ?? '-' }}</td>
                    <td>
                        {% if payment.status != 'paid' %}
                        <button class="btn btn-success btn-sm" onclick="openPaymentModal('monthly', {{ m }}, {{ effective }}, {{ paid_amount }}, {{ balance }})">
                            <i class="fas fa-money-bill-wave"></i>
                            {% if payment.status == 'partial' %}
                                {{ 'CompletePayment'|get_plugin_lang('SchoolPlugin') }}
                            {% endif %}
                        </button>
                        {% endif %}
                        {% if payment.id is defined and payment.id %}
                        {% if payment.voucher is defined and payment.voucher %}
                        <button class="btn btn-warning btn-sm" onclick="viewVoucher('{{ payment.voucher }}')" title="{{ 'ViewVoucher'|get_plugin_lang('SchoolPlugin') }}">
                            <i class="fas fa-image"></i>
                        </button>
                        {% endif %}
                        <a href="{{ _p.web }}payments/receipt?id={{ payment.id }}" target="_blank" class="btn btn-info btn-sm" title="{{ 'PrintReceipt'|get_plugin_lang('SchoolPlugin') }}">
                            <i class="fas fa-print"></i>
                        </a>
                        <button class="btn btn-danger btn-sm" onclick="deletePayment({{ payment.id }})">
                            <i class="fas fa-trash"></i>
                        </button>
                        {% endif %}
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>

        <!-- Payment History (Notes) -->
        {% for m, payment in payment_data.monthly %}
            {% if payment.notes is defined and payment.notes %}
            <div class="mt-2 mb-1">
                <small class="text-muted"><strong>{{ month_names[m] }} - {{ 'PaymentHistory'|get_plugin_lang('SchoolPlugin') }}:</strong></small>
                <pre class="bg-light p-2 rounded mb-0" style="font-size: 0.8em; white-space: pre-wrap;">{{ payment.notes }}</pre>
            </div>
            {% endif %}
        {% endfor %}
    </div>
</div>

<!-- Payment Modal -->
<div class="modal fade" id="paymentModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">{{ 'RegisterPayment'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <!-- Payment info summary in modal -->
                <div id="modal_info" class="alert alert-info" style="display:none;">
                    <div class="row">
                        <div class="col-4 text-center">
                            <small>{{ 'AmountToPay'|get_plugin_lang('SchoolPlugin') }}</small>
                            <div class="font-weight-bold" id="modal_total">S/ 0.00</div>
                        </div>
                        <div class="col-4 text-center">
                            <small>{{ 'AmountPaid'|get_plugin_lang('SchoolPlugin') }}</small>
                            <div class="font-weight-bold text-success" id="modal_paid">S/ 0.00</div>
                        </div>
                        <div class="col-4 text-center">
                            <small>{{ 'Balance'|get_plugin_lang('SchoolPlugin') }}</small>
                            <div class="font-weight-bold text-danger" id="modal_balance">S/ 0.00</div>
                        </div>
                    </div>
                </div>

                <form id="paymentForm">
                    <input type="hidden" name="type" id="pay_type">
                    <input type="hidden" name="month" id="pay_month">
                    <div class="form-group">
                        <label>{{ 'AmountToRegister'|get_plugin_lang('SchoolPlugin') }} (S/) *</label>
                        <input type="number" class="form-control" name="amount" id="pay_amount" step="0.01" min="0.01" required>
                        <small class="form-text text-muted" id="pay_hint"></small>
                    </div>
                    <div class="form-group">
                        <label>{{ 'PaymentDate'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="date" class="form-control" name="payment_date" id="pay_date" value="{{ 'now'|date('Y-m-d') }}">
                    </div>
                    <div class="form-group">
                        <label>{{ 'PaymentMethod'|get_plugin_lang('SchoolPlugin') }}</label>
                        <select class="form-control" name="payment_method" id="pay_method">
                            <option value="cash">{{ 'Cash'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="transfer">{{ 'Transfer'|get_plugin_lang('SchoolPlugin') }}</option>
                            <option value="yape">Yape</option>
                            <option value="plin">Plin</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>{{ 'Reference'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="text" class="form-control" name="reference" id="pay_reference" placeholder="Nro. de recibo o transferencia">
                    </div>
                    <div class="form-group">
                        <label>{{ 'Notes'|get_plugin_lang('SchoolPlugin') }}</label>
                        <textarea class="form-control" name="notes" id="pay_notes" rows="2"></textarea>
                    </div>
                    <div class="form-group">
                        <label><i class="fas fa-image"></i> {{ 'Voucher'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="file" class="form-control-file" name="voucher" id="pay_voucher" accept="image/*">
                        <small class="form-text text-muted">{{ 'VoucherHint'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div id="voucher_preview" class="mt-2" style="display:none;">
                            <img id="voucher_preview_img" src="" style="max-width:200px;max-height:200px;border:1px solid #ddd;border-radius:4px;" />
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-outline-success" id="btn_pay_balance" onclick="payBalance()" style="display:none;">
                    <i class="fas fa-check-double"></i> {{ 'PayFullBalance'|get_plugin_lang('SchoolPlugin') }}
                </button>
                <button type="button" class="btn btn-primary" onclick="savePayment()">
                    <i class="fas fa-save"></i> {{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';
var periodId = {{ period_id }};
var studentId = {{ student_id }};
var currentBalance = 0;

function openPaymentModal(type, month, totalAmount, paidAmount, balance) {
    document.getElementById('pay_type').value = type;
    document.getElementById('pay_month').value = month || '';
    document.getElementById('pay_date').value = new Date().toISOString().split('T')[0];
    document.getElementById('pay_reference').value = '';
    document.getElementById('pay_notes').value = '';
    document.getElementById('pay_voucher').value = '';
    document.getElementById('voucher_preview').style.display = 'none';

    currentBalance = balance;

    // Show info summary
    var infoDiv = document.getElementById('modal_info');
    document.getElementById('modal_total').textContent = 'S/ ' + totalAmount.toFixed(2);
    document.getElementById('modal_paid').textContent = 'S/ ' + paidAmount.toFixed(2);
    document.getElementById('modal_balance').textContent = 'S/ ' + balance.toFixed(2);
    infoDiv.style.display = 'block';

    // Set default amount to the remaining balance
    document.getElementById('pay_amount').value = balance.toFixed(2);
    document.getElementById('pay_amount').max = balance.toFixed(2);

    // Hint text
    var hint = document.getElementById('pay_hint');
    if (paidAmount > 0) {
        hint.textContent = '{{ 'PartialPaymentHint'|get_plugin_lang('SchoolPlugin') }}'.replace('%s', 'S/ ' + paidAmount.toFixed(2)).replace('%s', 'S/ ' + balance.toFixed(2));
        hint.style.display = 'block';
    } else {
        hint.textContent = '';
        hint.style.display = 'none';
    }

    // Show "Pay full balance" button if partial
    var btnBalance = document.getElementById('btn_pay_balance');
    btnBalance.style.display = (paidAmount > 0 && balance > 0) ? 'inline-block' : 'none';

    $('#paymentModal').modal('show');
}

function payBalance() {
    document.getElementById('pay_amount').value = currentBalance.toFixed(2);
}

function savePayment() {
    var amount = parseFloat(document.getElementById('pay_amount').value);
    if (!amount || amount <= 0) {
        alert('{{ 'AmountMustBeGreaterThanZero'|get_plugin_lang('SchoolPlugin') }}');
        return;
    }

    var formData = new FormData();
    formData.append('action', 'save_payment');
    formData.append('period_id', periodId);
    formData.append('user_id', studentId);
    formData.append('type', document.getElementById('pay_type').value);
    formData.append('month', document.getElementById('pay_month').value);
    formData.append('amount', document.getElementById('pay_amount').value);
    formData.append('payment_date', document.getElementById('pay_date').value);
    formData.append('payment_method', document.getElementById('pay_method').value);
    formData.append('reference', document.getElementById('pay_reference').value);
    formData.append('notes', document.getElementById('pay_notes').value);

    // Append voucher file if selected
    var voucherInput = document.getElementById('pay_voucher');
    if (voucherInput.files.length > 0) {
        formData.append('voucher', voucherInput.files[0]);
    }

    fetch(ajaxUrl, { method: 'POST', body: formData })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                $('#paymentModal').modal('hide');
                if (data.payment_id && confirm('{{ 'PrintReceiptQuestion'|get_plugin_lang('SchoolPlugin') }}')) {
                    window.open('{{ _p.web }}payments/receipt?id=' + data.payment_id, '_blank');
                }
                location.reload();
            } else {
                alert(data.message || 'Error');
            }
        });
}

function deletePayment(id) {
    if (!confirm('{{ 'ConfirmDeletePayment'|get_plugin_lang('SchoolPlugin') }}')) return;

    var formData = new FormData();
    formData.append('action', 'delete_payment');
    formData.append('id', id);

    fetch(ajaxUrl, { method: 'POST', body: formData })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                location.reload();
            }
        });
}

// Voucher image preview on file select
document.getElementById('pay_voucher').addEventListener('change', function() {
    var preview = document.getElementById('voucher_preview');
    var previewImg = document.getElementById('voucher_preview_img');
    if (this.files && this.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            previewImg.src = e.target.result;
            preview.style.display = 'block';
        };
        reader.readAsDataURL(this.files[0]);
    } else {
        preview.style.display = 'none';
    }
});

function viewVoucher(fileName) {
    var url = '{{ _p.web }}plugin/school/uploads/' + fileName;
    window.open(url, '_blank', 'width=600,height=600');
}
</script>
