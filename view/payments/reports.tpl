{% include 'payments/tabs.tpl' with {'active_tab': 'reports'} %}

<!-- Filters -->
<div class="card mb-4">
    <div class="card-header">
        <i class="fas fa-filter"></i> {{ 'Filter'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body">
        <form method="get" class="form-inline">
            <div class="form-group mr-2 mb-2">
                <label class="mr-1">{{ 'SelectPeriod'|get_plugin_lang('SchoolPlugin') }}</label>
                <select name="period_id" class="form-control form-control-sm">
                    {% for p in periods %}
                    <option value="{{ p.id }}" {{ period_id == p.id ? 'selected' : '' }}>{{ p.name }} ({{ p.year }})</option>
                    {% endfor %}
                </select>
            </div>
            <div class="form-group mr-2 mb-2">
                <label class="mr-1">{{ 'Months'|get_plugin_lang('SchoolPlugin') }}</label>
                <select name="month" class="form-control form-control-sm">
                    <option value="">{{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }}</option>
                    {% if report.months is defined %}
                    {% for m in report.months %}
                        <option value="{{ m }}" {{ selected_month is not null and selected_month == m ? 'selected' : '' }}>{{ month_names[m] }}</option>
                    {% endfor %}
                    {% endif %}
                </select>
            </div>
            <div class="form-group mr-2 mb-2">
                <label class="mr-1">{{ 'ShowFilter'|get_plugin_lang('SchoolPlugin') }}</label>
                <select name="filter" class="form-control form-control-sm">
                    <option value="all" {{ filter == 'all' ? 'selected' : '' }}>{{ 'AllStudents'|get_plugin_lang('SchoolPlugin') }}</option>
                    <option value="debtors" {{ filter == 'debtors' ? 'selected' : '' }}>{{ 'Debtors'|get_plugin_lang('SchoolPlugin') }}</option>
                    <option value="paid" {{ filter == 'paid' ? 'selected' : '' }}>{{ 'PaidUp'|get_plugin_lang('SchoolPlugin') }}</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary btn-sm mb-2 mr-2">
                <i class="fas fa-search"></i> {{ 'Filter'|get_plugin_lang('SchoolPlugin') }}
            </button>
            <a href="{{ ajax_url }}?action=export_report&period_id={{ period_id }}&month={{ selected_month }}&filter={{ filter }}" class="btn btn-success btn-sm mb-2">
                <i class="fas fa-file-excel"></i> {{ 'ExportExcel'|get_plugin_lang('SchoolPlugin') }}
            </a>
        </form>
    </div>
</div>

{% if report.summary is defined %}

<!-- Summary Cards -->
<div class="row mb-4">
    <div class="col-md-2 col-6 mb-2">
        <div class="card text-center h-100">
            <div class="card-body py-2">
                <div class="h4 mb-0 font-weight-bold text-primary">{{ report.summary.total_students }}</div>
                <small class="text-muted">{{ 'TotalStudents'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
    <div class="col-md-2 col-6 mb-2">
        <div class="card text-center h-100">
            <div class="card-body py-2">
                <div class="h4 mb-0 font-weight-bold text-success">{{ report.summary.total_paid_students }}</div>
                <small class="text-muted">{{ 'PaidUp'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
    <div class="col-md-2 col-6 mb-2">
        <div class="card text-center h-100">
            <div class="card-body py-2">
                <div class="h4 mb-0 font-weight-bold text-danger">{{ report.summary.total_debtors }}</div>
                <small class="text-muted">{{ 'Debtors'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
    <div class="col-md-3 col-6 mb-2">
        <div class="card text-center h-100">
            <div class="card-body py-2">
                <div class="h5 mb-0 font-weight-bold text-success">S/ {{ report.summary.total_collected|number_format(2, '.', ',') }}</div>
                <small class="text-muted">{{ 'TotalCollected'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
    <div class="col-md-3 col-6 mb-2">
        <div class="card text-center h-100">
            <div class="card-body py-2">
                <div class="h5 mb-0 font-weight-bold text-danger">S/ {{ report.summary.total_pending|number_format(2, '.', ',') }}</div>
                <small class="text-muted">{{ 'TotalPending'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
</div>

<!-- Charts -->
<div class="row mb-4">
    <div class="col-md-8">
        <div class="card h-100">
            <div class="card-header">
                <i class="fas fa-chart-bar"></i> {{ 'MonthlyCollection'|get_plugin_lang('SchoolPlugin') }}
            </div>
            <div class="card-body">
                <canvas id="barChart" height="250"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card h-100">
            <div class="card-header">
                <i class="fas fa-chart-pie"></i> {{ 'PaymentStatus'|get_plugin_lang('SchoolPlugin') }}
            </div>
            <div class="card-body d-flex align-items-center justify-content-center">
                <canvas id="pieChart" height="250"></canvas>
            </div>
        </div>
    </div>
</div>

<!-- Students count per month chart -->
<div class="row mb-4">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header">
                <i class="fas fa-users"></i> {{ 'StudentsPerMonth'|get_plugin_lang('SchoolPlugin') }}
            </div>
            <div class="card-body">
                <canvas id="studentsChart" height="150"></canvas>
            </div>
        </div>
    </div>
</div>

<!-- Debtors Table -->
{% if filter != 'paid' and report.debtors|length > 0 %}
<div class="card mb-4">
    <div class="card-header bg-danger text-white">
        <i class="fas fa-exclamation-triangle"></i> {{ 'Debtors'|get_plugin_lang('SchoolPlugin') }} ({{ report.debtors|length }})
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-striped table-hover table-sm mb-0">
                <thead class="thead-light">
                    <tr>
                        <th>{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-center">{{ 'TotalPaid'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-center">{{ 'TotalPending'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'DetailMonths'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for student in report.debtors %}
                    <tr>
                        <td><strong>{{ student.lastname }}, {{ student.firstname }}</strong></td>
                        <td class="text-center text-success">S/ {{ student.total_paid|number_format(2, '.', ',') }}</td>
                        <td class="text-center text-danger font-weight-bold">S/ {{ student.total_debt|number_format(2, '.', ',') }}</td>
                        <td>
                            {% for item in student.items %}
                                {% if item.status == 'pending' %}
                                    <span class="badge badge-danger">{{ month_names[item.month]|slice(0,3) }}</span>
                                {% elseif item.status == 'partial' %}
                                    <span class="badge badge-warning">{{ month_names[item.month]|slice(0,3) }}</span>
                                {% else %}
                                    <span class="badge badge-success">{{ month_names[item.month]|slice(0,3) }}</span>
                                {% endif %}
                            {% endfor %}
                        </td>
                        <td>
                            <a href="{{ _p.web }}payments/register?period_id={{ period_id }}&user_id={{ student.user_id }}" class="btn btn-primary btn-sm">
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
{% endif %}

<!-- Paid Students Table -->
{% if filter != 'debtors' and report.paid|length > 0 %}
<div class="card mb-4">
    <div class="card-header bg-success text-white">
        <i class="fas fa-check-circle"></i> {{ 'PaidUp'|get_plugin_lang('SchoolPlugin') }} ({{ report.paid|length }})
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-striped table-hover table-sm mb-0">
                <thead class="thead-light">
                    <tr>
                        <th>{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-center">{{ 'TotalPaid'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'DetailMonths'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for student in report.paid %}
                    <tr>
                        <td>{{ student.lastname }}, {{ student.firstname }}</td>
                        <td class="text-center text-success">S/ {{ student.total_paid|number_format(2, '.', ',') }}</td>
                        <td>
                            {% for item in student.items %}
                                <span class="badge badge-success">{{ month_names[item.month]|slice(0,3) }}</span>
                            {% endfor %}
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</div>
{% endif %}

{% else %}
<div class="alert alert-info">
    <i class="fas fa-info-circle"></i> {{ 'NoPaymentPeriods'|get_plugin_lang('SchoolPlugin') }}
</div>
{% endif %}

<script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
<script>
{% if report.chart_data is defined %}
var chartData = {{ report.chart_data|json_encode|raw }};

// Bar Chart - Monthly Collection
new Chart(document.getElementById('barChart').getContext('2d'), {
    type: 'bar',
    data: {
        labels: chartData.labels,
        datasets: [
            {
                label: '{{ 'TotalCollected'|get_plugin_lang('SchoolPlugin') }}',
                data: chartData.paid,
                backgroundColor: 'rgba(28, 200, 138, 0.8)',
                borderColor: 'rgba(28, 200, 138, 1)',
                borderWidth: 1
            },
            {
                label: '{{ 'TotalPending'|get_plugin_lang('SchoolPlugin') }}',
                data: chartData.pending,
                backgroundColor: 'rgba(231, 74, 59, 0.8)',
                borderColor: 'rgba(231, 74, 59, 1)',
                borderWidth: 1
            }
        ]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
            y: {
                beginAtZero: true,
                ticks: {
                    callback: function(value) { return 'S/ ' + value.toLocaleString(); }
                }
            }
        },
        plugins: {
            tooltip: {
                callbacks: {
                    label: function(context) {
                        return context.dataset.label + ': S/ ' + context.parsed.y.toLocaleString('es-PE', {minimumFractionDigits: 2});
                    }
                }
            }
        }
    }
});

// Pie Chart - Payment Status
new Chart(document.getElementById('pieChart').getContext('2d'), {
    type: 'doughnut',
    data: {
        labels: ['{{ 'PaidUp'|get_plugin_lang('SchoolPlugin') }}', '{{ 'Debtors'|get_plugin_lang('SchoolPlugin') }}'],
        datasets: [{
            data: [{{ report.summary.total_paid_students }}, {{ report.summary.total_debtors }}],
            backgroundColor: ['rgba(28, 200, 138, 0.8)', 'rgba(231, 74, 59, 0.8)'],
            borderColor: ['rgba(28, 200, 138, 1)', 'rgba(231, 74, 59, 1)'],
            borderWidth: 2
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                position: 'bottom'
            },
            tooltip: {
                callbacks: {
                    label: function(context) {
                        var total = context.dataset.data.reduce(function(a, b) { return a + b; }, 0);
                        var pct = total > 0 ? ((context.parsed / total) * 100).toFixed(1) : 0;
                        return context.label + ': ' + context.parsed + ' (' + pct + '%)';
                    }
                }
            }
        }
    }
});

// Students per month chart
new Chart(document.getElementById('studentsChart').getContext('2d'), {
    type: 'bar',
    data: {
        labels: chartData.labels,
        datasets: [
            {
                label: '{{ 'PaidUp'|get_plugin_lang('SchoolPlugin') }}',
                data: chartData.paid_count,
                backgroundColor: 'rgba(28, 200, 138, 0.7)',
                borderColor: 'rgba(28, 200, 138, 1)',
                borderWidth: 1
            },
            {
                label: '{{ 'Debtors'|get_plugin_lang('SchoolPlugin') }}',
                data: chartData.pending_count,
                backgroundColor: 'rgba(231, 74, 59, 0.7)',
                borderColor: 'rgba(231, 74, 59, 1)',
                borderWidth: 1
            }
        ]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
            y: {
                beginAtZero: true,
                ticks: {
                    stepSize: 1,
                    callback: function(value) { return value + ' alumnos'; }
                }
            }
        }
    }
});
{% endif %}
</script>
