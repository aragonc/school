<div class="card">
    <div class="card-header">
        <i class="fas fa-cog"></i> {{ 'PluginAdministration'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body">
        <div class="p-0 p-md-5">
            <div class="row">
                <div class="col-12 col-lg-6">
                    {{ form }}
                </div>
                <div class="col-12 col-lg-6">
                    {% if current_logo %}
                    <div class="mb-4">
                        <label class="font-weight-bold">{{ 'CurrentLogo'|get_plugin_lang('SchoolPlugin') }}</label>
                        <div class="p-3 border rounded" style="background: #f8f9fc;">
                            <img src="{{ current_logo }}" alt="Logo" style="max-height: 80px;">
                        </div>
                    </div>
                    {% endif %}
                    {% if sidebar_icon_url %}
                    <div class="mb-4">
                        <label class="font-weight-bold">{{ 'LoginIcon'|get_plugin_lang('SchoolPlugin') }}</label>
                        <div class="p-3 border rounded" style="background: #f8f9fc;">
                            <img src="{{ sidebar_icon_url }}" alt="Logo" style="max-height: 80px;">
                        </div>
                    </div>
                    {% endif %}

                    {% if current_login_bg_image %}
                    <div class="mb-4">
                        <label class="font-weight-bold">{{ 'CurrentLoginBgImage'|get_plugin_lang('SchoolPlugin') }}</label>
                        <div class="p-3 border rounded" style="background: #f8f9fc;">
                            <img src="{{ current_login_bg_image }}" alt="Login Background" style="max-height: 120px; border-radius: 4px;">
                        </div>
                    </div>
                    {% endif %}

                    {% if vegas_preview|length > 0 %}
                    <div class="mb-4">
                        <label class="font-weight-bold">Slideshow de fondo (Vegas.js)</label>
                        <div class="row">
                            {% for i, url in vegas_preview %}
                            <div class="col-6 mb-2">
                                <div class="p-1 border rounded" style="background:#f8f9fc;">
                                    <img src="{{ url }}" alt="Vegas {{ i }}"
                                         style="width:100%;height:90px;object-fit:cover;border-radius:4px;">
                                    <div class="text-center text-muted" style="font-size:11px;">Imagen {{ i }}</div>
                                </div>
                            </div>
                            {% endfor %}
                        </div>
                    </div>
                    {% endif %}

                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var colorInputs = document.querySelectorAll('.color-input');
    colorInputs.forEach(function(input) {
        var picker = document.createElement('input');
        picker.type = 'color';
        picker.value = input.value || '#ffffff';
        picker.style.cssText = 'width:40px;height:38px;padding:2px;border:1px solid #d1d3e2;border-radius:0 .35rem .35rem 0;cursor:pointer;vertical-align:top;';

        picker.addEventListener('input', function() {
            input.value = picker.value;
        });
        input.addEventListener('input', function() {
            if (/^#[0-9A-Fa-f]{6}$/.test(input.value)) {
                picker.value = input.value;
            }
        });

        var wrapper = document.createElement('div');
        wrapper.style.cssText = 'display:flex;align-items:stretch;';
        input.parentNode.insertBefore(wrapper, input);
        wrapper.appendChild(input);
        wrapper.appendChild(picker);
        input.style.borderRadius = '.35rem 0 0 .35rem';
    });
});
</script>
