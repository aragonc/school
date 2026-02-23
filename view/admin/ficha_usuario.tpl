<div class="d-flex justify-content-between align-items-center mb-3">
    <a href="{{ _p.web }}admin/usuarios" class="btn btn-secondary btn-sm">
        <i class="fas fa-arrow-left"></i> Volver a Usuarios
    </a>
</div>

{# === Usuario vinculado === #}
<div class="card mb-3 border-info">
    <div class="card-header bg-info text-white py-2">
        <i class="fas fa-user mr-1"></i> Usuario
    </div>
    <div class="card-body py-3 d-flex align-items-center">
        {% if target_user.avatar_small %}
        <img src="{{ target_user.avatar_small }}" alt="" style="width:48px;height:48px;object-fit:cover;border-radius:50%;border:2px solid #bee3f8;margin-right:14px;">
        {% else %}
        <span class="d-inline-flex align-items-center justify-content-center bg-secondary text-white rounded-circle mr-3" style="width:48px;height:48px;font-size:20px;">
            <i class="fas fa-user"></i>
        </span>
        {% endif %}
        <div>
            <div class="font-weight-bold" style="font-size:16px;">{{ target_user.complete_name }}</div>
            <div class="text-muted" style="font-size:13px;">{{ target_user.username }} &nbsp;·&nbsp; {{ target_user.email }}</div>
        </div>
    </div>
</div>

<form method="POST" action="">
    <input type="hidden" name="user_id" value="{{ target_user.user_id }}">

    {# === DATOS PERSONALES === #}
    <div class="card mb-4">
        <div class="card-header">
            <i class="fas fa-id-card mr-1"></i> Datos Personales
        </div>
        <div class="card-body">

            <div class="form-row">
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">Tipo de documento</label>
                    <select name="document_type" class="form-control">
                        {% for dt in ['DNI','CE','PASAPORTE','OTRO'] %}
                        <option value="{{ dt }}" {% if ficha.document_type == dt %}selected{% endif %}>{{ dt }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">Número de documento</label>
                    <input type="text" name="document_number" class="form-control"
                           value="{{ ficha.document_number }}" maxlength="20" placeholder="Nro. documento">
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">Sexo</label>
                    <select name="sexo" class="form-control">
                        <option value="">{{ select_option_text }}</option>
                        <option value="M" {% if ficha.sexo == 'M' %}selected{% endif %}>Masculino</option>
                        <option value="F" {% if ficha.sexo == 'F' %}selected{% endif %}>Femenino</option>
                    </select>
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">Fecha de nacimiento</label>
                    <input type="date" name="birthdate" class="form-control"
                           value="{{ ficha.birthdate }}">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">Nacionalidad</label>
                    <select name="nacionalidad" class="form-control">
                        <option value="Peruana"    {% if ficha.nacionalidad != 'Extranjera' %}selected{% endif %}>Peruana</option>
                        <option value="Extranjera" {% if ficha.nacionalidad == 'Extranjera' %}selected{% endif %}>Extranjera</option>
                    </select>
                </div>
                <div class="form-group col-md-2">
                    <label class="font-weight-bold">Tipo de sangre</label>
                    <select name="tipo_sangre" class="form-control">
                        <option value="">{{ select_option_text }}</option>
                        {% for ts in tipos_sangre %}
                        <option value="{{ ts }}" {% if ficha.tipo_sangre == ts %}selected{% endif %}>{{ ts }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">Peso (kg)</label>
                    <input type="number" step="0.01" min="0" max="300" name="peso" class="form-control"
                           value="{{ ficha.peso }}" placeholder="Ej: 65.50">
                </div>
                <div class="form-group col-md-3">
                    <label class="font-weight-bold">Estatura (m)</label>
                    <input type="number" step="0.01" min="0" max="3" name="estatura" class="form-control"
                           value="{{ ficha.estatura }}" placeholder="Ej: 1.70">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">Teléfono / Celular</label>
                    <input type="text" name="phone" class="form-control"
                           value="{{ ficha.phone }}" maxlength="20" placeholder="Nro. teléfono">
                </div>
            </div>

        </div>
    </div>

    {# === DOMICILIO === #}
    <div class="card mb-4">
        <div class="card-header">
            <i class="fas fa-map-marker-alt mr-1"></i> Domicilio
        </div>
        <div class="card-body">

            <div class="form-row">
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">Región</label>
                    <select name="region" id="sel-region" class="form-control">
                        <option value="">{{ select_option_text }}</option>
                        {% for r in regions %}
                        <option value="{{ r.id }}" {% if saved_region == r.id %}selected{% endif %}>{{ r.name }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">Provincia</label>
                    <select name="province" id="sel-province" class="form-control">
                        <option value="">{{ select_option_text }}</option>
                    </select>
                </div>
                <div class="form-group col-md-4">
                    <label class="font-weight-bold">Distrito</label>
                    <select name="district" id="sel-district" class="form-control">
                        <option value="">{{ select_option_text }}</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label class="font-weight-bold">Dirección de domicilio</label>
                <input type="text" name="address" class="form-control"
                       value="{{ ficha.address }}" maxlength="255" placeholder="Calle, número, urbanización...">
            </div>

            <div class="form-group">
                <label>Referencia</label>
                <input type="text" name="address_reference" class="form-control"
                       value="{{ ficha.address_reference }}" maxlength="255" placeholder="Referencia del domicilio">
            </div>

        </div>
    </div>

    <div class="text-right mb-4">
        <a href="{{ _p.web }}admin/usuarios" class="btn btn-secondary mr-2">Cancelar</a>
        <button type="submit" class="btn btn-primary">
            <i class="fas fa-save mr-1"></i> Guardar Ficha
        </button>
    </div>

</form>

<script>
(function () {
    var ubigeoPath    = '{{ ubigeo_path }}';
    var selectText    = '{{ select_option_text }}';
    var savedProvince = '{{ saved_province }}';
    var savedDistrict = '{{ saved_district }}';
    var provinciasData = null;
    var distritosData  = null;

    function fillProvincias(regionId) {
        var $p = $('#sel-province');
        $p.html('<option value="">' + selectText + '</option>');
        $.each(provinciasData, function (i, item) {
            if (item.department_id === regionId) {
                $p.append('<option value="' + item.id + '">' + item.name + '</option>');
            }
        });
    }

    function fillDistritos(provinceId) {
        var $d = $('#sel-district');
        $d.html('<option value="">' + selectText + '</option>');
        $.each(distritosData, function (i, item) {
            if (item.province_id === provinceId) {
                $d.append('<option value="' + item.id + '">' + item.name + '</option>');
            }
        });
    }

    $('#sel-region').on('change', function () {
        var regionId = $(this).val();
        $('#sel-province').html('<option value="">' + selectText + '</option>');
        $('#sel-district').html('<option value="">' + selectText + '</option>');
        if (!regionId) return;
        if (provinciasData) {
            fillProvincias(regionId);
        } else {
            $.getJSON(ubigeoPath + 'ubigeo_peru_2016_provincias.json', function (data) {
                provinciasData = data;
                fillProvincias(regionId);
            });
        }
    });

    $('#sel-province').on('change', function () {
        var provinceId = $(this).val();
        $('#sel-district').html('<option value="">' + selectText + '</option>');
        if (!provinceId) return;
        if (distritosData) {
            fillDistritos(provinceId);
        } else {
            $.getJSON(ubigeoPath + 'ubigeo_peru_2016_distritos.json', function (data) {
                distritosData = data;
                fillDistritos(provinceId);
            });
        }
    });

    // Preload saved values on page load
    var savedRegion = $('#sel-region').val();
    if (savedRegion && savedProvince) {
        $.getJSON(ubigeoPath + 'ubigeo_peru_2016_provincias.json', function (data) {
            provinciasData = data;
            fillProvincias(savedRegion);
            $('#sel-province').val(savedProvince);
            if (savedDistrict) {
                $.getJSON(ubigeoPath + 'ubigeo_peru_2016_distritos.json', function (data2) {
                    distritosData = data2;
                    fillDistritos(savedProvince);
                    $('#sel-district').val(savedDistrict);
                });
            }
        });
    }
})();
</script>
