{% include 'payments/tabs.tpl' with {'active_tab': 'pricing'} %}

<!-- Period selector -->
<div class="card mb-4">
    <div class="card-body py-2 d-flex justify-content-between align-items-center">
        <form method="get" class="form-inline">
            <label class="mr-2"><strong>{{ 'PaymentPeriod'|get_plugin_lang('SchoolPlugin') }}:</strong></label>
            <select name="period_id" class="form-control form-control-sm mr-2" onchange="this.form.submit()">
                {% for p in periods %}
                <option value="{{ p.id }}" {{ period_id == p.id ? 'selected' : '' }}>{{ p.name }} ({{ p.year }})</option>
                {% endfor %}
            </select>
        </form>
        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#priceModal" onclick="resetPriceForm()">
            <i class="fas fa-plus"></i> {{ 'AddPrice'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
</div>

{% if current_period %}
<!-- Default period prices info -->
<div class="alert alert-secondary mb-4">
    <i class="fas fa-info-circle"></i>
    <strong>{{ 'DefaultPrices'|get_plugin_lang('SchoolPlugin') }}:</strong>
    {{ 'Admission'|get_plugin_lang('SchoolPlugin') }}: <strong>S/ {{ current_period.admission_amount|number_format(2, '.', ',') }}</strong> |
    {{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}: <strong>S/ {{ current_period.enrollment_amount|number_format(2, '.', ',') }}</strong> |
    {{ 'Monthly'|get_plugin_lang('SchoolPlugin') }}: <strong>S/ {{ current_period.monthly_amount|number_format(2, '.', ',') }}</strong>
    <br><small class="text-muted">{{ 'DefaultPricesHint'|get_plugin_lang('SchoolPlugin') }}</small>
</div>

<!-- Price table -->
<div class="card">
    <div class="card-header">
        <i class="fas fa-tags"></i> {{ 'PricesByLevel'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body p-0">
        {% if prices|length > 0 %}
        <table class="table table-striped table-hover mb-0">
            <thead>
                <tr>
                    <th>{{ 'Level'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th class="text-right">{{ 'Admission'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th class="text-right">{{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th class="text-right">{{ 'MonthlyAmount'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                </tr>
            </thead>
            <tbody>
                {% for price in prices %}
                <tr class="{{ price.grade_id ? '' : 'table-info' }}">
                    <td><strong>{{ price.level_name }}</strong></td>
                    <td>
                        {% if price.grade_id %}
                            <span class="badge badge-warning">{{ price.grade_name }}</span>
                            <small class="text-muted">({{ 'GradeOverride'|get_plugin_lang('SchoolPlugin') }})</small>
                        {% else %}
                            <span class="badge badge-info">{{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }}</span>
                        {% endif %}
                    </td>
                    <td class="text-right">S/ {{ price.admission_amount|number_format(2, '.', ',') }}</td>
                    <td class="text-right">S/ {{ price.enrollment_amount|number_format(2, '.', ',') }}</td>
                    <td class="text-right">S/ {{ price.monthly_amount|number_format(2, '.', ',') }}</td>
                    <td>
                        <button class="btn btn-warning btn-sm btn-edit-price"
                                data-price="{{ price|json_encode|e }}">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-danger btn-sm" onclick="deletePrice({{ price.id }})">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
        {% else %}
        <div class="p-3">
            <div class="alert alert-info mb-0">
                <i class="fas fa-info-circle"></i> {{ 'NoPricesConfigured'|get_plugin_lang('SchoolPlugin') }}
            </div>
        </div>
        {% endif %}
    </div>
</div>
{% else %}
<div class="alert alert-warning">
    <i class="fas fa-exclamation-triangle"></i> {{ 'NoPaymentPeriods'|get_plugin_lang('SchoolPlugin') }}
</div>
{% endif %}

<!-- Price Modal -->
<div class="modal fade" id="priceModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="priceModalTitle">{{ 'AddPrice'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="price_id" value="0">

                <!-- ADD MODE: nivel con multi-grado -->
                <div id="section-add">
                    <div class="form-group">
                        <label>{{ 'Level'|get_plugin_lang('SchoolPlugin') }} *</label>
                        <select class="form-control" id="price_level" required onchange="buildGradeCheckboxes()">
                            <option value="">{{ 'SelectOption'|get_plugin_lang('SchoolPlugin') }}</option>
                            {% for l in levels %}
                            <option value="{{ l.id }}">{{ l.name }}</option>
                            {% endfor %}
                        </select>
                    </div>
                    <div class="form-group" id="grade-checkboxes-group" style="display:none;">
                        <label>{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</label>
                        <div id="grade-checkboxes" class="border rounded p-2" style="max-height:160px; overflow-y:auto;"></div>
                        <small class="text-muted">{{ 'GradeMultiHint'|get_plugin_lang('SchoolPlugin') }}</small>
                    </div>
                </div>

                <!-- EDIT MODE: nivel/grado fijos -->
                <div id="section-edit" style="display:none;">
                    <div class="form-group">
                        <label>{{ 'Level'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="text" class="form-control" id="edit_level_name" readonly>
                        <input type="hidden" id="edit_level_id">
                    </div>
                    <div class="form-group">
                        <label>{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</label>
                        <input type="text" class="form-control" id="edit_grade_name" readonly>
                        <input type="hidden" id="edit_grade_id">
                    </div>
                </div>

                <!-- Montos (comunes a add y edit) -->
                <div class="form-row">
                    <div class="form-group col-md-4">
                        <label>{{ 'Admission'|get_plugin_lang('SchoolPlugin') }} (S/)</label>
                        <input type="number" class="form-control" id="price_admission" step="0.01" min="0" value="0">
                    </div>
                    <div class="form-group col-md-4">
                        <label>{{ 'Enrollment'|get_plugin_lang('SchoolPlugin') }} (S/)</label>
                        <input type="number" class="form-control" id="price_enrollment" step="0.01" min="0" value="0">
                    </div>
                    <div class="form-group col-md-4">
                        <label>{{ 'MonthlyAmount'|get_plugin_lang('SchoolPlugin') }} (S/)</label>
                        <input type="number" class="form-control" id="price_monthly" step="0.01" min="0" value="0">
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="savePrice()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';
var periodId = {{ period_id }};
var allGrades = {{ grades|json_encode|raw }};

function buildGradeCheckboxes() {
    var levelId = document.getElementById('price_level').value;
    var container = document.getElementById('grade-checkboxes');
    var group = document.getElementById('grade-checkboxes-group');
    container.innerHTML = '';

    if (!levelId) { group.style.display = 'none'; return; }

    var filtered = allGrades.filter(function(g) { return g.level_id == levelId; });
    if (filtered.length === 0) { group.style.display = 'none'; return; }

    // Opción "todos los grados"
    var allLabel = document.createElement('label');
    allLabel.className = 'custom-control custom-checkbox d-block mb-1';
    allLabel.innerHTML = '<input type="checkbox" class="custom-control-input grade-check" value="" id="gc_all">'
        + '<label class="custom-control-label font-italic" for="gc_all">{{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }} ({{ 'LevelPrice'|get_plugin_lang('SchoolPlugin') }})</label>';
    container.appendChild(allLabel);

    filtered.forEach(function(g) {
        var id = 'gc_' + g.id;
        var item = document.createElement('label');
        item.className = 'custom-control custom-checkbox d-block mb-1';
        item.innerHTML = '<input type="checkbox" class="custom-control-input grade-check" value="' + g.id + '" id="' + id + '">'
            + '<label class="custom-control-label" for="' + id + '">' + g.name + '</label>';
        container.appendChild(item);
    });

    group.style.display = 'block';
}

function resetPriceForm() {
    document.getElementById('priceModalTitle').textContent = '{{ 'AddPrice'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('price_id').value = 0;
    document.getElementById('price_level').value = '';
    document.getElementById('grade-checkboxes').innerHTML = '';
    document.getElementById('grade-checkboxes-group').style.display = 'none';
    document.getElementById('price_admission').value = 0;
    document.getElementById('price_enrollment').value = 0;
    document.getElementById('price_monthly').value = 0;
    document.getElementById('section-add').style.display = 'block';
    document.getElementById('section-edit').style.display = 'none';
}

document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.btn-edit-price').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var p = JSON.parse(this.getAttribute('data-price'));
            editPrice(p);
        });
    });
});

function editPrice(p) {
    document.getElementById('priceModalTitle').textContent = '{{ 'EditPrice'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('price_id').value = p.id;
    document.getElementById('section-add').style.display = 'none';
    document.getElementById('section-edit').style.display = 'block';

    document.getElementById('edit_level_name').value = p.level_name;
    document.getElementById('edit_level_id').value = p.level_id;
    document.getElementById('edit_grade_name').value = p.grade_id ? p.grade_name : '{{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('edit_grade_id').value = p.grade_id ? p.grade_id : '';

    document.getElementById('price_admission').value = p.admission_amount;
    document.getElementById('price_enrollment').value = p.enrollment_amount;
    document.getElementById('price_monthly').value = p.monthly_amount;
    $('#priceModal').modal('show');
}

function savePrice() {
    var priceId = parseInt(document.getElementById('price_id').value);
    var admission = document.getElementById('price_admission').value;
    var enrollment = document.getElementById('price_enrollment').value;
    var monthly = document.getElementById('price_monthly').value;

    if (priceId > 0) {
        // EDIT MODE: single record
        var fd = new FormData();
        fd.append('action', 'save_period_price');
        fd.append('id', priceId);
        fd.append('period_id', periodId);
        fd.append('level_id', document.getElementById('edit_level_id').value);
        fd.append('grade_id', document.getElementById('edit_grade_id').value);
        fd.append('admission_amount', admission);
        fd.append('enrollment_amount', enrollment);
        fd.append('monthly_amount', monthly);
        fetch(ajaxUrl, {method:'POST', body:fd}).then(r=>r.json()).then(d=>{
            if (d.success) location.reload(); else alert(d.message || 'Error');
        });
        return;
    }

    // ADD MODE: multi-grade
    var levelId = document.getElementById('price_level').value;
    if (!levelId) { alert('{{ 'SelectLevel'|get_plugin_lang('SchoolPlugin') }}'); return; }

    var checked = document.querySelectorAll('.grade-check:checked');
    var gradeIds = [];
    checked.forEach(function(cb) { gradeIds.push(cb.value); });
    if (gradeIds.length === 0) { gradeIds = ['']; } // sin grado = nivel completo

    var fd = new FormData();
    fd.append('action', 'save_period_price');
    fd.append('id', 0);
    fd.append('period_id', periodId);
    fd.append('level_id', levelId);
    fd.append('admission_amount', admission);
    fd.append('enrollment_amount', enrollment);
    fd.append('monthly_amount', monthly);
    gradeIds.forEach(function(gid) { fd.append('grade_ids[]', gid); });

    fetch(ajaxUrl, {method:'POST', body:fd}).then(r=>r.json()).then(d=>{
        if (d.success) location.reload(); else alert(d.message || 'Error');
    });
}

function deletePrice(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData();
    fd.append('action', 'delete_period_price');
    fd.append('id', id);
    fetch(ajaxUrl, {method:'POST', body:fd}).then(r=>r.json()).then(d=>{if(d.success)location.reload();});
}
</script>
