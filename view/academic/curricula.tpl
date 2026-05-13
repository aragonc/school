{% include 'academic/tabs.tpl' with {'active_tab': 'curricula', 'is_admin': true} %}

{# Macro reutilizable para el accordion de áreas #}
{% macro areaAccordion(areas, ajaxUrl, labelComp, labelCap, labelNoItems, labelEdit, labelAdd, labelDelete, labelConfirm, labelRequired, labelEditComp, labelAddComp, labelEditCap, labelAddCap) %}
{% for area in areas %}
<div class="border-bottom" id="area-row-{{ area.id }}">
    <div class="d-flex justify-content-between align-items-center px-3 py-2 bg-light">
        <div class="d-flex align-items-center">
            <button class="btn btn-link btn-sm text-dark p-0 mr-2" type="button"
                    data-toggle="collapse" data-target="#area-detail-{{ area.id }}" aria-expanded="false">
                <i class="fas fa-chevron-right fa-xs toggle-icon"></i>
            </button>
            <strong>{{ area.name }}</strong>
            {% if area.level == 'primaria' %}<span class="badge badge-info ml-2">Solo Primaria</span>
            {% elseif area.level == 'secundaria' %}<span class="badge badge-warning ml-2">Solo Secundaria</span>
            {% elseif area.level == 'inicial' %}<span class="badge badge-success ml-2">Inicial</span>
            {% else %}<span class="badge badge-secondary ml-2">Primaria y Secundaria</span>{% endif %}
        </div>
        <div>
            <button class="btn btn-warning btn-sm" onclick="openAreaModal({{ area.id }}, {{ area|json_encode|e('html_attr') }})"><i class="fas fa-edit"></i></button>
            <button class="btn btn-danger btn-sm" onclick="deleteArea({{ area.id }})"><i class="fas fa-trash"></i></button>
        </div>
    </div>
    <div class="collapse" id="area-detail-{{ area.id }}">
        <div class="px-4 py-3">
            <div class="row">
                <div class="col-md-6">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <strong><i class="fas fa-star text-warning"></i> {{ 'Competencias'|get_plugin_lang('SchoolPlugin') }}</strong>
                        <button class="btn btn-outline-primary btn-sm" onclick="openItemModal('competencia', 0, {{ area.id }})"><i class="fas fa-plus"></i></button>
                    </div>
                    <ul class="list-group list-group-flush" id="competencias-{{ area.id }}">
                        {% for comp in area.competencias %}
                        <li class="list-group-item d-flex justify-content-between align-items-center py-1 px-2" id="competencia-{{ comp.id }}">
                            <span><i class="fas fa-circle fa-xs text-warning mr-1"></i> {{ comp.name }}</span>
                            <div class="btn-group btn-group-sm">
                                <button class="btn btn-outline-warning btn-sm" onclick="openItemModal('competencia', {{ comp.id }}, {{ area.id }}, {{ comp|json_encode|e('html_attr') }})"><i class="fas fa-edit fa-xs"></i></button>
                                <button class="btn btn-outline-danger btn-sm" onclick="deleteItem('competencia', {{ comp.id }})"><i class="fas fa-trash fa-xs"></i></button>
                            </div>
                        </li>
                        {% else %}
                        <li class="list-group-item text-muted py-1 px-2 small">{{ 'NoItems'|get_plugin_lang('SchoolPlugin') }}</li>
                        {% endfor %}
                    </ul>
                </div>
                <div class="col-md-6">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <strong><i class="fas fa-check-circle text-success"></i> {{ 'Capacidades'|get_plugin_lang('SchoolPlugin') }}</strong>
                        <button class="btn btn-outline-success btn-sm" onclick="openItemModal('capacidad', 0, {{ area.id }})"><i class="fas fa-plus"></i></button>
                    </div>
                    <ul class="list-group list-group-flush" id="capacidades-{{ area.id }}">
                        {% for cap in area.capacidades %}
                        <li class="list-group-item d-flex justify-content-between align-items-center py-1 px-2" id="capacidad-{{ cap.id }}">
                            <span><i class="fas fa-circle fa-xs text-success mr-1"></i> {{ cap.name }}</span>
                            <div class="btn-group btn-group-sm">
                                <button class="btn btn-outline-warning btn-sm" onclick="openItemModal('capacidad', {{ cap.id }}, {{ area.id }}, {{ cap|json_encode|e('html_attr') }})"><i class="fas fa-edit fa-xs"></i></button>
                                <button class="btn btn-outline-danger btn-sm" onclick="deleteItem('capacidad', {{ cap.id }})"><i class="fas fa-trash fa-xs"></i></button>
                            </div>
                        </li>
                        {% else %}
                        <li class="list-group-item text-muted py-1 px-2 small">{{ 'NoItems'|get_plugin_lang('SchoolPlugin') }}</li>
                        {% endfor %}
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
{% else %}
<p class="text-muted p-3">{{ 'NoAreas'|get_plugin_lang('SchoolPlugin') }}</p>
{% endfor %}
{% endmacro %}

{# Macro para competencias transversales #}
{% macro transversalSection(transversales) %}
{% for t in transversales %}
<div class="border-bottom" id="transversal-row-{{ t.id }}">
    <div class="d-flex justify-content-between align-items-center px-3 py-2 bg-light">
        <div class="d-flex align-items-center">
            <button class="btn btn-link btn-sm text-dark p-0 mr-2" type="button"
                    data-toggle="collapse" data-target="#transversal-detail-{{ t.id }}" aria-expanded="false">
                <i class="fas fa-chevron-right fa-xs toggle-icon"></i>
            </button>
            <strong>{{ loop.index }}. {{ t.name }}</strong>
        </div>
        <div>
            <button class="btn btn-warning btn-sm" onclick="openTransversalModal({{ t.id }}, {{ t|json_encode|e('html_attr') }})"><i class="fas fa-edit"></i></button>
            <button class="btn btn-danger btn-sm" onclick="deleteTransversal({{ t.id }})"><i class="fas fa-trash"></i></button>
        </div>
    </div>
    <div class="collapse" id="transversal-detail-{{ t.id }}">
        <div class="px-4 py-3">
            <div class="d-flex justify-content-between align-items-center mb-2">
                <strong><i class="fas fa-check-circle text-info"></i> {{ 'Capacidades'|get_plugin_lang('SchoolPlugin') }}</strong>
                <button class="btn btn-outline-info btn-sm" onclick="openTransversalCapModal(0, {{ t.id }})"><i class="fas fa-plus"></i></button>
            </div>
            <ul class="list-group list-group-flush" id="transversal-caps-{{ t.id }}">
                {% for cap in t.capacidades %}
                <li class="list-group-item d-flex justify-content-between align-items-center py-1 px-2" id="transversal-cap-{{ cap.id }}">
                    <span><i class="fas fa-circle fa-xs text-info mr-1"></i> {{ cap.name }}</span>
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-outline-warning btn-sm" onclick="openTransversalCapModal({{ cap.id }}, {{ t.id }}, {{ cap|json_encode|e('html_attr') }})"><i class="fas fa-edit fa-xs"></i></button>
                        <button class="btn btn-outline-danger btn-sm" onclick="deleteTransversalCap({{ cap.id }})"><i class="fas fa-trash fa-xs"></i></button>
                    </div>
                </li>
                {% else %}
                <li class="list-group-item text-muted py-1 px-2 small">{{ 'NoItems'|get_plugin_lang('SchoolPlugin') }}</li>
                {% endfor %}
            </ul>
        </div>
    </div>
</div>
{% else %}
<p class="text-muted p-3">{{ 'NoTransversales'|get_plugin_lang('SchoolPlugin') }}</p>
{% endfor %}
{% endmacro %}

{# Macro para sección de enfoques con valores #}
{% macro enfoqueSection(enfoques, level, ajaxUrl) %}
{% if enfoques %}
<div class="list-group list-group-flush">
{% for e in enfoques %}
<div class="list-group-item px-3 py-2" id="enfoque-row-{{ e.id }}">
    <div class="d-flex justify-content-between align-items-center">
        <div>
            <strong class="small">{{ loop.index }}. {{ e.name }}</strong>
            {% if e.valores %}
            <span class="badge badge-light border ml-2">{{ e.valores|length }} valores</span>
            {% endif %}
        </div>
        <div class="btn-group btn-group-sm">
            <button class="btn btn-outline-success btn-sm" title="Añadir valor"
                    onclick="openValorModal({{ e.id }}, 0, null)">
                <i class="fas fa-plus fa-xs"></i> Valor
            </button>
            <button class="btn btn-outline-warning btn-sm" title="Editar enfoque"
                    onclick="openEnfoqueModal({{ e.id }}, {{ e|json_encode|e('html_attr') }}, '{{ level }}')">
                <i class="fas fa-edit fa-xs"></i>
            </button>
            <button class="btn btn-outline-danger btn-sm" title="Eliminar enfoque"
                    onclick="deleteEnfoque({{ e.id }})">
                <i class="fas fa-trash fa-xs"></i>
            </button>
        </div>
    </div>
    {% if e.valores %}
    <div class="pl-3 mt-1" id="valores-list-{{ e.id }}">
        {% for v in e.valores %}
        <div class="d-flex justify-content-between align-items-center border-bottom py-1" id="valor-row-{{ v.id }}">
            <span class="small text-secondary"><i class="fas fa-circle fa-xs mr-1 text-success"></i>{{ v.name }}</span>
            <div class="btn-group btn-group-sm">
                <button class="btn btn-outline-warning btn-sm btn-xs" onclick="openValorModal({{ e.id }}, {{ v.id }}, {{ v|json_encode|e('html_attr') }})">
                    <i class="fas fa-edit fa-xs"></i>
                </button>
                <button class="btn btn-outline-danger btn-sm btn-xs" onclick="deleteValor({{ v.id }})">
                    <i class="fas fa-times fa-xs"></i>
                </button>
            </div>
        </div>
        {% endfor %}
    </div>
    {% else %}
    <div class="pl-3 mt-1" id="valores-list-{{ e.id }}">
        <small class="text-muted">Sin valores definidos. <a href="#" onclick="openValorModal({{ e.id }},0,null);return false;">Añadir valor</a></small>
    </div>
    {% endif %}
</div>
{% endfor %}
</div>
{% else %}
<p class="text-muted p-3 small">No hay enfoques definidos.</p>
{% endif %}
{% endmacro %}

{% import _self as self %}

<!-- Tabs de nivel -->
<ul class="nav nav-pills mb-4" id="levelTabs" role="tablist">
    <li class="nav-item">
        <a class="nav-link active" id="tab-inicial" data-toggle="pill" href="#panel-inicial" role="tab">
            <i class="fas fa-child"></i> {{ 'LevelInicial'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link" id="tab-ebr" data-toggle="pill" href="#panel-ebr" role="tab">
            <i class="fas fa-school"></i> {{ 'LevelEBR'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>

<div class="tab-content">

<!-- ============================================================ -->
<!-- PANEL INICIAL                                                 -->
<!-- ============================================================ -->
<div class="tab-pane fade show active" id="panel-inicial" role="tabpanel">

    <!-- Áreas Inicial -->
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <strong><i class="fas fa-layer-group"></i> {{ 'CurricularAreasInicial'|get_plugin_lang('SchoolPlugin') }}</strong>
            <button class="btn btn-primary btn-sm" onclick="openAreaModal(0, null, 'inicial')">
                <i class="fas fa-plus"></i> {{ 'AddArea'|get_plugin_lang('SchoolPlugin') }}
            </button>
        </div>
        <div class="card-body p-0">
            {{ self.areaAccordion(areas_by_level.inicial ?? []) }}
        </div>
    </div>

    <!-- Competencias Transversales Inicial -->
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <strong><i class="fas fa-exchange-alt"></i> {{ 'TransversalCompetencies'|get_plugin_lang('SchoolPlugin') }}</strong>
            <button class="btn btn-primary btn-sm" onclick="openTransversalModal(0, null, 'inicial')">
                <i class="fas fa-plus"></i> {{ 'Add'|get_plugin_lang('SchoolPlugin') }}
            </button>
        </div>
        <div class="card-body p-0">
            {{ self.transversalSection(transversales_ini) }}
        </div>
    </div>

    <!-- Enfoques Transversales Inicial -->
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <strong><i class="fas fa-compass"></i> {{ 'TransversalApproaches'|get_plugin_lang('SchoolPlugin') }}</strong>
            <button class="btn btn-primary btn-sm" onclick="openEnfoqueModal(0, null, 'inicial')">
                <i class="fas fa-plus"></i> {{ 'Add'|get_plugin_lang('SchoolPlugin') }}
            </button>
        </div>
        <div class="card-body p-0">
            {{ _self.enfoqueSection(enfoques_ini, 'inicial', ajax_url) }}
        </div>
    </div>

</div><!-- /panel-inicial -->

<!-- ============================================================ -->
<!-- PANEL EBR (Primaria + Secundaria)                            -->
<!-- ============================================================ -->
<div class="tab-pane fade" id="panel-ebr" role="tabpanel">

    <!-- Áreas EBR: Primaria y Secundaria juntas, Primaria sola, Secundaria sola -->
    {% set levelGroups = [
        {key: 'ambos',      label: 'Primaria y Secundaria', badge: 'secondary'},
        {key: 'primaria',   label: 'Solo Primaria',         badge: 'info'},
        {key: 'secundaria', label: 'Solo Secundaria',       badge: 'warning'}
    ] %}

    {% for grp in levelGroups %}
    {% if areas_by_level[grp.key] is defined and areas_by_level[grp.key]|length > 0 %}
    <div class="card mb-3">
        <div class="card-header d-flex justify-content-between align-items-center py-2">
            <span><i class="fas fa-layer-group"></i> <strong>{{ grp.label }}</strong>
                <span class="badge badge-{{ grp.badge }} ml-1">{{ areas_by_level[grp.key]|length }}</span>
            </span>
            <button class="btn btn-primary btn-sm" onclick="openAreaModal(0, null, '{{ grp.key }}')">
                <i class="fas fa-plus"></i> {{ 'AddArea'|get_plugin_lang('SchoolPlugin') }}
            </button>
        </div>
        <div class="card-body p-0">
            {{ self.areaAccordion(areas_by_level[grp.key]) }}
        </div>
    </div>
    {% endif %}
    {% endfor %}

    <!-- Botón para agregar área EBR si algún grupo no existe aún -->
    <div class="mb-4 text-right">
        <div class="dropdown d-inline">
            <button class="btn btn-outline-primary btn-sm dropdown-toggle" data-toggle="dropdown">
                <i class="fas fa-plus"></i> {{ 'AddArea'|get_plugin_lang('SchoolPlugin') }}
            </button>
            <div class="dropdown-menu dropdown-menu-right">
                <a class="dropdown-item" href="#" onclick="openAreaModal(0, null, 'ambos'); return false;">Primaria y Secundaria</a>
                <a class="dropdown-item" href="#" onclick="openAreaModal(0, null, 'primaria'); return false;">Solo Primaria</a>
                <a class="dropdown-item" href="#" onclick="openAreaModal(0, null, 'secundaria'); return false;">Solo Secundaria</a>
            </div>
        </div>
    </div>

    <!-- Competencias Transversales EBR -->
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <strong><i class="fas fa-exchange-alt"></i> {{ 'TransversalCompetencies'|get_plugin_lang('SchoolPlugin') }}</strong>
            <button class="btn btn-primary btn-sm" onclick="openTransversalModal(0, null, 'ebr')">
                <i class="fas fa-plus"></i> {{ 'Add'|get_plugin_lang('SchoolPlugin') }}
            </button>
        </div>
        <div class="card-body p-0">
            {{ self.transversalSection(transversales_ebr) }}
        </div>
    </div>

    <!-- Enfoques Transversales EBR -->
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <strong><i class="fas fa-compass"></i> {{ 'TransversalApproaches'|get_plugin_lang('SchoolPlugin') }}</strong>
            <button class="btn btn-primary btn-sm" onclick="openEnfoqueModal(0, null, 'ebr')">
                <i class="fas fa-plus"></i> {{ 'Add'|get_plugin_lang('SchoolPlugin') }}
            </button>
        </div>
        <div class="card-body p-0">
            {{ _self.enfoqueSection(enfoques_ebr, 'ebr', ajax_url) }}
        </div>
    </div>

</div><!-- /panel-ebr -->
</div><!-- /tab-content -->

<!-- ============================================================ -->
<!-- MODALS                                                        -->
<!-- ============================================================ -->

<!-- Modal: Área -->
<div class="modal fade" id="areaModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="areaModalTitle">{{ 'AddArea'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="area_id" value="0">
                <input type="hidden" id="area_level_hidden" value="">
                <div class="form-group">
                    <label>{{ 'Name'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" class="form-control" id="area_name" required>
                </div>
                <div class="form-group" id="area_level_group">
                    <label>{{ 'Level'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select class="form-control" id="area_level">
                        <option value="inicial">{{ 'LevelInicial'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="ambos">{{ 'LevelBoth'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="primaria">{{ 'LevelPrimaria'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="secundaria">{{ 'LevelSecundaria'|get_plugin_lang('SchoolPlugin') }}</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveArea()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Competencia / Capacidad de área -->
<div class="modal fade" id="itemModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="itemModalTitle">{{ 'Add'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="item_type" value="">
                <input type="hidden" id="item_id" value="0">
                <input type="hidden" id="item_area_id" value="0">
                <div class="form-group">
                    <label>{{ 'Name'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <textarea class="form-control" id="item_name" rows="3" required></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveItem()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Competencia Transversal -->
<div class="modal fade" id="transversalModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="transversalModalTitle">{{ 'AddTransversal'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="transversal_id" value="0">
                <input type="hidden" id="transversal_level" value="ebr">
                <div class="form-group">
                    <label>{{ 'Name'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <textarea class="form-control" id="transversal_name" rows="3" required></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveTransversal()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Capacidad de Competencia Transversal -->
<div class="modal fade" id="transversalCapModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="transversalCapModalTitle">{{ 'AddCapacidad'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="tcap_id" value="0">
                <input type="hidden" id="tcap_transversal_id" value="0">
                <div class="form-group">
                    <label>{{ 'Name'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <textarea class="form-control" id="tcap_name" rows="2" required></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveTransversalCap()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Enfoque -->
<div class="modal fade" id="enfoqueModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="enfoqueModalTitle">{{ 'AddEnfoque'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="enfoque_id" value="0">
                <input type="hidden" id="enfoque_level" value="ebr">
                <div class="form-group">
                    <label>{{ 'Name'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" class="form-control" id="enfoque_name" required>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Close'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveEnfoque()">{{ 'SaveChanges'|get_plugin_lang('SchoolPlugin') }}</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Valor de Enfoque -->
<div class="modal fade" id="valorModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title" id="valorModalTitle"><i class="fas fa-leaf mr-1"></i> Valor del Enfoque</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="valor_id" value="0">
                <input type="hidden" id="valor_enfoque_id" value="0">
                <div class="form-group">
                    <label class="font-weight-bold">Nombre del valor <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="valor_name"
                           placeholder="Ej: Conciencia de derechos" required>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">Orden</label>
                    <input type="number" class="form-control" id="valor_order" value="0" min="0">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-success" onclick="saveValor()">
                    <i class="fas fa-save mr-1"></i> Guardar
                </button>
            </div>
        </div>
    </div>
</div>

<style>
.toggle-icon { transition: transform .2s; }
[data-toggle="collapse"][aria-expanded="true"] .toggle-icon { transform: rotate(90deg); }
</style>

<script>
var ajaxUrl = '{{ ajax_url }}';

// ---- ÁREAS ----
function openAreaModal(id, data, defaultLevel) {
    document.getElementById('area_id').value = id || 0;
    document.getElementById('area_name').value = data ? data.name : '';
    document.getElementById('area_level').value = data ? data.level : (defaultLevel || 'ambos');
    document.getElementById('areaModalTitle').textContent = id
        ? '{{ 'EditArea'|get_plugin_lang('SchoolPlugin') }}'
        : '{{ 'AddArea'|get_plugin_lang('SchoolPlugin') }}';
    $('#areaModal').modal('show');
}

function saveArea() {
    var name = document.getElementById('area_name').value.trim();
    if (!name) { alert('{{ 'FieldRequired'|get_plugin_lang('SchoolPlugin') }}'); return; }
    var fd = new FormData();
    fd.append('action', 'save_area');
    fd.append('id', document.getElementById('area_id').value);
    fd.append('name', name);
    fd.append('level', document.getElementById('area_level').value);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) location.reload(); else alert(d.message || 'Error'); });
}

function deleteArea(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData();
    fd.append('action', 'delete_area');
    fd.append('id', id);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) document.getElementById('area-row-'+id).remove(); });
}

// ---- COMPETENCIAS / CAPACIDADES ----
function openItemModal(type, id, areaId, data) {
    document.getElementById('item_type').value = type;
    document.getElementById('item_id').value = id || 0;
    document.getElementById('item_area_id').value = areaId;
    document.getElementById('item_name').value = data ? data.name : '';
    var isComp = type === 'competencia';
    document.getElementById('itemModalTitle').textContent = id
        ? (isComp ? '{{ 'EditCompetencia'|get_plugin_lang('SchoolPlugin') }}' : '{{ 'EditCapacidad'|get_plugin_lang('SchoolPlugin') }}')
        : (isComp ? '{{ 'AddCompetencia'|get_plugin_lang('SchoolPlugin') }}' : '{{ 'AddCapacidad'|get_plugin_lang('SchoolPlugin') }}');
    $('#itemModal').modal('show');
}

function saveItem() {
    var name = document.getElementById('item_name').value.trim();
    if (!name) { alert('{{ 'FieldRequired'|get_plugin_lang('SchoolPlugin') }}'); return; }
    var type = document.getElementById('item_type').value;
    var fd = new FormData();
    fd.append('action', 'save_' + type);
    fd.append('id', document.getElementById('item_id').value);
    fd.append('area_id', document.getElementById('item_area_id').value);
    fd.append('name', name);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) location.reload(); else alert(d.message || 'Error'); });
}

function deleteItem(type, id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData();
    fd.append('action', 'delete_' + type);
    fd.append('id', id);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) document.getElementById(type+'-'+id).remove(); });
}

// ---- COMPETENCIAS TRANSVERSALES ----
function openTransversalModal(id, data, level) {
    document.getElementById('transversal_id').value = id || 0;
    document.getElementById('transversal_name').value = data ? data.name : '';
    document.getElementById('transversal_level').value = data ? data.level : (level || 'ebr');
    document.getElementById('transversalModalTitle').textContent = id
        ? '{{ 'EditTransversal'|get_plugin_lang('SchoolPlugin') }}'
        : '{{ 'AddTransversal'|get_plugin_lang('SchoolPlugin') }}';
    $('#transversalModal').modal('show');
}

function saveTransversal() {
    var name = document.getElementById('transversal_name').value.trim();
    if (!name) { alert('{{ 'FieldRequired'|get_plugin_lang('SchoolPlugin') }}'); return; }
    var fd = new FormData();
    fd.append('action', 'save_transversal');
    fd.append('id', document.getElementById('transversal_id').value);
    fd.append('name', name);
    fd.append('level', document.getElementById('transversal_level').value);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) location.reload(); else alert(d.message || 'Error'); });
}

function deleteTransversal(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData();
    fd.append('action', 'delete_transversal');
    fd.append('id', id);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) document.getElementById('transversal-row-'+id).remove(); });
}

// ---- CAPACIDADES TRANSVERSALES ----
function openTransversalCapModal(id, transversalId, data) {
    document.getElementById('tcap_id').value = id || 0;
    document.getElementById('tcap_transversal_id').value = transversalId;
    document.getElementById('tcap_name').value = data ? data.name : '';
    document.getElementById('transversalCapModalTitle').textContent = id
        ? '{{ 'EditCapacidad'|get_plugin_lang('SchoolPlugin') }}'
        : '{{ 'AddCapacidad'|get_plugin_lang('SchoolPlugin') }}';
    $('#transversalCapModal').modal('show');
}

function saveTransversalCap() {
    var name = document.getElementById('tcap_name').value.trim();
    if (!name) { alert('{{ 'FieldRequired'|get_plugin_lang('SchoolPlugin') }}'); return; }
    var fd = new FormData();
    fd.append('action', 'save_transversal_cap');
    fd.append('id', document.getElementById('tcap_id').value);
    fd.append('transversal_id', document.getElementById('tcap_transversal_id').value);
    fd.append('name', name);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) location.reload(); else alert(d.message || 'Error'); });
}

function deleteTransversalCap(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData();
    fd.append('action', 'delete_transversal_cap');
    fd.append('id', id);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) document.getElementById('transversal-cap-'+id).remove(); });
}

// ---- ENFOQUES ----
function openEnfoqueModal(id, data, level) {
    document.getElementById('enfoque_id').value = id || 0;
    document.getElementById('enfoque_name').value = data ? data.name : '';
    document.getElementById('enfoque_level').value = data ? data.level : (level || 'ebr');
    document.getElementById('enfoqueModalTitle').textContent = id
        ? '{{ 'EditEnfoque'|get_plugin_lang('SchoolPlugin') }}'
        : '{{ 'AddEnfoque'|get_plugin_lang('SchoolPlugin') }}';
    $('#enfoqueModal').modal('show');
}

function saveEnfoque() {
    var name = document.getElementById('enfoque_name').value.trim();
    if (!name) { alert('{{ 'FieldRequired'|get_plugin_lang('SchoolPlugin') }}'); return; }
    var fd = new FormData();
    fd.append('action', 'save_enfoque');
    fd.append('id', document.getElementById('enfoque_id').value);
    fd.append('name', name);
    fd.append('level', document.getElementById('enfoque_level').value);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) location.reload(); else alert(d.message || 'Error'); });
}

