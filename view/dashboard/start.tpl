<div class="pb-3">
    <h4>{{ 'Welcome'|get_plugin_lang('SchoolPlugin') }}, {{ user_info.complete_name }}</h4>
</div>

<div class="row">
    <!-- Cursos activos -->
    <div class="col-md-3 col-sm-6 mb-4">
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
    <div class="col-md-3 col-sm-6 mb-4">
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
    <div class="col-md-3 col-sm-6 mb-4">
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

    <!-- Conexiones a la plataforma -->
    <div class="col-md-3 col-sm-6 mb-4">
        <div class="card border-left-secondary shadow h-100">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-secondary text-uppercase mb-1">
                            Conexiones a la plataforma
                        </div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ login_stats.total }}</div>
                        {% if login_stats.last_login %}
                        <div class="text-xs text-muted mt-1">
                            <i class="fas fa-clock"></i>
                            Última: {{ login_stats.last_login|date('d/m/Y H:i') }}
                        </div>
                        {% endif %}
                    </div>
                    <div class="col-auto">
                        <i class="fas fa-sign-in-alt fa-2x text-gray-300"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Gráfico de asistencia mensual -->
{% if monthly_attendance|length > 0 %}
<script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
<div class="row mb-4">
    <div class="col-12">
        <div class="card shadow">
            <div class="card-header py-3 d-flex align-items-center justify-content-between">
                <h6 class="m-0 font-weight-bold text-primary">
                    <i class="fas fa-chart-bar mr-2"></i>Asistencia del mes
                </h6>
                <a href="/attendance/my" class="btn btn-sm btn-outline-primary">Ver detalle</a>
            </div>
            <div class="card-body">
                <canvas id="attendanceChart" height="80"></canvas>
            </div>
        </div>
    </div>
</div>

<script>
(function() {
    var rawData = {{ monthly_attendance|json_encode }};
    var labels = [], onTime = [], late = [], absent = [];
    var byDate = {};
    rawData.forEach(function(r) {
        byDate[r.date] = r.status;
    });
    Object.keys(byDate).sort().forEach(function(d) {
        var day = d.split('-')[2];
        labels.push(day);
        onTime.push(byDate[d] === 'on_time' ? 1 : 0);
        late.push(byDate[d] === 'late' ? 1 : 0);
        absent.push(byDate[d] === 'absent' ? 1 : 0);
    });

    var ctx = document.getElementById('attendanceChart').getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'A tiempo',
                    data: onTime,
                    backgroundColor: 'rgba(28,200,138,0.7)',
                    borderColor: '#1cc88a',
                    borderWidth: 1
                },
                {
                    label: 'Tardanza',
                    data: late,
                    backgroundColor: 'rgba(246,194,62,0.7)',
                    borderColor: '#f6c23e',
                    borderWidth: 1
                },
                {
                    label: 'Ausente',
                    data: absent,
                    backgroundColor: 'rgba(231,74,59,0.7)',
                    borderColor: '#e74a3b',
                    borderWidth: 1
                }
            ]
        },
        options: {
            responsive: true,
            scales: {
                x: { stacked: true, grid: { display: false } },
                y: {
                    stacked: true,
                    ticks: { stepSize: 1, precision: 0 },
                    max: 1
                }
            },
            plugins: {
                legend: { position: 'bottom' },
                tooltip: {
                    callbacks: {
                        label: function(ctx) {
                            return ctx.dataset.label + ': ' + (ctx.raw === 1 ? 'Sí' : 'No');
                        }
                    }
                }
            }
        }
    });
})();
</script>
{% endif %}

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

