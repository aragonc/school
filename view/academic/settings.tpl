{% include 'academic/tabs.tpl' with {'active_tab': 'settings', 'is_admin': true} %}

<!-- Settings Tabs -->
<ul class="nav nav-pills mb-4" id="settingsTabs" role="tablist">
    <li class="nav-item">
        <a class="nav-link active" id="years-tab" data-toggle="pill" href="#years-panel" role="tab">
            <i class="fas fa-calendar"></i> {{ 'AcademicYears'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link" id="levels-tab" data-toggle="pill" href="#levels-panel" role="tab">
            <i class="fas fa-layer-group"></i> {{ 'Levels'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link" id="grades-tab" data-toggle="pill" href="#grades-panel" role="tab">
            <i class="fas fa-graduation-cap"></i> {{ 'Grades'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link" id="sections-tab" data-toggle="pill" href="#sections-panel" role="tab">
            <i class="fas fa-th-large"></i> {{ 'Sections'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>

<div class="tab-content" id="settingsTabContent">
    <!-- ================================================================ -->
    <!-- YEARS TAB -->
    <!-- ================================================================ -->
    <div class="tab-pane fade show active" id="years-panel" role="tabpanel">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="fas fa-calendar"></i> {{ 'AcademicYears'|get_plugin_lang('SchoolPlugin') }}</span>
                <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#yearModal" onclick="resetYearForm()">
                    <i class="fas fa-plus"></i> {{ 'Add'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
            <div class="card-body p-0">
                {% if years|length > 0 %}
                <table class="table table-striped table-hover mb-0">
                    <thead>
                        <tr>
                            <th>{{ 'Name'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Year'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for y in years %}
                        <tr>
                            <td><strong>{{ y.name }}</strong></td>
                            <td>{{ y.year }}</td>
                            <td>
                                {% if y.active %}
                                    <span class="badge badge-success">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% else %}
                                    <span class="badge badge-secondary">{{ 'Inactive'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% endif %}
                            </td>
                            <td>
                                <button class="btn btn-warning btn-sm" onclick="editYear({{ y|json_encode|e('html_attr') }})">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-danger btn-sm" onclick="deleteYear({{ y.id }})">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                {% else %}
                <div class="p-3"><div class="alert alert-info mb-0"><i class="fas fa-info-circle"></i> {{ 'NoAcademicYears'|get_plugin_lang('SchoolPlugin') }}</div></div>
                {% endif %}
            </div>
        </div>
    </div>

    <!-- ================================================================ -->
    <!-- LEVELS TAB -->
    <!-- ================================================================ -->
    <div class="tab-pane fade" id="levels-panel" role="tabpanel">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="fas fa-layer-group"></i> {{ 'Levels'|get_plugin_lang('SchoolPlugin') }}</span>
                <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#levelModal" onclick="resetLevelForm()">
                    <i class="fas fa-plus"></i> {{ 'Add'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
            <div class="card-body p-0">
                {% if levels|length > 0 %}
                <table class="table table-striped table-hover mb-0">
                    <thead>
                        <tr>
                            <th>{{ 'Name'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Order'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th title="Años de duración del nivel (para cálculo de devoluciones)">Duración</th>
                            <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for l in levels %}
                        <tr>
                            <td><strong>{{ l.name }}</strong></td>
                            <td>{{ l.order_index }}</td>
                            <td>{{ l.years_duration }} año(s)</td>
                            <td>
                                {% if l.active %}
                                    <span class="badge badge-success">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% else %}
                                    <span class="badge badge-secondary">{{ 'Inactive'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% endif %}
                            </td>
                            <td>
                                <button class="btn btn-warning btn-sm" onclick="editLevel({{ l|json_encode|e('html_attr') }})">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-danger btn-sm" onclick="deleteLevel({{ l.id }})">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                {% else %}
                <div class="p-3"><div class="alert alert-info mb-0"><i class="fas fa-info-circle"></i> {{ 'NoLevels'|get_plugin_lang('SchoolPlugin') }}</div></div>
                {% endif %}
            </div>
        </div>
    </div>

    <!-- ================================================================ -->
    <!-- GRADES TAB -->
    <!-- ================================================================ -->
    <div class="tab-pane fade" id="grades-panel" role="tabpanel">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="fas fa-graduation-cap"></i> {{ 'Grades'|get_plugin_lang('SchoolPlugin') }}</span>
                <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#gradeModal" onclick="resetGradeForm()">
                    <i class="fas fa-plus"></i> {{ 'Add'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
            <div class="card-body p-0">
                {% if grades|length > 0 %}
                <table class="table table-striped table-hover mb-0">
                    <thead>
                        <tr>
                            <th>{{ 'Level'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Name'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Order'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for g in grades %}
                        <tr>
                            <td><span class="badge badge-info">{{ g.level_name }}</span></td>
                            <td><strong>{{ g.name }}</strong></td>
                            <td>{{ g.order_index }}</td>
                            <td>
                                {% if g.active %}
                                    <span class="badge badge-success">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% else %}
                                    <span class="badge badge-secondary">{{ 'Inactive'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% endif %}
                            </td>
                            <td>
                                <button class="btn btn-warning btn-sm" onclick="editGrade({{ g|json_encode|e('html_attr') }})">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-danger btn-sm" onclick="deleteGrade({{ g.id }})">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                {% else %}
                <div class="p-3"><div class="alert alert-info mb-0"><i class="fas fa-info-circle"></i> {{ 'NoGrades'|get_plugin_lang('SchoolPlugin') }}</div></div>
                {% endif %}
            </div>
        </div>
    </div>

    <!-- ================================================================ -->
    <!-- SECTIONS TAB -->
    <!-- ================================================================ -->
    <div class="tab-pane fade" id="sections-panel" role="tabpanel">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="fas fa-th-large"></i> {{ 'Sections'|get_plugin_lang('SchoolPlugin') }}</span>
                <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#sectionModal" onclick="resetSectionForm()">
                    <i class="fas fa-plus"></i> {{ 'Add'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
            <div class="card-body p-0">
                {% if sections|length > 0 %}
                <table class="table table-striped table-hover mb-0">
                    <thead>
                        <tr>
                            <th>{{ 'Name'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for s in sections %}
                        <tr>
                            <td><strong>{{ s.name }}</strong></td>
                            <td>
                                {% if s.active %}
                                    <span class="badge badge-success">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% else %}
                                    <span class="badge badge-secondary">{{ 'Inactive'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% endif %}
                            </td>
                            <td>
                                <button class="btn btn-warning btn-sm" onclick="editSection({{ s|json_encode|e('html_attr') }})">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-danger btn-sm" onclick="deleteSection({{ s.id }})">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                {% else %}
                <div class="p-3"><div class="alert alert-info mb-0"><i class="fas fa-info-circle"></i> {{ 'NoSections'|get_plugin_lang('SchoolPlugin') }}</div></div>
                {% endif %}
            </div>
        </div>
    </div>
</div>

<!-- ================================================================ -->
<!-- MODALS -->
<!-- ================================================================ -->

<!-- Year Modal -->
<div class="modal fade" id="yearModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="yearModalTitle">{{ 'AddAcademicYear'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="year_id" value="0">
                <div class="form-group">
                    <label>{{ 'Name'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" class="form-control" id="year_name" required placeholder="Ej: 2026">
                </div>
                <div class="form-group">
                    <label>{{ 'Year'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="number" class="form-control" id="year_value" value="{{ 'now'|date('Y') }}" min="2020" max="2050" required>
                </div>
                <div class="custom-control custom-checkbox">
                    <input type="checkbox" class="custom-control-input" id="year_active" checked>
                    <label class="custom-control-label" for="year_active">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</label>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveYear()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<!-- Level Modal -->
<div class="modal fade" id="levelModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="levelModalTitle">{{ 'AddLevel'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="level_id" value="0">
                <div class="form-group">
                    <label>{{ 'Name'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" class="form-control" id="level_name" required placeholder="Ej: Inicial, Primaria, Secundaria">
                </div>
                <div class="form-group">
                    <label>{{ 'Order'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="number" class="form-control" id="level_order" value="0" min="0">
                </div>
                <div class="form-group">
                    <label>Duración del nivel (años) *</label>
                    <input type="number" class="form-control" id="level_years_duration" value="1" min="1" max="20">
                    <small class="form-text text-muted">Total de años que dura este nivel educativo. Se usa para calcular la devolución de cuota de ingreso al retiro (norma Minedu).</small>
                </div>
                <div class="custom-control custom-checkbox">
                    <input type="checkbox" class="custom-control-input" id="level_active" checked>
                    <label class="custom-control-label" for="level_active">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</label>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveLevel()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<!-- Grade Modal -->
<div class="modal fade" id="gradeModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="gradeModalTitle">{{ 'AddGrade'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="grade_id" value="0">
                <div class="form-group">
                    <label>{{ 'Level'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <select class="form-control" id="grade_level" required>
                        <option value="">{{ 'SelectOption'|get_plugin_lang('SchoolPlugin') }}</option>
                        {% for l in levels %}
                        <option value="{{ l.id }}">{{ l.name }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group">
                    <label>{{ 'Name'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" class="form-control" id="grade_name" required placeholder="Ej: 1er Grado, 2do Grado">
                </div>
                <div class="form-group">
                    <label>{{ 'Order'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="number" class="form-control" id="grade_order" value="0" min="0">
                </div>
                <div class="custom-control custom-checkbox">
                    <input type="checkbox" class="custom-control-input" id="grade_active" checked>
                    <label class="custom-control-label" for="grade_active">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</label>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveGrade()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<!-- Section Modal -->
<div class="modal fade" id="sectionModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="sectionModalTitle">{{ 'AddSection'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="section_id" value="0">
                <div class="form-group">
                    <label>{{ 'Name'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" class="form-control" id="section_name" required placeholder="Ej: A, B, C">
                </div>
                <div class="custom-control custom-checkbox">
                    <input type="checkbox" class="custom-control-input" id="section_active" checked>
                    <label class="custom-control-label" for="section_active">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</label>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveSection()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';

// Recarga la página preservando la pestaña activa via hash
function reloadWithTab(tabPanelId) {
    location.hash = tabPanelId;
    location.reload();
}

// Al cargar la página, activa la pestaña indicada en el hash
$(document).ready(function() {
    var hash = window.location.hash;
    if (hash) {
        var tabLink = $('#settingsTabs a[href="' + hash + '"]');
        if (tabLink.length) {
            tabLink.tab('show');
        }
    }
});

// =========================================================================
// YEARS
// =========================================================================
function resetYearForm() {
    document.getElementById('yearModalTitle').textContent = '{{ 'AddAcademicYear'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('year_id').value = 0;
    document.getElementById('year_name').value = '';
    document.getElementById('year_value').value = new Date().getFullYear();
    document.getElementById('year_active').checked = true;
}
function editYear(y) {
    document.getElementById('yearModalTitle').textContent = '{{ 'EditAcademicYear'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('year_id').value = y.id;
    document.getElementById('year_name').value = y.name;
    document.getElementById('year_value').value = y.year;
    document.getElementById('year_active').checked = y.active == 1;
    $('#yearModal').modal('show');
}
function saveYear() {
    var fd = new FormData();
    fd.append('action', 'save_year');
    fd.append('id', document.getElementById('year_id').value);
    fd.append('name', document.getElementById('year_name').value);
    fd.append('year', document.getElementById('year_value').value);
    fd.append('active', document.getElementById('year_active').checked ? 1 : 0);
    fetch(ajaxUrl, {method:'POST', body:fd}).then(r=>r.json()).then(d=>{if(d.success)reloadWithTab('years-panel');else alert(d.message||'Error');});
}
function deleteYear(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData(); fd.append('action','delete_year'); fd.append('id',id);
    fetch(ajaxUrl,{method:'POST',body:fd}).then(r=>r.json()).then(d=>{if(d.success)reloadWithTab('years-panel');else alert(d.message||'Error');});
}

// =========================================================================
// LEVELS
// =========================================================================
function resetLevelForm() {
    document.getElementById('levelModalTitle').textContent = '{{ 'AddLevel'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('level_id').value = 0;
    document.getElementById('level_name').value = '';
    document.getElementById('level_order').value = 0;
    document.getElementById('level_years_duration').value = 1;
    document.getElementById('level_active').checked = true;
}
function editLevel(l) {
    document.getElementById('levelModalTitle').textContent = '{{ 'EditLevel'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('level_id').value = l.id;
    document.getElementById('level_name').value = l.name;
    document.getElementById('level_order').value = l.order_index;
    document.getElementById('level_years_duration').value = l.years_duration || 1;
    document.getElementById('level_active').checked = l.active == 1;
    $('#levelModal').modal('show');
}
function saveLevel() {
    var fd = new FormData();
    fd.append('action', 'save_level');
    fd.append('id', document.getElementById('level_id').value);
    fd.append('name', document.getElementById('level_name').value);
    fd.append('order_index', document.getElementById('level_order').value);
    fd.append('years_duration', document.getElementById('level_years_duration').value);
    fd.append('active', document.getElementById('level_active').checked ? 1 : 0);
    fetch(ajaxUrl,{method:'POST',body:fd}).then(r=>r.json()).then(d=>{if(d.success)reloadWithTab('levels-panel');else alert(d.message||'Error');});
}
function deleteLevel(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData(); fd.append('action','delete_level'); fd.append('id',id);
    fetch(ajaxUrl,{method:'POST',body:fd}).then(r=>r.json()).then(d=>{if(d.success)reloadWithTab('levels-panel');else alert(d.message||'Error');});
}

// =========================================================================
// GRADES
// =========================================================================
function resetGradeForm() {
    document.getElementById('gradeModalTitle').textContent = '{{ 'AddGrade'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('grade_id').value = 0;
    document.getElementById('grade_level').value = '';
    document.getElementById('grade_name').value = '';
    document.getElementById('grade_order').value = 0;
    document.getElementById('grade_active').checked = true;
}
function editGrade(g) {
    document.getElementById('gradeModalTitle').textContent = '{{ 'EditGrade'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('grade_id').value = g.id;
    document.getElementById('grade_level').value = g.level_id;
    document.getElementById('grade_name').value = g.name;
    document.getElementById('grade_order').value = g.order_index;
    document.getElementById('grade_active').checked = g.active == 1;
    $('#gradeModal').modal('show');
}
function saveGrade() {
    var fd = new FormData();
    fd.append('action', 'save_grade');
    fd.append('id', document.getElementById('grade_id').value);
    fd.append('level_id', document.getElementById('grade_level').value);
    fd.append('name', document.getElementById('grade_name').value);
    fd.append('order_index', document.getElementById('grade_order').value);
    fd.append('active', document.getElementById('grade_active').checked ? 1 : 0);
    fetch(ajaxUrl,{method:'POST',body:fd}).then(r=>r.json()).then(d=>{if(d.success)reloadWithTab('grades-panel');else alert(d.message||'Error');});
}
function deleteGrade(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData(); fd.append('action','delete_grade'); fd.append('id',id);
    fetch(ajaxUrl,{method:'POST',body:fd}).then(r=>r.json()).then(d=>{if(d.success)reloadWithTab('grades-panel');else alert(d.message||'Error');});
}

// =========================================================================
// SECTIONS
// =========================================================================
function resetSectionForm() {
    document.getElementById('sectionModalTitle').textContent = '{{ 'AddSection'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('section_id').value = 0;
    document.getElementById('section_name').value = '';
    document.getElementById('section_active').checked = true;
}
function editSection(s) {
    document.getElementById('sectionModalTitle').textContent = '{{ 'EditSection'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('section_id').value = s.id;
    document.getElementById('section_name').value = s.name;
    document.getElementById('section_active').checked = s.active == 1;
    $('#sectionModal').modal('show');
}
function saveSection() {
    var fd = new FormData();
    fd.append('action', 'save_section');
    fd.append('id', document.getElementById('section_id').value);
    fd.append('name', document.getElementById('section_name').value);
    fd.append('active', document.getElementById('section_active').checked ? 1 : 0);
    fetch(ajaxUrl,{method:'POST',body:fd}).then(r=>r.json()).then(d=>{if(d.success)reloadWithTab('sections-panel');else alert(d.message||'Error');});
}
function deleteSection(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData(); fd.append('action','delete_section'); fd.append('id',id);
    fetch(ajaxUrl,{method:'POST',body:fd}).then(r=>r.json()).then(d=>{if(d.success)reloadWithTab('sections-panel');else alert(d.message||'Error');});
}
</script>
