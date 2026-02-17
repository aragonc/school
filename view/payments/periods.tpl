{% include 'payments/tabs.tpl' with {'active_tab': 'periods'} %}

<div class="card mb-4">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="fas fa-calendar-alt"></i> {{ 'PaymentPeriods'|get_plugin_lang('SchoolPlugin') }}</span>
        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#periodModal" onclick="resetPeriodForm()">
            <i class="fas fa-plus"></i> {{ 'AddPeriod'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
    <div class="card-body">
        {% if periods|length > 0 %}
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead>
                    <tr>
                        <th>{{ 'PeriodName'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Year'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'MonthlyAmount'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Months'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for period in periods %}
                    <tr>
                        <td>
                            <a href="{{ _p.web }}payments/students?period_id={{ period.id }}">
                                <strong>{{ period.name }}</strong>
                            </a>
                        </td>
                        <td>{{ period.year }}</td>
                        <td>S/ {{ period.enrollment_amount|number_format(2, '.', ',') }}</td>
                        <td>S/ {{ period.monthly_amount|number_format(2, '.', ',') }}</td>
                        <td>
                            {% set monthNames = {1: 'Ene', 2: 'Feb', 3: 'Mar', 4: 'Abr', 5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Ago', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dic'} %}
                            {% set monthList = period.months|split(',') %}
                            {% for m in monthList %}
                                <span class="badge badge-info">{{ monthNames[m] }}</span>
                            {% endfor %}
                        </td>
                        <td>
                            {% if period.active %}
                                <span class="badge badge-success">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% else %}
                                <span class="badge badge-secondary">{{ 'Inactive'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% endif %}
                        </td>
                        <td>
                            <a href="{{ _p.web }}payments/students?period_id={{ period.id }}" class="btn btn-info btn-sm" title="{{ 'View'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-users"></i>
                            </a>
                            <button class="btn btn-warning btn-sm" onclick="editPeriod({{ period|json_encode }})" title="{{ 'EditPeriod'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-danger btn-sm" onclick="deletePeriod({{ period.id }})" title="{{ 'DeletePeriod'|get_plugin_lang('SchoolPlugin') }}">
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
            <i class="fas fa-info-circle"></i> {{ 'NoPaymentPeriods'|get_plugin_lang('SchoolPlugin') }}
        </div>
        {% endif %}
    </div>
</div>

<!-- Period Modal -->
<div class="modal fade" id="periodModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="periodModalTitle">{{ 'AddPeriod'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <form id="periodForm">
                    <input type="hidden" name="id" id="period_id" value="0">
                    <div class="form-group">
                        <label>{{ 'PeriodName'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <input type="text" class="form-control" name="name" id="period_name" required placeholder="Ej: Año Escolar 2026">
                    </div>
                    <div class="form-group">
                        <label>{{ 'Year'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <input type="number" class="form-control" name="year" id="period_year" value="{{ 'now'|date('Y') }}" min="2020" max="2050" required>
                    </div>
                    <div class="form-group">
                        <label>{{ 'EnrollmentAmount'|get_plugin_lang('SchoolPlugin') }} (S/)</label>
                        <input type="number" class="form-control" name="enrollment_amount" id="period_enrollment" step="0.01" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label>{{ 'MonthlyAmount'|get_plugin_lang('SchoolPlugin') }} (S/)</label>
                        <input type="number" class="form-control" name="monthly_amount" id="period_monthly" step="0.01" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label>{{ 'Months'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <div class="row">
                            {% set monthLabels = {1: 'Enero', 2: 'Febrero', 3: 'Marzo', 4: 'Abril', 5: 'Mayo', 6: 'Junio', 7: 'Julio', 8: 'Agosto', 9: 'Septiembre', 10: 'Octubre', 11: 'Noviembre', 12: 'Diciembre'} %}
                            {% for num, label in monthLabels %}
                            <div class="col-4">
                                <div class="custom-control custom-checkbox">
                                    <input type="checkbox" class="custom-control-input month-check" id="month_{{ num }}" value="{{ num }}">
                                    <label class="custom-control-label" for="month_{{ num }}">{{ label }}</label>
                                </div>
                            </div>
                            {% endfor %}
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="custom-control custom-checkbox">
                            <input type="checkbox" class="custom-control-input" id="period_active" checked>
                            <label class="custom-control-label" for="period_active">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</label>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="savePeriod()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';

function resetPeriodForm() {
    document.getElementById('periodModalTitle').textContent = '{{ 'AddPeriod'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('period_id').value = 0;
    document.getElementById('period_name').value = '';
    document.getElementById('period_year').value = new Date().getFullYear();
    document.getElementById('period_enrollment').value = 0;
    document.getElementById('period_monthly').value = 0;
    document.getElementById('period_active').checked = true;
    document.querySelectorAll('.month-check').forEach(function(cb) { cb.checked = false; });
}

function editPeriod(period) {
    document.getElementById('periodModalTitle').textContent = '{{ 'EditPeriod'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('period_id').value = period.id;
    document.getElementById('period_name').value = period.name;
    document.getElementById('period_year').value = period.year;
    document.getElementById('period_enrollment').value = period.enrollment_amount;
    document.getElementById('period_monthly').value = period.monthly_amount;
    document.getElementById('period_active').checked = period.active == 1;

    document.querySelectorAll('.month-check').forEach(function(cb) { cb.checked = false; });
    if (period.months) {
        var months = period.months.split(',');
        months.forEach(function(m) {
            var cb = document.getElementById('month_' + m.trim());
            if (cb) cb.checked = true;
        });
    }

    $('#periodModal').modal('show');
}

function savePeriod() {
    var months = [];
    document.querySelectorAll('.month-check:checked').forEach(function(cb) {
        months.push(cb.value);
    });

    var formData = new FormData();
    formData.append('action', 'save_period');
    formData.append('id', document.getElementById('period_id').value);
    formData.append('name', document.getElementById('period_name').value);
    formData.append('year', document.getElementById('period_year').value);
    formData.append('enrollment_amount', document.getElementById('period_enrollment').value);
    formData.append('monthly_amount', document.getElementById('period_monthly').value);
    formData.append('months', months.join(','));
    formData.append('active', document.getElementById('period_active').checked ? 1 : 0);

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

function deletePeriod(id) {
    if (!confirm('{{ 'ConfirmDeletePeriod'|get_plugin_lang('SchoolPlugin') }}')) return;

    var formData = new FormData();
    formData.append('action', 'delete_period');
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
