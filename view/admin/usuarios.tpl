<div class="card shadow mb-4">
    <div class="card-header py-3 d-flex justify-content-between align-items-center">
        <h6 class="m-0 font-weight-bold text-primary">
            <i class="fas fa-users mr-1"></i> Usuarios
            <span class="badge badge-primary badge-pill ml-1">{{ users|length }}</span>
        </h6>
        <a href="{{ _p.web }}admin/tarjetas-print" target="_blank" class="btn btn-sm btn-outline-primary">
            <i class="fas fa-print mr-1"></i> Imprimir tarjetas
        </a>
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
            <table class="table table-bordered table-hover table-sm" id="tabla-usuarios">
                <thead class="thead-light">
                    <tr>
                        <th style="width:56px;" class="text-center">Foto</th>
                        <th>Apellidos y nombres</th>
                        <th>Usuario</th>
                        <th>Correo</th>
                        <th>Perfil</th>
                        <th class="text-center" style="width:100px;">Estado</th>
                        <th class="text-center" style="width:200px;">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    {% for u in users %}
                    <tr id="row-{{ u.user_id }}">
                        <td class="text-center p-1">
                            {% if u.avatar %}
                            <img src="{{ u.avatar }}" alt=""
                                 style="width:40px;height:40px;object-fit:cover;border-radius:50%;border:1px solid #dee2e6;">
                            {% else %}
                            <span class="d-inline-flex align-items-center justify-content-center bg-secondary text-white rounded-circle"
                                  style="width:40px;height:40px;font-size:16px;">
                                <i class="fas fa-user"></i>
                            </span>
                            {% endif %}
                        </td>
                        <td class="align-middle">{{ u.lastname }}, {{ u.firstname }}</td>
                        <td class="align-middle"><code>{{ u.username }}</code></td>
                        <td class="align-middle" style="font-size:13px;">{{ u.email }}</td>
                        <td class="align-middle">
                            <span class="badge badge-secondary">{{ u.role_label }}</span>
                        </td>
                        <td class="text-center align-middle">
                            <button type="button"
                                    class="btn btn-sm btn-toggle-active {% if u.active %}btn-success{% else %}btn-secondary{% endif %}"
                                    data-user-id="{{ u.user_id }}"
                                    data-active="{{ u.active }}"
                                    title="{% if u.active %}Desactivar usuario{% else %}Activar usuario{% endif %}">
                                <i class="fas {% if u.active %}fa-toggle-on{% else %}fa-toggle-off{% endif %}"></i>
                                <span>{% if u.active %}Activo{% else %}Inactivo{% endif %}</span>
                            </button>
                        </td>
                        <td class="text-center align-middle">
                            {% if u.has_ficha %}
                            <a href="{{ ficha_url }}?user_id={{ u.user_id }}"
                               class="btn btn-sm btn-info mb-1"
                               title="Ver / Editar ficha de datos adicionales">
                                <i class="fas fa-file-alt"></i> Ver ficha
                            </a>
                            {% else %}
                            <a href="{{ ficha_url }}?user_id={{ u.user_id }}"
                               class="btn btn-sm btn-success mb-1"
                               title="Crear ficha de datos adicionales">
                                <i class="fas fa-file-medical"></i> Crear ficha
                            </a>
                            {% endif %}
                            <button type="button"
                                    class="btn btn-sm btn-outline-secondary btn-tarjeta-staff mb-1"
                                    data-user-id="{{ u.user_id }}"
                                    title="Ver tarjeta de personal">
                                <i class="fas fa-id-badge"></i> Tarjeta
                            </button>
                        </td>
                    </tr>
                    {% else %}
                    <tr>
                        <td colspan="7" class="text-center text-muted py-4">
                            No se encontraron usuarios.
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>

    </div>
</div>

