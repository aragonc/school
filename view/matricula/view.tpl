<!-- Toolbar -->
<div class="d-flex justify-content-between align-items-center mb-3 no-print">
    <a href="{{ _p.web }}matricula" class="btn btn-secondary btn-sm">
        <i class="fas fa-arrow-left"></i> {{ 'BackToList'|get_plugin_lang('SchoolPlugin') }}
    </a>
    <div>
        {% if (is_admin or is_secretary) and not matricula.user_id %}
        <button type="button" id="btn-crear-usuario" class="btn btn-success btn-sm mr-1"
                data-ficha-id="{{ ficha_id }}"
                title="Crear cuenta de alumno inactiva en Chamilo">
            <i class="fas fa-user-plus"></i> Crear usuario Chamilo
        </button>
        {% endif %}
        {% if (is_admin or is_secretary) and matricula.user_id %}
        <span class="badge badge-success mr-2 align-middle">
            <i class="fas fa-user-check"></i> {{ linked_user_name }}
        </span>
        {% endif %}
        <button type="button" class="btn btn-primary btn-sm mr-1"
                data-toggle="modal" data-target="#modalAsignarMatricula">
            <i class="fas fa-graduation-cap"></i> Asignar Matrícula
        </button>
        <a href="{{ _p.web }}matricula/editar?ficha_id={{ ficha_id }}" class="btn btn-warning btn-sm mr-1">
            <i class="fas fa-edit"></i> {{ 'Edit'|get_plugin_lang('SchoolPlugin') }}
        </a>
        <button onclick="window.print()" class="btn btn-outline-secondary btn-sm">
            <i class="fas fa-print"></i> {{ 'Print'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
</div>

{# Alerta resultado crear usuario #}
<div id="crear-usuario-result" class="no-print" style="display:none;"></div>

<!-- FICHA DE MATRÍCULA -->
<div class="card" id="ficha-matricula">
    <div class="card-header text-center py-3">
        <h5 class="mb-0 font-weight-bold">FICHA DE MATRÍCULA</h5>
        {% if historial|length > 0 %}
        <small class="text-muted">
            {% set lastMat = historial[0] %}
            {% if lastMat.academic_year_name %}<span class="badge badge-secondary">{{ lastMat.academic_year_name }}</span> {% endif %}
            {% if lastMat.tipo_ingreso == 'NUEVO_INGRESO' %}<span class="badge badge-success">NUEVO INGRESO</span>
            {% elseif lastMat.tipo_ingreso == 'REINGRESO' %}<span class="badge badge-warning">REINGRESO</span>
            {% else %}<span class="badge badge-info">CONTINUACIÓN</span>{% endif %}
            {% if lastMat.estado == 'RETIRADO' %}<span class="badge badge-danger ml-1">RETIRADO</span>{% endif %}
        </small>
        {% endif %}
    </div>
    <div class="card-body">

        {# ===== DATOS DEL ESTUDIANTE ===== #}
        <h6 class="title-form border-bottom pb-2 mb-3"><i class="fas fa-user-graduate mr-1"></i> {{ 'StudentData'|get_plugin_lang('SchoolPlugin') }}</h6>
        <div class="row mb-3">
            <div class="col-md-5">
                <table class="table table-sm table-borderless mb-0">
                    <tr>
                        <td class="font-weight-bold" width="45%">{{ 'ApellidoPaterno'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{{ matricula.apellido_paterno ?: '—' }}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'ApellidoMaterno'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{{ matricula.apellido_materno ?: '—' }}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'Nombres'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{{ matricula.nombres ?: '—' }}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'Grade'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{% if matricula.level_name %}{{ matricula.level_name }} — {% endif %}{{ matricula.grade_name ?: '—' }}{% if matricula.section_name %} / Sección {{ matricula.section_name }}{% endif %}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'Sexo'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{% if matricula.sexo == 'F' %}Femenino{% elseif matricula.sexo == 'M' %}Masculino{% else %}—{% endif %}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">
                            {% if matricula.nacionalidad == 'Extranjera' %}
                                {{ 'TipoDocumento'|get_plugin_lang('SchoolPlugin') }}:
                            {% else %}
                                {{ 'Dni'|get_plugin_lang('SchoolPlugin') }}:
                            {% endif %}
                        </td>
                        <td>
                            {% if matricula.nacionalidad == 'Extranjera' and matricula.tipo_documento %}
                                {% if matricula.tipo_documento == 'CARNET_EXTRANJERIA' %}{{ 'CarnetExtranjeria'|get_plugin_lang('SchoolPlugin') }}
                                {% elseif matricula.tipo_documento == 'PASAPORTE' %}{{ 'Pasaporte'|get_plugin_lang('SchoolPlugin') }}
                                {% elseif matricula.tipo_documento == 'OTRO' %}{{ 'Otro'|get_plugin_lang('SchoolPlugin') }}
                                {% else %}{{ matricula.tipo_documento }}{% endif %}
                                {% if matricula.dni %} — {{ matricula.dni }}{% endif %}
                            {% else %}
                                {{ matricula.dni ?: '—' }}
                            {% endif %}
                        </td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'TipoSangre'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{{ matricula.tipo_sangre ?: '—' }}</td>
                    </tr>
                </table>
            </div>
            <div class="col-md-5">
                <table class="table table-sm table-borderless mb-0">
                    <tr>
                        <td class="font-weight-bold" width="45%">{{ 'FechaNacimiento'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{% if matricula.fecha_nacimiento %}{{ matricula.fecha_nacimiento|date('d/m/Y') }} <small class="text-muted">({{ edad }})</small>{% else %}—{% endif %}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'Nacionalidad'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{{ matricula.nacionalidad ?: '—' }}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'Peso'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{% if matricula.peso %}{{ matricula.peso }} kg{% else %}—{% endif %}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'Estatura'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{% if matricula.estatura %}{{ matricula.estatura }} m{% else %}—{% endif %}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'Domicilio'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{{ matricula.domicilio ?: '—' }}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'Region'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{{ matricula.region_name ?: (matricula.region ?: '—') }}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'Province'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{{ matricula.provincia_name ?: (matricula.provincia ?: '—') }}</td>
                    </tr>
                    <tr>
                        <td class="font-weight-bold">{{ 'District'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{{ matricula.distrito_name ?: (matricula.distrito ?: '—') }}</td>
                    </tr>
                </table>
            </div>
            <div class="col-md-2 text-center">
                {% if foto_url %}
                <img src="{{ foto_url }}" alt="Foto del alumno"
                     style="width:110px; height:135px; object-fit:cover; border:2px solid #dee2e6; border-radius:4px;">
                {% else %}
                <div style="width:110px; height:135px; border:2px dashed #dee2e6; border-radius:4px; display:flex; flex-direction:column; align-items:center; justify-content:center; color:#adb5bd; margin:0 auto;">
                    <i class="fas fa-user" style="font-size:2.5rem;"></i>
                    <small style="font-size:11px; margin-top:4px;">Sin foto</small>
                </div>
                {% endif %}
            </div>
        </div>

        {# Salud #}
        <div class="row mb-3">
            <div class="col-md-4">
                <span class="font-weight-bold">{{ 'TieneAlergias'|get_plugin_lang('SchoolPlugin') }}:</span>
                {% if matricula.tiene_alergias %}
                    <span class="badge badge-warning">Sí</span>
                    {% if matricula.alergias_detalle %} — {{ matricula.alergias_detalle }}{% endif %}
                {% else %}<span class="badge badge-secondary">No</span>{% endif %}
            </div>
            <div class="col-md-4">
                <span class="font-weight-bold">{{ 'UsaLentes'|get_plugin_lang('SchoolPlugin') }}:</span>
                {% if matricula.usa_lentes %}<span class="badge badge-warning">Sí</span>{% else %}<span class="badge badge-secondary">No</span>{% endif %}
            </div>
            <div class="col-md-4">
                <span class="font-weight-bold">{{ 'TieneDiscapacidad'|get_plugin_lang('SchoolPlugin') }}:</span>
                {% if matricula.tiene_discapacidad %}
                    <span class="badge badge-warning">Sí</span>
                    {% if matricula.discapacidad_detalle %} — {{ matricula.discapacidad_detalle }}{% endif %}
                {% else %}<span class="badge badge-secondary">No</span>{% endif %}
            </div>
        </div>

        {% if matricula.ie_procedencia or matricula.motivo_traslado %}
        <div class="row mb-3">
            {% if matricula.ie_procedencia %}
            <div class="col-md-6">
                <span class="font-weight-bold">{{ 'IeProcedencia'|get_plugin_lang('SchoolPlugin') }}:</span> {{ matricula.ie_procedencia }}
            </div>
            {% endif %}
            {% if matricula.motivo_traslado %}
            <div class="col-md-6">
                <span class="font-weight-bold">{{ 'MotivoTraslado'|get_plugin_lang('SchoolPlugin') }}:</span> {{ matricula.motivo_traslado }}
            </div>
            {% endif %}
        </div>
        {% endif %}

        {# ===== PADRES ===== #}
        <h6 class="title-form border-bottom pb-2 mb-3 mt-4"><i class="fas fa-users mr-1"></i> {{ 'ParentsData'|get_plugin_lang('SchoolPlugin') }}</h6>
        <div class="row mb-3">
            <div class="col-md-6">
                <strong class="d-block mb-2">{{ 'MadreData'|get_plugin_lang('SchoolPlugin') }}</strong>
                {% if madre %}
                <table class="table table-sm table-borderless mb-0">
                    <tr><td width="45%" class="font-weight-bold">Apellidos y Nombres:</td><td>{{ madre.apellidos }} {{ madre.nombres }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'Dni'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ madre.dni ?: '—' }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'Celular'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ madre.celular ?: '—' }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'Ocupacion'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ madre.ocupacion ?: '—' }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'Edad'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ madre.edad ? madre.edad ~ ' años' : '—' }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'Religion'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ madre.religion ?: '—' }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'TipoParto'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ madre.tipo_parto ?: '—' }}</td></tr>
                </table>
                {% else %}<p class="text-muted">—</p>{% endif %}
            </div>
            <div class="col-md-6">
                <strong class="d-block mb-2">{{ 'PadreData'|get_plugin_lang('SchoolPlugin') }}</strong>
                {% if padre %}
                <table class="table table-sm table-borderless mb-0">
                    <tr><td width="45%" class="font-weight-bold">Apellidos y Nombres:</td><td>{{ padre.apellidos }} {{ padre.nombres }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'Dni'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ padre.dni ?: '—' }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'Celular'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ padre.celular ?: '—' }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'Ocupacion'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ padre.ocupacion ?: '—' }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'Edad'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ padre.edad ? padre.edad ~ ' años' : '—' }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'Religion'|get_plugin_lang('SchoolPlugin') }}:</td><td>{{ padre.religion ?: '—' }}</td></tr>
                    <tr><td class="font-weight-bold">{{ 'ViveConMenor'|get_plugin_lang('SchoolPlugin') }}:</td>
                        <td>{% if padre.vive_con_menor is not null %}{% if padre.vive_con_menor %}Sí{% else %}No{% endif %}{% else %}—{% endif %}</td>
                    </tr>
                </table>
                {% else %}<p class="text-muted">—</p>{% endif %}
            </div>
        </div>

        {# ===== CONTACTO DE EMERGENCIA ===== #}
        {% if contactos|length > 0 %}
        <h6 class="title-form border-bottom pb-2 mb-3 mt-4"><i class="fas fa-phone-alt mr-1"></i> {{ 'EmergencyContact'|get_plugin_lang('SchoolPlugin') }}</h6>
        <div class="row mb-3">
            {% for c in contactos %}
            <div class="col-md-4"><span class="font-weight-bold">{{ 'NombreContacto'|get_plugin_lang('SchoolPlugin') }}:</span> {{ c.nombre_contacto ?: '—' }}</div>
            <div class="col-md-4"><span class="font-weight-bold">{{ 'Telefono'|get_plugin_lang('SchoolPlugin') }}:</span> {{ c.telefono ?: '—' }}</div>
            <div class="col-md-4"><span class="font-weight-bold">{{ 'Direccion'|get_plugin_lang('SchoolPlugin') }}:</span> {{ c.direccion ?: '—' }}</div>
            {% endfor %}
        </div>
        {% endif %}

        {# ===== INFO ADICIONAL ===== #}
        {% if info %}
        <h6 class="title-form border-bottom pb-2 mb-3 mt-4"><i class="fas fa-info-circle mr-1"></i> {{ 'AdditionalInfo'|get_plugin_lang('SchoolPlugin') }}</h6>
        <div class="row">
            {% if info.encargados_cuidado %}
            <div class="col-md-6 mb-2"><span class="font-weight-bold">{{ 'EncargadosCuidado'|get_plugin_lang('SchoolPlugin') }}:</span> {{ info.encargados_cuidado }}</div>
            {% endif %}
            {% if info.familiar_en_institucion %}
            <div class="col-md-6 mb-2"><span class="font-weight-bold">{{ 'FamiliarEnInstitucion'|get_plugin_lang('SchoolPlugin') }}:</span> {{ info.familiar_en_institucion }}</div>
            {% endif %}
            {% if info.observaciones %}
            <div class="col-12"><span class="font-weight-bold">{{ 'Observaciones'|get_plugin_lang('SchoolPlugin') }}:</span> {{ info.observaciones }}</div>
            {% endif %}
        </div>
        {% endif %}

        <div class="row mt-5 firmas-row">
            <div class="col-md-4 text-center">
                <div style="border-top:1px solid #333; width:200px; margin:0 auto;"></div>
                <small class="text-muted">Firma del padre / tutor</small>
            </div>
            <div class="col-md-4 text-center">
                <div style="border-top:1px solid #333; width:200px; margin:0 auto;"></div>
                <small class="text-muted">Firma de la madre / tutora</small>
            </div>
            <div class="col-md-4 text-center">
                <div style="border-top:1px solid #333; width:200px; margin:0 auto;"></div>
                <small class="text-muted">Sello y firma del director</small>
            </div>
        </div>

    </div>
    <div class="card-footer text-muted text-right">
        <small>Registrado: {{ matricula.created_at|date('d/m/Y H:i') }}</small>
        {% if matricula.updated_at %} · <small>Actualizado: {{ matricula.updated_at|date('d/m/Y H:i') }}</small>{% endif %}
    </div>
</div>

{# ============================================================ #}
{# HISTORIAL DE MATRÍCULAS                                      #}
{# ============================================================ #}
<div class="card mt-4 no-print">
    <div class="card-header d-flex justify-content-between align-items-center py-2">
        <span><i class="fas fa-history mr-1"></i> Historial de Matrículas</span>
        <button type="button" class="btn btn-success btn-sm"
                data-toggle="modal" data-target="#modalAsignarMatricula"
                id="btn-nueva-matricula">
            <i class="fas fa-plus"></i> Asignar Matrícula
        </button>
    </div>
    <div class="card-body p-0">
        {% if historial is empty %}
        <p class="text-muted text-center my-3">Sin matrículas asignadas aún.</p>
        {% else %}
        <table class="table table-sm table-hover mb-0">
            <thead class="thead-light">
                <tr>
                    <th>Año</th>
                    <th>Nivel / Grado</th>
                    <th>Sección</th>
                    <th>Tipo</th>
                    <th>Estado</th>
                    <th>Registrado</th>
                    <th class="text-center" style="width:90px;">Acción</th>
                </tr>
            </thead>
            <tbody>
                {% for m in historial %}
                <tr>
                    <td>{{ m.academic_year_name ?: '—' }}</td>
                    <td>{% if m.level_name %}{{ m.level_name }} — {% endif %}{{ m.grade_name ?: '—' }}</td>
                    <td>{{ m.section_name ?: '—' }}</td>
                    <td>
                        {% if m.tipo_ingreso == 'NUEVO_INGRESO' %}<span class="badge badge-success">Nuevo</span>
                        {% elseif m.tipo_ingreso == 'REINGRESO' %}<span class="badge badge-warning">Reingreso</span>
                        {% else %}<span class="badge badge-info">Continuación</span>{% endif %}
                    </td>
                    <td>
                        {% if m.estado == 'ACTIVO' %}<span class="badge badge-success">Activo</span>
                        {% else %}<span class="badge badge-danger">Retirado</span>{% endif %}
                    </td>
                    <td>{{ m.created_at|date('d/m/Y') }}</td>
                    <td class="text-center">
                        <button class="btn btn-xs btn-outline-warning btn-editar-mat"
                                data-id="{{ m.id }}"
                                data-year="{{ m.academic_year_id }}"
                                data-level="{{ m.level_id }}"
                                data-grade="{{ m.grade_id }}"
                                data-section="{{ m.section_id }}"
                                data-tipo="{{ m.tipo_ingreso }}"
                                data-estado="{{ m.estado }}"
                                title="Editar matrícula">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-xs btn-outline-danger btn-delete-mat ml-1"
                                data-id="{{ m.id }}"
                                title="Eliminar matrícula">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
        {% endif %}
    </div>
</div>

{# ============================================================ #}
{# MODAL: Asignar / Editar Matrícula Anual                      #}
{# ============================================================ #}
<div class="modal fade" id="modalAsignarMatricula" tabindex="-1" role="dialog"
     aria-labelledby="modalAsignarMatriculaLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalAsignarMatriculaLabel">
                    <i class="fas fa-graduation-cap mr-1"></i> Asignar Matrícula
                </h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="modal-mat-id" value="0">
                <div class="form-group">
                    <label class="font-weight-bold">Año Académico</label>
                    <select class="form-control" id="modal-year">
                        <option value="">— Seleccione —</option>
                        {% for y in all_years %}
                        <option value="{{ y.id }}" {{ active_year_id == y.id ? 'selected' : '' }}>
                            {{ y.name }}{% if y.active %} ★{% endif %}
                        </option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">Nivel</label>
                    <select class="form-control" id="modal-level">
                        <option value="">— Seleccione Nivel —</option>
                        {% for level in levels %}
                        <option value="{{ level.id }}">{{ level.name }}</option>
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">Grado</label>
                    <select class="form-control" id="modal-grade" disabled>
                        <option value="">— Seleccione Grado —</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">Sección</label>
                    <select class="form-control" id="modal-section" disabled>
                        <option value="">— Seleccione Sección —</option>
                    </select>
                </div>
                <div id="modal-aula-info" class="alert alert-info py-2" style="display:none; font-size:13px;"></div>
                <div class="form-group">
                    <label class="font-weight-bold">Tipo de Ingreso</label>
                    <select class="form-control" id="modal-tipo-ingreso">
                        <option value="NUEVO_INGRESO">Nuevo Ingreso</option>
                        <option value="REINGRESO">Reingreso</option>
                        <option value="CONTINUACION" selected>Continuación</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="font-weight-bold">Estado</label>
                    <select class="form-control" id="modal-estado">
                        <option value="ACTIVO" selected>Activo</option>
                        <option value="RETIRADO">Retirado</option>
                    </select>
                </div>
                <div id="modal-error" class="alert alert-danger" style="display:none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btn-guardar-matricula">
                    <i class="fas fa-save"></i> Guardar
                </button>
            </div>
        </div>
    </div>
</div>

<style>
@media print {
    @page { size: A4 portrait; margin: 1.5cm 1.5cm 2cm; }

    /* Ocultar todo el layout de Chamilo */
    .no-print,
    .sidebar, .sidebar-wrapper, .side-nav,
    nav, .navbar, .navbar-default,
    header, .header, #top-bar, .topbar,
    footer, .footer,
    .breadcrumb, .subnav,
    .modal, .modal-backdrop,
    .btn, button,
    .card-footer { display: none !important; }

    /* Reset del contenedor principal */
    html, body {
        background: #fff !important;
        font-size: 10pt !important;
        color: #000 !important;
        margin: 0 !important;
        padding: 0 !important;
    }

    /* Quitar padding/margin del wrapper de Chamilo */
    #main, .main-content, .content-wrapper,
    .container-fluid, .container,
    .page-content, .wrapper, #content {
        padding: 0 !important;
        margin: 0 !important;
        width: 100% !important;
        max-width: 100% !important;
        float: none !important;
    }

    /* Ficha */
    #ficha-matricula {
        border: 1px solid #aaa !important;
        box-shadow: none !important;
        width: 100% !important;
        page-break-inside: avoid;
    }
    .card-header {
        background: #e8e8e8 !important;
        color: #000 !important;
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
        padding: 8px 12px !important;
    }
    .card-body {
        padding: 10px 14px !important;
    }

    /* Grilla Bootstrap para impresión */
    .row { display: flex !important; flex-wrap: wrap !important; margin: 0 !important; }
    .col-md-2  { flex: 0 0 16.66% !important; max-width: 16.66% !important; padding: 0 6px !important; }
    .col-md-4  { flex: 0 0 33.33% !important; max-width: 33.33% !important; padding: 0 6px !important; }
    .col-md-5  { flex: 0 0 41.66% !important; max-width: 41.66% !important; padding: 0 6px !important; }
    .col-md-6  { flex: 0 0 50%     !important; max-width: 50%     !important; padding: 0 6px !important; }
    .col-12,
    .col-md-12 { flex: 0 0 100%    !important; max-width: 100%    !important; padding: 0 6px !important; }

    /* Tablas */
    .table { width: 100% !important; border-collapse: collapse !important; }
    .table td, .table th {
        padding: 3px 5px !important;
        font-size: 9pt !important;
        border: none !important;
    }
    .font-weight-bold { font-weight: 700 !important; }

    /* Títulos de sección */
    h6.title-form {
        font-size: 10pt !important;
        font-weight: 700 !important;
        border-bottom: 1pt solid #555 !important;
        margin-top: 10px !important;
        margin-bottom: 6px !important;
        page-break-after: avoid !important;
    }

    /* Badges */
    .badge {
        border: 1px solid #666 !important;
        background: #eee !important;
        color: #000 !important;
        padding: 1px 4px !important;
        font-size: 8pt !important;
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
    }

    /* Foto del alumno */
    .col-md-2 img {
        width: 90px !important;
        height: 110px !important;
        object-fit: cover !important;
        border: 1px solid #aaa !important;
    }

    /* Líneas de firma — mostrar en impresión */
    .firmas-row {
        display: flex !important;
        margin-top: 30px !important;
        page-break-inside: avoid !important;
    }
    .firmas-row .text-muted { color: #333 !important; font-size: 8pt !important; }

    /* Evitar saltos de página dentro de secciones */
    .card-body > .row,
    .card-body > .mb-3 { page-break-inside: avoid !important; }

    /* Iconos FontAwesome: ocultar en impresión para limpiar el documento */
    .fas, .far, .fab { display: none !important; }
}
</style>

<script>
// --- Crear usuario Chamilo ---
(function() {
    var btn = document.getElementById('btn-crear-usuario');
    if (!btn) return;

    btn.addEventListener('click', function() {
        if (!confirm('¿Crear cuenta de usuario Chamilo para este alumno?\n\nEl usuario quedará INACTIVO hasta que la secretaría lo active.')) return;

        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creando...';

        $.post('{{ ajax_url }}', {
            action: 'crear_usuario_chamilo',
            ficha_id: btn.dataset.fichaId
        })
        .done(function(resp) {
            var area = document.getElementById('crear-usuario-result');
            if (resp.success) {
                area.innerHTML =
                    '<div class="alert alert-success">' +
                    '<i class="fas fa-check-circle mr-2"></i>' +
                    '<strong>Usuario creado correctamente.</strong> ' +
                    'Usuario: <strong>' + resp.username + '</strong> — ' +
                    'Contraseña inicial: <strong>' + resp.password + '</strong> ' +
                    '<small class="text-muted">(el alumno deberá cambiarla al primer ingreso)</small>' +
                    '</div>';
                area.style.display = '';
                btn.style.display = 'none';
            } else {
                area.innerHTML = '<div class="alert alert-danger"><i class="fas fa-times-circle mr-2"></i>' + (resp.message || 'Error al crear el usuario.') + '</div>';
                area.style.display = '';
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-user-plus"></i> Crear usuario Chamilo';
            }
        })
        .fail(function() {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-user-plus"></i> Crear usuario Chamilo';
            alert('Error de conexión al crear el usuario.');
        });
    });
})();

// --- Modal Asignar Matrícula ---
(function() {
    var ajaxUrl = '{{ ajax_url }}';
    var fichaId = {{ ficha_id }};

    var selYear    = document.getElementById('modal-year');
    var selLevel   = document.getElementById('modal-level');
    var selGrade   = document.getElementById('modal-grade');
    var selSection = document.getElementById('modal-section');
    var aulaInfo   = document.getElementById('modal-aula-info');

    function resetGrade() {
        selGrade.innerHTML = '<option value="">— Seleccione Grado —</option>';
        selGrade.disabled = true;
        resetSection();
    }

    function resetSection() {
        selSection.innerHTML = '<option value="">— Seleccione Sección —</option>';
        selSection.disabled = true;
        aulaInfo.style.display = 'none';
        aulaInfo.innerHTML = '';
    }

    function loadGrades(levelId, selectedGradeId, selectedSectionId) {
        if (!levelId) { resetGrade(); return; }
        $.get(ajaxUrl, { action: 'get_grades_by_level', level_id: levelId })
        .done(function(resp) {
            selGrade.innerHTML = '<option value="">— Seleccione Grado —</option>';
            if (resp.success && resp.grades.length) {
                resp.grades.forEach(function(g) {
                    var opt = document.createElement('option');
                    opt.value = g.id;
                    opt.textContent = g.name;
                    if (selectedGradeId && parseInt(selectedGradeId) === parseInt(g.id)) {
                        opt.selected = true;
                    }
                    selGrade.appendChild(opt);
                });
                selGrade.disabled = false;
                if (selectedGradeId) {
                    loadSections(selYear.value, selectedGradeId, selectedSectionId || null);
                }
            }
        });
    }

    function loadSections(yearId, gradeId, selectedSectionId) {
        resetSection();
        if (!yearId || !gradeId) return;
        $.get(ajaxUrl, { action: 'get_sections_by_grade', academic_year_id: yearId, grade_id: gradeId })
        .done(function(resp) {
            selSection.innerHTML = '<option value="">— Seleccione Sección —</option>';
            if (resp.success && resp.sections.length) {
                resp.sections.forEach(function(s) {
                    var opt = document.createElement('option');
                    opt.value = s.section_id;
                    opt.dataset.classroomId  = s.classroom_id;
                    opt.dataset.capacity     = s.capacity;
                    opt.dataset.studentCount = s.student_count;
                    opt.dataset.tutorName    = s.tutor_name;
                    opt.textContent = 'Sección ' + s.section_name;
                    if (selectedSectionId && parseInt(selectedSectionId) === parseInt(s.section_id)) {
                        opt.selected = true;
                    }
                    selSection.appendChild(opt);
                });
                selSection.disabled = false;
                if (selectedSectionId) {
                    showAulaInfo();
                }
            }
        });
    }

    function showAulaInfo() {
        var opt = selSection.options[selSection.selectedIndex];
        if (!opt || !opt.value) { aulaInfo.style.display = 'none'; return; }
        var parts = [];
        if (opt.dataset.tutorName) parts.push('<i class="fas fa-chalkboard-teacher mr-1"></i> Tutor: <strong>' + opt.dataset.tutorName + '</strong>');
        parts.push('<i class="fas fa-users mr-1"></i> Alumnos: <strong>' + opt.dataset.studentCount + ' / ' + opt.dataset.capacity + '</strong>');
        aulaInfo.innerHTML = parts.join(' &nbsp;|&nbsp; ');
        aulaInfo.style.display = '';
    }

    // Cascading selects
    selLevel.addEventListener('change', function() {
        resetGrade();
        loadGrades(this.value, null, null);
    });

    selGrade.addEventListener('change', function() {
        resetSection();
        loadSections(selYear.value, this.value, null);
    });

    selYear.addEventListener('change', function() {
        resetSection();
        if (selGrade.value) {
            loadSections(this.value, selGrade.value, null);
        }
    });

    selSection.addEventListener('change', showAulaInfo);

    // Abrir modal en modo "nuevo"
    document.getElementById('btn-nueva-matricula').addEventListener('click', function() {
        document.getElementById('modal-mat-id').value = 0;
        document.getElementById('modalAsignarMatriculaLabel').innerHTML =
            '<i class="fas fa-graduation-cap mr-1"></i> Asignar Matrícula';
        selLevel.value = '';
        resetGrade();
        document.getElementById('modal-tipo-ingreso').value = 'CONTINUACION';
        document.getElementById('modal-estado').value = 'ACTIVO';
        document.getElementById('modal-error').style.display = 'none';
    });

    // Abrir modal en modo "editar" desde botones de la tabla
    document.querySelectorAll('.btn-editar-mat').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var matId      = btn.dataset.id;
            var levelId    = btn.dataset.level  || '';
            var gradeId    = btn.dataset.grade  || '';
            var sectionId  = btn.dataset.section || '';

            document.getElementById('modal-mat-id').value = matId;
            document.getElementById('modalAsignarMatriculaLabel').innerHTML =
                '<i class="fas fa-graduation-cap mr-1"></i> Editar Matrícula';
            selYear.value  = btn.dataset.year || '';

            // Pre-load cascading selects
            selLevel.value = levelId;
            resetGrade();
            if (levelId) {
                loadGrades(levelId, gradeId, sectionId);
            }

            document.getElementById('modal-tipo-ingreso').value = btn.dataset.tipo || 'CONTINUACION';
            document.getElementById('modal-estado').value      = btn.dataset.estado || 'ACTIVO';
            document.getElementById('modal-error').style.display = 'none';
            $('#modalAsignarMatricula').modal('show');
        });
    });

    // Guardar matrícula
    document.getElementById('btn-guardar-matricula').addEventListener('click', function() {
        var btn     = this;
        var matId   = document.getElementById('modal-mat-id').value;
        var errDiv  = document.getElementById('modal-error');

        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Guardando...';
        errDiv.style.display = 'none';

        $.post(ajaxUrl, {
            action:           'save_matricula_anual',
            ficha_id:         fichaId,
            mat_id:           matId,
            academic_year_id: selYear.value,
            grade_id:         selGrade.value,
            section_id:       selSection.value,
            tipo_ingreso:     document.getElementById('modal-tipo-ingreso').value,
            estado:           document.getElementById('modal-estado').value
        })
        .done(function(resp) {
            if (resp.success) {
                if (resp.warning) {
                    alert('Matrícula guardada.\n\nAviso: ' + resp.warning);
                }
                location.reload();
            } else {
                errDiv.textContent = resp.message || 'Error al guardar la matrícula.';
                errDiv.style.display = '';
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-save"></i> Guardar';
            }
        })
        .fail(function() {
            errDiv.textContent = 'Error de conexión.';
            errDiv.style.display = '';
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-save"></i> Guardar';
        });
    });

    // Eliminar matrícula
    document.querySelectorAll('.btn-delete-mat').forEach(function(btn) {
        btn.addEventListener('click', function() {
            if (!confirm('¿Eliminar este registro de matrícula?\n\nLa ficha del alumno no se eliminará.')) return;
            $.post(ajaxUrl, { action: 'delete_matricula', id: btn.dataset.id })
             .done(function(resp) {
                if (resp.success) {
                    location.reload();
                } else {
                    alert(resp.message || 'Error al eliminar.');
                }
             });
        });
    });
})();
</script>
