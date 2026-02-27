{% include 'attendance/tabs.tpl' %}

<div class="card mb-4">
    <div class="card-header">
        <i class="fas fa-filter"></i> {{ 'FilterByDate'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body">
        <form method="get" action="" id="reportFilterForm">
            <div class="row align-items-end">
                <div class="col-md-2 mb-2">
                    <label class="small font-weight-bold mb-1">{{ 'StartDateFilter'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="date" name="start_date" class="form-control form-control-sm" value="{{ report_start_date }}">
                </div>
                <div class="col-md-2 mb-2">
                    <label class="small font-weight-bold mb-1">{{ 'EndDateFilter'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="date" name="end_date" class="form-control form-control-sm" value="{{ report_end_date }}">
                </div>
                <div class="col-md-2 mb-2">
                    <label class="small font-weight-bold mb-1">{{ 'FilterByType'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="user_type" class="form-control form-control-sm" id="reportUserType" onchange="toggleAcademicFilters()">
                        <option value="">{{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="teacher"  {{ report_user_type == 'teacher'  ? 'selected' : '' }}>{{ 'RoleTeacher'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="students" {{ report_user_type == 'students' ? 'selected' : '' }}>{{ 'RoleStudent'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="secretary" {{ report_user_type == 'secretary' ? 'selected' : '' }}>{{ 'RoleSecretary'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="auxiliary" {{ report_user_type == 'auxiliary' ? 'selected' : '' }}>{{ 'RoleAuxiliary'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="parent"   {{ report_user_type == 'parent'   ? 'selected' : '' }}>{{ 'RoleParent'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="guardian" {{ report_user_type == 'guardian' ? 'selected' : '' }}>{{ 'RoleGuardian'|get_plugin_lang('SchoolPlugin') }}</option>
                    </select>
                </div>

                <!-- Filters academic — visible only when "students" selected -->
                <div id="academicFilters" class="col-md-4 mb-2" style="{{ report_user_type == 'students' ? '' : 'display:none;' }}">
                    <div class="row">
                        <div class="col-md-4 pr-1">
                            <label class="small font-weight-bold mb-1">{{ 'Level'|get_plugin_lang('SchoolPlugin') }}</label>
                            <select name="level_id" class="form-control form-control-sm" id="rptLevel" onchange="rptCascadeGrades()">
                                <option value="">— {{ 'AllLevels'|get_plugin_lang('SchoolPlugin') }} —</option>
                                {% for lv in levels %}
                                <option value="{{ lv.id }}" {{ report_level_id == lv.id ? 'selected' : '' }}>{{ lv.name }}</option>
                                {% endfor %}
                            </select>
                        </div>
                        <div class="col-md-4 px-1">
                            <label class="small font-weight-bold mb-1">{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</label>
                            <select name="grade_id" class="form-control form-control-sm" id="rptGrade">
                                <option value="">— {{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }} —</option>
                                {% for gr in grades %}
                                <option value="{{ gr.id }}" data-level="{{ gr.level_id }}" {{ report_grade_id == gr.id ? 'selected' : '' }}>{{ gr.name }}</option>
                                {% endfor %}
                            </select>
                        </div>
                        <div class="col-md-4 pl-1">
                            <label class="small font-weight-bold mb-1">{{ 'Section'|get_plugin_lang('SchoolPlugin') }}</label>
                            <select name="section_id" class="form-control form-control-sm" id="rptSection">
                                <option value="">— {{ 'AllSections'|get_plugin_lang('SchoolPlugin') }} —</option>
                                {% for sec in sections %}
                                <option value="{{ sec.id }}" {{ report_section_id == sec.id ? 'selected' : '' }}>{{ sec.name }}</option>
                                {% endfor %}
                            </select>
                        </div>
                    </div>
                </div>

                <div class="col-md-2 mb-2 d-flex align-items-end" style="gap:4px; flex-wrap:wrap;">
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="fas fa-search"></i> {{ 'Filter'|get_plugin_lang('SchoolPlugin') }}
                    </button>
                    <a id="btnExportExcel" href="#" class="btn btn-success btn-sm">
                        <i class="fas fa-file-excel"></i> Excel
                    </a>
                    <a id="btnExportPdf" href="#" class="btn btn-danger btn-sm">
                        <i class="fas fa-file-pdf"></i> PDF
                    </a>
                </div>
            </div>
        </form>

<script>
var rptAllGrades = {{ grades|json_encode }};
var rptAjaxUrl   = '{{ ajax_url }}';

function toggleAcademicFilters() {
    var type = document.getElementById('reportUserType').value;
    document.getElementById('academicFilters').style.display = (type === 'students') ? '' : 'none';
    if (type !== 'students') {
        document.getElementById('rptLevel').value   = '';
        document.getElementById('rptGrade').value   = '';
        document.getElementById('rptSection').value = '';
    }
    updateExportLinks();
}

function rptCascadeGrades() {
    var levelId  = document.getElementById('rptLevel').value;
    var gradeEl  = document.getElementById('rptGrade');
    var current  = gradeEl.value;
    gradeEl.innerHTML = '<option value="">— {{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }} —</option>';
    rptAllGrades.forEach(function(g) {
        if (!levelId || String(g.level_id) === String(levelId)) {
            var opt = document.createElement('option');
            opt.value = g.id; opt.text = g.name;
            opt.setAttribute('data-level', g.level_id);
            if (String(g.id) === String(current)) opt.selected = true;
            gradeEl.appendChild(opt);
        }
    });
    updateExportLinks();
}

function updateExportLinks() {
    var form = document.getElementById('reportFilterForm');
    var params = new URLSearchParams();
    params.set('action',     'PLACEHOLDER');
    params.set('start_date', form.querySelector('[name=start_date]').value);
    params.set('end_date',   form.querySelector('[name=end_date]').value);
    params.set('user_type',  form.querySelector('[name=user_type]').value);
    params.set('level_id',   document.getElementById('rptLevel').value   || '0');
    params.set('grade_id',   document.getElementById('rptGrade').value   || '0');
    params.set('section_id', document.getElementById('rptSection').value || '0');

    var base = rptAjaxUrl + '?' + params.toString().replace('action=PLACEHOLDER', 'action=');
    document.getElementById('btnExportExcel').href = rptAjaxUrl + '?' + params.toString().replace('PLACEHOLDER', 'export_excel');
    document.getElementById('btnExportPdf').href   = rptAjaxUrl + '?' + params.toString().replace('PLACEHOLDER', 'export_pdf');
}

// Init on load
rptCascadeGrades();
updateExportLinks();
document.getElementById('rptGrade').addEventListener('change',   updateExportLinks);
document.getElementById('rptSection').addEventListener('change', updateExportLinks);
document.querySelector('[name=start_date]').addEventListener('change', updateExportLinks);
document.querySelector('[name=end_date]').addEventListener('change',   updateExportLinks);
document.getElementById('reportUserType').addEventListener('change',   updateExportLinks);
</script>
    </div>
</div>

{% if report_stats %}
<div class="row mb-4">
    <div class="col-md-3">
        <div class="card text-center">
            <div class="card-body">
                <h4>{{ report_stats.total }}</h4>
                <small class="text-muted">{{ 'TotalRecords'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-center border-success">
            <div class="card-body">
                <h4 class="text-success">{{ report_stats.on_time }}</h4>
                <small class="text-muted">{{ 'OnTime'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-center border-warning">
            <div class="card-body">
                <h4 class="text-warning">{{ report_stats.late }}</h4>
                <small class="text-muted">{{ 'Late'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-center border-danger">
            <div class="card-body">
                <h4 class="text-danger">{{ report_stats.absent }}</h4>
                <small class="text-muted">{{ 'Absent'|get_plugin_lang('SchoolPlugin') }}</small>
            </div>
        </div>
    </div>
</div>
{% endif %}
