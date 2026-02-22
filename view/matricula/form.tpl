{% if missing_academic_params is not empty and matricula_id == 0 %}
{# ============================================================ #}
{# MODAL: Parámetros académicos requeridos no configurados       #}
{# ============================================================ #}
<div class="modal fade" id="modalMissingAcademic" tabindex="-1" role="dialog"
     data-backdrop="static" data-keyboard="false" aria-labelledby="modalMissingAcademicLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content border-warning">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title" id="modalMissingAcademicLabel">
                    <i class="fas fa-exclamation-triangle mr-2"></i>
                    {{ 'ModalMissingParamsTitle'|get_plugin_lang('SchoolPlugin') }}
                </h5>
            </div>
            <div class="modal-body">
                <p>{{ 'ModalMissingParamsBody'|get_plugin_lang('SchoolPlugin') }}</p>
                <ul class="list-group list-group-flush">
                    {% if 'year' in missing_academic_params %}
                    <li class="list-group-item text-danger">
                        <i class="fas fa-times-circle mr-2"></i>
                        {{ 'ModalMissingParamYear'|get_plugin_lang('SchoolPlugin') }}
                    </li>
                    {% endif %}
                    {% if 'level' in missing_academic_params %}
                    <li class="list-group-item text-danger">
                        <i class="fas fa-times-circle mr-2"></i>
                        {{ 'ModalMissingParamLevel'|get_plugin_lang('SchoolPlugin') }}
                    </li>
                    {% endif %}
                    {% if 'grade' in missing_academic_params %}
                    <li class="list-group-item text-danger">
                        <i class="fas fa-times-circle mr-2"></i>
                        {{ 'ModalMissingParamGrade'|get_plugin_lang('SchoolPlugin') }}
                    </li>
                    {% endif %}
                </ul>
            </div>
            <div class="modal-footer justify-content-between">
                <a href="{{ _p.web }}matricula" class="btn btn-secondary">
                    <i class="fas fa-arrow-left mr-1"></i>
                    {{ 'ModalMissingParamsBack'|get_plugin_lang('SchoolPlugin') }}
                </a>
                <a href="{{ _p.web }}academic/settings" class="btn btn-warning text-dark">
                    <i class="fas fa-cog mr-1"></i>
                    {{ 'ModalMissingParamsAction'|get_plugin_lang('SchoolPlugin') }}
                </a>
            </div>
        </div>
    </div>
</div>
<script>
$(document).ready(function() {
    $('#modalMissingAcademic').modal('show');
});
</script>
{% endif %}

<div class="d-flex justify-content-between align-items-center mb-3">
    <a href="{{ _p.web }}matricula" class="btn btn-secondary btn-sm">
        <i class="fas fa-arrow-left"></i> {{ 'BackToList'|get_plugin_lang('SchoolPlugin') }}
    </a>
    {% if matricula_id > 0 %}
    <a href="{{ _p.web }}matricula/ver?id={{ matricula_id }}" class="btn btn-info btn-sm">
        <i class="fas fa-eye"></i> {{ 'ViewEnrollment'|get_plugin_lang('SchoolPlugin') }}
    </a>
    {% endif %}
</div>

<form method="POST" action="" enctype="multipart/form-data">
    <input type="hidden" name="matricula_id" value="{{ matricula_id }}">
    <input type="hidden" name="user_id" id="matricula-user-id" value="{{ matricula.user_id ?? '' }}">

    {# ============================================================ #}
    {# VÍNCULO CON USUARIO DE CHAMILO                               #}
    {# ============================================================ #}
    <div class="card mb-4 border-info">
        <div class="card-header bg-info text-white py-2">
            <i class="fas fa-link"></i> Vincular a cuenta de usuario
        </div>
        <div class="card-body py-3">
            {% if matricula.user_id %}
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <i class="fas fa-user-check text-success mr-2"></i>
                    <strong>Usuario vinculado:</strong>
                    <span id="linked-user-label" class="ml-1">{{ linked_user_name }}</span>
                </div>
                <button type="button" class="btn btn-sm btn-outline-danger" id="btn-desvincular">
                    <i class="fas fa-unlink"></i> Desvincular
                </button>
            </div>
            {% else %}
            <p class="text-muted mb-2" style="font-size:13px;">
                Al vincular esta matrícula a un usuario, el alumno podrá ver su ficha en su perfil.
            </p>
            {% endif %}
            <div id="user-search-area" {% if matricula.user_id %}style="display:none;"{% endif %}>
                <div class="input-group" style="flex-wrap:nowrap; max-width:400px;">
                    <input type="text" id="user-search-input" class="form-control form-control-sm"
                           placeholder="Buscar por usuario o nombre..."
                           autocomplete="off">
                    <div class="input-group-append">
                        <button type="button" id="btn-buscar-usuario" class="btn btn-sm btn-outline-info">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
                <div id="user-search-results" class="list-group mt-1"
                     style="position:absolute; z-index:200; max-width:400px; display:none;"></div>
            </div>
        </div>
    </div>

    {# ============================================================ #}
    {# SECCIÓN 1: DATOS DEL ESTUDIANTE                              #}
    {# ============================================================ #}
    <div class="card mb-4">
        <div class="card-header"><i class="fas fa-user-graduate"></i> {{ 'StudentData'|get_plugin_lang('SchoolPlugin') }}</div>
        <div class="card-body">

            <div class="form-row">
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'AcademicYear'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="academic_year_id" class="form-control">
                        <option value="">— {{ 'SelectOption'|get_plugin_lang('SchoolPlugin') }} —</option>
                        {% for y in all_years %}
                        <option value="{{ y.id }}" {{ default_year_id == y.id ? 'selected' : '' }}>{{ y.name }}{% if y.active %} ★{% endif %}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group col-md-2">
                    <label class="font-weight-bold">{{ 'EstadoMatricula'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="estado" class="form-control">
                        <option value="ACTIVO" {{ (matricula.estado ?? 'ACTIVO') == 'ACTIVO' ? 'selected' : '' }}>{{ 'Activo'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="RETIRADO" {{ (matricula.estado ?? '') == 'RETIRADO' ? 'selected' : '' }}>{{ 'Retirado'|get_plugin_lang('SchoolPlugin') }}</option>
                    </select>
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'TipoIngreso'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <select name="tipo_ingreso" class="form-control" required>
                        <option value="NUEVO_INGRESO" {{ (matricula.tipo_ingreso ?? 'NUEVO_INGRESO') == 'NUEVO_INGRESO' ? 'selected' : '' }}>{{ 'NewEnrollmentType'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="REINGRESO" {{ (matricula.tipo_ingreso ?? '') == 'REINGRESO' ? 'selected' : '' }}>{{ 'ReenrollmentType'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="CONTINUACION" {{ (matricula.tipo_ingreso ?? '') == 'CONTINUACION' ? 'selected' : '' }}>{{ 'ContinuacionType'|get_plugin_lang('SchoolPlugin') }}</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">{{ 'ApellidoPaterno'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" name="apellido_paterno" class="form-control text-uppercase" value="{{ matricula.apellido_paterno ?? '' }}" required placeholder="Apellido paterno">
                </div>
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">{{ 'ApellidoMaterno'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="apellido_materno" class="form-control text-uppercase" value="{{ matricula.apellido_materno ?? '' }}" placeholder="Apellido materno">
                </div>
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">{{ 'Nombres'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" name="nombres" class="form-control text-uppercase" value="{{ matricula.nombres ?? '' }}" required placeholder="Nombres">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'Level'|get_plugin_lang('SchoolPlugin') }} / {{ 'Grade'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="grade_id" class="form-control" id="grade_id">
                        <option value="">— {{ 'SelectOption'|get_plugin_lang('SchoolPlugin') }} —</option>
                        {% for level in levels %}
                            <optgroup label="{{ level.name }}">
                                {% for grade in level.grades %}
                                <option value="{{ grade.id }}" {{ (matricula.grade_id ?? 0) == grade.id ? 'selected' : '' }}>{{ grade.name }}</option>
                                {% endfor %}
                            </optgroup>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group col-md-2">
                    <label class="font-weight-bold">{{ 'Sexo'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="sexo" class="form-control">
                        <option value="">—</option>
                        <option value="F" {{ (matricula.sexo ?? '') == 'F' ? 'selected' : '' }}>Femenino</option>
                        <option value="M" {{ (matricula.sexo ?? '') == 'M' ? 'selected' : '' }}>Masculino</option>
                    </select>
                </div>
                <div class="form-group col-md-2">
                    <label class="font-weight-bold">{{ 'Nacionalidad'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="nacionalidad" id="field-nacionalidad" class="form-control">
                        <option value="Peruana"    {{ (matricula.nacionalidad ?? 'Peruana') == 'Peruana'    ? 'selected' : '' }}>{{ 'Peruana'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="Extranjera" {{ (matricula.nacionalidad ?? '') == 'Extranjera' ? 'selected' : '' }}>{{ 'Extranjera'|get_plugin_lang('SchoolPlugin') }}</option>
                    </select>
                </div>
                <div class="form-group col-md-2">
                    <label class="font-weight-bold">{{ 'TipoDocumento'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="tipo_documento" id="field-tipo-doc" class="form-control">
                        {% set nacActual = matricula.nacionalidad ?? 'Peruana' %}
                        {% set docActual = matricula.tipo_documento ?? 'DNI' %}
                        <option value="DNI" {{ docActual == 'DNI' ? 'selected' : '' }}>DNI</option>
                        {% if nacActual == 'Extranjera' %}
                        <option value="CARNET_EXTRANJERIA" {{ docActual == 'CARNET_EXTRANJERIA' ? 'selected' : '' }}>{{ 'CarnetExtranjeria'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="PASAPORTE"          {{ docActual == 'PASAPORTE'          ? 'selected' : '' }}>{{ 'Pasaporte'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="RUC"                {{ docActual == 'RUC'                ? 'selected' : '' }}>RUC</option>
                        <option value="OTRO"               {{ docActual == 'OTRO'               ? 'selected' : '' }}>{{ 'Otro'|get_plugin_lang('SchoolPlugin') }}</option>
                        {% endif %}
                    </select>
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'NroDocumento'|get_plugin_lang('SchoolPlugin') }}</label>
                    <div class="input-group" style="flex-wrap:nowrap;">
                        <input type="text" name="dni" id="field-doc-nro" class="form-control" style="margin:0;"
                               value="{{ matricula.dni ?? '' }}"
                               maxlength="{{ (matricula.nacionalidad ?? 'Peruana') == 'Peruana' ? '8' : '20' }}"
                               placeholder="{{ (matricula.nacionalidad ?? 'Peruana') == 'Peruana' ? '00000000' : '' }}">
                        <div class="input-group-append">
                            <button type="button" id="btn-consultar-reniec" class="btn btn-outline-info"
                                    title="Consultar apellidos y nombres en RENIEC" style="display:none; font-size:12px; width:100px;">
                                <i class="fas fa-search"></i> RENIEC
                            </button>
                        </div>
                    </div>
                    <small id="reniec-msg" class="form-text text-muted"></small>
                </div>
            </div>

            {# Foto del alumno #}
            <div class="form-row align-items-center mb-3">
                <div class="form-group col-md-3">
                    <label class="font-weight-bold d-block">Foto del alumno</label>
                    <div class="d-flex align-items-center">
                        <div class="mr-3">
                            <img id="foto-preview"
                                 src="{{ foto_url ?: '' }}"
                                 alt="Foto"
                                 style="width:100px; height:120px; object-fit:cover; border:1px solid #ccc; border-radius:4px; background:#f0f0f0; display:{{ foto_url ? 'block' : 'none' }};">
                            <div id="foto-placeholder" style="width:100px; height:120px; border:1px dashed #ccc; border-radius:4px; background:#f9f9f9; display:flex; align-items:center; justify-content:center; color:#aaa; font-size:12px; text-align:center; {{ foto_url ? 'display:none;' : '' }}">
                                <span><i class="fas fa-user" style="font-size:2rem; display:block; margin-bottom:4px;"></i>Sin foto</span>
                            </div>
                        </div>
                        <div>
                            <input type="file" name="foto" id="input-foto" accept="image/*" class="form-control-file" style="font-size:12px;">
                            <small class="text-muted d-block mt-1">JPG, PNG o GIF. Máx. 2 MB.</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'FechaNacimiento'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="date" name="fecha_nacimiento" class="form-control" value="{{ matricula.fecha_nacimiento ?? '' }}">
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'TipoSangre'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="tipo_sangre" class="form-control">
                        <option value="">—</option>
                        {% for ts in tipos_sangre %}
                        <option value="{{ ts }}" {{ (matricula.tipo_sangre ?? '') == ts ? 'selected' : '' }}>{{ ts }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'Peso'|get_plugin_lang('SchoolPlugin') }} (kg)</label>
                    <input type="number" name="peso" class="form-control" value="{{ matricula.peso ?? '' }}" step="0.01" min="0" placeholder="0.00">
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'Estatura'|get_plugin_lang('SchoolPlugin') }} (m)</label>
                    <input type="number" name="estatura" class="form-control" value="{{ matricula.estatura ?? '' }}" step="0.01" min="0" placeholder="0.00">
                </div>
            </div>

            {# Domicilio + Ubigeo #}
            <div class="form-group">
                <label class="font-weight-bold">{{ 'Domicilio'|get_plugin_lang('SchoolPlugin') }}</label>
                <input type="text" name="domicilio" class="form-control" value="{{ matricula.domicilio ?? '' }}" placeholder="Dirección (calle, número, referencia)">
            </div>
            <div class="form-row">
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">{{ 'Region'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="region" id="mat_region" class="form-control">
                        <option value="">{{ select_option_text }}</option>
                        {% for r in regions %}
                        <option value="{{ r.id }}" {{ saved_region == r.id ? 'selected' : '' }}>{{ r.name }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">{{ 'Province'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="provincia" id="mat_province" class="form-control" {{ saved_region ? '' : 'disabled' }}>
                        <option value="">{{ select_option_text }}</option>
                    </select>
                </div>
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">{{ 'District'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="distrito" id="mat_district" class="form-control" {{ saved_province ? '' : 'disabled' }}>
                        <option value="">{{ select_option_text }}</option>
                    </select>
                </div>
            </div>

            {# Salud #}
            <hr>
            <h6 class="font-weight-bold text-secondary">{{ 'HealthInfo'|get_plugin_lang('SchoolPlugin') }}</h6>
            <div class="form-row">
                <div class="form-group col-md-4">
                    <div class="custom-control custom-switch">
                        <input type="hidden" name="tiene_alergias" value="0">
                        <input type="checkbox" class="custom-control-input" id="tiene_alergias" name="tiene_alergias" value="1"
                            {{ (matricula.tiene_alergias ?? 0) ? 'checked' : '' }}
                            onchange="toggleDetail('alergias_detalle_group', this.checked)">
                        <label class="custom-control-label" for="tiene_alergias">{{ 'TieneAlergias'|get_plugin_lang('SchoolPlugin') }}</label>
                    </div>
                </div>
                <div class="form-group col-md-4">
                    <div class="custom-control custom-switch">
                        <input type="hidden" name="usa_lentes" value="0">
                        <input type="checkbox" class="custom-control-input" id="usa_lentes" name="usa_lentes" value="1"
                            {{ (matricula.usa_lentes ?? 0) ? 'checked' : '' }}>
                        <label class="custom-control-label" for="usa_lentes">{{ 'UsaLentes'|get_plugin_lang('SchoolPlugin') }}</label>
                    </div>
                </div>
                <div class="form-group col-md-4">
                    <div class="custom-control custom-switch">
                        <input type="hidden" name="tiene_discapacidad" value="0">
                        <input type="checkbox" class="custom-control-input" id="tiene_discapacidad" name="tiene_discapacidad" value="1"
                            {{ (matricula.tiene_discapacidad ?? 0) ? 'checked' : '' }}
                            onchange="toggleDetail('discapacidad_detalle_group', this.checked)">
                        <label class="custom-control-label" for="tiene_discapacidad">{{ 'TieneDiscapacidad'|get_plugin_lang('SchoolPlugin') }}</label>
                    </div>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group col-md-6" id="alergias_detalle_group" style="{{ (matricula.tiene_alergias ?? 0) ? '' : 'display:none;' }}">
                    <label>{{ 'AlergiasDetalle'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="alergias_detalle" class="form-control" value="{{ matricula.alergias_detalle ?? '' }}" placeholder="Describir alergias...">
                </div>
                <div class="form-group col-md-6" id="discapacidad_detalle_group" style="{{ (matricula.tiene_discapacidad ?? 0) ? '' : 'display:none;' }}">
                    <label>{{ 'DiscapacidadDetalle'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="discapacidad_detalle" class="form-control" value="{{ matricula.discapacidad_detalle ?? '' }}" placeholder="Describir discapacidad...">
                </div>
            </div>

            {# Procedencia #}
            <hr>
            <h6 class="font-weight-bold text-secondary">{{ 'OriginInfo'|get_plugin_lang('SchoolPlugin') }}</h6>
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label>{{ 'IeProcedencia'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="ie_procedencia" class="form-control" value="{{ matricula.ie_procedencia ?? '' }}" placeholder="Institución educativa anterior">
                </div>
                <div class="form-group col-md-6">
                    <label>{{ 'MotivoTraslado'|get_plugin_lang('SchoolPlugin') }}</label>
                    <textarea name="motivo_traslado" class="form-control" rows="2" placeholder="Motivo de traslado...">{{ matricula.motivo_traslado ?? '' }}</textarea>
                </div>
            </div>
        </div>
    </div>

    {# ============================================================ #}
    {# SECCIÓN 2: DATOS DE LA MADRE                                 #}
    {# ============================================================ #}
    <div class="card mb-4">
        <div class="card-header"><i class="fas fa-female"></i> {{ 'MadreData'|get_plugin_lang('SchoolPlugin') }}</div>
        <div class="card-body">
            <div class="form-row">
                <div class="form-group col-md-4">
                    <label>{{ 'Apellidos'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="madre[apellidos]" class="form-control text-uppercase" value="{{ madre.apellidos ?? '' }}">
                </div>
                <div class="form-group col-md-4">
                    <label>{{ 'Nombres'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="madre[nombres]" class="form-control text-uppercase" value="{{ madre.nombres ?? '' }}">
                </div>
                <div class="form-group col-md-2">
                    <label>{{ 'Edad'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="number" name="madre[edad]" class="form-control" value="{{ madre.edad ?? '' }}" min="18" max="99">
                </div>
                <div class="form-group col-md-2">
                    <label>{{ 'Dni'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="madre[dni]" class="form-control" value="{{ madre.dni ?? '' }}" maxlength="8">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group col-md-3">
                    <label>{{ 'Celular'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="madre[celular]" class="form-control" value="{{ madre.celular ?? '' }}">
                </div>
                <div class="form-group col-md-3">
                    <label>{{ 'Ocupacion'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="madre[ocupacion]" class="form-control" value="{{ madre.ocupacion ?? '' }}">
                </div>
                <div class="form-group col-md-3">
                    <label>{{ 'Religion'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="madre[religion]" class="form-control" value="{{ madre.religion ?? '' }}">
                </div>
                <div class="form-group col-md-3">
                    <label>{{ 'TipoParto'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select name="madre[tipo_parto]" class="form-control">
                        <option value="">—</option>
                        <option value="NORMAL" {{ (madre.tipo_parto ?? '') == 'NORMAL' ? 'selected' : '' }}>Normal</option>
                        <option value="CESAREA" {{ (madre.tipo_parto ?? '') == 'CESAREA' ? 'selected' : '' }}>Cesárea</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    {# ============================================================ #}
    {# SECCIÓN 3: DATOS DEL PADRE                                   #}
    {# ============================================================ #}
    <div class="card mb-4">
        <div class="card-header"><i class="fas fa-male"></i> {{ 'PadreData'|get_plugin_lang('SchoolPlugin') }}</div>
        <div class="card-body">
            <div class="form-row">
                <div class="form-group col-md-4">
                    <label>{{ 'Apellidos'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="padre[apellidos]" class="form-control text-uppercase" value="{{ padre.apellidos ?? '' }}">
                </div>
                <div class="form-group col-md-4">
                    <label>{{ 'Nombres'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="padre[nombres]" class="form-control text-uppercase" value="{{ padre.nombres ?? '' }}">
                </div>
                <div class="form-group col-md-2">
                    <label>{{ 'Edad'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="number" name="padre[edad]" class="form-control" value="{{ padre.edad ?? '' }}" min="18" max="99">
                </div>
                <div class="form-group col-md-2">
                    <label>{{ 'Dni'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="padre[dni]" class="form-control" value="{{ padre.dni ?? '' }}" maxlength="8">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group col-md-3">
                    <label>{{ 'Celular'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="padre[celular]" class="form-control" value="{{ padre.celular ?? '' }}">
                </div>
                <div class="form-group col-md-3">
                    <label>{{ 'Ocupacion'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="padre[ocupacion]" class="form-control" value="{{ padre.ocupacion ?? '' }}">
                </div>
                <div class="form-group col-md-3">
                    <label>{{ 'Religion'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="padre[religion]" class="form-control" value="{{ padre.religion ?? '' }}">
                </div>
                <div class="form-group col-md-3">
                    <div class="custom-control custom-switch mt-4">
                        <input type="hidden" name="padre[vive_con_menor]" value="0">
                        <input type="checkbox" class="custom-control-input" id="padre_vive" name="padre[vive_con_menor]" value="1"
                            {{ (padre.vive_con_menor ?? 0) ? 'checked' : '' }}>
                        <label class="custom-control-label" for="padre_vive">{{ 'ViveConMenor'|get_plugin_lang('SchoolPlugin') }}</label>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {# ============================================================ #}
    {# SECCIÓN 4: CONTACTO DE EMERGENCIA                            #}
    {# ============================================================ #}
    <div class="card mb-4">
        <div class="card-header"><i class="fas fa-phone-alt"></i> {{ 'EmergencyContact'|get_plugin_lang('SchoolPlugin') }}</div>
        <div class="card-body">
            <input type="hidden" name="contacto_id" value="{{ contactos[0].id ?? 0 }}">
            <div class="form-row">
                <div class="form-group col-md-5">
                    <label>{{ 'NombreContacto'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="contacto[nombre_contacto]" class="form-control" value="{{ contactos[0].nombre_contacto ?? '' }}">
                </div>
                <div class="form-group col-md-3">
                    <label>{{ 'Telefono'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="contacto[telefono]" class="form-control" value="{{ contactos[0].telefono ?? '' }}">
                </div>
                <div class="form-group col-md-4">
                    <label>{{ 'Direccion'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="contacto[direccion]" class="form-control" value="{{ contactos[0].direccion ?? '' }}">
                </div>
            </div>
        </div>
    </div>

    {# ============================================================ #}
    {# SECCIÓN 5: INFORMACIÓN ADICIONAL                             #}
    {# ============================================================ #}
    <div class="card mb-4">
        <div class="card-header"><i class="fas fa-info-circle"></i> {{ 'AdditionalInfo'|get_plugin_lang('SchoolPlugin') }}</div>
        <div class="card-body">
            <div class="form-group">
                <label>{{ 'EncargadosCuidado'|get_plugin_lang('SchoolPlugin') }}</label>
                <input type="text" name="info[encargados_cuidado]" class="form-control" value="{{ info.encargados_cuidado ?? '' }}" placeholder="Persona(s) que cuidan al menor en casa">
            </div>
            <div class="form-group">
                <label>{{ 'FamiliarEnInstitucion'|get_plugin_lang('SchoolPlugin') }}</label>
                <input type="text" name="info[familiar_en_institucion]" class="form-control" value="{{ info.familiar_en_institucion ?? '' }}" placeholder="Nombre del familiar que estudia en la institución">
            </div>
            <div class="form-group">
                <label>{{ 'Observaciones'|get_plugin_lang('SchoolPlugin') }}</label>
                <textarea name="info[observaciones]" class="form-control" rows="3" placeholder="Observaciones generales...">{{ info.observaciones ?? '' }}</textarea>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-between mb-4">
        <a href="{{ _p.web }}matricula" class="btn btn-secondary">
            <i class="fas fa-times"></i> {{ 'Cancel'|get_plugin_lang('SchoolPlugin') }}
        </a>
        <button type="submit" class="btn btn-primary btn-lg">
            <i class="fas fa-save"></i> {{ 'SaveEnrollment'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
</form>

<script>
function toggleDetail(groupId, show) {
    document.getElementById(groupId).style.display = show ? 'block' : 'none';
}

$(function() {
    var provinciasData = null;
    var distritosData  = null;
    var selectText     = "{{ select_option_text }}";
    var ubigeoPath     = "{{ ubigeo_path }}";

    $("#mat_region").on("change", function() {
        var regionId   = $(this).val();
        var $province  = $("#mat_province");
        var $district  = $("#mat_district");

        $province.html('<option value="">' + selectText + '</option>').attr("disabled", "disabled");
        $district.html('<option value="">' + selectText + '</option>').attr("disabled", "disabled");

        if (!regionId) return;

        if (provinciasData) {
            fillProvincias(regionId);
        } else {
            $.getJSON(ubigeoPath + "ubigeo_peru_2016_provincias.json", function(data) {
                provinciasData = data;
                fillProvincias(regionId);
            });
        }
    });

    $("#mat_province").on("change", function() {
        var provinceId = $(this).val();
        var $district  = $("#mat_district");

        $district.html('<option value="">' + selectText + '</option>').attr("disabled", "disabled");

        if (!provinceId) return;

        if (distritosData) {
            fillDistritos(provinceId);
        } else {
            $.getJSON(ubigeoPath + "ubigeo_peru_2016_distritos.json", function(data) {
                distritosData = data;
                fillDistritos(provinceId);
            });
        }
    });

    function fillProvincias(regionId) {
        var $province = $("#mat_province");
        $province.html('<option value="">' + selectText + '</option>');
        $.each(provinciasData, function(i, item) {
            if (item.department_id === regionId) {
                $province.append('<option value="' + item.id + '">' + item.name + '</option>');
            }
        });
        $province.removeAttr("disabled");
    }

    function fillDistritos(provinceId) {
        var $district = $("#mat_district");
        $district.html('<option value="">' + selectText + '</option>');
        $.each(distritosData, function(i, item) {
            if (item.province_id === provinceId) {
                $district.append('<option value="' + item.id + '">' + item.name + '</option>');
            }
        });
        $district.removeAttr("disabled");
    }

    // Prevent disabled selects from being excluded from form submission
    $("form").on("submit", function() {
        $("#mat_province, #mat_district").removeAttr("disabled");
    });

    // Restore saved ubigeo on page load
    var savedRegion   = "{{ saved_region }}";
    var savedProvince = "{{ saved_province }}";
    var savedDistrict = "{{ saved_district }}";

    if (savedRegion) {
        $("#mat_region").val(savedRegion);
        $.getJSON(ubigeoPath + "ubigeo_peru_2016_provincias.json", function(data) {
            provinciasData = data;
            fillProvincias(savedRegion);
            if (savedProvince) {
                $("#mat_province").val(savedProvince);
                $.getJSON(ubigeoPath + "ubigeo_peru_2016_distritos.json", function(data2) {
                    distritosData = data2;
                    fillDistritos(savedProvince);
                    if (savedDistrict) {
                        $("#mat_district").val(savedDistrict);
                    }
                });
            }
        });
    }
});

// Actualiza opciones de tipo_documento y atributos de N° documento según nacionalidad
function updateTipoDoc() {
    var nac    = document.getElementById('field-nacionalidad').value;
    var esPe   = (nac === 'Peruana');
    var select = document.getElementById('field-tipo-doc');
    var input  = document.getElementById('field-doc-nro');
    var current = select.value;

    // Reconstruir opciones
    select.innerHTML = '<option value="DNI">DNI</option>';
    if (!esPe) {
        select.innerHTML +=
            '<option value="CARNET_EXTRANJERIA">{{ 'CarnetExtranjeria'|get_plugin_lang('SchoolPlugin') }}</option>' +
            '<option value="PASAPORTE">{{ 'Pasaporte'|get_plugin_lang('SchoolPlugin') }}</option>' +
            '<option value="RUC">RUC</option>' +
            '<option value="OTRO">{{ 'Otro'|get_plugin_lang('SchoolPlugin') }}</option>';
    }

    // Restaurar selección si sigue disponible
    if (current && select.querySelector('option[value="' + current + '"]')) {
        select.value = current;
    } else {
        select.value = 'DNI';
    }

    // Ajustar maxlength y placeholder del N° documento
    input.maxLength  = esPe ? 8 : 20;
    input.placeholder = esPe ? '00000000' : '';
}
document.getElementById('field-nacionalidad').addEventListener('change', updateTipoDoc);

// --- Integración RENIEC ---
function toggleReniecBtn() {
    var tipo = document.getElementById('field-tipo-doc').value;
    var nac  = document.getElementById('field-nacionalidad').value;
    var show = (tipo === 'DNI' && nac === 'Peruana');
    document.getElementById('btn-consultar-reniec').style.display = show ? '' : 'none';
    if (!show) {
        var msg = document.getElementById('reniec-msg');
        msg.textContent = '';
        msg.className = 'form-text text-muted';
    }
}
document.getElementById('field-tipo-doc').addEventListener('change', toggleReniecBtn);
document.getElementById('field-nacionalidad').addEventListener('change', toggleReniecBtn);
toggleReniecBtn();

document.getElementById('btn-consultar-reniec').addEventListener('click', function() {
    var dni = document.getElementById('field-doc-nro').value.trim();
    var msg = document.getElementById('reniec-msg');
    if (!/^\d{8}$/.test(dni)) {
        msg.textContent = 'Ingrese un DNI válido de 8 dígitos.';
        msg.className = 'form-text text-danger';
        return;
    }
    var btn = this;
    btn.disabled = true;
    msg.textContent = 'Consultando RENIEC...';
    msg.className = 'form-text text-muted';

    $.post('{{ ajax_matricula_url }}', { action: 'consultar_reniec', dni: dni })
     .done(function(resp) {
        if (resp.success) {
            $('input[name="apellido_paterno"]').val(resp.apellido_paterno);
            $('input[name="apellido_materno"]').val(resp.apellido_materno);
            $('input[name="nombres"]').val(resp.nombres);
            msg.textContent = 'Datos obtenidos de RENIEC correctamente.';
            msg.className = 'form-text text-success';
        } else {
            msg.textContent = resp.message || 'No se encontró el DNI en RENIEC.';
            msg.className = 'form-text text-danger';
        }
     })
     .fail(function() {
        msg.textContent = 'Error de conexión al consultar RENIEC.';
        msg.className = 'form-text text-danger';
     })
     .always(function() { btn.disabled = false; });
});

// Vincular usuario de Chamilo
(function() {
    var input    = document.getElementById('user-search-input');
    var results  = document.getElementById('user-search-results');
    var hiddenId = document.getElementById('matricula-user-id');
    var btnBuscar    = document.getElementById('btn-buscar-usuario');
    var btnDesvincular = document.getElementById('btn-desvincular');

    function buscar() {
        var term = input ? input.value.trim() : '';
        if (term.length < 2) { results.style.display = 'none'; return; }
        $.post('{{ ajax_matricula_url }}', { action: 'buscar_usuario', term: term })
         .done(function(resp) {
            results.innerHTML = '';
            if (resp.success && resp.users.length) {
                resp.users.forEach(function(u) {
                    var a = document.createElement('a');
                    a.href = '#';
                    a.className = 'list-group-item list-group-item-action py-1';
                    a.style.fontSize = '13px';
                    a.textContent = u.label;
                    a.addEventListener('click', function(e) {
                        e.preventDefault();
                        hiddenId.value = u.id;
                        input.value = u.label;
                        results.style.display = 'none';
                    });
                    results.appendChild(a);
                });
                results.style.display = 'block';
            } else {
                results.style.display = 'none';
            }
         });
    }

    if (btnBuscar) btnBuscar.addEventListener('click', buscar);
    if (input) input.addEventListener('keyup', function(e) { if (e.key === 'Enter') buscar(); });

    document.addEventListener('click', function(e) {
        if (results && !results.contains(e.target) && e.target !== input) {
            results.style.display = 'none';
        }
    });

    if (btnDesvincular) {
        btnDesvincular.addEventListener('click', function() {
            hiddenId.value = '';
            document.getElementById('user-search-area').style.display = '';
            this.closest('.d-flex').style.display = 'none';
        });
    }
})();

// Preview de foto del alumno
document.getElementById('input-foto').addEventListener('change', function() {
    var file = this.files[0];
    if (!file) return;
    var reader = new FileReader();
    reader.onload = function(e) {
        var preview = document.getElementById('foto-preview');
        var placeholder = document.getElementById('foto-placeholder');
        preview.src = e.target.result;
        preview.style.display = 'block';
        placeholder.style.display = 'none';
    };
    reader.readAsDataURL(file);
});
</script>
