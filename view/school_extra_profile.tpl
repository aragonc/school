<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link" href="/profile">
            {{ 'PersonalData'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link active" href="/extra-profile">
            {{ 'ExtraProfileData'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link" href="/password">
            {{ 'ChangePassword'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link" href="/avatar">
            {{ 'EditAvatar'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>

<div class="card">
    <div class="card-body">
        <div class="p-0 p-md-5">
            <div class="row">
                <div class="col-12 col-lg-8">
                    <h5 class="mb-4">
                        <i class="fas fa-id-card"></i> {{ 'ExtraProfileData'|get_plugin_lang('SchoolPlugin') }}
                    </h5>
                    {{ form }}
                </div>
                <div class="col-12 col-lg-4">
                    <div class="d-none d-md-block">
                        <div class="bd-callout bd-callout-info">
                            <p><i class="fas fa-info-circle"></i> {{ 'ExtraProfileHelp'|get_plugin_lang('SchoolPlugin') }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
$(function() {
    var provinciasData = null;
    var distritosData = null;
    var selectOptionText = "{{ select_option_text }}";
    var ubigeoPath = "{{ ubigeo_path }}";

    $("#region").on("change", function() {
        var regionId = $(this).val();
        var $province = $("#province");
        var $district = $("#district");

        $province.html('<option value="">' + selectOptionText + '</option>').attr("disabled", "disabled");
        $district.html('<option value="">' + selectOptionText + '</option>').attr("disabled", "disabled");

        if (!regionId) {
            return;
        }

        if (provinciasData) {
            fillProvincias(regionId);
        } else {
            $.getJSON(ubigeoPath + "ubigeo_peru_2016_provincias.json", function(data) {
                provinciasData = data;
                fillProvincias(regionId);
            });
        }
    });

    $("#province").on("change", function() {
        var provinceId = $(this).val();
        var $district = $("#district");

        $district.html('<option value="">' + selectOptionText + '</option>').attr("disabled", "disabled");

        if (!provinceId) {
            return;
        }

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
        var $province = $("#province");
        $province.html('<option value="">' + selectOptionText + '</option>');

        $.each(provinciasData, function(i, item) {
            if (item.department_id === regionId) {
                $province.append('<option value="' + item.id + '">' + item.name + '</option>');
            }
        });

        $province.removeAttr("disabled");
    }

    function fillDistritos(provinceId) {
        var $district = $("#district");
        $district.html('<option value="">' + selectOptionText + '</option>');

        $.each(distritosData, function(i, item) {
            if (item.province_id === provinceId) {
                $district.append('<option value="' + item.id + '">' + item.name + '</option>');
            }
        });

        $district.removeAttr("disabled");
    }

    $("form[name='extra_profile_form']").on("submit", function() {
        $("#province, #district").removeAttr("disabled");
    });

    // Load saved values on page init
    var savedRegion = "{{ saved_region }}";
    var savedProvince = "{{ saved_province }}";
    var savedDistrict = "{{ saved_district }}";

    if (savedRegion) {
        $("#region").val(savedRegion);
        $.getJSON(ubigeoPath + "ubigeo_peru_2016_provincias.json", function(data) {
            provinciasData = data;
            fillProvincias(savedRegion);

            if (savedProvince) {
                $("#province").val(savedProvince);
                $.getJSON(ubigeoPath + "ubigeo_peru_2016_distritos.json", function(data) {
                    distritosData = data;
                    fillDistritos(savedProvince);

                    if (savedDistrict) {
                        $("#district").val(savedDistrict);
                    }
                });
            }
        });
    }
});
</script>
