<!-- Contadores -->
<div class="row mb-3">
    <div class="col">
        <div class="card border-left-primary shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">{{ 'TotalEnrollments'|get_plugin_lang('SchoolPlugin') }}</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ (counts.NUEVO_INGRESO + counts.REINGRESO + counts.CONTINUACION) }}</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-users fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col">
        <div class="card border-left-success shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">{{ 'NewEnrollments'|get_plugin_lang('SchoolPlugin') }}</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ counts.NUEVO_INGRESO }}</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-user-plus fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col">
        <div class="card border-left-info shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-info text-uppercase mb-1">{{ 'Reenrollments'|get_plugin_lang('SchoolPlugin') }}</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ counts.REINGRESO }}</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-redo fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col">
        <div class="card border-left-warning shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">{{ 'Continuacion'|get_plugin_lang('SchoolPlugin') }}</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ counts.CONTINUACION }}</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-arrow-right fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col">
        <div class="card border-left-danger shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">Retirados</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ counts.RETIRADO }}</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-user-times fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-auto d-flex align-items-center" style="gap:8px;">
        {% if all_years|length > 1 %}
        <button class="btn btn-outline-secondary btn-sm" onclick="showPromoteModal()" title="{{ 'PromoteToNextYear'|get_plugin_lang('SchoolPlugin') }}">
            <i class="fas fa-angle-double-right"></i> {{ 'PromoteToNextYear'|get_plugin_lang('SchoolPlugin') }}
        </button>
        {% endif %}
        <button class="btn btn-info btn-sm" data-toggle="modal" data-target="#bulkCsvModal">
            <i class="fas fa-file-csv"></i> {{ 'BulkEnrollCsv'|get_plugin_lang('SchoolPlugin') }}
        </button>
        <button class="btn btn-success btn-sm" data-toggle="modal" data-target="#quickEnrollModal">
            <i class="fas fa-bolt"></i> {{ 'QuickEnroll'|get_plugin_lang('SchoolPlugin') }}
        </button>
        <a href="{{ _p.web }}matricula/alumnos" class="btn btn-primary btn-sm">
            <i class="fas fa-plus"></i> {{ 'NewEnrollment'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </div>
</div>

<!-- Filtros -->
<div class="card mb-4">
    <div class="card-body py-2">
        <form method="get" class="form-inline flex-wrap" style="gap:8px;">
            <select name="academic_year_id" class="form-control form-control-sm" onchange="this.form.submit()">
                <option value="">{{ 'AllYears'|get_plugin_lang('SchoolPlugin') }}</option>
                {% for y in all_years %}
                <option value="{{ y.id }}" {{ selected_year_id == y.id ? 'selected' : '' }}>
                    {{ y.name }} {% if y.active %}★{% endif %}
                </option>
                {% endfor %}
            </select>
            <input type="text" name="search" class="form-control form-control-sm" placeholder="{{ 'SearchByNameDni'|get_plugin_lang('SchoolPlugin') }}" value="{{ filters.search }}">
            <select name="tipo_ingreso" class="form-control form-control-sm">
                <option value="">{{ 'AllTypes'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="NUEVO_INGRESO" {{ filters.tipo_ingreso == 'NUEVO_INGRESO' ? 'selected' : '' }}>{{ 'NewEnrollmentType'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="REINGRESO" {{ filters.tipo_ingreso == 'REINGRESO' ? 'selected' : '' }}>{{ 'ReenrollmentType'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="CONTINUACION" {{ filters.tipo_ingreso == 'CONTINUACION' ? 'selected' : '' }}>{{ 'ContinuacionType'|get_plugin_lang('SchoolPlugin') }}</option>
            </select>
            <select name="estado" class="form-control form-control-sm">
                <option value="">{{ 'AllStates'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="ACTIVO" {{ filters.estado == 'ACTIVO' ? 'selected' : '' }}>{{ 'Activo'|get_plugin_lang('SchoolPlugin') }}</option>
                <option value="RETIRADO" {{ filters.estado == 'RETIRADO' ? 'selected' : '' }}>{{ 'Retirado'|get_plugin_lang('SchoolPlugin') }}</option>
            </select>
            <select name="grade_id" class="form-control form-control-sm">
                <option value="">{{ 'AllGrades'|get_plugin_lang('SchoolPlugin') }}</option>
                {% for level in levels %}
                    <optgroup label="{{ level.name }}">
                        {% for grade in level.grades %}
                        <option value="{{ grade.id }}" {{ filters.grade_id == grade.id ? 'selected' : '' }}>{{ grade.name }}</option>
                        {% endfor %}
                    </optgroup>
                {% endfor %}
            </select>
            <button type="submit" class="btn btn-secondary btn-sm"><i class="fas fa-search"></i> {{ 'Filter'|get_plugin_lang('SchoolPlugin') }}</button>
            <a href="{{ _p.web }}matricula" class="btn btn-outline-secondary btn-sm"><i class="fas fa-times"></i></a>
        </form>
    </div>
</div>

<!-- Tabla -->
<div class="card">
    <div class="card-body p-0">
        {% if matriculas|length > 0 %}
        <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
                <thead>
                    <tr>
                        <th>{{ 'EstadoMatricula'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'TipoIngreso'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'NombreApellidos'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Dni'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Sexo'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'FechaRegistro'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for m in matriculas %}
                    <tr class="{{ m.estado == 'RETIRADO' ? 'text-muted' : '' }}">
                        <td>
                            {% if m.estado == 'RETIRADO' %}
                                <span class="badge badge-secondary"><i class="fas fa-user-times"></i> {{ 'Retirado'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% else %}
                                <span class="badge badge-success"><i class="fas fa-user-check"></i> {{ 'Activo'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% endif %}
                        </td>
                        <td>
                            {% if m.tipo_ingreso == 'NUEVO_INGRESO' %}
                                <span class="badge badge-success">{{ 'NewEnrollmentType'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% elseif m.tipo_ingreso == 'REINGRESO' %}
                                <span class="badge badge-info">{{ 'ReenrollmentType'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% else %}
                                <span class="badge badge-warning text-dark">{{ 'ContinuacionType'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% endif %}
                        </td>
                        <td>
                            <strong>{{ m.full_name }}</strong>
                            {% if not m.dni and not m.fecha_nacimiento %}
                                <br><span class="badge badge-warning" title="{{ 'FichaIncompleta'|get_plugin_lang('SchoolPlugin') }}">
                                    <i class="fas fa-exclamation-triangle"></i> {{ 'FichaIncompleta'|get_plugin_lang('SchoolPlugin') }}
                                </span>
                            {% endif %}
                        </td>
                        <td>
                            {% if m.level_name %}
                                <small class="text-muted">{{ m.level_name }}</small><br>
                                {{ m.grade_name }}
                            {% else %}
                                <span class="text-muted">—</span>
                            {% endif %}
                        </td>
                        <td>{{ m.dni ?: '—' }}</td>
                        <td>
                            {% if m.sexo == 'F' %}
                                <i class="fas fa-venus text-danger"></i> F
                            {% elseif m.sexo == 'M' %}
                                <i class="fas fa-mars text-primary"></i> M
                            {% else %}—{% endif %}
                        </td>
                        <td><small>{{ m.created_at|date('d/m/Y') }}</small></td>
                        <td>
                            <a href="{{ _p.web }}matricula/ver?ficha_id={{ m.ficha_id }}" class="btn btn-info btn-sm" title="{{ 'View'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-eye"></i>
                            </a>
                            <a href="{{ _p.web }}matricula/editar?ficha_id={{ m.ficha_id }}" class="btn btn-warning btn-sm" title="{{ 'Edit'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-edit"></i>
                            </a>
                            {% if m.estado == 'ACTIVO' %}
                            <button class="btn btn-secondary btn-sm" onclick="retireMatricula({{ m.id }}, '{{ m.full_name|e('js') }}')" title="{{ 'RetirarAlumno'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-user-times"></i>
                            </button>
                            {% endif %}
                            <button class="btn btn-danger btn-sm" onclick="deleteMatricula({{ m.id }}, '{{ m.full_name|e('js') }}')" title="{{ 'Delete'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
        {% else %}
        <div class="p-4">
            <div class="alert alert-info mb-0">
                <i class="fas fa-info-circle"></i> {{ 'NoEnrollments'|get_plugin_lang('SchoolPlugin') }}
            </div>
        </div>
        {% endif %}
    </div>
</div>

<!-- Modal: Matrícula Masiva CSV -->
<div class="modal fade" id="bulkCsvModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title"><i class="fas fa-file-csv mr-2"></i>{{ 'BulkEnrollCsv'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="alert alert-info py-2 mb-3">
                    <i class="fas fa-info-circle"></i> {{ 'BulkEnrollCsvHelp'|get_plugin_lang('SchoolPlugin') }}
                    &nbsp;
                    <a href="#" onclick="downloadCsvTemplate();return false;" class="font-weight-bold">
                        <i class="fas fa-download"></i> {{ 'DownloadTemplate'|get_plugin_lang('SchoolPlugin') }}
                    </a>
                </div>

                <p class="text-muted small mb-2"><i class="fas fa-info-circle"></i> {{ 'CsvDefaultsHelp'|get_plugin_lang('SchoolPlugin') }}</p>

                <div class="row">
                    <div class="col-md-6">
                        <!-- Academic year (default) -->
                        <div class="form-group">
                            <label class="font-weight-bold">{{ 'AcademicYear'|get_plugin_lang('SchoolPlugin') }} <span class="text-muted font-weight-normal small">({{ 'DefaultIfEmpty'|get_plugin_lang('SchoolPlugin') }})</span></label>
                            <select class="form-control" id="csv_year">
                                <option value="">— sin defecto —</option>
                                {% for y in all_years %}
                                <option value="{{ y.id }}" {{ (active_year and active_year.id == y.id) or selected_year_id == y.id ? 'selected' : '' }}>
                                    {{ y.name }}{% if y.active %} ★{% endif %}
                                </option>
                                {% endfor %}
                            </select>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <!-- Tipo ingreso (default) -->
                        <div class="form-group">
                            <label class="font-weight-bold">{{ 'TipoIngreso'|get_plugin_lang('SchoolPlugin') }} <span class="text-muted font-weight-normal small">({{ 'DefaultIfEmpty'|get_plugin_lang('SchoolPlugin') }})</span></label>
                            <select class="form-control" id="csv_tipo">
                                <option value="NUEVO_INGRESO">{{ 'NewEnrollmentType'|get_plugin_lang('SchoolPlugin') }}</option>
                                <option value="REINGRESO">{{ 'ReenrollmentType'|get_plugin_lang('SchoolPlugin') }}</option>
                                <option value="CONTINUACION">{{ 'ContinuacionType'|get_plugin_lang('SchoolPlugin') }}</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-4">
                        <div class="form-group">
                            <label class="font-weight-bold">{{ 'Level'|get_plugin_lang('SchoolPlugin') }} <span class="text-muted font-weight-normal small">({{ 'DefaultIfEmpty'|get_plugin_lang('SchoolPlugin') }})</span></label>
                            <select class="form-control" id="csv_level" onchange="loadCsvGrades()">
                                <option value="">— {{ 'SelectLevel'|get_plugin_lang('SchoolPlugin') }} —</option>
                                {% for level in levels %}
                                <option value="{{ level.id }}">{{ level.name }}</option>
                                {% endfor %}
                            </select>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label class="font-weight-bold">{{ 'Grade'|get_plugin_lang('SchoolPlugin') }} <span class="text-muted font-weight-normal small">({{ 'DefaultIfEmpty'|get_plugin_lang('SchoolPlugin') }})</span></label>
                            <select class="form-control" id="csv_grade" onchange="loadCsvSections()" disabled>
                                <option value="">— {{ 'SelectGrade'|get_plugin_lang('SchoolPlugin') }} —</option>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label class="font-weight-bold">{{ 'Section'|get_plugin_lang('SchoolPlugin') }} <span class="text-muted font-weight-normal small">({{ 'DefaultIfEmpty'|get_plugin_lang('SchoolPlugin') }})</span></label>
                            <select class="form-control" id="csv_section" disabled>
                                <option value="">— {{ 'SelectSection'|get_plugin_lang('SchoolPlugin') }} —</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- File input -->
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'CsvFile'|get_plugin_lang('SchoolPlugin') }} <span class="text-danger">*</span></label>
                    <div class="custom-file">
                        <input type="file" class="custom-file-input" id="csv_file_input" accept=".csv,text/csv" onchange="onCsvFileChange(this)">
                        <label class="custom-file-label" id="csv_file_label" for="csv_file_input">{{ 'ChooseFile'|get_plugin_lang('SchoolPlugin') }}</label>
                    </div>
                    <small class="text-muted">{{ 'CsvFormatHelp'|get_plugin_lang('SchoolPlugin') }}</small>
                </div>

                <!-- Results -->
                <div id="csv_results" style="display:none">
                    <hr>
                    <div id="csv_summary" class="mb-2"></div>
                    <div style="max-height:250px;overflow-y:auto;">
                        <table class="table table-sm table-bordered mb-0">
                            <thead class="thead-light">
                                <tr>
                                    <th>{{ 'Username'|get_plugin_lang('SchoolPlugin') }}</th>
                                    <th>{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}</th>
                                    <th>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                                </tr>
                            </thead>
                            <tbody id="csv_results_body"></tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Cancel'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-info" id="btnBulkCsv" onclick="submitBulkCsv()">
                    <i class="fas fa-upload mr-1"></i>{{ 'ProcessCsv'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Matrícula Rápida -->
<div class="modal fade" id="quickEnrollModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title"><i class="fas fa-bolt mr-2"></i>{{ 'QuickEnroll'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="alert alert-info py-2 mb-3">
                    <i class="fas fa-info-circle"></i> {{ 'QuickEnrollHelp'|get_plugin_lang('SchoolPlugin') }}
                </div>

                <!-- Student search -->
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'Student'|get_plugin_lang('SchoolPlugin') }} <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="qe_search" placeholder="{{ 'TypeToSearch'|get_plugin_lang('SchoolPlugin') }}" autocomplete="off">
                    <div id="qe_results" style="max-height:200px;overflow-y:auto;border:1px solid #ced4da;border-top:none;display:none;border-radius:0 0 4px 4px;"></div>
                    <input type="hidden" id="qe_user_id" value="0">
                    <div id="qe_selected" class="mt-1" style="display:none">
                        <span class="badge badge-success py-1 px-2" id="qe_selected_name"></span>
                        <a href="#" onclick="clearQeUser();return false;" class="ml-1 text-danger small"><i class="fas fa-times"></i></a>
                    </div>
                </div>

                <!-- Academic year -->
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'AcademicYear'|get_plugin_lang('SchoolPlugin') }} <span class="text-danger">*</span></label>
                    <select class="form-control" id="qe_year">
                        {% for y in all_years %}
                        <option value="{{ y.id }}" {{ (active_year and active_year.id == y.id) or selected_year_id == y.id ? 'selected' : '' }}>
                            {{ y.name }}{% if y.active %} ★{% endif %}
                        </option>
                        {% endfor %}
                    </select>
                </div>

                <!-- Level → Grade -->
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'Level'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select class="form-control" id="qe_level" onchange="loadQeGrades()">
                        <option value="">— {{ 'SelectLevel'|get_plugin_lang('SchoolPlugin') }} —</option>
                        {% for level in levels %}
                        <option value="{{ level.id }}">{{ level.name }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select class="form-control" id="qe_grade" onchange="loadQeSections()" disabled>
                        <option value="">— {{ 'SelectGrade'|get_plugin_lang('SchoolPlugin') }} —</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'Section'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select class="form-control" id="qe_section" disabled>
                        <option value="">— {{ 'SelectSection'|get_plugin_lang('SchoolPlugin') }} —</option>
                    </select>
                </div>

                <!-- Tipo ingreso -->
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'TipoIngreso'|get_plugin_lang('SchoolPlugin') }} <span class="text-danger">*</span></label>
                    <select class="form-control" id="qe_tipo">
                        <option value="NUEVO_INGRESO">{{ 'NewEnrollmentType'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="REINGRESO">{{ 'ReenrollmentType'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="CONTINUACION">{{ 'ContinuacionType'|get_plugin_lang('SchoolPlugin') }}</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Cancel'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-success" id="btnQuickEnroll" onclick="submitQuickEnroll()">
                    <i class="fas fa-bolt mr-1"></i>{{ 'QuickEnroll'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Retiro de alumno con cálculo de devolución (Minedu) -->
<div class="modal fade" id="retireModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-warning">
                <h5 class="modal-title"><i class="fas fa-user-times"></i> Retirar alumno</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="retire_matricula_id" value="0">
                <input type="hidden" id="retire_ficha_id" value="0">
                <input type="hidden" id="retire_user_id" value="0">

                <div class="alert alert-warning py-2">
                    <i class="fas fa-exclamation-triangle"></i>
                    Esta acción marcará al alumno como <strong>RETIRADO</strong> y calculará la devolución de cuota de ingreso según la norma Minedu.
                </div>

                <div class="form-group">
                    <label class="font-weight-bold">Alumno</label>
                    <input type="text" class="form-control" id="retire_student_name" readonly>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">Nivel educativo</label>
                    <input type="text" class="form-control" id="retire_level_name" readonly>
                </div>

                <hr>
                <h6 class="text-muted mb-3"><i class="fas fa-calculator"></i> Cálculo de devolución (Minedu)</h6>

                <div class="row">
                    <div class="col-6">
                        <div class="form-group">
                            <label>Total años pactados</label>
                            <input type="number" class="form-control" id="retire_years_contracted" min="1" max="20" value="1" oninput="calcRetireRefund()">
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="form-group">
                            <label>Años cursados</label>
                            <input type="number" class="form-control" id="retire_years_attended" min="0" max="20" value="0" oninput="calcRetireRefund()">
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-6">
                        <div class="form-group">
                            <label>Años sin cursar (restantes)</label>
                            <input type="text" class="form-control bg-light" id="retire_years_remaining" readonly value="0">
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="form-group">
                            <label>Cuota de ingreso pagada S/</label>
                            <input type="number" class="form-control" id="retire_admission_paid" min="0" step="0.01" value="0" oninput="calcRetireRefund()" placeholder="0.00">
                        </div>
                    </div>
                </div>

                <div class="alert alert-info py-2" id="retire_refund_box">
                    <strong>Monto a devolver: </strong>
                    <span class="font-weight-bold text-primary" id="retire_refund_amount">S/ 0.00</span>
                    <small class="d-block text-muted mt-1" id="retire_refund_formula"></small>
                </div>

                <div class="form-group">
                    <label>Notas / Observaciones</label>
                    <textarea class="form-control" id="retire_notes" rows="2" placeholder="Motivo del retiro, acuerdos, etc."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-danger" id="btnConfirmRetire" onclick="submitRetire()">
                    <i class="fas fa-user-times"></i> Confirmar retiro
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Promover al siguiente año -->
<div class="modal fade" id="promoteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-angle-double-right"></i> {{ 'PromoteToNextYear'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>{{ 'PromoteHelp'|get_plugin_lang('SchoolPlugin') }}</p>
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'FromYear'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select id="promote_from" class="form-control">
                        {% for y in all_years %}
                        <option value="{{ y.id }}" {{ selected_year_id == y.id ? 'selected' : '' }}>{{ y.name }}{% if y.active %} ★{% endif %}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">{{ 'ToYear'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select id="promote_to" class="form-control">
                        {% for y in all_years %}
                        <option value="{{ y.id }}">{{ y.name }}{% if y.active %} ★{% endif %}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i> {{ 'ConfirmPromote'|get_plugin_lang('SchoolPlugin') }}
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Cancel'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" id="btnPromote">
                    <i class="fas fa-angle-double-right"></i> {{ 'PromoteToNextYear'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';
var qeSearchTimer;

// =========================================================================
// BULK CSV ENROLL
// =========================================================================
$('#bulkCsvModal').on('show.bs.modal', function() {
    document.getElementById('csv_file_input').value = '';
    document.getElementById('csv_file_label').textContent = '{{ 'ChooseFile'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('csv_results').style.display = 'none';
    document.getElementById('csv_grade').innerHTML = '<option value="">— {{ 'SelectGrade'|get_plugin_lang('SchoolPlugin') }} —</option>';
    document.getElementById('csv_grade').disabled = true;
    document.getElementById('csv_section').innerHTML = '<option value="">— {{ 'SelectSection'|get_plugin_lang('SchoolPlugin') }} —</option>';
    document.getElementById('csv_section').disabled = true;
    document.getElementById('btnBulkCsv').disabled = false;
    document.getElementById('btnBulkCsv').innerHTML = '<i class="fas fa-upload mr-1"></i>{{ 'ProcessCsv'|get_plugin_lang('SchoolPlugin') }}';
});

function downloadCsvTemplate() {
    var content = 'usuario,año_academico,tipo_ingreso,nivel,grado,seccion\n';
    content += '78208072@playschool.edu.pe,2026,NUEVO_INGRESO,INICIAL,3 AÑOS,A\n';
    content += '90665955@playschool.edu.pe,2026,CONTINUACION,PRIMARIA,1° GRADO,B\n';
    content += '12345678@playschool.edu.pe,,,,,\n';
    var blob = new Blob(['\ufeff' + content], {type: 'text/csv;charset=utf-8;'});
    var link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = 'plantilla_matricula.csv';
    link.click();
}

function onCsvFileChange(input) {
    var label = document.getElementById('csv_file_label');
    label.textContent = input.files.length > 0 ? input.files[0].name : '{{ 'ChooseFile'|get_plugin_lang('SchoolPlugin') }}';
    document.getElementById('csv_results').style.display = 'none';
}

function loadCsvGrades() {
    var levelId = document.getElementById('csv_level').value;
    var gradeEl = document.getElementById('csv_grade');
    var secEl   = document.getElementById('csv_section');
    gradeEl.innerHTML = '<option value="">— {{ 'SelectGrade'|get_plugin_lang('SchoolPlugin') }} —</option>';
    gradeEl.disabled  = true;
    secEl.innerHTML   = '<option value="">— {{ 'SelectSection'|get_plugin_lang('SchoolPlugin') }} —</option>';
    secEl.disabled    = true;
    if (!levelId) return;
    fetch(ajaxUrl + '?action=get_grades_by_level&level_id=' + levelId)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.grades && data.grades.length) {
                data.grades.forEach(function(g) {
                    gradeEl.innerHTML += '<option value="' + g.id + '">' + g.name + '</option>';
                });
                gradeEl.disabled = false;
            }
        });
}

function loadCsvSections() {
    var gradeId = document.getElementById('csv_grade').value;
    var yearId  = document.getElementById('csv_year').value;
    var secEl   = document.getElementById('csv_section');
    secEl.innerHTML = '<option value="">— {{ 'SelectSection'|get_plugin_lang('SchoolPlugin') }} —</option>';
    secEl.disabled  = true;
    if (!gradeId || !yearId) return;
    fetch(ajaxUrl + '?action=get_sections_by_grade&grade_id=' + gradeId + '&academic_year_id=' + yearId)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.sections && data.sections.length) {
                data.sections.forEach(function(s) {
                    secEl.innerHTML += '<option value="' + s.section_id + '">' + s.section_name + '</option>';
                });
                secEl.disabled = false;
            }
        });
}

function submitBulkCsv() {
    var fileInput = document.getElementById('csv_file_input');
    if (!fileInput.files.length) {
        alert('{{ 'CsvFileRequired'|get_plugin_lang('SchoolPlugin') }}');
        return;
    }
    var btn = document.getElementById('btnBulkCsv');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i>{{ 'Processing'|get_plugin_lang('SchoolPlugin') }}...';


    var fd = new FormData();
    fd.append('action',           'bulk_enroll_csv');
    fd.append('academic_year_id', document.getElementById('csv_year').value);
    fd.append('grade_id',         document.getElementById('csv_grade').value   || '0');
    fd.append('section_id',       document.getElementById('csv_section').value || '0');
    fd.append('tipo_ingreso',     document.getElementById('csv_tipo').value);
    fd.append('csv_file',         fileInput.files[0]);

    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-upload mr-1"></i>{{ 'ProcessCsv'|get_plugin_lang('SchoolPlugin') }}';
            if (!d.success) {
                alert(d.message || 'Error');
                return;
            }
            // Show results
            var statusMap = {
                enrolled: '<span class="badge badge-success">{{ 'BulkStatusEnrolled'|get_plugin_lang('SchoolPlugin') }}</span>',
                updated:  '<span class="badge badge-info">Actualizado</span>',
                skipped:  '<span class="badge badge-warning text-dark">{{ 'BulkStatusSkipped'|get_plugin_lang('SchoolPlugin') }}</span>',
                error:    '<span class="badge badge-danger">{{ 'BulkStatusError'|get_plugin_lang('SchoolPlugin') }}</span>'
            };
            var tbody = '';
            d.results.forEach(function(r) {
                tbody += '<tr>';
                tbody += '<td><code>' + r.username + '</code></td>';
                tbody += '<td>' + (r.message || '') + '</td>';
                tbody += '<td>' + (statusMap[r.status] || r.status) + '</td>';
                tbody += '</tr>';
            });
            document.getElementById('csv_results_body').innerHTML = tbody;
            var updated = d.updated || 0;
            document.getElementById('csv_summary').innerHTML =
                '<div class="d-flex" style="gap:8px">' +
                '<span class="badge badge-success px-2 py-1"><i class="fas fa-check mr-1"></i>' + d.enrolled + ' matriculados</span>' +
                (updated > 0 ? '<span class="badge badge-info px-2 py-1"><i class="fas fa-sync-alt mr-1"></i>' + updated + ' actualizados</span>' : '') +
                '<span class="badge badge-warning text-dark px-2 py-1"><i class="fas fa-forward mr-1"></i>' + d.skipped + ' omitidos</span>' +
                '<span class="badge badge-danger px-2 py-1"><i class="fas fa-times mr-1"></i>' + d.errors + ' errores</span>' +
                '</div>';
            document.getElementById('csv_results').style.display = '';
            if (d.enrolled > 0 || updated > 0) {
                // Auto-refresh after 3 seconds if there were enrollments or updates
                setTimeout(function() { location.reload(); }, 3000);
            }
        })
        .catch(function() {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-upload mr-1"></i>{{ 'ProcessCsv'|get_plugin_lang('SchoolPlugin') }}';
            alert('Error de conexión');
        });
}

// =========================================================================
// QUICK ENROLL
// =========================================================================
$('#quickEnrollModal').on('show.bs.modal', function() {
    document.getElementById('qe_search').value = '';
    document.getElementById('qe_user_id').value = '0';
    document.getElementById('qe_results').style.display = 'none';
    document.getElementById('qe_selected').style.display = 'none';
    document.getElementById('qe_grade').innerHTML = '<option value="">— {{ 'SelectGrade'|get_plugin_lang('SchoolPlugin') }} —</option>';
    document.getElementById('qe_grade').disabled = true;
    document.getElementById('qe_section').innerHTML = '<option value="">— {{ 'SelectSection'|get_plugin_lang('SchoolPlugin') }} —</option>';
    document.getElementById('qe_section').disabled = true;
});

document.getElementById('qe_search').addEventListener('input', function() {
    clearTimeout(qeSearchTimer);
    var q = this.value.trim();
    if (q.length < 2) {
        document.getElementById('qe_results').style.display = 'none';
        return;
    }
    qeSearchTimer = setTimeout(function() {
        var yearId = document.getElementById('qe_year').value;
        fetch(ajaxUrl + '?action=search_users_no_matricula&q=' + encodeURIComponent(q) + '&academic_year_id=' + yearId)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                var box = document.getElementById('qe_results');
                var html = '';
                if (data.data && data.data.length > 0) {
                    data.data.forEach(function(u) {
                        html += '<div class="p-2 border-bottom" style="cursor:pointer" onclick="selectQeUser(' + u.user_id + ',\'' + (u.lastname + ', ' + u.firstname).replace(/'/g, "\\'") + '\')">';
                        html += '<strong>' + u.lastname + ', ' + u.firstname + '</strong>';
                        html += '<br><small class="text-muted">' + u.username + '</small>';
                        html += '</div>';
                    });
                } else {
                    html = '<div class="p-2 text-muted">{{ 'NoResults'|get_plugin_lang('SchoolPlugin') }}</div>';
                }
                box.innerHTML = html;
                box.style.display = '';
            });
    }, 300);
});

function selectQeUser(userId, label) {
    document.getElementById('qe_user_id').value = userId;
    document.getElementById('qe_search').value = '';
    document.getElementById('qe_results').style.display = 'none';
    document.getElementById('qe_selected_name').textContent = label;
    document.getElementById('qe_selected').style.display = '';
}

function clearQeUser() {
    document.getElementById('qe_user_id').value = '0';
    document.getElementById('qe_selected').style.display = 'none';
}

function loadQeGrades() {
    var levelId = document.getElementById('qe_level').value;
    var gradeEl = document.getElementById('qe_grade');
    var secEl   = document.getElementById('qe_section');
    gradeEl.innerHTML = '<option value="">— {{ 'SelectGrade'|get_plugin_lang('SchoolPlugin') }} —</option>';
    gradeEl.disabled = true;
    secEl.innerHTML   = '<option value="">— {{ 'SelectSection'|get_plugin_lang('SchoolPlugin') }} —</option>';
    secEl.disabled    = true;
    if (!levelId) return;
    fetch(ajaxUrl + '?action=get_grades_by_level&level_id=' + levelId)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.grades && data.grades.length) {
                data.grades.forEach(function(g) {
                    gradeEl.innerHTML += '<option value="' + g.id + '">' + g.name + '</option>';
                });
                gradeEl.disabled = false;
            }
        });
}

function loadQeSections() {
    var gradeId = document.getElementById('qe_grade').value;
    var yearId  = document.getElementById('qe_year').value;
    var secEl   = document.getElementById('qe_section');
    secEl.innerHTML = '<option value="">— {{ 'SelectSection'|get_plugin_lang('SchoolPlugin') }} —</option>';
    secEl.disabled  = true;
    if (!gradeId || !yearId) return;
    fetch(ajaxUrl + '?action=get_sections_by_grade&grade_id=' + gradeId + '&academic_year_id=' + yearId)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.sections && data.sections.length) {
                data.sections.forEach(function(s) {
                    secEl.innerHTML += '<option value="' + s.section_id + '">' + s.section_name + '</option>';
                });
                secEl.disabled = false;
            }
        });
}

function submitQuickEnroll() {
    var userId = document.getElementById('qe_user_id').value;
    var yearId = document.getElementById('qe_year').value;
    if (userId == '0' || !userId) {
        alert('{{ 'QuickEnrollSelectUser'|get_plugin_lang('SchoolPlugin') }}');
        return;
    }
    var fd = new FormData();
    fd.append('action',           'quick_enroll');
    fd.append('user_id',          userId);
    fd.append('academic_year_id', yearId);
    fd.append('grade_id',         document.getElementById('qe_grade').value   || '0');
    fd.append('section_id',       document.getElementById('qe_section').value || '0');
    fd.append('tipo_ingreso',     document.getElementById('qe_tipo').value);
    var btn = document.getElementById('btnQuickEnroll');
    btn.disabled = true;
    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            btn.disabled = false;
            if (d.success) {
                $('#quickEnrollModal').modal('hide');
                if (confirm('{{ 'QuickEnrollSuccessCompleteFicha'|get_plugin_lang('SchoolPlugin') }}')) {
                    window.location.href = d.ficha_url;
                } else {
                    location.reload();
                }
            } else {
                alert(d.message || 'Error');
            }
        })
        .catch(function() {
            btn.disabled = false;
            alert('Error de conexión');
        });
}


function deleteMatricula(id, name) {
    if (!confirm('¿Eliminar la matrícula de ' + name + '? Esta acción no se puede deshacer.')) return;
    var fd = new FormData();
    fd.append('action', 'delete_matricula');
    fd.append('id', id);
    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) { if (d.success) location.reload(); else alert(d.message || 'Error'); });
}

function retireMatricula(id, name) {
    // Pre-fill name while loading info
    document.getElementById('retire_matricula_id').value = id;
    document.getElementById('retire_student_name').value = name;
    document.getElementById('retire_level_name').value = 'Cargando...';
    document.getElementById('retire_years_contracted').value = 1;
    document.getElementById('retire_years_attended').value = 0;
    document.getElementById('retire_admission_paid').value = '0';
    document.getElementById('retire_notes').value = '';
    document.getElementById('retire_ficha_id').value = 0;
    document.getElementById('retire_user_id').value = 0;
    calcRetireRefund();
    $('#retireModal').modal('show');

    // Fetch retirement info (years_contracted, years_attended, level)
    fetch(ajaxUrl + '?action=get_retirement_info&id=' + id)
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success && d.data) {
                document.getElementById('retire_student_name').value  = d.data.full_name  || name;
                document.getElementById('retire_level_name').value    = d.data.level_name || '—';
                document.getElementById('retire_years_contracted').value = d.data.years_contracted || 1;
                document.getElementById('retire_years_attended').value   = d.data.years_attended   || 0;
                document.getElementById('retire_ficha_id').value         = d.data.ficha_id || 0;
                document.getElementById('retire_user_id').value          = d.data.user_id  || 0;
                calcRetireRefund();
            } else {
                document.getElementById('retire_level_name').value = '—';
            }
        })
        .catch(function() {
            document.getElementById('retire_level_name').value = '—';
        });
}

function calcRetireRefund() {
    var contracted = Math.max(1, parseInt(document.getElementById('retire_years_contracted').value) || 1);
    var attended   = Math.max(0, parseInt(document.getElementById('retire_years_attended').value)   || 0);
    var remaining  = Math.max(0, contracted - attended);
    var paid       = parseFloat(document.getElementById('retire_admission_paid').value) || 0;
    var refund     = contracted > 0 ? Math.round(paid * (remaining / contracted) * 100) / 100 : 0;

    document.getElementById('retire_years_remaining').value = remaining;
    document.getElementById('retire_refund_amount').textContent = 'S/ ' + refund.toFixed(2);
    document.getElementById('retire_refund_formula').textContent =
        paid > 0
        ? 'S/ ' + paid.toFixed(2) + ' × (' + remaining + ' / ' + contracted + ') = S/ ' + refund.toFixed(2)
        : 'Ingrese la cuota de ingreso pagada para calcular la devolución.';
}

function submitRetire() {
    var id         = document.getElementById('retire_matricula_id').value;
    var fichaId    = document.getElementById('retire_ficha_id').value;
    var userId     = document.getElementById('retire_user_id').value;
    var contracted = document.getElementById('retire_years_contracted').value;
    var attended   = document.getElementById('retire_years_attended').value;
    var paid       = document.getElementById('retire_admission_paid').value;
    var notes      = document.getElementById('retire_notes').value;

    document.getElementById('btnConfirmRetire').disabled = true;

    var fd = new FormData();
    fd.append('action',            'retire_matricula');
    fd.append('id',                id);
    fd.append('ficha_id',          fichaId);
    fd.append('user_id',           userId);
    fd.append('years_contracted',  contracted);
    fd.append('years_attended',    attended);
    fd.append('admission_paid',    paid);
    fd.append('retire_notes',      notes);

    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            document.getElementById('btnConfirmRetire').disabled = false;
            if (d.success) {
                $('#retireModal').modal('hide');
                location.reload();
            } else {
                alert(d.message || 'Error al procesar el retiro');
            }
        })
        .catch(function() {
            document.getElementById('btnConfirmRetire').disabled = false;
            alert('Error de conexión');
        });
}

function showPromoteModal() {
    $('#promoteModal').modal('show');
}

document.getElementById('btnPromote').addEventListener('click', function() {
    var fromId = document.getElementById('promote_from').value;
    var toId   = document.getElementById('promote_to').value;
    if (fromId === toId) {
        alert('El año de origen y destino no pueden ser iguales.');
        return;
    }
    var fd = new FormData();
    fd.append('action', 'promote_year');
    fd.append('from_year_id', fromId);
    fd.append('to_year_id', toId);
    fetch(ajaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success) {
                $('#promoteModal').modal('hide');
                alert(d.count + ' {{ 'StudentsPromoted'|get_plugin_lang('SchoolPlugin') }}');
                location.reload();
            } else {
                alert(d.message || 'Error');
            }
        });
});
</script>