{# ===== MODAL TARJETA DE PERSONAL ===== #}
<div class="modal fade" id="modalTarjetaStaff" tabindex="-1" role="dialog">
    <div class="modal-dialog" style="max-width:400px;" role="document">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h6 class="modal-title font-weight-bold">
                    <i class="fas fa-id-badge mr-1"></i> Tarjeta de Personal
                </h6>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body p-3">
                <div id="staff-card-loading" class="text-center py-5">
                    <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                </div>
                <div id="staff-card-contenido" style="display:none;">
                    <div id="staff-card" style="
                        width: 100%;
                        background: #ffffff;
                        color: #2d3748;
                        font-family: Arial, sans-serif;
                        border-radius: 14px;
                        overflow: hidden;
                        border: 1px solid #e2e8f0;
                        box-shadow: 0 2px 12px rgba(0,0,0,0.08);
                    ">
                        {# Cabecera: franja azul oscuro con logo + institución #}
                        <div style="display:flex; align-items:center; padding:14px 18px 12px; background:#1a3558; border-bottom:3px solid #0f2040;">
                            <img id="sc-logo" src="{{ logo_url }}" alt="Logo"
                                 style="height:42px; max-width:76px; object-fit:contain; background:#fff; border-radius:6px; padding:3px; margin-right:12px; flex-shrink:0;">
                            <div>
                                <div style="font-size:9px; font-weight:700; letter-spacing:1px; text-transform:uppercase; color:#a8c4e0; line-height:1.3;">{{ institution_name }}</div>
                                <div style="font-size:11px; font-weight:800; letter-spacing:1px; color:#ffffff; line-height:1.4;">CARNET DE PERSONAL</div>
                            </div>
                        </div>

                        {# Foto centrada #}
                        <div style="text-align:center; padding:20px 20px 10px;">
                            <div style="width:110px; height:140px; background:#f0f4f8; border-radius:10px; overflow:hidden; border:2px solid #cbd5e0; display:inline-block;">
                                <img id="sc-foto" src="" alt="Foto"
                                     style="width:100%; height:100%; object-fit:cover; display:none;">
                                <div id="sc-foto-placeholder" style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;">
                                    <i class="fas fa-user" style="font-size:50px; color:#a0aec0;"></i>
                                </div>
                            </div>
                        </div>

                        {# Nombre #}
                        <div style="text-align:center; padding:0 18px 12px;">
                            <div style="font-size:8px; color:#718096; text-transform:uppercase; letter-spacing:1px; margin-bottom:3px;">Apellidos y Nombres</div>
                            <div id="sc-nombre" style="font-size:16px; font-weight:800; color:#1a202c; line-height:1.3;"></div>
                        </div>

                        {# Cargo + Nivel (si aplica) #}
                        <div style="display:flex; margin:0 16px 12px; background:#f7f8fa; border-radius:8px; border:1px solid #e2e8f0; overflow:hidden;" id="sc-info-row">
                            <div style="flex:1; padding:10px 12px; border-right:1px solid #e2e8f0;">
                                <div style="font-size:8px; color:#718096; text-transform:uppercase; letter-spacing:1px;">Cargo</div>
                                <div id="sc-cargo" style="font-size:13px; font-weight:700; color:#2d3748;"></div>
                            </div>
                            <div id="sc-nivel-col" style="flex:1; padding:10px 12px;">
                                <div style="font-size:8px; color:#718096; text-transform:uppercase; letter-spacing:1px;">Nivel</div>
                                <div id="sc-nivel" style="font-size:13px; font-weight:700; color:#2d3748;"></div>
                            </div>
                        </div>

                        {# QR centrado #}
                        <div style="text-align:center; padding:0 18px 16px;">
                            <div id="sc-qr" style="background:#f7f8fa; border:1px solid #e2e8f0; padding:8px; border-radius:8px; display:inline-block;"></div>
                            <div id="sc-email" style="font-size:9px; color:#718096; margin-top:5px; word-break:break-all;"></div>
                        </div>

                        {# Pie #}
                        <div style="background:#1a3558; border-top:3px solid #0f2040; text-align:center; padding:9px; font-size:8px; letter-spacing:1.5px; color:#ffffff; font-weight:700;">
                            DOCUMENTO DE IDENTIFICACIÓN — PERSONAL
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer py-2" id="staff-card-footer" style="display:none!important;">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-dismiss="modal">Cerrar</button>
                <button type="button" class="btn btn-dark btn-sm" id="btn-imprimir-staff">
                    <i class="fas fa-print mr-1"></i> Imprimir
                </button>
            </div>
        </div>
    </div>
</div>

<script src="{{ qrcode_js }}"></script>
<script>
$(document).ready(function () {

    if ($.fn.DataTable) {
        $('#tabla-usuarios').DataTable({
            language: { url: '//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json' },
            order: [[1, 'asc']],
            pageLength: 25,
            columnDefs: [{ orderable: false, targets: [0, 5, 6] }],
            autoWidth: false
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

    // Tarjeta de personal
    $(document).on('click', '.btn-tarjeta-staff', function () {
        var userId = $(this).data('user-id');
        $('#staff-card-loading').show().html('<i class="fas fa-spinner fa-spin fa-2x text-primary"></i>');
        $('#staff-card-contenido').hide();
        $('#staff-card-footer').css('display', 'none');
        $('#modalTarjetaStaff').modal('show');

        $.get('{{ ajax_admin_url }}', { action: 'get_staff_card_data', user_id: userId }, function (resp) {
            $('#staff-card-loading').hide();
            if (!resp.success) {
                $('#staff-card-loading').html('<p class="text-danger p-3">' + (resp.error || 'Error') + '</p>').show();
                return;
            }

            $('#sc-nombre').html(resp.apellidos + '<br><span style="font-weight:400;font-size:15px;">' + resp.nombres + '</span>');
            $('#sc-cargo').text(resp.cargo || '—');
            $('#sc-email').text(resp.email || '');

            // Nivel: solo si tiene valor
            if (resp.nivel) {
                $('#sc-nivel').text(resp.nivel);
                $('#sc-nivel-col').show();
            } else {
                $('#sc-nivel-col').hide();
                // Cargo ocupa todo el ancho
                $('#sc-info-row > div:first-child').css('border-right', 'none');
            }

            // Foto
            if (resp.foto_url) {
                $('#sc-foto').attr('src', resp.foto_url).show();
                $('#sc-foto-placeholder').hide();
            } else {
                $('#sc-foto').hide();
                $('#sc-foto-placeholder').show();
            }

            // QR
            $('#sc-qr').empty();
            if (resp.email) {
                new QRCode(document.getElementById('sc-qr'), {
                    text: resp.email,
                    width: 90,
                    height: 90,
                    colorDark: '#2d3748',
                    colorLight: '#f7f8fa',
                    correctLevel: QRCode.CorrectLevel.M
                });
            }

            $('#staff-card-contenido').show();
            $('#staff-card-footer').css('display', 'flex');
        }, 'json').fail(function () {
            $('#staff-card-loading').html('<p class="text-danger p-3">Error de conexión.</p>').show();
        });
    });

    // Imprimir tarjeta de personal
    $('#btn-imprimir-staff').on('click', function () {
        var cardHtml = document.getElementById('staff-card').outerHTML;
        var w = window.open('', '_blank');
        w.document.write([
            '<!DOCTYPE html><html><head>',
            '<meta charset="utf-8">',
            '<title>Carnet de Personal</title>',
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
            '#staff-card {',
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
});
</script>
