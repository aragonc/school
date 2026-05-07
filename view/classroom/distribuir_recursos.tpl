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
        <div class="d-flex flex-wrap" style="gap:8px;">
            {% if can_upload %}
            <button type="button" class="btn btn-sm btn-outline-primary" id="btnUploadResource">
                <i class="fas fa-cloud-upload-alt mr-1"></i>Subir archivo
            </button>
            {% endif %}
            <button type="button" class="btn btn-sm btn-success" id="btnDistributeSelected" disabled>
                <i class="fas fa-paper-plane mr-1"></i>Distribuir <span id="selectedCountBadge" class="badge badge-light ml-1">0</span>
            </button>
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
            </form>
        </div>
    </div>
    {% endif %}

    {% if not classroom %}
    <div class="alert alert-info">
        <i class="fas fa-info-circle mr-2"></i>No tienes un aula asignada en el año académico activo.
    </div>
    {% else %}

    {% if can_upload %}
    {# ---- Drop zone ---- #}
    <div id="dropZone" class="border-dashed rounded mb-3 text-center py-3 px-3"
         style="border:2px dashed #adb5bd; background:#f8f9fc; cursor:pointer; transition:border-color .2s;">
        <i class="fas fa-cloud-upload-alt fa-lg text-muted mr-2"></i>
        <span class="text-muted">Arrastra archivos aquí o <strong>haz clic para seleccionar</strong></span>
        <span class="small text-muted ml-2">— Imágenes, PDF, Word, PPT, Excel, MP3, MP4 — máx. 100 MB</span>
        <input type="file" id="fileInputHidden" multiple style="display:none;"
               accept="image/*,.pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.mp3,.mp4,.ogg,.wav,.webm">
    </div>
    <div id="uploadProgress" class="mb-3" style="display:none;">
        <div class="progress" style="height:6px;">
            <div id="uploadProgressBar" class="progress-bar progress-bar-striped progress-bar-animated" style="width:0%"></div>
        </div>
        <small class="text-muted mt-1 d-block" id="uploadProgressLabel"></small>
    </div>
    {% endif %}

    {# ---- Resources table ---- #}
    <div class="card shadow-sm border-0">
        <div class="card-header bg-white d-flex align-items-center justify-content-between py-2 px-3">
            <div class="d-flex align-items-center" style="gap:10px;">
                <div class="custom-control custom-checkbox mb-0">
                    <input type="checkbox" class="custom-control-input" id="chkAll">
                    <label class="custom-control-label font-weight-bold text-dark" for="chkAll">Archivos subidos</label>
                </div>
                <span class="badge badge-secondary" id="resourceCount">{{ resources|length }}</span>
            </div>
            <small class="text-muted">Configura el destino de cada archivo y luego usa <strong>Distribuir</strong></small>
        </div>
        <div class="card-body p-0">
            <div id="resourceList">
            {% if resources %}
            <div class="table-responsive">
            <table class="table table-hover mb-0 align-middle" id="resourcesTable">
                <thead class="thead-light" style="font-size:.8rem;">
                    <tr>
                        <th style="width:36px;"></th>
                        <th style="width:36px;"></th>
                        <th>Nombre</th>
                        <th style="width:75px;" class="text-center">Tipo</th>
                        <th style="width:75px;" class="text-center">Tamaño</th>
                        <th>Destino</th>
                        <th style="width:160px;" class="text-right">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                {% for r in resources %}
                <tr id="res-row-{{ r.id }}" data-id="{{ r.id }}">
                    {# Checkbox #}
                    <td class="text-center align-middle">
                        <div class="custom-control custom-checkbox">
                            <input type="checkbox" class="custom-control-input res-checkbox" id="chk-{{ r.id }}" value="{{ r.id }}">
                            <label class="custom-control-label" for="chk-{{ r.id }}"></label>
                        </div>
                    </td>
                    {# Icon #}
                    <td class="text-center align-middle">
                        {%- if r.file_type == 'image' -%}<i class="fas fa-image text-success fa-lg"></i>
                        {%- elseif r.file_type == 'pdf' -%}<i class="fas fa-file-pdf text-danger fa-lg"></i>
                        {%- elseif r.file_type == 'word' -%}<i class="fas fa-file-word text-primary fa-lg"></i>
                        {%- elseif r.file_type == 'ppt' -%}<i class="fas fa-file-powerpoint fa-lg" style="color:#d04423;"></i>
                        {%- elseif r.file_type == 'excel' -%}<i class="fas fa-file-excel text-success fa-lg"></i>
                        {%- elseif r.file_type == 'audio' -%}<i class="fas fa-file-audio text-warning fa-lg"></i>
                        {%- elseif r.file_type == 'video' -%}<i class="fas fa-file-video text-info fa-lg"></i>
                        {%- else -%}<i class="fas fa-file text-secondary fa-lg"></i>
                        {%- endif -%}
                    </td>
                    {# Name (inline rename) #}
                    <td class="align-middle">
                        <div class="res-title-wrap" id="title-wrap-{{ r.id }}">
                            <span class="res-title font-weight-semibold" id="title-text-{{ r.id }}">{{ r.title }}</span>
                            <input type="text" class="form-control form-control-sm res-title-input"
                                   id="title-input-{{ r.id }}" value="{{ r.title }}" maxlength="255">
                            <span class="res-rename-actions d-none" id="title-actions-{{ r.id }}">
                                <button class="btn btn-xs btn-primary ml-1 btn-rename-save" data-id="{{ r.id }}"><i class="fas fa-check"></i></button>
                                <button class="btn btn-xs btn-outline-secondary ml-1 btn-rename-cancel" data-id="{{ r.id }}"><i class="fas fa-times"></i></button>
                            </span>
                        </div>
                        <small class="text-muted d-block" id="filename-{{ r.id }}">{{ r.filename }}</small>
                        {% if r.uploader_name %}<small class="text-muted"><i class="fas fa-user mr-1"></i>{{ r.uploader_name }}</small>{% endif %}
                    </td>
                    {# Type #}
                    <td class="text-center align-middle"><span class="badge badge-light text-uppercase small">{{ r.file_type }}</span></td>
                    {# Size #}
                    <td class="text-center align-middle text-muted small">{{ r.file_size_fmt }}</td>
                    {# Destination #}
                    <td class="align-middle" id="dest-cell-{{ r.id }}">
                        {% if r.has_destination %}
                        <div class="dest-info">
                            <span class="badge badge-success-soft d-block mb-1" style="background:#e8f5e9; color:#2e7d32; font-size:.75rem; padding:3px 7px; border-radius:4px;">
                                <i class="fas fa-book mr-1"></i>{{ r.dest_course_title }}
                                {% if r.dest_session_name %}<span class="ml-1 opacity-75">· {{ r.dest_session_name }}</span>{% endif %}
                            </span>
                            <span class="badge badge-light" style="font-size:.72rem;"><i class="fas fa-folder mr-1"></i><code>{{ r.dest_folder_path ?: '/' }}</code></span>
                        </div>
                        {% else %}
                        <span class="badge badge-light text-muted" style="font-size:.75rem;" id="dest-empty-{{ r.id }}">
                            <i class="fas fa-exclamation-circle mr-1"></i>Sin destino
                        </span>
                        {% endif %}
                    </td>
                    {# Actions #}
                    <td class="text-right align-middle" style="white-space:nowrap;">
                        <a href="{{ r.web_url }}" target="_blank" class="btn btn-xs btn-outline-secondary mr-1" title="Ver/descargar"><i class="fas fa-eye"></i></a>
                        {% if is_admin or is_tutor or r.uploaded_by == current_user_id %}
                        <button class="btn btn-xs btn-outline-warning mr-1 btn-rename-start" data-id="{{ r.id }}" title="Renombrar"><i class="fas fa-pencil-alt"></i></button>
                        {% endif %}
                        <button class="btn btn-xs btn-outline-primary mr-1 btn-set-dest"
                                data-id="{{ r.id }}"
                                data-course="{{ r.dest_course_code }}"
                                data-session="{{ r.dest_session_id }}"
                                data-folder="{{ r.dest_folder_path ?: '/' }}"
                                title="Configurar destino">
                            <i class="fas fa-map-marker-alt"></i>
                        </button>
                        {% if is_admin or is_tutor or r.uploaded_by == current_user_id %}
                        <button class="btn btn-xs btn-outline-danger btn-delete-resource" data-id="{{ r.id }}" data-title="{{ r.title }}" title="Eliminar"><i class="fas fa-trash"></i></button>
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
                No hay archivos. Sube archivos para comenzar.
            </div>
            {% endif %}
            </div>
        </div>
    </div>

    {% endif %}{# end if classroom #}
</div>

{# ==================== MODALES ==================== #}

{# Modal: Configurar destino #}
<div class="modal fade" id="modalSetDest" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title"><i class="fas fa-map-marker-alt mr-2"></i>Configurar destino</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p class="text-muted small mb-3">Archivo: <strong id="destFileName"></strong></p>
                <input type="hidden" id="destResourceId">

                <div class="form-group">
                    <label class="font-weight-bold small">Curso <span class="text-danger">*</span></label>
                    <select class="form-control form-control-sm" id="destCourseSelect">
                        <option value="">— Selecciona un curso —</option>
                        {% for c in classroom_courses %}
                        <option value="{{ c.code }}" data-title="{{ c.title }}">{{ c.title }}</option>
                        {% endfor %}
                    </select>
                </div>

                <div class="form-group">
                    <label class="font-weight-bold small">Sesión</label>
                    <select class="form-control form-control-sm" id="destSessionSelect">
                        <option value="0">Sin sesión (base del curso)</option>
                        {% if session_id > 0 %}
                        <option value="{{ session_id }}">Sesión del aula (id: {{ session_id }})</option>
                        {% endif %}
                    </select>
                </div>

                <div class="form-group mb-0">
                    <label class="font-weight-bold small">Carpeta destino</label>
                    <div class="input-group input-group-sm">
                        <select class="form-control" id="destFolderSelect">
                            <option value="/">/ (raíz)</option>
                        </select>
                        <div class="input-group-append">
                            <button type="button" class="btn btn-outline-secondary" id="btnDestRefreshFolders" title="Recargar"><i class="fas fa-sync-alt"></i></button>
                            <button type="button" class="btn btn-outline-primary"   id="btnDestNewFolder"     title="Nueva carpeta"><i class="fas fa-folder-plus"></i></button>
                        </div>
                    </div>
                </div>

                <div id="destAlert" class="alert alert-danger small mt-3" style="display:none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary btn-sm" id="btnConfirmSetDest">
                    <i class="fas fa-check mr-1"></i>Guardar destino
                </button>
            </div>
        </div>
    </div>
</div>

{# Modal: Nueva carpeta #}
<div class="modal fade" id="modalNewFolder" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title"><i class="fas fa-folder-plus mr-2"></i>Nueva carpeta</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group mb-2">
                    <label class="font-weight-bold small">Carpeta padre</label>
                    <select class="form-control form-control-sm" id="newFolderParent"><option value="/">/ (raíz)</option></select>
                </div>
                <div class="form-group mb-0">
                    <label class="font-weight-bold small">Nombre <span class="text-danger">*</span></label>
                    <input type="text" class="form-control form-control-sm" id="newFolderName" placeholder="Ej: Semana 1" maxlength="100">
                </div>
                <div id="folderAlert" class="alert alert-danger small mt-2" style="display:none;"></div>
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-sm btn-primary" id="btnConfirmNewFolder"><i class="fas fa-plus mr-1"></i>Crear</button>
            </div>
        </div>
    </div>
</div>

{# Modal: Confirmar distribución masiva #}
<div class="modal fade" id="modalConfirmDistribute" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title"><i class="fas fa-paper-plane mr-2"></i>Confirmar distribución</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p class="mb-2">Se moverán los siguientes archivos a sus destinos configurados:</p>
                <div id="distributePreviewList" class="small"></div>
                <div id="distributeWarning" class="alert alert-warning small mt-3" style="display:none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-success btn-sm" id="btnConfirmDistribute">
                    <i class="fas fa-paper-plane mr-1"></i>Distribuir
                </button>
            </div>
        </div>
    </div>
</div>

{# Modal: Resultados #}
<div class="modal fade" id="modalDistributeResults" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-check-circle mr-2"></i>Resultado de la distribución</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body p-0">
                <div id="distributeResultsList"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary btn-sm" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<style>
.border-dashed { border-style: dashed !important; }
#dropZone.drag-over { border-color:#4e73df!important; background:#eef0fa!important; }
.btn-xs { padding:2px 7px; font-size:12px; }
.font-weight-semibold { font-weight:600; }
.res-title-input { display:none; max-width:260px; }
</style>

<script>
(function () {
    var AJAX_URL   = '{{ ajax_url }}';
    var CLASSROOM  = {{ classroom_id }};
    var CAN_UPLOAD = {{ can_upload ? 'true' : 'false' }};

    // =====================================================================
    // Upload
    // =====================================================================
    if (CAN_UPLOAD) {
        var dropZone = document.getElementById('dropZone');
        dropZone.addEventListener('dragover',  function(e){ e.preventDefault(); dropZone.classList.add('drag-over'); });
        dropZone.addEventListener('dragleave', function()  { dropZone.classList.remove('drag-over'); });
        dropZone.addEventListener('drop',      function(e){ e.preventDefault(); dropZone.classList.remove('drag-over'); uploadFiles(e.dataTransfer.files); });
        dropZone.addEventListener('click',     function()  { document.getElementById('fileInputHidden').click(); });
        document.getElementById('btnUploadResource').addEventListener('click', function(){ document.getElementById('fileInputHidden').click(); });
        document.getElementById('fileInputHidden').addEventListener('change', function(){ uploadFiles(this.files); this.value=''; });
    }

    function uploadFiles(files) {
        Array.prototype.forEach.call(files, uploadSingle);
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
            if (e.lengthComputable) bar.style.width = Math.round(e.loaded/e.total*100) + '%';
        };
        xhr.onload = function() {
            document.getElementById('uploadProgress').style.display = 'none';
            var resp; try { resp = JSON.parse(xhr.responseText); } catch(e){ resp={success:false,error:'Respuesta inválida'}; }
            if (!resp.success) { alert('Error: ' + (resp.error||'desconocido')); return; }
            addResourceRow(resp);
            updateCount(1);
        };
        xhr.onerror = function(){ document.getElementById('uploadProgress').style.display='none'; alert('Error de red'); };
        xhr.send(fd);
    }

    function fileTypeIcon(type) {
        var map = { image:'<i class="fas fa-image text-success fa-lg"></i>', pdf:'<i class="fas fa-file-pdf text-danger fa-lg"></i>',
            word:'<i class="fas fa-file-word text-primary fa-lg"></i>', ppt:'<i class="fas fa-file-powerpoint fa-lg" style="color:#d04423;"></i>',
            excel:'<i class="fas fa-file-excel text-success fa-lg"></i>', audio:'<i class="fas fa-file-audio text-warning fa-lg"></i>',
            video:'<i class="fas fa-file-video text-info fa-lg"></i>' };
        return map[type] || '<i class="fas fa-file text-secondary fa-lg"></i>';
    }

    function addResourceRow(r) {
        var empty = document.getElementById('emptyState');
        if (empty) empty.remove();

        var tbody = document.querySelector('#resourcesTable tbody');
        if (!tbody) {
            document.getElementById('resourceList').innerHTML =
                '<div class="table-responsive"><table class="table table-hover mb-0 align-middle" id="resourcesTable">'
                + '<thead class="thead-light" style="font-size:.8rem;"><tr>'
                + '<th style="width:36px;"></th><th style="width:36px;"></th><th>Nombre</th>'
                + '<th style="width:75px;" class="text-center">Tipo</th><th style="width:75px;" class="text-center">Tamaño</th>'
                + '<th>Destino</th><th style="width:160px;" class="text-right">Acciones</th>'
                + '</tr></thead><tbody></tbody></table></div>';
            tbody = document.querySelector('#resourcesTable tbody');
        }

        var tr = document.createElement('tr');
        tr.id = 'res-row-' + r.id;
        tr.setAttribute('data-id', r.id);
        tr.innerHTML =
            '<td class="text-center align-middle"><div class="custom-control custom-checkbox">'
            + '<input type="checkbox" class="custom-control-input res-checkbox" id="chk-'+r.id+'" value="'+r.id+'">'
            + '<label class="custom-control-label" for="chk-'+r.id+'"></label></div></td>'
            + '<td class="text-center align-middle">' + fileTypeIcon(r.file_type) + '</td>'
            + '<td class="align-middle">'
            + '<div class="res-title-wrap" id="title-wrap-'+r.id+'">'
            + '<span class="res-title font-weight-semibold" id="title-text-'+r.id+'">' + escHtml(r.title) + '</span>'
            + '<input type="text" class="form-control form-control-sm res-title-input" id="title-input-'+r.id+'" value="'+escHtml(r.title)+'" maxlength="255">'
            + '<span class="res-rename-actions d-none" id="title-actions-'+r.id+'">'
            + '<button class="btn btn-xs btn-primary ml-1 btn-rename-save" data-id="'+r.id+'"><i class="fas fa-check"></i></button>'
            + '<button class="btn btn-xs btn-outline-secondary ml-1 btn-rename-cancel" data-id="'+r.id+'"><i class="fas fa-times"></i></button>'
            + '</span></div>'
            + '<small class="text-muted d-block" id="filename-'+r.id+'">'+escHtml(r.filename)+'</small></td>'
            + '<td class="text-center align-middle"><span class="badge badge-light text-uppercase small">'+r.file_type+'</span></td>'
            + '<td class="text-center align-middle text-muted small">'+r.file_size_fmt+'</td>'
            + '<td class="align-middle" id="dest-cell-'+r.id+'">'
            + '<span class="badge badge-light text-muted" style="font-size:.75rem;" id="dest-empty-'+r.id+'"><i class="fas fa-exclamation-circle mr-1"></i>Sin destino</span>'
            + '</td>'
            + '<td class="text-right align-middle" style="white-space:nowrap;">'
            + '<a href="'+r.web_url+'" target="_blank" class="btn btn-xs btn-outline-secondary mr-1" title="Ver"><i class="fas fa-eye"></i></a>'
            + '<button class="btn btn-xs btn-outline-warning mr-1 btn-rename-start" data-id="'+r.id+'" title="Renombrar"><i class="fas fa-pencil-alt"></i></button>'
            + '<button class="btn btn-xs btn-outline-primary mr-1 btn-set-dest" data-id="'+r.id+'" data-course="" data-session="0" data-folder="/" title="Configurar destino"><i class="fas fa-map-marker-alt"></i></button>'
            + '<button class="btn btn-xs btn-outline-danger btn-delete-resource" data-id="'+r.id+'" data-title="'+escHtml(r.title)+'" title="Eliminar"><i class="fas fa-trash"></i></button>'
            + '</td>';
        tbody.insertBefore(tr, tbody.firstChild);
        updateCheckboxListeners();
    }

    // =====================================================================
    // Checkbox / selection
    // =====================================================================
    document.getElementById('chkAll').addEventListener('change', function() {
        document.querySelectorAll('.res-checkbox').forEach(function(cb){ cb.checked = this.checked; }, this);
        refreshDistributeBtn();
    });

    function updateCheckboxListeners() {
        document.querySelectorAll('.res-checkbox').forEach(function(cb) {
            cb.removeEventListener('change', refreshDistributeBtn);
            cb.addEventListener('change', refreshDistributeBtn);
        });
    }
    updateCheckboxListeners();

    function getCheckedIds() {
        return Array.from(document.querySelectorAll('.res-checkbox:checked')).map(function(cb){ return parseInt(cb.value); });
    }

    function refreshDistributeBtn() {
        var ids = getCheckedIds();
        var btn = document.getElementById('btnDistributeSelected');
        btn.disabled = ids.length === 0;
        document.getElementById('selectedCountBadge').textContent = ids.length;
    }

    // =====================================================================
    // Set Destination modal
    // =====================================================================
    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-set-dest');
        if (!btn) return;
        var id      = btn.getAttribute('data-id');
        var course  = btn.getAttribute('data-course') || '';
        var session = btn.getAttribute('data-session') || '0';
        var folder  = btn.getAttribute('data-folder')  || '/';

        document.getElementById('destResourceId').value = id;
        var titleEl = document.getElementById('title-text-' + id);
        document.getElementById('destFileName').textContent = titleEl ? titleEl.textContent : id;
        document.getElementById('destAlert').style.display = 'none';

        // Pre-select course
        var courseSel = document.getElementById('destCourseSelect');
        courseSel.value = course;

        // Pre-select session
        document.getElementById('destSessionSelect').value = session;

        // Load folders (and pre-select after load)
        document.getElementById('destFolderSelect').innerHTML = '<option value="/">/ (raíz)</option>';
        if (course) loadDestFolders(course, session, folder);

        $('#modalSetDest').modal('show');
    });

    document.getElementById('destCourseSelect').addEventListener('change', function() {
        loadDestFolders(this.value, document.getElementById('destSessionSelect').value, '/');
    });
    document.getElementById('destSessionSelect').addEventListener('change', function() {
        var code = document.getElementById('destCourseSelect').value;
        if (code) loadDestFolders(code, this.value, '/');
    });
    document.getElementById('btnDestRefreshFolders').addEventListener('click', function() {
        var code = document.getElementById('destCourseSelect').value;
        if (code) loadDestFolders(code, document.getElementById('destSessionSelect').value, document.getElementById('destFolderSelect').value);
    });

    function loadDestFolders(courseCode, sessionId, preSelect) {
        var sel = document.getElementById('destFolderSelect');
        sel.innerHTML = '<option value="/">Cargando…</option>';
        ajaxGet({action:'get_folders', course_code: courseCode, session_id: sessionId||0}, function(resp) {
            sel.innerHTML = '';
            var folders = (resp.success && resp.folders) ? resp.folders : [{path:'/', label:'/ (raíz)'}];
            folders.forEach(function(f) {
                var o = document.createElement('option');
                o.value = f.path; o.textContent = f.label;
                sel.appendChild(o);
            });
            if (preSelect) sel.value = preSelect;
            syncParentSelect(folders);
        });
    }

    function syncParentSelect(folders) {
        var sel = document.getElementById('newFolderParent');
        sel.innerHTML = '';
        folders.forEach(function(f) {
            var o = document.createElement('option');
            o.value = f.path; o.textContent = f.label;
            sel.appendChild(o);
        });
    }

    // Confirm set destination
    document.getElementById('btnConfirmSetDest').addEventListener('click', function() {
        var id         = document.getElementById('destResourceId').value;
        var courseCode = document.getElementById('destCourseSelect').value;
        var sessionId  = document.getElementById('destSessionSelect').value;
        var folderPath = document.getElementById('destFolderSelect').value;

        if (!courseCode) { showAlert('destAlert', 'Selecciona un curso.'); return; }

        var btn = this; btn.disabled = true;
        ajaxPost({action:'set_destination', resource_id:id, classroom_id:CLASSROOM,
                  course_code:courseCode, session_id:sessionId, folder_path:folderPath}, function(resp) {
            btn.disabled = false;
            if (!resp.success) { showAlert('destAlert', resp.error||'Error al guardar destino.'); return; }

            // Update the destination cell in the table
            var cell = document.getElementById('dest-cell-' + id);
            if (cell) {
                var folderLabel = resp.folder_path || '/';
                cell.innerHTML =
                    '<div class="dest-info">'
                    + '<span class="badge d-block mb-1" style="background:#e8f5e9; color:#2e7d32; font-size:.75rem; padding:3px 7px; border-radius:4px;">'
                    + '<i class="fas fa-book mr-1"></i>' + escHtml(resp.course_title)
                    + (resp.session_name ? ' <span style="opacity:.75;">· '+escHtml(resp.session_name)+'</span>' : '')
                    + '</span>'
                    + '<span class="badge badge-light" style="font-size:.72rem;"><i class="fas fa-folder mr-1"></i><code>' + escHtml(folderLabel) + '</code></span>'
                    + '</div>';
            }

            // Update the button data attributes
            var setBtn = document.querySelector('#res-row-'+id+' .btn-set-dest');
            if (setBtn) {
                setBtn.setAttribute('data-course',   resp.course_code);
                setBtn.setAttribute('data-session',  resp.session_id);
                setBtn.setAttribute('data-folder',   resp.folder_path);
            }

            $('#modalSetDest').modal('hide');
        });
    });

    // =====================================================================
    // New folder (from set-destination modal)
    // =====================================================================
    document.getElementById('btnDestNewFolder').addEventListener('click', function() {
        document.getElementById('newFolderName').value = '';
        document.getElementById('folderAlert').style.display = 'none';
        $('#modalNewFolder').modal('show');
    });

    document.getElementById('btnConfirmNewFolder').addEventListener('click', function() {
        var folderName = document.getElementById('newFolderName').value.trim();
        var parentPath = document.getElementById('newFolderParent').value;
        var courseCode = document.getElementById('destCourseSelect').value;
        var sessionId  = document.getElementById('destSessionSelect').value;
        if (!folderName) { showAlert('folderAlert', 'Escribe el nombre.'); return; }
        if (!courseCode) { showAlert('folderAlert', 'Primero selecciona un curso.'); return; }

        ajaxPost({action:'create_folder', classroom_id:CLASSROOM, course_code:courseCode,
                  session_id:sessionId, folder_name:folderName, parent_path:parentPath}, function(resp) {
            if (!resp.success) { showAlert('folderAlert', resp.error||'Error al crear carpeta.'); return; }
            $('#modalNewFolder').modal('hide');
            loadDestFolders(courseCode, sessionId, resp.path);
        });
    });

    // =====================================================================
    // Bulk distribute
    // =====================================================================
    document.getElementById('btnDistributeSelected').addEventListener('click', function() {
        var ids = getCheckedIds();
        if (ids.length === 0) return;

        // Build preview list
        var previewHtml = '<ul class="list-group list-group-flush">';
        var noDestCount = 0;
        ids.forEach(function(id) {
            var titleEl = document.getElementById('title-text-' + id);
            var title   = titleEl ? titleEl.textContent : 'ID ' + id;
            var cell    = document.getElementById('dest-cell-' + id);
            var hasDest = cell && cell.querySelector('.dest-info');
            if (!hasDest) noDestCount++;
            previewHtml += '<li class="list-group-item py-2 px-3 d-flex align-items-center justify-content-between" style="font-size:.85rem;">'
                + '<span>' + escHtml(title) + '</span>'
                + (hasDest
                    ? '<span class="badge badge-success"><i class="fas fa-check mr-1"></i>Con destino</span>'
                    : '<span class="badge badge-warning"><i class="fas fa-exclamation mr-1"></i>Sin destino</span>')
                + '</li>';
        });
        previewHtml += '</ul>';

        document.getElementById('distributePreviewList').innerHTML = previewHtml;

        var warnEl = document.getElementById('distributeWarning');
        if (noDestCount > 0) {
            warnEl.style.display = '';
            warnEl.textContent = noDestCount + ' archivo(s) no tienen destino configurado y serán omitidos.';
        } else {
            warnEl.style.display = 'none';
        }

        document.getElementById('btnConfirmDistribute').setAttribute('data-ids', ids.join(','));
        $('#modalConfirmDistribute').modal('show');
    });

    document.getElementById('btnConfirmDistribute').addEventListener('click', function() {
        var ids = this.getAttribute('data-ids');
        var btn = this; btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin mr-1"></i>Distribuyendo…';

        ajaxPost({action:'distribute_selected', classroom_id:CLASSROOM, resource_ids:ids}, function(resp) {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-paper-plane mr-1"></i>Distribuir';
            $('#modalConfirmDistribute').modal('hide');

            if (!resp.success) { alert('Error: ' + (resp.error||'desconocido')); return; }

            // Build results
            var html = '<ul class="list-group list-group-flush">';
            (resp.results||[]).forEach(function(r) {
                if (r.success) {
                    html += '<li class="list-group-item py-2 px-3" style="font-size:.85rem;">'
                        + '<i class="fas fa-check-circle text-success mr-2"></i><strong>' + escHtml(r.title) + '</strong>'
                        + ' → ' + escHtml(r.course_title)
                        + (r.session_name ? ' · ' + escHtml(r.session_name) : '')
                        + ' <code class="ml-1">' + escHtml(r.folder_path) + '</code></li>';
                    // Remove row from table
                    var row = document.getElementById('res-row-' + r.resource_id);
                    if (row) row.remove();
                    updateCount(-1);
                } else {
                    html += '<li class="list-group-item py-2 px-3" style="font-size:.85rem;">'
                        + '<i class="fas fa-times-circle text-danger mr-2"></i><strong>' + escHtml(r.title||'ID '+r.resource_id) + '</strong>'
                        + ' — ' + escHtml(r.error) + '</li>';
                }
            });
            html += '</ul>';
            document.getElementById('distributeResultsList').innerHTML = html;
            $('#modalDistributeResults').modal('show');

            // Uncheck all and refresh button
            document.querySelectorAll('.res-checkbox').forEach(function(cb){ cb.checked=false; });
            document.getElementById('chkAll').checked = false;
            refreshDistributeBtn();
        });
    });

    // =====================================================================
    // Rename inline
    // =====================================================================
    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-rename-start');
        if (!btn) return;
        enterRenameMode(btn.getAttribute('data-id'));
    });

    function enterRenameMode(id) {
        document.getElementById('title-text-'+id).style.display = 'none';
        var inp = document.getElementById('title-input-'+id);
        inp.style.removeProperty('display'); inp.style.display = 'inline-block';
        document.getElementById('title-actions-'+id).classList.remove('d-none');
        inp.focus(); inp.select();
    }

    function exitRenameMode(id, newTitle) {
        var inp = document.getElementById('title-input-'+id);
        inp.style.display = '';
        document.getElementById('title-text-'+id).style.display = '';
        if (newTitle !== undefined) document.getElementById('title-text-'+id).textContent = newTitle;
        document.getElementById('title-actions-'+id).classList.add('d-none');
    }

    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-rename-save');
        if (!btn) return;
        var id = btn.getAttribute('data-id');
        var newTitle = document.getElementById('title-input-'+id).value.trim();
        if (!newTitle) return;
        ajaxPost({action:'rename_resource', resource_id:id, classroom_id:CLASSROOM, title:newTitle}, function(resp) {
            if (!resp.success) { alert('Error: '+(resp.error||'No se pudo renombrar')); return; }
            exitRenameMode(id, resp.title);
            var small = document.querySelector('#res-row-'+id+' small.text-muted');
            if (small) small.textContent = resp.filename;
            var link = document.querySelector('#res-row-'+id+' a[target="_blank"]');
            if (link) link.href = resp.web_url;
        });
    });

    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-rename-cancel');
        if (!btn) return;
        var id = btn.getAttribute('data-id');
        document.getElementById('title-input-'+id).value = document.getElementById('title-text-'+id).textContent;
        exitRenameMode(id);
    });

    document.addEventListener('keydown', function(e) {
        if (!e.target.classList.contains('res-title-input')) return;
        var id = e.target.id.replace('title-input-', '');
        if (e.key === 'Enter')  { e.preventDefault(); document.querySelector('.btn-rename-save[data-id="'+id+'"]').click(); }
        if (e.key === 'Escape') { document.querySelector('.btn-rename-cancel[data-id="'+id+'"]').click(); }
    });

    // =====================================================================
    // Delete
    // =====================================================================
    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-delete-resource');
        if (!btn) return;
        var id = btn.getAttribute('data-id'), title = btn.getAttribute('data-title');
        if (!confirm('¿Eliminar "' + title + '"?')) return;
        ajaxPost({action:'delete_resource', resource_id:id, classroom_id:CLASSROOM}, function(resp) {
            if (!resp.success) { alert('Error: '+(resp.error||'desconocido')); return; }
            var row = document.getElementById('res-row-'+id);
            if (row) row.remove();
            updateCount(-1);
        });
    });

    // =====================================================================
    // Utilities
    // =====================================================================
    function updateCount(delta) {
        var el = document.getElementById('resourceCount');
        el.textContent = parseInt(el.textContent||'0') + delta;
    }

    function ajaxPost(data, cb) {
        var fd = new FormData();
        Object.keys(data).forEach(function(k){ fd.append(k, data[k]); });
        var xhr = new XMLHttpRequest();
        xhr.open('POST', AJAX_URL, true);
        xhr.onload  = function(){ var r; try{r=JSON.parse(xhr.responseText);}catch(e){r={success:false,error:'Respuesta inválida'};} cb(r); };
        xhr.onerror = function(){ cb({success:false, error:'Error de red'}); };
        xhr.send(fd);
    }

    function ajaxGet(params, cb) {
        var url = AJAX_URL + '?' + Object.keys(params).map(function(k){ return encodeURIComponent(k)+'='+encodeURIComponent(params[k]); }).join('&');
        var xhr = new XMLHttpRequest();
        xhr.open('GET', url, true);
        xhr.onload  = function(){ var r; try{r=JSON.parse(xhr.responseText);}catch(e){r={success:false,error:'Respuesta inválida'};} cb(r); };
        xhr.onerror = function(){ cb({success:false,error:'Error de red'}); };
        xhr.send();
    }

    function showAlert(id, msg) { var el=document.getElementById(id); el.textContent=msg; el.style.display=''; }

    function escHtml(str) {
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }
}());
</script>