function deleteEnfoque(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData();
    fd.append('action', 'delete_enfoque');
    fd.append('id', id);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) document.getElementById('enfoque-row-'+id).remove(); });
}

// ---- VALORES DE ENFOQUES ----
function openValorModal(enfoqueId, valorId, data) {
    document.getElementById('valor_enfoque_id').value = enfoqueId;
    document.getElementById('valor_id').value = valorId || 0;
    document.getElementById('valor_name').value = data ? data.name : '';
    document.getElementById('valor_order').value = data ? data.order_index : 0;
    document.getElementById('valorModalTitle').innerHTML = (valorId > 0
        ? '<i class="fas fa-edit mr-1"></i> Editar Valor'
        : '<i class="fas fa-plus-circle mr-1"></i> Nuevo Valor');
    $('#valorModal').modal('show');
}

function saveValor() {
    var name = document.getElementById('valor_name').value.trim();
    if (!name) { alert('El nombre del valor es obligatorio'); return; }
    var fd = new FormData();
    fd.append('action', 'save_enfoque_valor');
    fd.append('id', document.getElementById('valor_id').value);
    fd.append('enfoque_id', document.getElementById('valor_enfoque_id').value);
    fd.append('name', name);
    fd.append('order_index', document.getElementById('valor_order').value);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => {
            if (d.success) { $('#valorModal').modal('hide'); location.reload(); }
            else alert(d.message || 'Error al guardar');
        });
}

function deleteValor(id) {
    if (!confirm('¿Eliminar este valor?')) return;
    var fd = new FormData();
    fd.append('action', 'delete_enfoque_valor');
    fd.append('id', id);
    fetch(ajaxUrl, {method:'POST', body:fd})
        .then(r => r.json())
        .then(d => { if (d.success) document.getElementById('valor-row-'+id).remove(); });
}
</script>
