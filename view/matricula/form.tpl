<div class="d-flex justify-content-between align-items-center mb-3">
    <a href="{{ _p.web }}matricula" class="btn btn-secondary btn-sm">
        <i class="fas fa-arrow-left"></i> {{ 'BackToList'|get_plugin_lang('SchoolPlugin') }}
    </a>
    {% if ficha_id > 0 %}
    <a href="{{ _p.web }}matricula/ver?ficha_id={{ ficha_id }}" class="btn btn-info btn-sm">
        <i class="fas fa-eye"></i> {{ 'ViewEnrollment'|get_plugin_lang('SchoolPlugin') }}
    </a>
    {% endif %}
</div>

<form method="POST" action="" enctype="multipart/form-data">
    <input type="hidden" name="ficha_id" value="{{ ficha_id }}">
    <input type="hidden" name="user_id" id="matricula-user-id" value="{{ prelinked_user_id ?: (matricula.user_id ?? '') }}">

    {# ============================================================ #}
    {# VÍNCULO CON USUARIO DE CHAMILO                               #}
    {# ============================================================ #}
    <div class="card mb-4 border-info">
        <div class="card-header bg-info text-white py-2">
            <i class="fas fa-link"></i> Vincular a cuenta de usuario
        </div>
        <div class="card-body py-3">
            {% if prelinked_user_id or matricula.user_id %}
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
            <div id="user-search-area" {% if prelinked_user_id or matricula.user_id %}style="display:none;"{% endif %}>
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

            {% if prelinked_user_id or matricula.user_id %}
            {# Nombre viene del perfil de Chamilo — solo se muestra, no se edita #}
            <div class="alert alert-light border mb-3 py-2">
                <span class="text-muted" style="font-size:12px;">Apellidos y Nombres</span><br>
                <strong style="font-size:15px;">
                    {{ matricula.apellido_paterno ?? preload.apellido_paterno ?? '' }}
                    {{ matricula.apellido_materno ?? preload.apellido_materno ?? '' }},
                    {{ matricula.nombres ?? preload.nombres ?? '' }}
                </strong>
                <small class="text-muted ml-2">(tomado del perfil de usuario)</small>
            </div>
            {% else %}
            <div class="form-row">
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">{{ 'ApellidoPaterno'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" name="apellido_paterno" class="form-control text-uppercase" value="{{ matricula.apellido_paterno ?? preload.apellido_paterno ?? '' }}" required placeholder="Apellido paterno">
                </div>
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">{{ 'ApellidoMaterno'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="apellido_materno" class="form-control text-uppercase" value="{{ matricula.apellido_materno ?? preload.apellido_materno ?? '' }}" placeholder="Apellido materno">
                </div>
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">{{ 'Nombres'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" name="nombres" class="form-control text-uppercase" value="{{ matricula.nombres ?? preload.nombres ?? '' }}" required placeholder="Nombres">
                </div>
            </div>
            {% endif %}

            <div class="form-row">
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
                        {% set docActual = matricula.tipo_documento ?? preload.tipo_documento ?? 'DNI' %}
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
                               value="{{ matricula.dni ?? preload.dni ?? '' }}"
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
    {# SECCIÓN 2: PADRES / APODERADOS                              #}
    {# ============================================================ #}
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center py-2">
            <span><i class="fas fa-users mr-1"></i> Padres / Apoderados</span>
            <button type="button" class="btn btn-sm btn-success" id="btn-agregar-padre">
                <i class="fas fa-plus"></i> Agregar
            </button>
        </div>
        <div class="card-body p-0">
            <table class="table table-sm table-hover mb-0" id="tabla-padres">
                <thead class="thead-light">
                    <tr>
                        <th style="width:100px;">Tipo</th>
                        <th>Apellidos y Nombres</th>
                        <th style="width:130px;">Celular</th>
                        <th style="width:80px;"></th>
                    </tr>
                </thead>
                <tbody id="tbody-padres"></tbody>
            </table>
        </div>
        <input type="hidden" name="padres_data" id="padres-data-input" value="[]">
    </div>

    {# ============================================================ #}
    {# SECCIÓN 2b: HERMANOS                                        #}
    {# ============================================================ #}
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center py-2">
            <span><i class="fas fa-child mr-1"></i> Hermanos</span>
            <button type="button" class="btn btn-sm btn-success" id="btn-agregar-hermano">
                <i class="fas fa-plus"></i> Agregar
            </button>
        </div>
        <div class="card-body p-0">
            <table class="table table-sm table-hover mb-0" id="tabla-hermanos">
                <thead class="thead-light">
                    <tr>
                        <th>Nombre</th>
                        <th style="width:60px;"></th>
                    </tr>
                </thead>
                <tbody id="tbody-hermanos"></tbody>
            </table>
        </div>
        <input type="hidden" name="hermanos_data" id="hermanos-data-input" value="[]">
    </div>

    {# ============================================================ #}
    {# SECCIÓN 3: CONTACTOS DE EMERGENCIA                          #}
    {# ============================================================ #}
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center py-2">
            <span><i class="fas fa-phone-alt mr-1"></i> Contactos de Emergencia</span>
            <button type="button" class="btn btn-sm btn-success" id="btn-agregar-contacto">
                <i class="fas fa-plus"></i> Agregar
            </button>
        </div>
        <div class="card-body p-0">
            <table class="table table-sm table-hover mb-0" id="tabla-contactos">
                <thead class="thead-light">
                    <tr>
                        <th>Nombre</th>
                        <th style="width:130px;">Teléfono</th>
                        <th>Dirección</th>
                        <th style="width:80px;"></th>
                    </tr>
                </thead>
                <tbody id="tbody-contactos"></tbody>
            </table>
        </div>
        <input type="hidden" name="contactos_data" id="contactos-data-input" value="[]">
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

{# ============================================================ #}
{# MODAL: Padre / Madre / Apoderado                             #}
{# ============================================================ #}
<div class="modal fade" id="modalPadre" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title font-weight-bold">
                    <i class="fas fa-user-friends mr-1"></i> Datos del Padre / Madre / Apoderado
                </h6>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="mp-index" value="-1">
                <div class="form-row">
                    <div class="form-group col-md-4">
                        <label class="font-weight-bold">Tipo <span class="text-danger">*</span></label>
                        <select id="mp-tipo" class="form-control form-control-sm">
                            <option value="PADRE">Padre</option>
                            <option value="MADRE">Madre</option>
                            <option value="APODERADO">Apoderado</option>
                        </select>
                    </div>
                    <div class="form-group col-md-4">
                        <label class="font-weight-bold">Apellidos</label>
                        <input type="text" id="mp-apellidos" class="form-control form-control-sm" placeholder="Apellidos">
                    </div>
                    <div class="form-group col-md-4">
                        <label class="font-weight-bold">Nombres</label>
                        <input type="text" id="mp-nombres" class="form-control form-control-sm" placeholder="Nombres">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-2">
                        <label class="font-weight-bold">Edad</label>
                        <input type="number" id="mp-edad" class="form-control form-control-sm" min="18" max="99" placeholder="Edad">
                    </div>
                    <div class="form-group col-md-3">
                        <label class="font-weight-bold">DNI</label>
                        <input type="text" id="mp-dni" class="form-control form-control-sm" maxlength="12" placeholder="DNI">
                    </div>
                    <div class="form-group col-md-3">
                        <label class="font-weight-bold">Celular</label>
                        <input type="text" id="mp-celular" class="form-control form-control-sm" maxlength="15" placeholder="Celular">
                    </div>
                    <div class="form-group col-md-4">
                        <label class="font-weight-bold">Ocupación</label>
                        <input type="text" id="mp-ocupacion" class="form-control form-control-sm" placeholder="Ocupación">
                    </div>
                </div>
                <div class="form-row align-items-end">
                    <div class="form-group col-md-4">
                        <label class="font-weight-bold">Religión</label>
                        <input type="text" id="mp-religion" class="form-control form-control-sm" placeholder="Religión">
                    </div>
                    <div id="mp-tipo-parto-group" class="form-group col-md-4" style="display:none;">
                        <label class="font-weight-bold">Tipo de parto</label>
                        <select id="mp-tipo-parto" class="form-control form-control-sm">
                            <option value="">—</option>
                            <option value="NORMAL">Normal</option>
                            <option value="CESAREA">Cesárea</option>
                        </select>
                    </div>
                    <div class="form-group col-md-4">
                        <div class="custom-control custom-switch mb-1">
                            <input type="checkbox" class="custom-control-input" id="mp-vive-con-menor">
                            <label class="custom-control-label" for="mp-vive-con-menor">Vive con el menor</label>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary btn-sm" id="btn-guardar-padre">
                    <i class="fas fa-save mr-1"></i> Guardar
                </button>
            </div>
        </div>
    </div>
</div>

{# ============================================================ #}
{# MODAL: Contacto de Emergencia                               #}
{# ============================================================ #}
<div class="modal fade" id="modalContacto" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title font-weight-bold">
                    <i class="fas fa-phone-alt mr-1"></i> Contacto de Emergencia
                </h6>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="mc-index" value="-1">
                <div class="form-group">
                    <label class="font-weight-bold">Nombre <span class="text-danger">*</span></label>
                    <input type="text" id="mc-nombre" class="form-control form-control-sm" placeholder="Nombre del contacto">
                </div>
                <div class="form-row">
                    <div class="form-group col-md-5">
                        <label class="font-weight-bold">Teléfono</label>
                        <input type="text" id="mc-telefono" class="form-control form-control-sm" maxlength="15" placeholder="Teléfono">
                    </div>
                    <div class="form-group col-md-7">
                        <label class="font-weight-bold">Dirección</label>
                        <input type="text" id="mc-direccion" class="form-control form-control-sm" placeholder="Dirección">
                    </div>
                </div>
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary btn-sm" id="btn-guardar-contacto">
                    <i class="fas fa-save mr-1"></i> Guardar
                </button>
            </div>
        </div>
    </div>
</div>

{# ============================================================ #}
{# MODAL: Hermano                                              #}
{# ============================================================ #}
<div class="modal fade" id="modalHermano" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title font-weight-bold">
                    <i class="fas fa-child mr-1"></i> Agregar Hermano
                </h6>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group mb-2">
                    <label class="font-weight-bold">Buscar usuario en el sistema</label>
                    <div class="input-group">
                        <input type="text" id="hermano-search" class="form-control form-control-sm"
                               placeholder="Buscar por nombre, apellido o usuario..." autocomplete="off">
                        <div class="input-group-append">
                            <button type="button" id="btn-buscar-hermano" class="btn btn-sm btn-outline-info">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>
                    <div id="hermano-search-results" class="list-group mt-1"
                         style="position:relative; z-index:200; display:none;"></div>
                </div>
                <div id="hermano-selected-box" class="alert alert-success d-none py-2 mb-0" style="font-size:13px;">
                    <i class="fas fa-user-check mr-1"></i> <span id="hermano-selected-label"></span>
                </div>
                <input type="hidden" id="hermano-selected-id" value="">
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary btn-sm" id="btn-confirmar-hermano" disabled>
                    <i class="fas fa-plus mr-1"></i> Agregar
                </button>
            </div>
        </div>
    </div>
</div>

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

// =========================================================
// Padres / Apoderados modal management
// =========================================================
(function () {
    var padresArr  = {{ all_padres_json|default('[]') }};
    var tipoLabel  = { PADRE: 'Padre', MADRE: 'Madre', APODERADO: 'Apoderado' };
    var tipoBadge  = { PADRE: 'badge-primary', MADRE: 'badge-danger', APODERADO: 'badge-warning' };

    function renderPadres() {
        var tbody = document.getElementById('tbody-padres');
        if (padresArr.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3" style="font-size:13px;">Sin registros. Haga clic en "Agregar" para añadir.</td></tr>';
        } else {
            tbody.innerHTML = '';
            padresArr.forEach(function (p, idx) {
                var label  = tipoLabel[p.tipo]  || p.tipo;
                var badge  = tipoBadge[p.tipo]  || 'badge-secondary';
                var nombre = (p.apellidos || '') + (p.apellidos && p.nombres ? ', ' : '') + (p.nombres || '');
                tbody.innerHTML +=
                    '<tr>' +
                    '<td><span class="badge ' + badge + '">' + label + '</span></td>' +
                    '<td>' + nombre + '</td>' +
                    '<td>' + (p.celular || '') + '</td>' +
                    '<td class="text-right">' +
                        '<button type="button" class="btn btn-xs btn-outline-info mr-1" onclick="editarPadre(' + idx + ')"><i class="fas fa-edit"></i></button>' +
                        '<button type="button" class="btn btn-xs btn-outline-danger" onclick="eliminarPadre(' + idx + ')"><i class="fas fa-trash"></i></button>' +
                    '</td></tr>';
            });
        }
        document.getElementById('padres-data-input').value = JSON.stringify(padresArr);
    }

    function abrirModal(idx) {
        var p = idx >= 0 ? padresArr[idx] : {};
        document.getElementById('mp-index').value         = idx;
        document.getElementById('mp-tipo').value          = p.tipo       || 'PADRE';
        document.getElementById('mp-apellidos').value     = p.apellidos  || '';
        document.getElementById('mp-nombres').value       = p.nombres    || '';
        document.getElementById('mp-edad').value          = p.edad       || '';
        document.getElementById('mp-dni').value           = p.dni        || '';
        document.getElementById('mp-celular').value       = p.celular    || '';
        document.getElementById('mp-ocupacion').value     = p.ocupacion  || '';
        document.getElementById('mp-religion').value      = p.religion   || '';
        document.getElementById('mp-tipo-parto').value    = p.tipo_parto || '';
        document.getElementById('mp-vive-con-menor').checked = !!p.vive_con_menor;
        document.getElementById('mp-tipo-parto-group').style.display =
            (document.getElementById('mp-tipo').value === 'MADRE') ? '' : 'none';
        $('#modalPadre').modal('show');
    }

    window.editarPadre   = function (idx) { abrirModal(idx); };
    window.eliminarPadre = function (idx) {
        if (!confirm('¿Eliminar este registro?')) return;
        padresArr.splice(idx, 1);
        renderPadres();
    };

    document.getElementById('btn-agregar-padre').addEventListener('click', function () { abrirModal(-1); });

    document.getElementById('mp-tipo').addEventListener('change', function () {
        document.getElementById('mp-tipo-parto-group').style.display =
            this.value === 'MADRE' ? '' : 'none';
    });

    document.getElementById('btn-guardar-padre').addEventListener('click', function () {
        var tipo  = document.getElementById('mp-tipo').value;
        var entry = {
            tipo:           tipo,
            apellidos:      document.getElementById('mp-apellidos').value.trim(),
            nombres:        document.getElementById('mp-nombres').value.trim(),
            edad:           document.getElementById('mp-edad').value.trim(),
            dni:            document.getElementById('mp-dni').value.trim(),
            celular:        document.getElementById('mp-celular').value.trim(),
            ocupacion:      document.getElementById('mp-ocupacion').value.trim(),
            religion:       document.getElementById('mp-religion').value.trim(),
            tipo_parto:     tipo === 'MADRE' ? document.getElementById('mp-tipo-parto').value : '',
            vive_con_menor: document.getElementById('mp-vive-con-menor').checked ? 1 : 0
        };
        var idx = parseInt(document.getElementById('mp-index').value);
        if (idx >= 0) { padresArr[idx] = entry; } else { padresArr.push(entry); }
        renderPadres();
        $('#modalPadre').modal('hide');
    });

    renderPadres();
})();

// =========================================================
// Hermanos modal management
// =========================================================
(function () {
    var hermanosArr = {{ all_hermanos_json|default('[]') }};

    function renderHermanos() {
        var tbody = document.getElementById('tbody-hermanos');
        if (hermanosArr.length === 0) {
            tbody.innerHTML = '<tr><td colspan="2" class="text-center text-muted py-3" style="font-size:13px;">Sin registros. Haga clic en "Agregar" para añadir.</td></tr>';
        } else {
            tbody.innerHTML = '';
            hermanosArr.forEach(function (h, idx) {
                tbody.innerHTML +=
                    '<tr>' +
                    '<td>' + (h.label || '') + '</td>' +
                    '<td class="text-right">' +
                        '<button type="button" class="btn btn-xs btn-outline-danger" onclick="eliminarHermano(' + idx + ')"><i class="fas fa-trash"></i></button>' +
                    '</td></tr>';
            });
        }
        document.getElementById('hermanos-data-input').value = JSON.stringify(hermanosArr);
    }

    window.eliminarHermano = function (idx) {
        if (!confirm('¿Eliminar este hermano?')) return;
        hermanosArr.splice(idx, 1);
        renderHermanos();
    };

    document.getElementById('btn-agregar-hermano').addEventListener('click', function () {
        document.getElementById('hermano-search').value = '';
        document.getElementById('hermano-search-results').innerHTML = '';
        document.getElementById('hermano-search-results').style.display = 'none';
        document.getElementById('hermano-selected-box').classList.add('d-none');
        document.getElementById('hermano-selected-id').value = '';
        document.getElementById('btn-confirmar-hermano').disabled = true;
        $('#modalHermano').modal('show');
    });

    function buscarHermano() {
        var term = document.getElementById('hermano-search').value.trim();
        var resultsEl = document.getElementById('hermano-search-results');
        if (term.length < 2) { resultsEl.style.display = 'none'; return; }
        $.post('{{ ajax_matricula_url }}', { action: 'buscar_usuario', term: term })
         .done(function (resp) {
            resultsEl.innerHTML = '';
            if (resp.success && resp.users.length) {
                resp.users.forEach(function (u) {
                    var a = document.createElement('a');
                    a.href = '#';
                    a.className = 'list-group-item list-group-item-action py-1';
                    a.style.fontSize = '13px';
                    a.textContent = u.label;
                    a.addEventListener('click', function (e) {
                        e.preventDefault();
                        document.getElementById('hermano-selected-id').value = u.id;
                        document.getElementById('hermano-selected-label').textContent = u.label;
                        document.getElementById('hermano-selected-box').classList.remove('d-none');
                        document.getElementById('btn-confirmar-hermano').disabled = false;
                        resultsEl.style.display = 'none';
                        document.getElementById('hermano-search').value = u.label;
                    });
                    resultsEl.appendChild(a);
                });
                resultsEl.style.display = 'block';
            } else {
                resultsEl.style.display = 'none';
            }
         });
    }

    document.getElementById('btn-buscar-hermano').addEventListener('click', buscarHermano);
    document.getElementById('hermano-search').addEventListener('keyup', function (e) {
        if (e.key === 'Enter') buscarHermano();
        else if (this.value.length >= 2) buscarHermano();
    });

    document.getElementById('btn-confirmar-hermano').addEventListener('click', function () {
        var userId = parseInt(document.getElementById('hermano-selected-id').value);
        var label  = document.getElementById('hermano-selected-label').textContent;
        if (!userId) return;
        var exists = hermanosArr.some(function (h) { return h.user_id === userId; });
        if (exists) { alert('Este usuario ya está en la lista.'); return; }
        hermanosArr.push({ user_id: userId, label: label });
        renderHermanos();
        $('#modalHermano').modal('hide');
    });

    renderHermanos();
})();

// =========================================================
// Contactos de Emergencia modal management
// =========================================================
(function () {
    var contactosArr = {{ all_contactos_json|default('[]') }};

    function renderContactos() {
        var tbody = document.getElementById('tbody-contactos');
        if (contactosArr.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3" style="font-size:13px;">Sin registros. Haga clic en "Agregar" para añadir.</td></tr>';
        } else {
            tbody.innerHTML = '';
            contactosArr.forEach(function (c, idx) {
                tbody.innerHTML +=
                    '<tr>' +
                    '<td>' + (c.nombre_contacto || '') + '</td>' +
                    '<td>' + (c.telefono || '') + '</td>' +
                    '<td>' + (c.direccion || '') + '</td>' +
                    '<td class="text-right">' +
                        '<button type="button" class="btn btn-xs btn-outline-info mr-1" onclick="editarContacto(' + idx + ')"><i class="fas fa-edit"></i></button>' +
                        '<button type="button" class="btn btn-xs btn-outline-danger" onclick="eliminarContacto(' + idx + ')"><i class="fas fa-trash"></i></button>' +
                    '</td></tr>';
            });
        }
        document.getElementById('contactos-data-input').value = JSON.stringify(contactosArr);
    }

    function abrirModalContacto(idx) {
        var c = idx >= 0 ? contactosArr[idx] : {};
        document.getElementById('mc-index').value     = idx;
        document.getElementById('mc-nombre').value    = c.nombre_contacto || '';
        document.getElementById('mc-telefono').value  = c.telefono  || '';
        document.getElementById('mc-direccion').value = c.direccion || '';
        $('#modalContacto').modal('show');
    }

    window.editarContacto   = function (idx) { abrirModalContacto(idx); };
    window.eliminarContacto = function (idx) {
        if (!confirm('¿Eliminar este contacto?')) return;
        contactosArr.splice(idx, 1);
        renderContactos();
    };

    document.getElementById('btn-agregar-contacto').addEventListener('click', function () { abrirModalContacto(-1); });

    document.getElementById('btn-guardar-contacto').addEventListener('click', function () {
        var nombre = document.getElementById('mc-nombre').value.trim();
        if (!nombre) { alert('El nombre del contacto es obligatorio.'); return; }
        var entry = {
            nombre_contacto: nombre,
            telefono:        document.getElementById('mc-telefono').value.trim(),
            direccion:       document.getElementById('mc-direccion').value.trim()
        };
        var idx = parseInt(document.getElementById('mc-index').value);
        if (idx >= 0) { contactosArr[idx] = entry; } else { contactosArr.push(entry); }
        renderContactos();
        $('#modalContacto').modal('hide');
    });

    renderContactos();
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
