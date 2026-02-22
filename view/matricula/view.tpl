<!-- Toolbar -->
<div class="d-flex justify-content-between align-items-center mb-3 no-print">
    <a href="{{ _p.web }}matricula" class="btn btn-secondary btn-sm">
        <i class="fas fa-arrow-left"></i> {{ 'BackToList'|get_plugin_lang('SchoolPlugin') }}
    </a>
    <div>
        {% if (is_admin or is_secretary) and not matricula.user_id %}
        <button type="button" id="btn-crear-usuario" class="btn btn-success btn-sm mr-1"
                data-id="{{ matricula.id }}"
                title="Crear cuenta de alumno inactiva en Chamilo">
            <i class="fas fa-user-plus"></i> Crear usuario Chamilo
        </button>
        {% endif %}
        {% if (is_admin or is_secretary) and matricula.user_id %}
        <span class="badge badge-success mr-2 align-middle">
            <i class="fas fa-user-check"></i> {{ linked_user_name }}
        </span>
        {% endif %}
        <a href="{{ _p.web }}matricula/editar?id={{ matricula.id }}" class="btn btn-warning btn-sm mr-1">
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
        <small class="text-muted">
            {% if matricula.tipo_ingreso == 'NUEVO_INGRESO' %}
                <span class="badge badge-success">NUEVO INGRESO</span>
            {% else %}
                <span class="badge badge-info">REINGRESO</span>
            {% endif %}
        </small>
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
                        <td>{% if matricula.level_name %}{{ matricula.level_name }} — {% endif %}{{ matricula.grade_name ?: '—' }}</td>
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

        <div class="row mt-5 no-print">
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

<style>
@media print {
    .no-print, .sidebar, nav, .topbar, footer { display: none !important; }
    #ficha-matricula { border: none !important; box-shadow: none !important; }
    .card-header { background: none !important; color: #000 !important; }
}
</style>

<script>
(function() {
    var btn = document.getElementById('btn-crear-usuario');
    if (!btn) return;

    btn.addEventListener('click', function() {
        if (!confirm('¿Crear cuenta de usuario Chamilo para este alumno?\n\nEl usuario quedará INACTIVO hasta que la secretaría lo active.')) return;

        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creando...';

        $.post('{{ ajax_url }}', {
            action: 'crear_usuario_chamilo',
            matricula_id: btn.dataset.id
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
</script>
