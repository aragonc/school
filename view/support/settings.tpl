<div class="d-flex align-items-center mb-4">
    <h4 class="mb-0 font-weight-bold text-dark">
        <i class="fas fa-cog text-primary mr-2"></i>Configuración de tickets
    </h4>
</div>

{% if saved %}
<div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="fas fa-check-circle mr-1"></i> Configuración guardada correctamente.
    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
</div>
{% endif %}

<form method="post" action="{{ settings_url }}">
    <input type="hidden" name="save_support_settings" value="1">

    {# Mensaje de atención #}
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-header bg-white">
            <h6 class="m-0 font-weight-bold text-primary">
                <i class="fas fa-clock mr-1"></i> Horario / Mensaje de atención
            </h6>
        </div>
        <div class="card-body">
            <div class="form-group mb-0">
                <textarea id="support_attention_message" name="support_attention_message"
                          rows="4">{{ support_attention_message|raw }}</textarea>
                <small class="form-text text-muted">
                    Se muestra en el modal de soporte del login como aviso de horario. Déjalo vacío para no mostrar ningún mensaje.
                </small>
            </div>
        </div>
    </div>

    {# WhatsApp #}
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-header bg-white">
            <h6 class="m-0 font-weight-bold text-primary">
                <i class="fab fa-whatsapp text-success mr-1"></i> WhatsApp de soporte
            </h6>
        </div>
        <div class="card-body">
            <div class="form-group mb-0">
                <div style="position:relative;max-width:280px;">
                    <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);pointer-events:none;">
                        <i class="fab fa-whatsapp text-success" style="font-size:16px;"></i>
                    </span>
                    <input type="text" class="form-control" name="support_whatsapp"
                           maxlength="20" placeholder="+51987654321"
                           style="padding-left:34px;"
                           value="{{ support_whatsapp }}">
                </div>
                <small class="form-text text-muted">
                    Incluye el código de país. Si se configura, aparece un botón de WhatsApp directo en el modal del login.
                </small>
            </div>
        </div>
    </div>

    {# Categorías #}
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-header bg-white">
            <h6 class="m-0 font-weight-bold text-primary">
                <i class="fas fa-tags mr-1"></i> Categorías de soporte
            </h6>
        </div>
        <div class="card-body">
            <p class="text-muted small mb-3">
                Activa o desactiva las categorías visibles en el formulario de soporte. Puedes agregar las que necesites.
            </p>

            <input type="hidden" name="support_categories_json" id="supportCategoriesJson" value="">

            <div id="catList" class="mb-3" style="max-width:480px;"></div>

            <div class="d-flex" style="gap:8px;max-width:480px;">
                <input type="text" id="newCatName" class="form-control form-control-sm"
                       placeholder="Nueva categoría..." maxlength="80">
                <button type="button" class="btn btn-sm btn-outline-primary flex-shrink-0"
                        onclick="scAddCategory()">
                    <i class="fas fa-plus mr-1"></i>Agregar
                </button>
            </div>
        </div>
    </div>

    <button type="submit" class="btn btn-primary">
        <i class="fas fa-save mr-1"></i> Guardar configuración
    </button>
</form>

<script src="{{ _p.web }}web/assets/ckeditor/ckeditor.js"></script>
<script>
var scCategories = {{ support_categories_json|raw }};
document.getElementById('supportCategoriesJson').value = JSON.stringify(scCategories);

function scRender() {
    var list = document.getElementById('catList');
    list.innerHTML = '';
    if (!scCategories.length) {
        list.innerHTML = '<p class="text-muted small">Sin categorías configuradas.</p>';
        return;
    }
    scCategories.forEach(function (cat, idx) {
        var row = document.createElement('div');
        row.className = 'd-flex align-items-center py-2 border-bottom';
        row.style.gap = '10px';
        row.innerHTML =
            '<div class="custom-control custom-switch">' +
                '<input type="checkbox" class="custom-control-input" id="cat_sw_' + idx + '"' +
                (cat.active ? ' checked' : '') + '>' +
                '<label class="custom-control-label" for="cat_sw_' + idx + '"></label>' +
            '</div>' +
            '<span class="flex-grow-1" style="font-size:14px;">' + scEsc(cat.name) + '</span>' +
            '<span class="badge ' + (cat.active ? 'badge-success' : 'badge-secondary') + ' mr-2" id="cat_badge_' + idx + '">' +
                (cat.active ? 'Activa' : 'Inactiva') +
            '</span>' +
            '<button type="button" class="btn btn-sm btn-outline-danger py-0 px-2" title="Eliminar" onclick="scRemove(' + idx + ')">' +
                '<i class="fas fa-trash" style="font-size:11px;"></i>' +
            '</button>';

        row.querySelector('input[type=checkbox]').addEventListener('change', function () {
            scCategories[idx].active = this.checked;
            scSync();
            scRender();
        });
        list.appendChild(row);
    });
}

function scAddCategory() {
    var input = document.getElementById('newCatName');
    var name  = input.value.trim();
    if (!name) { input.focus(); return; }
    if (scCategories.some(function(c) { return c.name.toLowerCase() === name.toLowerCase(); })) {
        alert('Esa categoría ya existe.');
        return;
    }
    scCategories.push({ name: name, active: true });
    input.value = '';
    scSync();
    scRender();
}

function scRemove(idx) {
    if (!confirm('¿Eliminar la categoría "' + scCategories[idx].name + '"?')) return;
    scCategories.splice(idx, 1);
    scSync();
    scRender();
}

function scSync() {
    document.getElementById('supportCategoriesJson').value = JSON.stringify(scCategories);
}

function scEsc(s) {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

document.getElementById('newCatName').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') { e.preventDefault(); scAddCategory(); }
});

scRender();

// CKEditor para el mensaje de atención
CKEDITOR.replace('support_attention_message', {
    language: 'es',
    toolbar: [
        { name: 'basicstyles', items: ['Bold','Italic','Underline','Strike','RemoveFormat'] },
        { name: 'paragraph',   items: ['NumberedList','BulletedList','Blockquote'] },
        { name: 'links',       items: ['Link','Unlink'] },
        { name: 'styles',      items: ['Format'] },
        { name: 'colors',      items: ['TextColor','BGColor'] },
    ],
    height: 140,
    resize_enabled: false,
    removePlugins: 'elementspath',
});

// Volcar contenido del editor al textarea antes de enviar
document.querySelector('form').addEventListener('submit', function () {
    if (CKEDITOR.instances.support_attention_message) {
        document.getElementById('support_attention_message').value =
            CKEDITOR.instances.support_attention_message.getData();
    }
});
</script>
