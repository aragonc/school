<div class="card">
    <div class="card-header">
        <i class="fas fa-cog"></i> {{ 'PluginAdministration'|get_plugin_lang('SchoolPlugin') }}
    </div>
    <div class="card-body">
        {% if current_logo %}
        <div class="mb-4">
            <label class="font-weight-bold">{{ 'CurrentLogo'|get_plugin_lang('SchoolPlugin') }}</label>
            <div class="p-3 border rounded" style="background: #f8f9fc;">
                <img src="{{ current_logo }}" alt="Logo" style="max-height: 80px;">
            </div>
        </div>
        {% endif %}
        {{ form }}
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
