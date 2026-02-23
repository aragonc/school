{# Template: student_documents.tpl #}
{# Vista optimizada de documentos para estudiantes - Twig Template #}
<div class="card">
    <div class="card-body p-0 p-md-0 p-lg-3">
<div class="student-documents-container">

    {# Breadcrumb de navegación #}
    <div class="breadcrumb-container">
        <ol class="breadcrumb">
            {% for crumb in data.breadcrumb %}
            {% if crumb.active %}
            <li class="active">{{ crumb.name }}</li>
            {% else %}
            <li><a href="{{ crumb.url }}">{{ crumb.name }}</a></li>
            {% endif %}
            {% endfor %}
        </ol>
    </div>

    {# Barra de acciones #}
    <div class="documents-toolbar">
        <div class="row">
            <div class="col-md-12">
                {% if data.parent_id %}
                <a href="{{ data.base_url }}&id={{ data.parent_id }}" class="btn btn-default">
                    <i class="fa fa-level-up"></i> {{ 'Up'|get_lang }}
                </a>
                {% endif %}

                {% if data.can_download_folders and data.current_document_id %}
                <a href="{{ data.base_url }}&action=downloadfolder&id={{ data.current_document_id }}"
                   class="btn btn-primary">
                    <i class="fa fa-download"></i> {{ 'DownloadFolder'|get_plugin_lang('SchoolPlugin') }}
                </a>
                {% endif %}
            </div>
        </div>
    </div>

    {# Lista de documentos #}
    <div class="documents-list">
        {% if data.documents|length > 0 %}
        <div class="table-responsive">
            <table class="table table-hover table-striped">
                <thead>
                <tr>
                    <th width="50">{{ 'Type'|get_lang }}</th>
                    <th>{{ 'Name'|get_lang }}</th>
                    <th width="120" class="d-none d-md-table-cell">{{ 'Size'|get_lang }}</th>
                    <th width="100" class="text-center">{{ 'Actions'|get_lang }}</th>
                </tr>
                </thead>
                <tbody>
                {% for doc in data.documents %}
                <tr class="{% if not doc.is_visible %}muted{% endif %}">
                    {# Icono del tipo #}
                    <td class="text-center">
                        {% if doc.is_folder %}
                        <i class="fa fa-folder" style="font-size: 24px; color: #FFA500;"></i>
                        {% elseif doc.filetype == 'link' %}
                        <i class="fa fa-link" style="font-size: 24px; color: #2196F3;"></i>
                        {% else %}
                        {% set icon_class = '' %}
                        {% set icon_color = '#607D8B' %}

                        {% if doc.extension in ['pdf'] %}
                        {% set icon_class = 'fa-file-pdf' %}
                        {% set icon_color = '#F40F02' %}
                        {% elseif doc.extension in ['doc', 'docx', 'odt'] %}
                        {% set icon_class = 'fa-file-word' %}
                        {% set icon_color = '#2B579A' %}
                        {% elseif doc.extension in ['xls', 'xlsx', 'ods', 'csv'] %}
                        {% set icon_class = 'fa-file-excel' %}
                        {% set icon_color = '#217346' %}
                        {% elseif doc.extension in ['ppt', 'pptx', 'odp'] %}
                        {% set icon_class = 'fa-file-powerpoint' %}
                        {% set icon_color = '#D24726' %}
                        {% elseif doc.extension in ['zip', 'rar', '7z', 'tar', 'gz'] %}
                        {% set icon_class = 'fa-file-archive' %}
                        {% set icon_color = '#795548' %}
                        {% elseif doc.extension in ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg'] %}
                        {% set icon_class = 'fa-file-image' %}
                        {% set icon_color = '#9C27B0' %}
                        {% elseif doc.extension in ['mp4', 'avi', 'mov', 'wmv', 'mkv', 'webm'] %}
                        {% set icon_class = 'fa-file-video' %}
                        {% set icon_color = '#FF5722' %}
                        {% elseif doc.extension in ['mp3', 'wav', 'ogg', 'm4a', 'flac'] %}
                        {% set icon_class = 'fa-file-audio' %}
                        {% set icon_color = '#00BCD4' %}
                        {% elseif doc.extension in ['html', 'htm', 'php', 'js', 'css', 'xml', 'json', 'sql'] %}
                        {% set icon_class = 'fa-file-code' %}
                        {% set icon_color = '#4CAF50' %}
                        {% elseif doc.extension in ['txt', 'md', 'rtf'] %}
                        {% set icon_class = 'fa-file-text' %}
                        {% set icon_color = '#607D8B' %}
                        {% else %}
                        {% set icon_class = 'fa-file' %}
                        {% set icon_color = '#607D8B' %}
                        {% endif %}

                        <i class="fa {{ icon_class }}" style="font-size: 24px; color: {{ icon_color }};"></i>
                        {% endif %}
                    </td>

                    {# Nombre con link #}
                    <td>
                        {% if doc.is_folder %}
                        <a href="{{ data.base_url }}&id={{ doc.id }}" class="document-link folder-link">
                            <strong>{{ doc.title }}</strong>
                        </a>
                        {% else %}
                        <a href="{{ doc.url }}"
                           target="_blank"
                           class="document-link file-link">
                            {{ doc.title }}
                        </a>
                        {% endif %}

                        {% if doc.session_img is defined %}
                        {{ doc.session_img|raw }}
                        {% endif %}

                        {% if doc.comment %}
                        <br>
                        <small class="text-muted">
                            <em>{{ doc.comment|nl2br }}</em>
                        </small>
                        {% endif %}
                    </td>

                    {# Tamaño #}
                    <td class="d-none d-md-table-cell">
                        {% if doc.is_folder %}
                        <span class="folder-size"
                              data-id="{{ doc.id }}"
                              data-path="{{ doc.path }}">
                                            <i class="fa fa-spinner fa-spin"></i>
                                        </span>
                        {% else %}
                        {{ doc.size_formatted }}
                        {% endif %}
                    </td>

                    {# Acciones #}
                    <td class="text-center">
                        {% if not doc.is_folder %}
                        <a href="{{ doc.download_url }}"
                           class="btn btn-sm btn-default"
                           title="{{ 'Download'|get_lang }}">
                            <i class="fa fa-download"></i>
                        </a>

                        <a href="{{ doc.url }}"
                           target="_blank"
                           class="btn btn-sm btn-primary"
                           title="{{ 'View'|get_lang }}">
                            <i class="fa fa-eye"></i>
                        </a>
                        {% else %}
                        <a href="{{ data.base_url }}&id={{ doc.id }}"
                           class="btn btn-sm btn-primary"
                           title="{{ 'Open'|get_lang }}">
                            <i class="fa fa-folder-open"></i>
                        </a>
                        {% endif %}
                    </td>
                </tr>
                {% endfor %}
                </tbody>
            </table>
        </div>

        {# Estadísticas #}
        <div class="documents-stats">
            <small class="text-muted">
                {{ 'Total'|get_lang }}: {{ data.documents|length }} {{ 'Documents'|get_lang|lower }}
            </small>
        </div>
        {% else %}
        <div class="alert alert-info">
            <i class="fa fa-info-circle"></i>
            {% if data.has_search %}
            {{ 'NoSearchResults'|get_lang }}
            {% else %}
            {{ 'NoDocsInFolder'|get_lang }}
            {% endif %}
        </div>
        {% endif %}
    </div>

</div>
    </div>
</div>
{# CSS personalizado #}
<style>
    .student-documents-container {
        padding: 20px 0;
    }

    .documents-toolbar {
        margin-bottom: 20px;
        padding: 15px;
        border-radius: 4px;
    }

    .documents-list .table > tbody > tr > td {
        vertical-align: middle;
    }

    .document-link {
        font-size: 14px;
    }

    .document-link.folder-link {
        color: #337ab7;
        font-weight: 500;
    }

    .document-link.folder-link:hover {
        color: #23527c;
        text-decoration: none;
    }

    .document-link.file-link {
        color: #333;
    }

    .document-link.file-link:hover {
        color: #337ab7;
    }

    .documents-stats {
        padding: 10px 0;
        border-top: 1px solid #ddd;
        margin-top: 10px;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .documents-toolbar .col-md-6 {
            margin-bottom: 10px;
        }

        .documents-toolbar .pull-right {
            float: none !important;
        }

        .table td {
            font-size: 12px;
        }
    }
</style>

{# JavaScript para cargar tamaños de carpetas #}
<script>
    $(document).ready(function() {
        // Cargar tamaños de carpetas
        $('.folder-size').each(function() {
            var $elem = $(this);
            var docId = $elem.data('id');
            var docPath = $elem.data('path');

            $.ajax({
                url: '{{ _p.web_ajax }}document.ajax.php',
                data: {
                    a: 'get_dir_size',
                    path: docPath,
                    cidReq: '{{ data.course_info.code }}',
                    id_session: '{{ data.session_id }}',
                    gidReq: '{{ data.group_id }}'
                },
                success: function(data) {
                    $elem.html(data);
                },
                error: function() {
                    $elem.html('<span class="text-muted">-</span>');
                }
            });
        });
    });
</script>