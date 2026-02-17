{% include 'payments/tabs.tpl' with {'active_tab': 'periods'} %}

<div class="mb-3">
    <a href="{{ _p.web }}payments" class="btn btn-outline-secondary btn-sm">
        <i class="fas fa-arrow-left"></i> {{ 'PaymentPeriods'|get_plugin_lang('SchoolPlugin') }}
    </a>
</div>

<!-- Summary Cards -->
<div class="row mb-4">
    <div class="col-md-3">
        <div class="card border-left-primary" style="border-left: 4px solid #4e73df;">
            <div class="card-body py-2">
                <div class="text-xs text-uppercase text-muted">{{ 'TotalPaid'|get_plugin_lang('SchoolPlugin') }}</div>
                <div class="h5 mb-0 font-weight-bold text-success">S/ {{ summary.total_collected|number_format(2, '.', ',') }}</div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-left-danger" style="border-left: 4px solid #e74a3b;">
            <div class="card-body py-2">
                <div class="text-xs text-uppercase text-muted">{{ 'TotalPending'|get_plugin_lang('SchoolPlugin') }}</div>
                <div class="h5 mb-0 font-weight-bold text-danger">S/ {{ summary.total_pending|number_format(2, '.', ',') }}</div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-left-warning" style="border-left: 4px solid #f6c23e;">
            <div class="card-body py-2">
                <div class="text-xs text-uppercase text-muted">{{ 'TotalDiscount'|get_plugin_lang('SchoolPlugin') }}</div>
                <div class="h5 mb-0 font-weight-bold text-warning">S/ {{ summary.total_discounts|number_format(2, '.', ',') }}</div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-left-info" style="border-left: 4px solid #36b9cc;">
            <div class="card-body py-2">
                <div class="text-xs text-uppercase text-muted">{{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}</div>
                <div class="h5 mb-0 font-weight-bold text-info">{{ summary.enrollments_paid }}</div>
            </div>
        </div>
    </div>
</div>

<!-- Search -->
<div class="card mb-3">
    <div class="card-body py-2">
        <form method="get" class="form-inline">
            <input type="hidden" name="period_id" value="{{ period_id }}">
            <div class="form-group mr-2">
                <input type="text" name="search" class="form-control form-control-sm" placeholder="{{ 'SearchByName'|get_plugin_lang('SchoolPlugin') }}" value="{{ search }}" style="min-width: 250px;">
            </div>
            <button type="submit" class="btn btn-primary btn-sm mr-2">
                <i class="fas fa-search"></i> {{ 'Filter'|get_plugin_lang('SchoolPlugin') }}
            </button>
            {% if search %}
            <a href="{{ _p.web }}payments/students?period_id={{ period_id }}" class="btn btn-outline-secondary btn-sm">
                <i class="fas fa-times"></i>
            </a>
            {% endif %}
        </form>
    </div>
</div>

<!-- Students Table -->
<div class="card">
    <div class="card-header">
        <i class="fas fa-users"></i> {{ period.name }} - {{ 'StudentPayments'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-bordered table-hover table-sm mb-0">
                <thead class="thead-light">
                    <tr>
                        <th style="min-width:200px; position:sticky; left:0; background:#f8f9fa; z-index:1;">{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-center" style="min-width:80px;">{{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}</th>
                        {% for m in months %}
                        <th class="text-center" style="min-width:70px;">{{ month_names[m]|slice(0,3) }}</th>
                        {% endfor %}
                        <th class="text-center" style="min-width:80px;">{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for student in students %}
                    <tr>
                        <td style="position:sticky; left:0; background:#fff; z-index:1;">
                            <strong>{{ student.lastname }}, {{ student.firstname }}</strong>
                        </td>
                        <!-- Enrollment cell -->
                        <td class="text-center">
                            {% if student.payments.enrollment %}
                                {% if student.payments.enrollment.status == 'paid' %}
                                    <span class="badge badge-success" title="S/ {{ student.payments.enrollment.amount }}"><i class="fas fa-check"></i></span>
                                {% elseif student.payments.enrollment.status == 'partial' %}
                                    <span class="badge badge-warning" title="S/ {{ student.payments.enrollment.amount }}"><i class="fas fa-minus"></i></span>
                                {% else %}
                                    <span class="badge badge-danger"><i class="fas fa-times"></i></span>
                                {% endif %}
                            {% else %}
                                <span class="badge badge-danger"><i class="fas fa-times"></i></span>
                            {% endif %}
                        </td>
                        <!-- Monthly cells -->
                        {% for m in months %}
                        <td class="text-center">
                            {% set mInt = m|number_format(0) %}
                            {% if student.payments.months[mInt] is defined %}
                                {% if student.payments.months[mInt].status == 'paid' %}
                                    <span class="badge badge-success" title="S/ {{ student.payments.months[mInt].amount }}"><i class="fas fa-check"></i></span>
                                {% elseif student.payments.months[mInt].status == 'partial' %}
                                    <span class="badge badge-warning" title="S/ {{ student.payments.months[mInt].amount }}"><i class="fas fa-minus"></i></span>
                                {% else %}
                                    <span class="badge badge-danger"><i class="fas fa-times"></i></span>
                                {% endif %}
                            {% else %}
                                <span class="badge badge-danger"><i class="fas fa-times"></i></span>
                            {% endif %}
                        </td>
                        {% endfor %}
                        <td class="text-center">
                            <a href="{{ _p.web }}payments/register?period_id={{ period_id }}&user_id={{ student.user_id }}" class="btn btn-primary btn-sm" title="{{ 'RegisterPayment'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-money-bill-wave"></i>
                            </a>
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</div>

<style>
.badge { font-size: 0.85em; padding: 4px 8px; }
</style>
