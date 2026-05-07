<div class="container-fluid px-4 py-4">

    {# ---- Header ---- #}
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap" style="gap:10px;">
        <div>
            <h4 class="mb-1 font-weight-bold text-dark">
                <i class="fas fa-share-alt text-primary mr-2"></i>Distribuir recursos
            </h4>
            {% if classroom %}
            <p class="mb-0 text-muted small">
                {{ classroom.level_name }} &mdash; {{ classroom.grade_name }}
                {% if classroom.section_name %} &mdash; Sección {{ classroom.section_name }}{% endif %}
                {% if classroom.tutor_name %}
                <span class="ml-2 badge badge-light text-muted">
                    <i class="fas fa-chalkboard-teacher mr-1"></i>{{ classroom.tutor_name }}
                </span>
                {% endif %}
            </p>
            {% endif %}
        </div>
        <div class="d-flex" style="gap:8px;">
            {% if can_upload %}
            <button type="button" class="btn btn-sm btn-primary" id="btnUploadResource">
                <i class="fas fa-cloud-upload-alt mr-1"></i>Subir archivo
            </button>
            {% endif %}
            <a href="/my-aula" class="btn btn-sm btn-outline-secondary">
                <i class="fas fa-arrow-left mr-1"></i>Mi Aula
            </a>
        </div>
    </div>

    {# ---- Classroom selector ---- #}
    {% if classrooms_list and classrooms_list|length > 0 %}
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body py-3">
            <form method="get" action="" class="d-flex align-items-center flex-wrap" style="gap:16px;">
                <div>
                    <label class="mb-1 small font-weight-bold text-muted">Aula</label>
                    <select name="classroom_id" class="form-control form-control-sm" onchange="this.form.submit()" style="min-width:240px;">
                        {% for cls in classrooms_list %}
                        <option value="{{ cls.id }}" {% if cls.id == classroom_id %}selected{% endif %}>
                            {{ cls.level_name }} — {{ cls.grade_name }}{% if cls.section_name %} Sec. {{ cls.section_name }}{% endif %}
                        </option>
                        {% endfor %}
                    </select>
                </div>
                {% if is_admin %}
                <div class="mt-3">
                    <span class="badge badge-primary px-3 py-2" style="font-size:0.8rem;">
                        <i class="fas fa-shield-alt mr-1"></i>Administrador
                    </span>
                </div>
                {% elseif is_tutor %}
                <div class="mt-3">
                    <span class="badge badge-success px-3 py-2" style="font-size:0.8rem;">
                        <i class="fas fa-star mr-1"></i>Tutor(a) de esta aula
                    </span>
                </div>
                {% endif %}
            </form>
        </div>
    </div>
    {% endif %}

    {% if not classroom %}
    <div class="alert alert-info">
        <i class="fas fa-info-circle mr-2"></i>
        No tienes un aula asignada en el año académico activo.
    </div>
    {% else %}

    {% if can_upload %}
    {# ---- Upload drop zone (tutor / admin only) ---- #}
    <div id="dropZone" class="border-dashed rounded mb-4 text-center py-4 px-3"
         style="border:2px dashed #adb5bd; background:#f8f9fc; cursor:pointer; transition:border-color .2s;"
         onclick="document.getElementById('fileInputHidden').click()">
        <i class="fas fa-cloud-upload-alt fa-2x text-muted mb-2"></i>
        <p class="mb-1 text-muted">Arrastra archivos aquí o <strong>haz clic para seleccionar</strong></p>
        <p class="small text-muted mb-0">Imágenes, PDF, Word, PPT, Excel, MP3, MP4 — máx. 100 MB por archivo</p>
        <input type="file" id="fileInputHidden" multiple style="display:none;"
               accept="image/*,.pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.mp3,.mp4,.ogg,.wav,.webm">
    </div>
    {# ---- Upload progress bar ---- #}
    <div id="uploadProgress" class="mb-3" style="display:none;">
        <div class="progress" style="height:8px;">
            <div id="uploadProgressBar" class="progress-bar progress-bar-striped progress-bar-animated"
                 role="progressbar" style="width:0%"></div>
        </div>
        <small class="text-muted mt-1 d-block" id="uploadProgressLabel">Subiendo...</small>
    </div>
    {% endif %}

    {# ---- Resources list ---- #}
    <div class="card shadow-sm border-0">
        <div class="card-header bg-white d-flex align-items-center justify-content-between py-3">
            <span class="font-weight-bold text-dark">
                <i class="fas fa-folder-open text-warning mr-2"></i>Archivos subidos
            </span>
            <span class="badge badge-secondary" id="resourceCount">{{ resources|length }}</span>
        </div>
        <div class="card-body p-0">
            <div id="resourceList">
                {% if resources %}
                <div class="table-responsive">
                    <table class="table table-hover mb-0" id="resourcesTable">
                        <thead class="thead-light">
                            <tr>
                                <th style="width:40px;"></th>
                                <th>Nombre</th>
                                <th class="text-center" style="width:80px;">Tipo</th>
                                <th class="text-center" style="width:80px;">Tamaño</th>
                                <th class="text-center" style="width:80px;">Distribuido</th>
                                <th class="text-right" style="width:180px;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for r in resources %}
                            <tr id="res-row-{{ r.id }}" data-id="{{ r.id }}" data-filename="{{ r.filename }}"
                                data-type="{{ r.file_type }}" data-title="{{ r.title }}">
                                <td class="text-center align-middle">
                                    <span class="file-type-icon" data-type="{{ r.file_type }}">
                                        {%- if r.file_type == 'image' -%}<i class="fas fa-image text-success fa-lg"></i>
                                        {%- elseif r.file_type == 'pdf' -%}<i class="fas fa-file-pdf text-danger fa-lg"></i>
                                        {%- elseif r.file_type == 'word' -%}<i class="fas fa-file-word text-primary fa-lg"></i>
                                        {%- elseif r.file_type == 'ppt' -%}<i class="fas fa-file-powerpoint" style="color:#d04423; font-size:1.2rem;"></i>
                                        {%- elseif r.file_type == 'excel' -%}<i class="fas fa-file-excel text-success fa-lg"></i>
                                        {%- elseif r.file_type == 'audio' -%}<i class="fas fa-file-audio text-warning fa-lg"></i>
                                        {%- elseif r.file_type == 'video' -%}<i class="fas fa-file-video text-info fa-lg"></i>
                                        {%- else -%}<i class="fas fa-file text-secondary fa-lg"></i>
                                        {%- endif -%}
                                    </span>
                                </td>
                                <td class="align-middle">
                                    <div class="res-title-wrap" id="title-wrap-{{ r.id }}">
                                        <span class="res-title font-weight-semibold" id="title-text-{{ r.id }}">{{ r.title }}</span>
                                        <input type="text" class="form-control form-control-sm res-title-input d-none"
                                               id="title-input-{{ r.id }}" value="{{ r.title }}"
                                               maxlength="255" style="display:none!important; max-width:280px;">
                                        <span class="res-rename-actions d-none" id="title-actions-{{ r.id }}" style="white-space:nowrap;">
                                            <button class="btn btn-xs btn-primary ml-1 btn-rename-save" data-id="{{ r.id }}" title="Guardar"><i class="fas fa-check"></i></button>
                                            <button class="btn btn-xs btn-outline-secondary ml-1 btn-rename-cancel" data-id="{{ r.id }}" title="Cancelar"><i class="fas fa-times"></i></button>
                                        </span>
                                    </div>
                                    <small class="text-muted">{{ r.filename }}</small>
                                    {% if r.uploader_name %}
                                    <br><small class="text-muted"><i class="fas fa-user mr-1"></i>{{ r.uploader_name }} &mdash; {{ r.created_at|date("d/m/Y H:i") }}</small>
                                    {% endif %}
                                </td>
                                <td class="text-center align-middle">
                                    <span class="badge badge-light text-uppercase small">{{ r.file_type }}</span>
                                </td>
                                <td class="text-center align-middle text-muted small">{{ r.file_size_fmt }}</td>
                                <td class="text-center align-middle">
                                    <span class="badge badge-{{ r.dist_count > 0 ? 'success' : 'light' }} dist-count-badge" id="dist-count-{{ r.id }}">
                                        {{ r.dist_count }}
                                    </span>
                                </td>
                                <td class="text-right align-middle" style="white-space:nowrap;">
                                    <a href="{{ r.web_url }}" target="_blank" class="btn btn-xs btn-outline-secondary mr-1"
                                       title="Vista previa / descargar">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    {% if is_admin or is_tutor or r.uploaded_by == current_user_id %}
                                    <button class="btn btn-xs btn-outline-warning mr-1 btn-rename-start"
                                            data-id="{{ r.id }}"
                                            title="Renombrar">
                                        <i class="fas fa-pencil-alt"></i>
                                    </button>
                                    {% endif %}
                                    <button class="btn btn-xs btn-outline-info mr-1 btn-view-dists"
                                            data-id="{{ r.id }}" data-title="{{ r.title }}"
                                            title="Ver distribuciones">
                                        <i class="fas fa-list-ul"></i>
                                    </button>
                                    <button class="btn btn-xs btn-success mr-1 btn-distribute"
                                            data-id="{{ r.id }}" data-title="{{ r.title }}"
                                            title="Distribuir a curso">
                                        <i class="fas fa-share-alt"></i>
                                    </button>
                                    {% if is_admin or is_tutor or r.uploaded_by == current_user_id %}
                                    <button class="btn btn-xs btn-outline-danger btn-delete-resource"
                                            data-id="{{ r.id }}" data-title="{{ r.title }}"
                                            title="Eliminar">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                    {% endif %}
                                </td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                </div>
                {% else %}
                <div class="text-center py-5 text-muted" id="emptyState">
                    <i class="fas fa-inbox fa-3x mb-3 d-block"></i>
                    No hay archivos subidos aún. Usa el botón o arrastra archivos arriba.
                </div>
                {% endif %}
            </div>
        </div>
    </div>

    {% endif %}{# end if classroom #}
</div>

{# ============================== MODALES ============================== #}

{# ---- Modal: Distribuir recurso ---- #}
<div class="modal fade" id="modalDistribute" tabindex="-1" role="dialog" aria-labelledby="modalDistributeLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title" id="modalDistributeLabel">
                    <i class="fas fa-share-alt mr-2"></i>Distribuir recurso
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p class="mb-3 text-muted small">
                    El archivo <strong id="distResourceTitle"></strong> se copiará a la herramienta
                    <em>Documentos</em> del curso seleccionado.
                </p>
                <input type="hidden" id="distResourceId">

                <div class="form-group">
                    <label class="font-weight-bold">Curso <span class="text-danger">*</span></label>
                    <select class="form-control" id="distCourseSelect">
                        <option value="">— Selecciona un curso —</option>
                        {% for c in classroom_courses %}
                        <option value="{{ c.code }}" data-title="{{ c.title }}">{{ c.title }}</option>
                        {% endfor %}
                    </select>
                </div>

                <div class="form-group">
                    <label class="font-weight-bold">Sesión</label>
                    <select class="form-control" id="distSessionSelect">
                        <option value="0">Sin sesión (base del curso)</option>
                        {% if session_id > 0 %}
                        <option value="{{ session_id }}" selected>Sesión del aula (id: {{ session_id }})</option>
                        {% endif %}
                    </select>
                    <small class="text-muted">Normalmente se usa la sesión del aula o sin sesión.</small>
                </div>

                <div class="form-group">
                    <label class="font-weight-bold">Carpeta destino</label>
                    <div class="input-group">
                        <select class="form-control" id="distFolderSelect">
                            <option value="/">/ (raíz)</option>
                        </select>
                        <div class="input-group-append">
                            <button type="button" class="btn btn-outline-secondary" id="btnRefreshFolders"
                                    title="Recargar carpetas">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                            <button type="button" class="btn btn-outline-primary" id="btnNewFolderFromDist"
                                    title="Crear nueva carpeta">
                                <i class="fas fa-folder-plus"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <div id="distAlert" class="alert alert-danger small mt-2" style="display:none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-success" id="btnConfirmDistribute">
                    <i class="fas fa-share-alt mr-1"></i>Distribuir
                </button>
            </div>
        </div>
    </div>
</div>

{# ---- Modal: Crear carpeta ---- #}
<div class="modal fade" id="modalNewFolder" tabindex="-1" role="dialog" aria-labelledby="modalNewFolderLabel" aria-hidden="true">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="modalNewFolderLabel">
                    <i class="fas fa-folder-plus mr-2"></i>Nueva carpeta
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group mb-2">
                    <label class="font-weight-bold small">Carpeta padre</label>
                    <select class="form-control form-control-sm" id="newFolderParent">
                        <option value="/">/ (raíz)</option>
                    </select>
                </div>
                <div class="form-group mb-0">
                    <label class="font-weight-bold small">Nombre de la carpeta <span class="text-danger">*</span></label>
                    <input type="text" class="form-control form-control-sm" id="newFolderName"
                           placeholder="Ej: Semana 1" maxlength="100">
                </div>
                <div id="folderAlert" class="alert alert-danger small mt-2" style="display:none;"></div>
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-sm btn-primary" id="btnConfirmNewFolder">
                    <i class="fas fa-plus mr-1"></i>Crear
                </button>
            </div>
        </div>
    </div>
</div>

{# ---- Modal: Ver distribuciones ---- #}
<div class="modal fade" id="modalViewDists" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title">
                    <i class="fas fa-list-ul mr-2"></i>Distribuciones de: <span id="distViewTitle"></span>
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body p-0">
                <div id="distListContent" class="p-3 text-muted text-center">
                    <i class="fas fa-spinner fa-spin mr-2"></i>Cargando...
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<style>
.border-dashed { border-style: dashed !important; }
#dropZone.drag-over { border-color: #4e73df !important; background: #eef0fa !important; }
.btn-xs { padding: 2px 7px; font-size: 12px; }
.font-weight-semibold { font-weight: 600; }
</style>

<script>
(function () {
    var AJAX_URL    = '{{ ajax_url }}';
    var CLASSROOM   = {{ classroom_id }};
    var CAN_UPLOAD  = {{ can_upload ? 'true' : 'false' }};

    // ---- drag-and-drop (only when tutor/admin) ----
    if (CAN_UPLOAD) {
        var dropZone = document.getElementById('dropZone');
        dropZone.addEventListener('dragover',  function(e){ e.preventDefault(); dropZone.classList.add('drag-over'); });
        dropZone.addEventListener('dragleave', function()  { dropZone.classList.remove('drag-over'); });
        dropZone.addEventListener('drop',      function(e){ e.preventDefault(); dropZone.classList.remove('drag-over'); uploadFiles(e.dataTransfer.files); });
        document.getElementById('btnUploadResource').addEventListener('click', function(){ document.getElementById('fileInputHidden').click(); });
        document.getElementById('fileInputHidden').addEventListener('change', function(){ uploadFiles(this.files); this.value=''; });
    }

    // ---- upload files ----
    function uploadFiles(files) {
        if (!files || files.length === 0) return;
        Array.prototype.forEach.call(files, function(f){ uploadSingle(f); });
    }

    function uploadSingle(file) {
        var fd = new FormData();
        fd.append('action', 'upload_resource');
        fd.append('classroom_id', CLASSROOM);
        fd.append('file', file);

        var bar = document.getElementById('uploadProgressBar');
        var lbl = document.getElementById('uploadProgressLabel');
        document.getElementById('uploadProgress').style.display = '';
        bar.style.width = '0%';
        lbl.textContent = 'Subiendo ' + file.name + '…';

        var xhr = new XMLHttpRequest();
        xhr.open('POST', AJAX_URL, true);

        xhr.upload.onprogress = function(e) {
            if (e.lengthComputable) {
                var pct = Math.round(e.loaded / e.total * 100);
                bar.style.width = pct + '%';
            }
        };

        xhr.onload = function() {
            document.getElementById('uploadProgress').style.display = 'none';
            var resp;
            try { resp = JSON.parse(xhr.responseText); } catch(e){ resp = {success:false, error:'Respuesta inválida'}; }
            if (!resp.success) {
                alert('Error al subir ' + file.name + ': ' + (resp.error || 'Error desconocido'));
                return;
            }
            addResourceRow(resp);
            updateResourceCount(1);
        };

        xhr.onerror = function() {
            document.getElementById('uploadProgress').style.display = 'none';
            alert('Error de red al subir ' + file.name);
        };

        xhr.send(fd);
    }

    function fileTypeIcon(type) {
        var map = {
            image: '<i class="fas fa-image text-success fa-lg"></i>',
            pdf:   '<i class="fas fa-file-pdf text-danger fa-lg"></i>',
            word:  '<i class="fas fa-file-word text-primary fa-lg"></i>',
            ppt:   '<i class="fas fa-file-powerpoint fa-lg" style="color:#d04423;"></i>',
            excel: '<i class="fas fa-file-excel text-success fa-lg"></i>',
            audio: '<i class="fas fa-file-audio text-warning fa-lg"></i>',
            video: '<i class="fas fa-file-video text-info fa-lg"></i>',
        };
        return map[type] || '<i class="fas fa-file text-secondary fa-lg"></i>';
    }

    function addResourceRow(r) {
        var tbody = document.querySelector('#resourcesTable tbody');
        // Remove empty state if present
        var empty = document.getElementById('emptyState');
        if (empty) empty.remove();

        if (!tbody) {
            // Table doesn't exist yet, create it
            var listDiv = document.getElementById('resourceList');
            listDiv.innerHTML = '<div class="table-responsive"><table class="table table-hover mb-0" id="resourcesTable">'
                + '<thead class="thead-light"><tr>'
                + '<th style="width:40px;"></th><th>Nombre</th>'
                + '<th class="text-center" style="width:80px;">Tipo</th>'
                + '<th class="text-center" style="width:80px;">Tamaño</th>'
                + '<th class="text-center" style="width:80px;">Distribuido</th>'
                + '<th class="text-right" style="width:180px;">Acciones</th>'
                + '</tr></thead><tbody></tbody></table></div>';
            tbody = document.querySelector('#resourcesTable tbody');
        }

        var tr = document.createElement('tr');
        tr.id = 'res-row-' + r.id;
        tr.setAttribute('data-id', r.id);
        tr.setAttribute('data-type', r.file_type);
        tr.setAttribute('data-title', r.title);
        tr.innerHTML = '<td class="text-center align-middle">' + fileTypeIcon(r.file_type) + '</td>'
            + '<td class="align-middle">'
            + '<div class="res-title-wrap" id="title-wrap-' + r.id + '">'
            + '<span class="res-title font-weight-semibold" id="title-text-' + r.id + '">' + escHtml(r.title) + '</span>'
            + '<input type="text" class="form-control form-control-sm res-title-input" id="title-input-' + r.id + '" value="' + escHtml(r.title) + '" maxlength="255" style="display:none!important; max-width:280px;">'
            + '<span class="res-rename-actions d-none" id="title-actions-' + r.id + '" style="white-space:nowrap;">'
            + '<button class="btn btn-xs btn-primary ml-1 btn-rename-save" data-id="' + r.id + '" title="Guardar"><i class="fas fa-check"></i></button>'
            + '<button class="btn btn-xs btn-outline-secondary ml-1 btn-rename-cancel" data-id="' + r.id + '" title="Cancelar"><i class="fas fa-times"></i></button>'
            + '</span></div>'
            + '<small class="text-muted">' + escHtml(r.filename) + '</small>'
            + '<br><small class="text-muted"><i class="fas fa-clock mr-1"></i>' + escHtml(r.created_at) + '</small></td>'
            + '<td class="text-center align-middle"><span class="badge badge-light text-uppercase small">' + r.file_type + '</span></td>'
            + '<td class="text-center align-middle text-muted small">' + r.file_size_fmt + '</td>'
            + '<td class="text-center align-middle"><span class="badge badge-light dist-count-badge" id="dist-count-' + r.id + '">0</span></td>'
            + '<td class="text-right align-middle" style="white-space:nowrap;">'
            + '<a href="' + r.web_url + '" target="_blank" class="btn btn-xs btn-outline-secondary mr-1" title="Descargar"><i class="fas fa-eye"></i></a>'
            + (CAN_UPLOAD ? '<button class="btn btn-xs btn-outline-warning mr-1 btn-rename-start" data-id="' + r.id + '" title="Renombrar"><i class="fas fa-pencil-alt"></i></button>' : '')
            + '<button class="btn btn-xs btn-outline-info mr-1 btn-view-dists" data-id="' + r.id + '" data-title="' + escHtml(r.title) + '" title="Ver distribuciones"><i class="fas fa-list-ul"></i></button>'
            + '<button class="btn btn-xs btn-success mr-1 btn-distribute" data-id="' + r.id + '" data-title="' + escHtml(r.title) + '" title="Distribuir"><i class="fas fa-share-alt"></i></button>'
            + (CAN_UPLOAD ? '<button class="btn btn-xs btn-outline-danger btn-delete-resource" data-id="' + r.id + '" data-title="' + escHtml(r.title) + '" title="Eliminar"><i class="fas fa-trash"></i></button>' : '')
            + '</td>';
        tbody.insertBefore(tr, tbody.firstChild);
    }

    function updateResourceCount(delta) {
        var el = document.getElementById('resourceCount');
        el.textContent = parseInt(el.textContent || '0') + delta;
    }

    // ---- Delete resource ----
    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-delete-resource');
        if (!btn) return;
        var id    = btn.getAttribute('data-id');
        var title = btn.getAttribute('data-title');
        if (!confirm('¿Eliminar el archivo "' + title + '"? Esta acción no se puede deshacer.')) return;

        ajaxPost({action: 'delete_resource', resource_id: id, classroom_id: CLASSROOM}, function(resp) {
            if (!resp.success) { alert('Error: ' + (resp.error || 'desconocido')); return; }
            var row = document.getElementById('res-row-' + id);
            if (row) row.remove();
            updateResourceCount(-1);
        });
    });

    // ---- Rename: start editing ----
    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-rename-start');
        if (!btn) return;
        var id = btn.getAttribute('data-id');
        enterRenameMode(id);
    });

    function enterRenameMode(id) {
        var textEl    = document.getElementById('title-text-' + id);
        var inputEl   = document.getElementById('title-input-' + id);
        var actionsEl = document.getElementById('title-actions-' + id);
        textEl.style.display    = 'none';
        inputEl.style.removeProperty('display');   // override the inline !important
        inputEl.style.display   = 'inline-block';
        actionsEl.classList.remove('d-none');
        inputEl.focus();
        inputEl.select();
    }

    function exitRenameMode(id, newTitle) {
        var textEl    = document.getElementById('title-text-' + id);
        var inputEl   = document.getElementById('title-input-' + id);
        var actionsEl = document.getElementById('title-actions-' + id);
        if (newTitle !== undefined) {
            textEl.textContent = newTitle;
            // Update data-title on distribute / view-dists buttons
            var row = document.getElementById('res-row-' + id);
            if (row) {
                row.setAttribute('data-title', newTitle);
                var distBtn = row.querySelector('.btn-distribute');
                if (distBtn) distBtn.setAttribute('data-title', newTitle);
                var viewBtn = row.querySelector('.btn-view-dists');
                if (viewBtn) viewBtn.setAttribute('data-title', newTitle);
            }
        }
        inputEl.style.display = '';   // let the !important hide it again
        textEl.style.display  = '';
        actionsEl.classList.add('d-none');
    }

    // ---- Rename: save ----
    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-rename-save');
        if (!btn) return;
        var id       = btn.getAttribute('data-id');
        var inputEl  = document.getElementById('title-input-' + id);
        var newTitle = inputEl.value.trim();
        if (!newTitle) { inputEl.focus(); return; }

        ajaxPost({action:'rename_resource', resource_id: id, classroom_id: CLASSROOM, title: newTitle}, function(resp) {
            if (!resp.success) { alert('Error: ' + (resp.error || 'No se pudo renombrar')); return; }
            exitRenameMode(id, resp.title);
        });
    });

    // ---- Rename: cancel ----
    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-rename-cancel');
        if (!btn) return;
        var id = btn.getAttribute('data-id');
        var inputEl = document.getElementById('title-input-' + id);
        // Restore original value
        inputEl.value = document.getElementById('title-text-' + id).textContent;
        exitRenameMode(id);
    });

    // ---- Rename: confirm with Enter, cancel with Escape ----
    document.addEventListener('keydown', function(e) {
        if (!e.target.classList.contains('res-title-input')) return;
        var id = e.target.id.replace('title-input-', '');
        if (e.key === 'Enter') {
            e.preventDefault();
            document.querySelector('.btn-rename-save[data-id="' + id + '"]').click();
        } else if (e.key === 'Escape') {
            document.querySelector('.btn-rename-cancel[data-id="' + id + '"]').click();
        }
    });

    // ---- Open distribute modal ----
    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-distribute');
        if (!btn) return;
        var id    = btn.getAttribute('data-id');
        var titleEl = document.getElementById('title-text-' + id);
        var title = titleEl ? titleEl.textContent : btn.getAttribute('data-title');

        document.getElementById('distResourceId').value = id;
        document.getElementById('distResourceTitle').textContent = title;
        document.getElementById('distAlert').style.display = 'none';
        document.getElementById('distFolderSelect').innerHTML = '<option value="/">/ (raíz)</option>';

        $('#modalDistribute').modal('show');
    });

    // When course changes, reload folders
    document.getElementById('distCourseSelect').addEventListener('change', function() {
        loadFolders(this.value);
    });
    document.getElementById('distSessionSelect').addEventListener('change', function() {
        var code = document.getElementById('distCourseSelect').value;
        if (code) loadFolders(code);
    });

    document.getElementById('btnRefreshFolders').addEventListener('click', function() {
        var code = document.getElementById('distCourseSelect').value;
        if (code) loadFolders(code);
    });

    function loadFolders(courseCode) {
        if (!courseCode) return;
        var sessionId = document.getElementById('distSessionSelect').value;
        var sel = document.getElementById('distFolderSelect');
        sel.innerHTML = '<option value="/">Cargando…</option>';

        ajaxGet({action:'get_folders', course_code: courseCode, session_id: sessionId}, function(resp) {
            sel.innerHTML = '';
            if (resp.success && resp.folders) {
                resp.folders.forEach(function(f) {
                    var o = document.createElement('option');
                    o.value = f.path;
                    o.textContent = f.label;
                    sel.appendChild(o);
                });
                // Also update newFolderParent
                syncFolderSelectToParent(resp.folders);
            } else {
                sel.innerHTML = '<option value="/">/ (raíz)</option>';
            }
        });
    }

    function syncFolderSelectToParent(folders) {
        var sel = document.getElementById('newFolderParent');
        sel.innerHTML = '';
        folders.forEach(function(f) {
            var o = document.createElement('option');
            o.value = f.path;
            o.textContent = f.label;
            sel.appendChild(o);
        });
    }

    // ---- Open new-folder modal from distribute modal ----
    document.getElementById('btnNewFolderFromDist').addEventListener('click', function() {
        document.getElementById('newFolderName').value = '';
        document.getElementById('folderAlert').style.display = 'none';
        $('#modalNewFolder').modal('show');
    });

    // ---- Confirm new folder ----
    document.getElementById('btnConfirmNewFolder').addEventListener('click', function() {
        var folderName = document.getElementById('newFolderName').value.trim();
        var parentPath = document.getElementById('newFolderParent').value;
        var courseCode = document.getElementById('distCourseSelect').value;
        var sessionId  = document.getElementById('distSessionSelect').value;

        if (!folderName) { showAlert('folderAlert', 'Escribe el nombre de la carpeta.'); return; }
        if (!courseCode) { showAlert('folderAlert', 'Primero selecciona un curso en el modal anterior.'); return; }

        ajaxPost({action:'create_folder', classroom_id: CLASSROOM, course_code: courseCode,
                  session_id: sessionId, folder_name: folderName, parent_path: parentPath}, function(resp) {
            if (!resp.success) { showAlert('folderAlert', resp.error || 'Error al crear carpeta.'); return; }
            $('#modalNewFolder').modal('hide');
            // Reload folders
            loadFolders(courseCode);
        });
    });

    // ---- Confirm distribute ----
    document.getElementById('btnConfirmDistribute').addEventListener('click', function() {
        var resourceId = document.getElementById('distResourceId').value;
        var courseCode = document.getElementById('distCourseSelect').value;
        var sessionId  = document.getElementById('distSessionSelect').value;
        var folderPath = document.getElementById('distFolderSelect').value;

        if (!courseCode) { showAlert('distAlert', 'Selecciona un curso.'); return; }

        var btn = this;
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i>Distribuyendo…';

        ajaxPost({action:'distribute_resource', resource_id: resourceId, classroom_id: CLASSROOM,
                  course_code: courseCode, session_id: sessionId, folder_path: folderPath}, function(resp) {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-share-alt mr-1"></i>Distribuir';

            if (!resp.success) { showAlert('distAlert', resp.error || 'Error al distribuir.'); return; }

            // Update distribution badge
            var badge = document.getElementById('dist-count-' + resourceId);
            if (badge) {
                badge.textContent = parseInt(badge.textContent || '0') + 1;
                badge.className = badge.className.replace('badge-light', 'badge-success');
            }

            $('#modalDistribute').modal('hide');
            var msg = 'Recurso distribuido a "' + resp.course_title + '"';
            if (resp.session_name) msg += ' — Sesión: ' + resp.session_name;
            msg += '\nCarpeta: ' + resp.folder_path;
            alert(msg);
        });
    });

    // ---- View distributions ----
    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-view-dists');
        if (!btn) return;
        var id    = btn.getAttribute('data-id');
        var title = btn.getAttribute('data-title');

        document.getElementById('distViewTitle').textContent = title;
        document.getElementById('distListContent').innerHTML = '<div class="text-center py-3"><i class="fas fa-spinner fa-spin"></i> Cargando...</div>';
        $('#modalViewDists').modal('show');

        ajaxGet({action:'get_distributions', resource_id: id, classroom_id: CLASSROOM}, function(resp) {
            var html = '';
            if (!resp.success || !resp.distributions || resp.distributions.length === 0) {
                html = '<div class="text-center py-4 text-muted"><i class="fas fa-inbox fa-2x mb-2 d-block"></i>Aún no se ha distribuido este recurso.</div>';
            } else {
                html = '<div class="table-responsive"><table class="table table-sm mb-0"><thead class="thead-light"><tr>'
                    + '<th>Curso</th><th>Sesión</th><th>Carpeta</th><th>Por</th><th>Fecha</th>'
                    + '</tr></thead><tbody>';
                resp.distributions.forEach(function(d) {
                    html += '<tr>'
                        + '<td>' + escHtml(d.course_title) + '</td>'
                        + '<td>' + (d.session_name ? escHtml(d.session_name) : '<span class="text-muted">—</span>') + '</td>'
                        + '<td><code>' + escHtml(d.folder_path) + '</code></td>'
                        + '<td>' + escHtml(d.distributed_by) + '</td>'
                        + '<td>' + escHtml(d.distributed_at) + '</td>'
                        + '</tr>';
                });
                html += '</tbody></table></div>';
            }
            document.getElementById('distListContent').innerHTML = html;
        });
    });

    // ---- Utilities ----
    function ajaxPost(data, callback) {
        var fd = new FormData();
        Object.keys(data).forEach(function(k){ fd.append(k, data[k]); });
        var xhr = new XMLHttpRequest();
        xhr.open('POST', AJAX_URL, true);
        xhr.onload = function() {
            var r; try { r = JSON.parse(xhr.responseText); } catch(e){ r={success:false,error:'Respuesta inválida'}; }
            callback(r);
        };
        xhr.onerror = function(){ callback({success:false, error:'Error de red'}); };
        xhr.send(fd);
    }

    function ajaxGet(params, callback) {
        var url = AJAX_URL + '?' + Object.keys(params).map(function(k){ return encodeURIComponent(k)+'='+encodeURIComponent(params[k]); }).join('&');
        var xhr = new XMLHttpRequest();
        xhr.open('GET', url, true);
        xhr.onload = function() {
            var r; try { r = JSON.parse(xhr.responseText); } catch(e){ r={success:false,error:'Respuesta inválida'}; }
            callback(r);
        };
        xhr.onerror = function(){ callback({success:false,error:'Error de red'}); };
        xhr.send();
    }

    function showAlert(id, msg) {
        var el = document.getElementById(id);
        el.textContent = msg;
        el.style.display = '';
    }

    function escHtml(str) {
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }
}());
</script>
