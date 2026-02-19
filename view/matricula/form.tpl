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

<form method="POST" action="">
    <input type="hidden" name="matricula_id" value="{{ matricula_id }}">

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
                <div class="form-group col-md-4">
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
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'Dni'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="dni" class="form-control" value="{{ matricula.dni ?? '' }}" maxlength="8" placeholder="00000000">
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
            </div>

            <div class="form-row">
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'FechaNacimiento'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="date" name="fecha_nacimiento" class="form-control" value="{{ matricula.fecha_nacimiento ?? '' }}">
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">{{ 'Nacionalidad'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" name="nacionalidad" class="form-control" value="{{ matricula.nacionalidad ?? 'Peruana' }}">
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
</script>
