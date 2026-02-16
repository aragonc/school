{% include 'school_attendance_tabs.tpl' %}

<div class="card mb-4">
    <div class="card-header">
        <i class="fas fa-filter"></i> {{ 'FilterByDate'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body">
        <form method="get" action="" class="form-inline">
            <div class="form-group mr-2 mb-2">
                <label class="mr-1">{{ 'StartDateFilter'|get_plugin_lang('SchoolPlugin') }}</label>
                <input type="date" name="start_date" class="form-control form-control-sm" value="{{ report_start_date }}">
            </div>
            <div class="form-group mr-2 mb-2">
                <label class="mr-1">{{ 'EndDateFilter'|get_plugin_lang('SchoolPlugin') }}</label>
                <input type="date" name="end_date" class="form-control form-control-sm" value="{{ report_end_date }}">
            </div>
            <div class="form-group mr-2 mb-2">
                <label class="mr-1">{{ 'FilterByType'|get_plugin_lang('SchoolPlugin') }}</label>
                <select name="user_type" class="form-control form-control-sm">
                    <option value="">{{ 'AllUsers'|get_plugin_lang('SchoolPlugin') }}</option>
                    <option value="teacher" {{ report_user_type == 'teacher' ? 'selected' : '' }}>{{ 'RoleTeacher'|get_plugin_lang('SchoolPlugin') }}</option>
                    <option value="students" {{ report_user_type == 'students' ? 'selected' : '' }}>{{ 'RoleStudent'|get_plugin_lang('SchoolPlugin') }}</option>
                    <option value="secretary" {{ report_user_type == 'secretary' ? 'selected' : '' }}>{{ 'RoleSecretary'|get_plugin_lang('SchoolPlugin') }}</option>
                    <option value="auxiliary" {{ report_user_type == 'auxiliary' ? 'selected' : '' }}>{{ 'RoleAuxiliary'|get_plugin_lang('SchoolPlugin') }}</option>
                    <option value="parent" {{ report_user_type == 'parent' ? 'selected' : '' }}>{{ 'RoleParent'|get_plugin_lang('SchoolPlugin') }}</option>
                    <option value="guardian" {{ report_user_type == 'guardian' ? 'selected' : '' }}>{{ 'RoleGuardian'|get_plugin_lang('SchoolPlugin') }}</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary btn-sm mb-2 mr-2">
                <i class="fas fa-search"></i> {{ 'Filter'|get_plugin_lang('SchoolPlugin') }}
            </button>
            <a href="{{ ajax_url }}?action=export_excel&start_date={{ report_start_date }}&end_date={{ report_end_date }}&user_type={{ report_user_type }}" class="btn btn-success btn-sm mb-2 mr-2">
                <i class="fas fa-file-excel"></i> {{ 'ExportExcel'|get_plugin_lang('SchoolPlugin') }}
            </a>
            <a href="{{ ajax_url }}?action=export_pdf&start_date={{ report_start_date }}&end_date={{ report_end_date }}&user_type={{ report_user_type }}" class="btn btn-danger btn-sm mb-2">
                <i class="fas fa-file-pdf"></i> {{ 'ExportPDF'|get_plugin_lang('SchoolPlugin') }}
            </a>
        </form>
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
