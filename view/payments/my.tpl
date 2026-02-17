<div class="card mb-4">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="fas fa-money-bill-wave"></i> {{ 'MyPayments'|get_plugin_lang('SchoolPlugin') }}</span>
        {% if periods|length > 1 %}
        <form method="get" class="form-inline">
            <select name="period_id" class="form-control form-control-sm" onchange="this.form.submit()">
                {% for p in periods %}
                <option value="{{ p.id }}" {{ period_id == p.id ? 'selected' : '' }}>{{ p.name }} ({{ p.year }})</option>
                {% endfor %}
            </select>
        </form>
        {% endif %}
    </div>
    <div class="card-body">
        {% if payment_data is empty or payment_data.period is not defined %}
        <div class="alert alert-info">
            <i class="fas fa-info-circle"></i> {{ 'NoPaymentPeriods'|get_plugin_lang('SchoolPlugin') }}
        </div>
        {% else %}

        <!-- Summary Cards -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card border-left-success" style="border-left: 4px solid #1cc88a;">
                    <div class="card-body py-2 text-center">
                        <small class="text-muted">{{ 'TotalPaid'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div class="h5 text-success mb-0">S/ {{ payment_data.total_paid|number_format(2, '.', ',') }}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-left-danger" style="border-left: 4px solid #e74a3b;">
                    <div class="card-body py-2 text-center">
                        <small class="text-muted">{{ 'TotalPending'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div class="h5 text-danger mb-0">S/ {{ payment_data.total_pending|number_format(2, '.', ',') }}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-left-warning" style="border-left: 4px solid #f6c23e;">
                    <div class="card-body py-2 text-center">
                        <small class="text-muted">{{ 'TotalDiscount'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div class="h5 text-warning mb-0">S/ {{ payment_data.total_discount|number_format(2, '.', ',') }}</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Enrollment -->
        <h5 class="mb-3"><i class="fas fa-graduation-cap"></i> {{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}</h5>
        <div class="card mb-4 {% if payment_data.enrollment.status == 'paid' %}border-success{% elseif payment_data.enrollment.status == 'partial' %}border-warning{% else %}border-danger{% endif %}">
            <div class="card-body py-2 d-flex justify-content-between align-items-center">
                <div>
                    <strong>{{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}</strong>
                    {% if payment_data.enrollment.discount > 0 %}
                        <br><small class="text-muted"><del>S/ {{ payment_data.enrollment.original_amount|number_format(2, '.', ',') }}</del> — {{ 'Discount'|get_plugin_lang('SchoolPlugin') }}: S/ {{ payment_data.enrollment.discount|number_format(2, '.', ',') }}</small>
                    {% endif %}
                </div>
                <div class="text-right">
                    <div class="h5 mb-0">S/ {{ payment_data.enrollment.amount|number_format(2, '.', ',') }}</div>
                    {% if payment_data.enrollment.status == 'paid' %}
                        <span class="badge badge-success">{{ 'Paid'|get_plugin_lang('SchoolPlugin') }}</span>
                    {% elseif payment_data.enrollment.status == 'partial' %}
                        <span class="badge badge-warning">{{ 'Partial'|get_plugin_lang('SchoolPlugin') }}</span>
                    {% else %}
                        <span class="badge badge-danger">{{ 'Pending'|get_plugin_lang('SchoolPlugin') }}</span>
                    {% endif %}
                </div>
            </div>
        </div>

        <!-- Monthly Payments -->
        <h5 class="mb-3"><i class="fas fa-calendar"></i> {{ 'Monthly'|get_plugin_lang('SchoolPlugin') }}</h5>
        <div class="table-responsive">
            <table class="table table-bordered table-hover">
                <thead class="thead-light">
                    <tr>
                        <th>{{ 'Months'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'OriginalAmount'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Discount'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Amount'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'PaymentDate'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Reference'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for m, payment in payment_data.monthly %}
                    <tr>
                        <td><strong>{{ month_names[m] }}</strong></td>
                        <td>S/ {{ payment.original_amount|number_format(2, '.', ',') }}</td>
                        <td>
                            {% if payment.discount > 0 %}
                            S/ {{ payment.discount|number_format(2, '.', ',') }}
                            {% else %}
                            -
                            {% endif %}
                        </td>
                        <td><strong>S/ {{ payment.amount|number_format(2, '.', ',') }}</strong></td>
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
                        <td>{{ payment.reference ?? '-' }}</td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>

        {% endif %}
    </div>
</div>
