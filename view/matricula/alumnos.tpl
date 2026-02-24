<div class="card shadow mb-4">
    <div class="card-header py-3 d-flex justify-content-between align-items-center">
        <h6 class="m-0 font-weight-bold text-primary">
            <i class="fas fa-user-graduate mr-1"></i> Alumnos
        </h6>
        <div class="d-flex align-items-center gap-2">
            <span class="badge badge-primary badge-pill">{{ students|length }}</span>
            <button type="button" class="btn btn-sm btn-success ml-2" data-toggle="modal" data-target="#modalNuevoAlumno">
                <i class="fas fa-user-plus mr-1"></i> Nuevo alumno
            </button>
            <a href="{{ _p.web }}matricula/tarjetas-print" target="_blank"
               class="btn btn-sm btn-outline-primary ml-2">
                <i class="fas fa-id-card mr-1"></i> Imprimir tarjetas
            </a>
        </div>
    </div>
    <div class="card-body">

        <form method="get" class="mb-3">
            <div class="input-group" style="max-width:420px;">
                <input type="text" name="search" class="form-control"
                       placeholder="Buscar por nombre, usuario o correo..."
                       value="{{ search }}">
                <div class="input-group-append">
                    <button class="btn btn-primary" type="submit"><i class="fas fa-search"></i></button>
                    {% if search %}
                    <a href="?" class="btn btn-outline-secondary"><i class="fas fa-times"></i></a>
                    {% endif %}
                </div>
            </div>
        </form>

        <div id="toggle-alert" class="alert d-none mb-3" role="alert"></div>

        <div class="table-responsive">
            <table class="table table-bordered table-hover table-sm" id="tabla-alumnos">
                <thead class="thead-light">
                    <tr>
                        <th style="width:56px;" class="text-center">Foto</th>
                        <th>Apellidos y nombres</th>
                        <th>Usuario</th>
                        <th>Correo</th>
                        <th class="text-center" style="width:100px;">Estado</th>
                        <th class="text-center" style="width:220px;">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    {% for s in students %}
                    <tr id="row-{{ s.user_id }}">
                        <td class="text-center p-1">
                            {% if s.avatar %}
                            <img src="{{ s.avatar }}" alt=""
                                 style="width:40px;height:40px;object-fit:cover;border-radius:50%;border:1px solid #dee2e6;">
                            {% else %}
                            <span class="d-inline-flex align-items-center justify-content-center bg-secondary text-white rounded-circle"
                                  style="width:40px;height:40px;font-size:16px;">
                                <i class="fas fa-user"></i>
                            </span>
                            {% endif %}
                        </td>
                        <td class="align-middle">{{ s.lastname }}, {{ s.firstname }}</td>
                        <td class="align-middle"><code>{{ s.username }}</code></td>
                        <td class="align-middle" style="font-size:13px;">{{ s.email }}</td>
                        <td class="text-center align-middle">
                            <button type="button"
                                    class="btn btn-sm btn-toggle-active {% if s.active %}btn-success{% else %}btn-secondary{% endif %}"
                                    data-user-id="{{ s.user_id }}"
                                    data-active="{{ s.active }}"
                                    title="{% if s.active %}Desactivar usuario{% else %}Activar usuario{% endif %}">
                                <i class="fas {% if s.active %}fa-toggle-on{% else %}fa-toggle-off{% endif %}"></i>
                                <span>{% if s.active %}Activo{% else %}Inactivo{% endif %}</span>
                            </button>
                        </td>
                        <td class="text-center align-middle">
                            {% if s.ficha_id %}
                            <a href="{{ view_url }}?ficha_id={{ s.ficha_id }}"
                               class="btn btn-sm btn-info mb-1">
                                <i class="fas fa-eye"></i> Ver ficha
                            </a>
                            {% else %}
                            <a href="{{ form_url }}?user_id={{ s.user_id }}"
                               class="btn btn-sm btn-success mb-1">
                                <i class="fas fa-file-medical"></i> Crear ficha
                            </a>
                            {% endif %}
                            <button type="button"
                                    class="btn btn-sm btn-warning mb-1 btn-tarjeta"
                                    data-matricula-id="{{ s.matricula_id }}"
                                    data-user-id="{{ s.user_id }}">
                                <i class="fas fa-id-card"></i> Tarjeta
                            </button>
                        </td>
                    </tr>
                    {% else %}
                    <tr>
                        <td colspan="6" class="text-center text-muted py-4">
                            No se encontraron alumnos.
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>

    </div>
</div>

