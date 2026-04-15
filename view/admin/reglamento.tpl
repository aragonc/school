<div class="d-flex align-items-center mb-4">
    <h4 class="mb-0 font-weight-bold text-dark">
        <i class="fas fa-file-contract text-primary mr-2"></i>{{ 'ReglamentoInterno'|get_plugin_lang('SchoolPlugin') }}
    </h4>
    <span class="ml-3 text-muted small">{{ 'ReglamentoInternoDesc'|get_plugin_lang('SchoolPlugin') }}</span>
</div>

{% if saved %}
<div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="fas fa-check-circle mr-1"></i> {{ 'DocSaved'|get_plugin_lang('SchoolPlugin') }}
    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
</div>
{% endif %}

<form method="post" action="{{ form_action }}" enctype="multipart/form-data">
    <input type="hidden" name="save_reglamento" value="1">

    {% for doc in docs %}
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-header bg-white d-flex align-items-center">
            <h6 class="m-0 font-weight-bold text-primary">
                <i class="fas fa-file-pdf text-danger mr-2"></i>{{ doc.label }}
            </h6>
            {% if doc.exists %}
            <span class="badge badge-success ml-auto">
                <i class="fas fa-check mr-1"></i> Documento cargado
            </span>
            {% else %}
            <span class="badge badge-secondary ml-auto">
                <i class="fas fa-times mr-1"></i> {{ 'DocNoFile'|get_plugin_lang('SchoolPlugin') }}
            </span>
            {% endif %}
        </div>
        <div class="card-body">
            <div class="row">

                {# Fecha de publicación #}
                <div class="col-12 col-md-4 mb-3">
                    <label class="font-weight-bold small text-uppercase text-muted mb-1">
                        <i class="fas fa-calendar-alt mr-1"></i>{{ 'DocPublicationDate'|get_plugin_lang('SchoolPlugin') }}
                    </label>
                    <input type="date"
                           class="form-control"
                           name="date_{{ doc.key }}"
                           value="{{ doc.date }}">
                    {% if doc.date %}
                    <small class="text-muted">
                        Publicado: <strong id="label_date_{{ doc.key }}">{{ doc.date }}</strong>
                    </small>
                    {% endif %}
                </div>

                {# Subir PDF #}
                <div class="col-12 col-md-8 mb-3">
                    <label class="font-weight-bold small text-uppercase text-muted mb-1">
                        <i class="fas fa-upload mr-1"></i>{{ 'DocUploadPdf'|get_plugin_lang('SchoolPlugin') }}
                    </label>
                    <div class="custom-file">
                        <input type="file"
                               class="custom-file-input"
                               id="file_{{ doc.key }}"
                               name="file_{{ doc.key }}"
                               accept=".pdf">
                        <label class="custom-file-label" for="file_{{ doc.key }}">
                            {% if doc.exists %}
                                {{ doc.filename }}
                            {% else %}
                                Seleccionar PDF...
                            {% endif %}
                        </label>
                    </div>
                    <small class="form-text text-muted">Solo archivos PDF. Reemplazará el documento actual si existe.</small>
                </div>
            </div>

            {# Archivo actual #}
            {% if doc.exists %}
            <div class="d-flex align-items-center p-3 border rounded bg-light mt-1">
                <i class="fas fa-file-pdf text-danger mr-3" style="font-size:2rem;"></i>
                <div class="flex-grow-1">
                    <div class="font-weight-bold" style="font-size:13px;">{{ doc.filename }}</div>
                    {% if doc.date %}
                    <small class="text-muted">
                        <i class="fas fa-calendar-alt mr-1"></i>Publicado el {{ doc.date }}
                    </small>
                    {% endif %}
                </div>
                <a href="{{ doc.url }}" target="_blank" class="btn btn-sm btn-outline-primary mr-2">
                    <i class="fas fa-eye mr-1"></i>{{ 'DocView'|get_plugin_lang('SchoolPlugin') }}
                </a>
                <a href="{{ doc.url }}" download class="btn btn-sm btn-outline-secondary mr-2">
                    <i class="fas fa-download mr-1"></i>{{ 'DocDownload'|get_plugin_lang('SchoolPlugin') }}
                </a>
            </div>

            <div class="mt-2">
                <div class="custom-control custom-checkbox">
                    <input type="checkbox"
                           class="custom-control-input"
                           id="remove_{{ doc.key }}"
                           name="remove_{{ doc.key }}"
                           value="1">
                    <label class="custom-control-label text-danger small" for="remove_{{ doc.key }}">
                        <i class="fas fa-trash mr-1"></i>{{ 'DocRemove'|get_plugin_lang('SchoolPlugin') }}
                    </label>
                </div>
            </div>
            {% endif %}
        </div>
    </div>
    {% endfor %}

    <button type="submit" class="btn btn-primary">
        <i class="fas fa-save mr-1"></i> {{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}
    </button>
</form>

<script>
// Update custom file input label on change
document.querySelectorAll('.custom-file-input').forEach(function(input) {
    input.addEventListener('change', function() {
        var label = this.nextElementSibling;
        if (this.files && this.files.length > 0) {
            label.textContent = this.files[0].name;
        }
    });
});

// Format date labels nicely
document.querySelectorAll('input[type="date"]').forEach(function(input) {
    input.addEventListener('change', function() {
        var key = this.name.replace('date_', '');
        var labelEl = document.getElementById('label_date_' + key);
        if (labelEl && this.value) {
            var parts = this.value.split('-');
            if (parts.length === 3) {
                var months = ['enero','febrero','marzo','abril','mayo','junio',
                              'julio','agosto','septiembre','octubre','noviembre','diciembre'];
                labelEl.textContent = parseInt(parts[2]) + ' de ' + months[parseInt(parts[1])-1] + ' de ' + parts[0];
            }
        }
    });
});
</script>
