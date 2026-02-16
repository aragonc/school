<div class="pb-3">
    <h4>{{ 'Welcome'|get_plugin_lang('SchoolPlugin') }}, {{ user_info.complete_name }}</h4>
</div>

<div class="row">
    <!-- Cursos activos -->
    <div class="col-md-4 col-sm-6 mb-4">
        <a href="/courses" class="text-decoration-none">
            <div class="card border-left-primary shadow h-100">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                {{ 'ActiveCourses'|get_plugin_lang('SchoolPlugin') }}
                            </div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">{{ total_courses }}</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-book-open fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </a>
    </div>

    <!-- Cursos anteriores -->
    <div class="col-md-4 col-sm-6 mb-4">
        <a href="/previous" class="text-decoration-none">
            <div class="card border-left-success shadow h-100">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                {{ 'CompletedCourses'|get_plugin_lang('SchoolPlugin') }}
                            </div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">{{ total_history }}</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-check-circle fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </a>
    </div>

    <!-- Asistencia hoy -->
    <div class="col-md-4 col-sm-6 mb-4">
        <a href="/attendance/my" class="text-decoration-none">
            <div class="card border-left-info shadow h-100">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                {{ 'TodayAttendance'|get_plugin_lang('SchoolPlugin') }}
                            </div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">
                                {% if today_attendance|length > 0 %}
                                    {% set att = today_attendance[0] %}
                                    {% if att.status == 'on_time' %}
                                        <span class="text-success"><i class="fas fa-check-circle"></i> {{ 'OnTime'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% elseif att.status == 'late' %}
                                        <span class="text-warning"><i class="fas fa-clock"></i> {{ 'Late'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% elseif att.status == 'absent' %}
                                        <span class="text-danger"><i class="fas fa-times-circle"></i> {{ 'Absent'|get_plugin_lang('SchoolPlugin') }}</span>
                                    {% endif %}
                                {% else %}
                                    <span class="text-muted">{{ 'NoRecord'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% endif %}
                            </div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-clipboard-check fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </a>
    </div>
</div>

{% if show_certificates %}
<div class="row">
    <div class="col-md-4 col-sm-6 mb-4">
        <a href="/certified" class="text-decoration-none">
            <div class="card border-left-warning shadow h-100">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                {{ 'MyCertificates'|get_plugin_lang('SchoolPlugin') }}
                            </div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">
                                <i class="fas fa-arrow-right"></i> {{ 'View'|get_plugin_lang('SchoolPlugin') }}
                            </div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-file-alt fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </a>
    </div>
</div>
{% endif %}

{% if show_profile_completion_modal %}
{% include 'profile_completion_modal.tpl' %}
{% endif %}

<style>
.border-left-primary { border-left: 4px solid #4e73df !important; }
.border-left-success { border-left: 4px solid #1cc88a !important; }
.border-left-info { border-left: 4px solid #36b9cc !important; }
.border-left-warning { border-left: 4px solid #f6c23e !important; }
.text-xs { font-size: .7rem; }
a.text-decoration-none:hover { text-decoration: none; }
a.text-decoration-none .card { transition: transform 0.15s ease-in-out; }
a.text-decoration-none:hover .card { transform: translateY(-3px); }
</style>