{# ===== MODAL TARJETA DE IDENTIFICACIÓN ===== #}
<div class="modal fade" id="modalTarjeta" tabindex="-1" role="dialog">
    <div class="modal-dialog" style="max-width:420px;" role="document">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title font-weight-bold">
                    <i class="fas fa-id-card mr-1"></i> Tarjeta de Identificación
                </h6>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body p-3">
                <div id="tarjeta-loading" class="text-center py-5">
                    <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                </div>
                <div id="tarjeta-contenido" style="display:none;">
                    {# Tarjeta vertical imprimible #}
                    <div id="tarjeta-card" style="
                        width: 100%;
                        background: linear-gradient(160deg, #1a3a6b 0%, #2563aa 55%, #0ea5e9 100%);
                        color: #fff;
                        font-family: Arial, sans-serif;
                        border-radius: 16px;
                        overflow: hidden;
                        position: relative;
                    ">
                        {# Cabecera: logo + institución #}
                        <div style="display:flex; align-items:center; padding:16px 20px 12px; background:rgba(255,255,255,0.12);">
                            <img id="tc-logo" src="{{ logo_url }}" alt="Logo"
                                 style="height:44px; max-width:80px; object-fit:contain; background:#fff; border-radius:6px; padding:3px; margin-right:12px; flex-shrink:0;">
                            <div>
                                <div style="font-size:10px; font-weight:700; letter-spacing:1px; text-transform:uppercase; opacity:.85; line-height:1.3;">{{ institution_name }}</div>
                                <div style="font-size:12px; font-weight:800; letter-spacing:1.5px; line-height:1.3;">TARJETA DE IDENTIFICACIÓN</div>
                            </div>
                        </div>

                        {# Foto centrada #}
                        <div style="text-align:center; padding:20px 20px 12px;">
                            <div style="width:120px; height:150px; background:rgba(255,255,255,0.2); border-radius:10px; overflow:hidden; border:3px solid rgba(255,255,255,0.6); display:inline-block;">
                                <img id="tc-foto" src="" alt="Foto"
                                     style="width:100%; height:100%; object-fit:cover; display:none;">
                                <div id="tc-foto-placeholder" style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;">
                                    <i class="fas fa-user" style="font-size:56px; opacity:.4;"></i>
                                </div>
                            </div>
                        </div>

                        {# Nombre centrado #}
                        <div style="text-align:center; padding:0 20px 16px;">
                            <div style="font-size:9px; opacity:.7; text-transform:uppercase; letter-spacing:1px; margin-bottom:4px;">Apellidos y Nombres</div>
                            <div id="tc-nombre" style="font-size:17px; font-weight:800; line-height:1.3;"></div>
                        </div>

                        {# DNI + Nivel #}
                        <div style="display:flex; margin:0 20px 10px; background:rgba(255,255,255,0.12); border-radius:8px; overflow:hidden;">
                            <div style="flex:1; padding:10px 14px; border-right:1px solid rgba(255,255,255,0.2);">
                                <div style="font-size:9px; opacity:.7; text-transform:uppercase; letter-spacing:1px;">DNI</div>
                                <div id="tc-dni" style="font-size:15px; font-weight:700; letter-spacing:2px;"></div>
                            </div>
                            <div style="flex:1; padding:10px 14px;">
                                <div style="font-size:9px; opacity:.7; text-transform:uppercase; letter-spacing:1px;">Nivel</div>
                                <div id="tc-level" style="font-size:15px; font-weight:700;"></div>
                            </div>
                        </div>

                        {# Grado + Sección #}
                        <div style="display:flex; margin:0 20px 18px; background:rgba(255,255,255,0.12); border-radius:8px; overflow:hidden;">
                            <div style="flex:1; padding:10px 14px; border-right:1px solid rgba(255,255,255,0.2);">
                                <div style="font-size:9px; opacity:.7; text-transform:uppercase; letter-spacing:1px;">Grado</div>
                                <div id="tc-grade" style="font-size:15px; font-weight:700;"></div>
                            </div>
                            <div style="flex:1; padding:10px 14px;">
                                <div style="font-size:9px; opacity:.7; text-transform:uppercase; letter-spacing:1px;">Sección</div>
                                <div id="tc-section" style="font-size:15px; font-weight:700;"></div>
                            </div>
                        </div>

                        {# QR centrado #}
                        <div style="text-align:center; padding:0 20px 18px;">
                            <div id="tc-qr" style="background:#fff; padding:8px; border-radius:8px; display:inline-block;"></div>
                            <div id="tc-email" style="font-size:9px; opacity:.75; margin-top:6px; word-break:break-all;"></div>
                        </div>

                        {# Pie #}
                        <div style="background:rgba(0,0,0,0.25); text-align:center; padding:8px; font-size:9px; letter-spacing:1.5px; opacity:.8;">
                            DOCUMENTO DE IDENTIFICACIÓN ESTUDIANTIL
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer py-2" id="tarjeta-footer" style="display:none!important;">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-dismiss="modal">Cerrar</button>
                <button type="button" class="btn btn-primary btn-sm" id="btn-imprimir-tarjeta">
                    <i class="fas fa-print mr-1"></i> Imprimir
                </button>
            </div>
        </div>
    </div>
</div>


{# ===== MODAL NUEVO ALUMNO ===== #}
<div class="modal fade" id="modalNuevoAlumno" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title font-weight-bold">
                    <i class="fas fa-user-plus mr-1"></i> Nuevo Alumno
                </h6>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <form id="form-nuevo-alumno">
                <div class="modal-body pb-2">
                    <div class="alert alert-danger d-none mb-2" id="nuevo-alumno-error"></div>
                    <div class="form-group mb-2">
                        <label class="font-weight-bold mb-1" style="font-size:13px;">Apellidos <span class="text-danger">*</span></label>
                        <input type="text" id="na-apellidos" class="form-control form-control-sm"
                               placeholder="Apellido paterno y materno" required autocomplete="off">
                    </div>
                    <div class="form-group mb-2">
                        <label class="font-weight-bold mb-1" style="font-size:13px;">Nombres <span class="text-danger">*</span></label>
                        <input type="text" id="na-nombres" class="form-control form-control-sm"
                               placeholder="Nombres completos" required autocomplete="off">
                    </div>
                    <div class="form-group mb-0">
                        <label class="font-weight-bold mb-1" style="font-size:13px;">DNI <span class="text-danger">*</span></label>
                        <input type="text" id="na-dni" class="form-control form-control-sm"
                               placeholder="8 dígitos" maxlength="8" pattern="\d{8}" required autocomplete="off">
                        <small class="text-muted">Usuario: <em>DNI@playschool.edu.pe</em></small>
                    </div>
                </div>
                <div class="modal-footer py-2">
                    <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-success btn-sm" id="btn-guardar-alumno">
                        <i class="fas fa-save mr-1"></i> Guardar y crear ficha
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="{{ qrcode_js }}"></script>
<script>
$(document).ready(function () {

    // DataTable
    if ($.fn.DataTable) {
        $('#tabla-alumnos').DataTable({
            language: { url: '//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json' },
            order: [[1, 'asc']],
            pageLength: 25,
            columnDefs: [{ orderable: false, targets: [0, 4, 5] }]
        });
    }

    // Toggle activo/inactivo
    $(document).on('click', '.btn-toggle-active', function () {
        var btn    = $(this);
        var userId = btn.data('user-id');
        var active = parseInt(btn.data('active'));
        var newVal = active ? 0 : 1;
        btn.prop('disabled', true);
        $.post('{{ ajax_url }}', { action: 'toggle_user_active', user_id: userId, active: newVal }, function (resp) {
            btn.prop('disabled', false);
            if (resp.success) {
                btn.data('active', newVal);
                if (newVal) {
                    btn.removeClass('btn-secondary').addClass('btn-success');
                    btn.find('i').removeClass('fa-toggle-off').addClass('fa-toggle-on');
                    btn.find('span').text('Activo');
                    btn.attr('title', 'Desactivar usuario');
                } else {
                    btn.removeClass('btn-success').addClass('btn-secondary');
                    btn.find('i').removeClass('fa-toggle-on').addClass('fa-toggle-off');
                    btn.find('span').text('Inactivo');
                    btn.attr('title', 'Activar usuario');
                }
                showAlert('success', resp.message || 'Estado actualizado.');
            } else {
                showAlert('danger', resp.error || 'Error al actualizar.');
            }
        }, 'json').fail(function () {
            btn.prop('disabled', false);
            showAlert('danger', 'Error de conexión.');
        });
    });

    // Tarjeta de identificación
    $(document).on('click', '.btn-tarjeta', function () {
        var matriculaId = $(this).data('matricula-id');
        var userId      = $(this).data('user-id');
        $('#tarjeta-loading').show().html('<i class="fas fa-spinner fa-spin fa-2x text-primary"></i>');
        $('#tarjeta-contenido').hide();
        $('#tarjeta-footer').css('display', 'none');
        $('#modalTarjeta').modal('show');

        var params = { action: 'get_tarjeta_data' };
        if (matriculaId) { params.matricula_id = matriculaId; } else { params.user_id = userId; }

        $.get('{{ ajax_url }}', params, function (resp) {
            $('#tarjeta-loading').hide();
            if (!resp.success) {
                $('#tarjeta-loading').html('<p class="text-danger p-3">' + (resp.error || 'Error') + '</p>').show();
                return;
            }

            // Datos
            $('#tc-nombre').text(resp.apellidos + '\n' + resp.nombres);
            $('#tc-nombre').html(resp.apellidos + '<br><span style="font-weight:400;font-size:16px;">' + resp.nombres + '</span>');
            $('#tc-dni').text(resp.dni || '—');
            $('#tc-level').text(resp.level || '—');
            $('#tc-grade').text(resp.grade || '—');
            $('#tc-section').text(resp.section || '—');
            $('#tc-email').text(resp.email || '');

            // Foto
            if (resp.foto_url) {
                $('#tc-foto').attr('src', resp.foto_url).show();
                $('#tc-foto-placeholder').hide();
            } else {
                $('#tc-foto').hide();
                $('#tc-foto-placeholder').show();
            }

            // QR
            $('#tc-qr').empty();
            if (resp.email) {
                new QRCode(document.getElementById('tc-qr'), {
                    text: resp.email,
                    width: 98,
                    height: 98,
                    colorDark: '#1a3a6b',
                    colorLight: '#ffffff',
                    correctLevel: QRCode.CorrectLevel.M
                });
            }

            $('#tarjeta-contenido').show();
            $('#tarjeta-footer').css('display', 'flex');
        }, 'json').fail(function () {
            $('#tarjeta-loading').html('<p class="text-danger p-3">Error de conexión.</p>').show();
        });
    });

    // Imprimir tarjeta (ventana separada para evitar imprimir toda la página)
    $('#btn-imprimir-tarjeta').on('click', function () {
        var cardHtml = document.getElementById('tarjeta-card').outerHTML;
        var w = window.open('', '_blank');
        w.document.write([
            '<!DOCTYPE html><html><head>',
            '<meta charset="utf-8">',
            '<title>Tarjeta de Identificación</title>',
            '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">',
            '<style>',
            '* { box-sizing: border-box; }',
            '@page { size: A4 portrait; margin: 0; }',
            'html { margin: 0; padding: 0; background: #fff; }',
            'body {',
            '  margin: 0; padding: 0;',
            '  width: 21cm; height: 29.7cm;',
            '  display: flex; align-items: center; justify-content: center;',
            '  background: #fff;',
            '}',
            '#tarjeta-card {',
            '  width: 9cm !important;',
            '  border-radius: 12px !important;',
            '  -webkit-print-color-adjust: exact;',
            '  print-color-adjust: exact;',
            '}',
            '</style>',
            '</head><body>',
            cardHtml,
            '<script>',
            'window.addEventListener("load", function () {',
            '  setTimeout(function () { window.print(); window.close(); }, 400);',
            '});',
            '<\/script>',
            '</body></html>'
        ].join(''));
        w.document.close();
    });

    function showAlert(type, msg) {
        var $a = $('#toggle-alert');
        $a.removeClass('d-none alert-success alert-danger').addClass('alert-' + type).text(msg);
        setTimeout(function () { $a.addClass('d-none'); }, 3000);
    }

    // === Nuevo alumno ===
    $('#form-nuevo-alumno').on('submit', function (e) {
        e.preventDefault();
        var $btn = $('#btn-guardar-alumno');
        var $err = $('#nuevo-alumno-error');
        $err.addClass('d-none').text('');
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Guardando...');

        $.post('{{ ajax_url }}', {
            action   : 'crear_alumno_nuevo',
            apellidos: $('#na-apellidos').val(),
            nombres  : $('#na-nombres').val(),
            dni      : $('#na-dni').val()
        }, function (resp) {
            $btn.prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar y crear ficha');
            if (resp.success) {
                $('#modalNuevoAlumno').modal('hide');
                window.location.href = resp.form_url;
            } else {
                $err.removeClass('d-none').text(resp.error || 'Error al crear el usuario.');
            }
        }, 'json').fail(function () {
            $btn.prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Guardar y crear ficha');
            $err.removeClass('d-none').text('Error de conexión.');
        });
    });

    $('#modalNuevoAlumno').on('hidden.bs.modal', function () {
        $('#form-nuevo-alumno')[0].reset();
        $('#nuevo-alumno-error').addClass('d-none').text('');
    });
});
</script>