{% if reglamento_docs|length > 0 %}
<div class="rgl-section mt-3 mb-4">
    <div class="rgl-section-header">
        <span class="rgl-section-icon"><i class="fas fa-landmark"></i></span>
        <div>
            <div class="rgl-section-title">{{ 'ReglamentoInterno'|get_plugin_lang('SchoolPlugin') }}</div>
            <div class="rgl-section-sub">Documentos oficiales del colegio</div>
        </div>
    </div>
    <div class="rgl-docs-grid">
        {% set rgl_colors = {'primary': '#4e73df', 'info': '#36b9cc', 'warning': '#e67e22'} %}
        {% for doc in reglamento_docs %}
        <a href="{{ doc.url }}" target="_blank" class="rgl-doc-card">
            <div class="rgl-doc-icon-wrap" style="background: {{ rgl_colors[doc.color] }}1a; border-color: {{ rgl_colors[doc.color] }}33;">
                <i class="fas {{ doc.icon }} rgl-doc-icon" style="color: {{ rgl_colors[doc.color] }};"></i>
                <span class="rgl-pdf-badge">PDF</span>
            </div>
            <div class="rgl-doc-info">
                <div class="rgl-doc-name">{{ doc.label }}</div>
                {% if doc.date %}
                <div class="rgl-doc-date">
                    <i class="fas fa-calendar-alt"></i> {{ doc.date }}
                </div>
                {% endif %}
                <div class="rgl-doc-action" style="color: {{ rgl_colors[doc.color] }};">
                    <i class="fas fa-arrow-down-to-line"></i>
                    <i class="fas fa-external-link-alt"></i> Abrir documento
                </div>
            </div>
        </a>
        {% endfor %}
    </div>
</div>
{% endif %}

{% if show_profile_completion_modal %}
{% include 'profile/completion_modal.tpl' %}
{% endif %}

<style>
/* ── Stats cards ── */
.border-left-primary   { border-left: 4px solid #4e73df !important; }
.border-left-success   { border-left: 4px solid #1cc88a !important; }
.border-left-info      { border-left: 4px solid #36b9cc !important; }
.border-left-warning   { border-left: 4px solid #f6c23e !important; }
.border-left-secondary { border-left: 4px solid #858796 !important; }
.text-xs { font-size: .7rem; }
a.text-decoration-none:hover { text-decoration: none; }
a.text-decoration-none .card { transition: transform 0.15s ease-in-out; }
a.text-decoration-none:hover .card { transform: translateY(-3px); }

/* ── Reglamento section ── */
.rgl-section {
    background: #fff;
    border-radius: 12px;
    border: 1px solid #e3e6f0;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 20px 24px 16px;
}
.rgl-section-header {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 18px;
    padding-bottom: 14px;
    border-bottom: 1px solid #f0f1f7;
}
.rgl-section-icon {
    width: 42px; height: 42px;
    background: #4e73df;
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    color: #fff;
    font-size: 18px;
    flex-shrink: 0;
}
.rgl-section-title {
    font-size: 15px;
    font-weight: 700;
    color: #2d3748;
    line-height: 1.2;
}
.rgl-section-sub {
    font-size: 12px;
    color: #a0aec0;
    margin-top: 2px;
}
.rgl-docs-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
    gap: 14px;
}
.rgl-doc-card {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 14px 16px;
    border-radius: 10px;
    border: 1px solid #e8ecf4;
    background: #f8f9fc;
    text-decoration: none !important;
    transition: all .18s ease;
    color: inherit;
}
.rgl-doc-card:hover {
    background: #fff;
    border-color: #c5cde8;
    box-shadow: 0 4px 16px rgba(78,115,223,.12);
    transform: translateY(-2px);
    text-decoration: none !important;
    color: inherit;
}
.rgl-doc-icon-wrap {
    position: relative;
    width: 52px; height: 52px;
    border-radius: 10px;
    border: 1px solid;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}
.rgl-doc-icon { font-size: 22px; }
.rgl-pdf-badge {
    position: absolute;
    bottom: -5px; right: -6px;
    background: #e74c3c;
    color: #fff;
    font-size: 8px;
    font-weight: 700;
    padding: 1px 4px;
    border-radius: 4px;
    letter-spacing: .03em;
    line-height: 1.4;
}
.rgl-doc-info { flex: 1; min-width: 0; }
.rgl-doc-name {
    font-size: 13px;
    font-weight: 700;
    color: #2d3748;
    line-height: 1.3;
    margin-bottom: 3px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.rgl-doc-date {
    font-size: 11px;
    color: #718096;
    margin-bottom: 5px;
}
.rgl-doc-date i { margin-right: 3px; }
.rgl-doc-action {
    font-size: 11px;
    font-weight: 600;
}
.rgl-doc-action i { margin-right: 3px; font-size: 10px; }

@media (max-width: 576px) {
    .rgl-docs-grid { grid-template-columns: 1fr; }
}
</style>
