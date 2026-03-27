</div>
<!-- /.container-fluid -->
</div>
<!-- End of Main Content -->

<footer class="sticky-footer">
    <div class="container my-auto">
        <div class="copyright text-center my-auto">
            <!-- <span>Copyright &copy; {{_s.institution }} / {{_s.date }}</span> -->
        </div>
    </div>
</footer>

</div>
<!-- End of Content Wrapper -->
</div>
<!-- End of Page Wrapper -->
<!-- Scroll to Top Button-->
<a class="scroll-to-top rounded" href="#page-top">
    <i class="fas fa-angle-up"></i>
</a>

<!-- Logout Modal-->
<div class="modal fade" id="logoutModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">{{ 'Logout'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">×</span>
                </button>
            </div>
            <div class="modal-body">{{ 'SelectEndYourCurrentSession'|get_plugin_lang('SchoolPlugin') }}</div>
            <div class="modal-footer">
                <button class="btn btn-secondary" type="button" data-dismiss="modal">Cancelar</button>
                <a class="btn btn-primary" href="{{ logout_link }}">{{ 'Logout'|get_plugin_lang('SchoolPlugin') }}</a>
            </div>
        </div>
    </div>
</div>

<!-- Modal General Bootstrap -->
<div class="modal fade" id="generalModal" tabindex="-1" role="dialog" aria-labelledby="generalModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="generalModalLabel">Cargando...</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body" id="generalModalBody">

            </div>
        </div>
    </div>
</div>

{% if support_show_button %}
{# ===== Botón flotante de soporte (usuarios logueados) ===== #}
<button id="btnOpenSupportAuth" data-toggle="modal" data-target="#supportAuthModal"
        title="¿Necesitas ayuda?"
        style="position:fixed;bottom:28px;right:28px;z-index:1050;
               background:linear-gradient(135deg,#ff6b35,#f7931e);
               color:#fff;border:none;border-radius:50px;
               padding:14px 22px;font-size:15px;font-weight:700;
               box-shadow:0 6px 24px rgba(255,107,53,.55);
               cursor:pointer;display:flex;align-items:center;gap:10px;
               animation:sp-pulse 2s ease-in-out infinite;">
    <i class="fas fa-headset" style="font-size:20px;"></i>
    <span>¿Necesitas ayuda?</span>
</button>
<style>
@keyframes sp-pulse {
    0%,100% { box-shadow:0 6px 24px rgba(255,107,53,.55); transform:scale(1); }
    50%      { box-shadow:0 8px 32px rgba(255,107,53,.85); transform:scale(1.04); }
}
#btnOpenSupportAuth:hover { animation:none; transform:scale(1.06); box-shadow:0 10px 36px rgba(255,107,53,.75); transition:transform .15s,box-shadow .15s; }
</style>

{# ===== Modal de Soporte Autenticado ===== #}
<div class="modal fade" id="supportAuthModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content shadow-lg border-0">
            <div class="modal-header bg-primary text-white py-3">
                <h6 class="modal-title mb-0"><i class="fas fa-headset mr-2"></i>Soporte técnico</h6>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>

            <div class="modal-body px-4 py-3" id="saFormWrapper">
                {% if support_attention_message %}
                <div class="alert mb-3 py-2 px-3 d-flex align-items-start"
                     style="background:#fff8e1;border-left:4px solid #f7931e;font-size:13px;">
                    <i class="fas fa-clock mr-2 mt-1" style="color:#f7931e;flex-shrink:0;"></i>
                    <div>{{ support_attention_message|raw }}</div>
                </div>
                {% endif %}

                <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">Categoría</label>
                    <select id="sa_category" class="form-control form-control-sm">
                        {% for cat in support_categories %}
                        <option value="{{ cat.name|lower|replace({' ': '_', '/': '', 'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u'}) }}"
                                data-template="{{ cat.template|default('')|e }}">{{ cat.name }}</option>
                        {% endfor %}
                    </select>
                </div>

                <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">Asunto *</label>
                    <input type="text" id="sa_subject" class="form-control form-control-sm"
                           placeholder="Describe brevemente el problema" maxlength="255">
                    <div class="invalid-feedback" id="sa_subject_err"></div>
                </div>

                <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">Mensaje *</label>
                    <textarea id="sa_body" name="sa_body"></textarea>
                    <div class="text-danger small mt-1 d-none" id="sa_body_err"></div>
                </div>

                <div class="form-group mb-0">
                    <label class="small font-weight-bold mb-1">
                        <i class="fas fa-paperclip mr-1"></i>Adjuntar imagen
                        <span class="text-muted font-weight-normal">(opcional, máx. 5 MB)</span>
                    </label>
                    <div class="custom-file">
                        <input type="file" class="custom-file-input" id="sa_image"
                               accept="image/jpeg,image/png,image/gif,image/webp">
                        <label class="custom-file-label" for="sa_image">Seleccionar imagen...</label>
                    </div>
                    <div id="sa_image_preview" class="mt-2 d-none">
                        <img id="sa_image_thumb" src="" alt="preview"
                             style="max-height:120px;max-width:100%;border-radius:6px;border:1px solid #dee2e6;">
                    </div>
                    <div class="text-danger small mt-1 d-none" id="sa_image_err"></div>
                </div>

                <div id="sa_global_err" class="alert alert-danger py-2 mt-3 d-none small"></div>
            </div>

            <div class="modal-body text-center py-5 d-none" id="saSuccessWrapper">
                <i class="fas fa-check-circle fa-3x text-success mb-3 d-block"></i>
                <h6 class="font-weight-bold">¡Ticket enviado!</h6>
                <p class="text-muted small mb-0">
                    Nuestro equipo revisará tu solicitud a la brevedad.
                    <a href="/support" class="d-block mt-2">Ver mis tickets</a>
                </p>
            </div>

            <div class="modal-footer py-2" id="saFooter">
                {% if support_whatsapp %}
                <a href="https://wa.me/{{ support_whatsapp|replace({'+': ''}) }}"
                   target="_blank" rel="noopener"
                   class="btn btn-sm btn-success mr-auto"
                   style="background:#25D366;border-color:#25D366;">
                    <i class="fab fa-whatsapp mr-1"></i>WhatsApp directo
                </a>
                {% endif %}
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-sm btn-primary" id="btnSubmitSupportAuth">
                    <i class="fas fa-paper-plane mr-1"></i>Enviar
                </button>
            </div>
        </div>
    </div>
</div>

<script src="{{ _p.web }}web/assets/ckeditor/ckeditor.js"></script>
<script>
var saAjaxUrl = '{{ support_ajax_url }}';

function saLoadTemplate() {
    var sel = document.getElementById('sa_category');
    var opt = sel ? sel.options[sel.selectedIndex] : null;
    var tpl = (opt ? opt.getAttribute('data-template') : '') || '';
    if (tpl && CKEDITOR.instances.sa_body) {
        var current = CKEDITOR.instances.sa_body.getData().replace(/<[^>]+>/g,'').trim();
        if (!current) CKEDITOR.instances.sa_body.setData(tpl.replace(/\n/g,'<br>'));
    }
}

$('#supportAuthModal').on('shown.bs.modal', function () {
    if (!CKEDITOR.instances.sa_body) {
        CKEDITOR.replace('sa_body', {
            language: 'es',
            toolbar: [
                { name: 'basicstyles', items: ['Bold','Italic','Underline','Strike','RemoveFormat'] },
                { name: 'paragraph',   items: ['NumberedList','BulletedList','Blockquote'] },
                { name: 'links',       items: ['Link','Unlink'] },
            ],
            height: 130,
            resize_enabled: false,
            removePlugins: 'elementspath',
        });
    }
    setTimeout(saLoadTemplate, 300);
});

document.getElementById('sa_category').addEventListener('change', function () {
    var tpl = (this.options[this.selectedIndex].getAttribute('data-template') || '').replace(/\n/g,'<br>');
    if (CKEDITOR.instances.sa_body) CKEDITOR.instances.sa_body.setData(tpl);
});

$('#supportAuthModal').on('hidden.bs.modal', function () {
    document.getElementById('saFormWrapper').classList.remove('d-none');
    document.getElementById('saSuccessWrapper').classList.add('d-none');
    document.getElementById('saFooter').classList.remove('d-none');
    document.getElementById('sa_subject').value = '';
    document.getElementById('sa_subject').classList.remove('is-invalid');
    document.getElementById('sa_image').value = '';
    document.getElementById('sa_image_preview').classList.add('d-none');
    document.getElementById('sa_image_err').classList.add('d-none');
    document.querySelector('label[for="sa_image"]').textContent = 'Seleccionar imagen...';
    document.getElementById('sa_body_err').classList.add('d-none');
    document.getElementById('sa_global_err').classList.add('d-none');
    if (CKEDITOR.instances.sa_body) CKEDITOR.instances.sa_body.setData('');
});

// Preview imagen
document.getElementById('sa_image').addEventListener('change', function () {
    var file = this.files[0];
    var preview = document.getElementById('sa_image_preview');
    var thumb   = document.getElementById('sa_image_thumb');
    var label   = document.querySelector('label[for="sa_image"]');
    var errEl   = document.getElementById('sa_image_err');
    errEl.classList.add('d-none');

    if (!file) { preview.classList.add('d-none'); label.textContent = 'Seleccionar imagen...'; return; }

    if (file.size > 5 * 1024 * 1024) {
        errEl.textContent = 'La imagen no debe superar 5 MB.';
        errEl.classList.remove('d-none');
        this.value = '';
        preview.classList.add('d-none');
        label.textContent = 'Seleccionar imagen...';
        return;
    }
    label.textContent = file.name;
    var reader = new FileReader();
    reader.onload = function(e) {
        thumb.src = e.target.result;
        preview.classList.remove('d-none');
    };
    reader.readAsDataURL(file);
});

document.getElementById('btnSubmitSupportAuth').addEventListener('click', function () {
    var btn      = this;
    var subject  = document.getElementById('sa_subject').value.trim();
    var category = document.getElementById('sa_category').value;
    var body     = CKEDITOR.instances.sa_body ? CKEDITOR.instances.sa_body.getData().trim() : '';
    var emptyBody = !body || body === '<p>&nbsp;</p>' || body === '<p></p>';
    var imageFile = document.getElementById('sa_image').files[0] || null;

    document.getElementById('sa_subject').classList.remove('is-invalid');
    document.getElementById('sa_body_err').classList.add('d-none');
    document.getElementById('sa_global_err').classList.add('d-none');

    var valid = true;
    if (!subject) {
        document.getElementById('sa_subject').classList.add('is-invalid');
        document.getElementById('sa_subject_err').textContent = 'El asunto es obligatorio.';
        valid = false;
    }
    if (emptyBody) {
        document.getElementById('sa_body_err').textContent = 'El mensaje es obligatorio.';
        document.getElementById('sa_body_err').classList.remove('d-none');
        valid = false;
    }
    if (!valid) return;

    btn.disabled = true;
    var fd = new FormData();
    fd.append('action',   'create_ticket');
    fd.append('subject',  subject);
    fd.append('category', category);
    fd.append('priority', 'medium');
    fd.append('body',     body);
    if (imageFile) fd.append('attachment', imageFile);

    fetch(saAjaxUrl, { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            btn.disabled = false;
            if (d.success) {
                document.getElementById('saFormWrapper').classList.add('d-none');
                document.getElementById('saSuccessWrapper').classList.remove('d-none');
                document.getElementById('saFooter').classList.add('d-none');
            } else {
                var gl = document.getElementById('sa_global_err');
                gl.textContent = d.message || 'Error al enviar. Intenta de nuevo.';
                gl.classList.remove('d-none');
            }
        })
        .catch(function() {
            btn.disabled = false;
            var gl = document.getElementById('sa_global_err');
            gl.textContent = 'Error de conexión. Intenta de nuevo.';
            gl.classList.remove('d-none');
        });
});
</script>
{% endif %}

<!-- Bootstrap core JavaScript-->

<script>
    $(function () {
        $('[data-toggle="tooltip"]').tooltip();

        // Toggle the side navigation
        $('#sidebarToggle, #sidebarToggleTop, #sidebarToggleDesktop').on('click', function (e) {
            e.preventDefault();
            $('body').toggleClass('sidebar-toggled');
            $('.sidebar').toggleClass('toggled');
            if ($('.sidebar').hasClass('toggled')) {
                $('.sidebar .collapse').collapse('hide');
            }
        });

        // Close any open menu accordions when window is resized below 768px
        $(window).resize(function () {
            if ($(window).width() < 768) {
                $('.sidebar .collapse').collapse('hide');
            }
        });

        // Prevent the content wrapper from scrolling when the fixed side navigation hovered over
        $('body.fixed-nav .sidebar').on('mousewheel DOMMouseScroll wheel', function (e) {
            if ($(window).width() > 768) {
                var e0 = e.originalEvent,
                    delta = e0.wheelDelta || -e0.detail;
                this.scrollTop += (delta < 0 ? 1 : -1) * 30;
                e.preventDefault();
            }
        });

        // Scroll to top button appear
        $(document).on('scroll', function () {
            var scrollDistance = $(this).scrollTop();
            if (scrollDistance > 100) {
                $('.scroll-to-top').fadeIn();
            } else {
                $('.scroll-to-top').fadeOut();
            }
        });

        // Smooth scrolling using jQuery easing
        $(document).on('click', 'a.scroll-to-top', function (e) {
            var $anchor = $(this);
            $('html, body').stop().animate({
                scrollTop: ($($anchor.attr('href')).offset().top)
            }, 1000, 'easeInOutExpo');
            e.preventDefault();
        });
    });

    function setCheckboxTable(value, table_id) {
        let checkboxes = $("#"+table_id+" input:checkbox");
        $.each(checkboxes, function(index, checkbox) {
            checkbox.checked = value;
            if (value) {
                $(checkbox).parentsUntil("tr").parent().addClass("row_selected");
            } else {
                $(checkbox).parentsUntil("tr").parent().removeClass("row_selected");
            }
        });
        return false;
    }

    function action_click_table(element, table_id) {
        let form = $("#"+table_id);
        if (!confirm('{{ "ConfirmYourChoice"|get_lang | escape('js')}}')) {
            return false;
        } else {
            let action=$(element).attr("data-action");
            $('#'+table_id+' input[name="action"]').val(action);
            form.submit();
            return false;
        }
    }

    // Table highlight.
    $("form .table input:checkbox").click(function () {
        if ($(this).is(":checked")) {
            $(this).parentsUntil("tr").parent().addClass("row_selected");
        } else {
            $(this).parentsUntil("tr").parent().removeClass("row_selected");
        }
    });

    $(document).on('click', '.open-calendar', function(e) {
        e.preventDefault();
        const calendarHtml = $('#data_tool_calendar').html();
        // Inserta el contenido en el body del modal
        $('#generalModalBody').html(calendarHtml);
        $('#generalModalLabel').text('{{ "AcademicCalendar"|get_plugin_lang('SchoolPlugin') }}');
        $('#generalModal').modal('show');
    });


    $(document).on('click', '.open_description', function(e) {
        e.preventDefault();
        const descriptionHtml = $('#data_tool_description').html();
        $('#generalModalBody').html(descriptionHtml);
        $('#generalModalLabel').text('{{ "ProgramInformation"|get_plugin_lang('SchoolPlugin') }}');
        $('#generalModal').modal('show');
    });

    // Limpia el contenido del modal al cerrarse (opcional)
    $('#generalModal').on('hidden.bs.modal', function () {
        $('#generalModalBody').html('');
    });

    $(document).ready(function () {

        $('.open-pdf').on('click', function(e) {
            e.preventDefault(); // Evita que el enlace navegue
            const pdfUrl = $(this).attr('href');
            const modalTitle = $(this).data('title') || 'Visualizar Ficha PDF del curso';

            $('#pdfViewer').attr('src', pdfUrl);
            $('#generalModalLabel').text(modalTitle);

            const iframe = $('<iframe>', {
                src: pdfUrl,
                width: '100%',
                height: '600px',
                frameborder: 0
            });

            $('#generalModalBody').html(iframe);

        });

        // Limpia el iframe al cerrar el modal
        $('#pdfModal').on('hidden.bs.modal', function () {
            $('#pdfViewer').attr('src', '');
        });


        function loadNotifications() {
            let count = 0;
            let url_platform = '{{ _p.web_plugin }}';
            $.ajax({
                url: url_platform + 'school/src/ajax.php?action=check_notifications',
                method: 'GET',
                dataType: 'json',
                success: function (data) {

                    count = data.count_messages > 0 ? data.count_messages : '0';
                    if (data.messages.length > 0) {

                        $('.badge-counter').text(count).show();
                        $('#counter-sidebar').remove();
                        $('#menu-notifications').append('<span id="counter-sidebar" class="badge badge-danger badge-counter">' + count + '</span>');

                    } else {
                        $('.badge-counter').hide();
                        $('#counter-sidebar').remove();
                    }

                    $('#notifications').empty();

                    if (data.messages.length > 0) {
                        data.messages.forEach(function (message) {
                            $('#notifications').append(`
                            <a class="dropdown-item d-flex align-items-center" href="${message.link}">
                                <div class="mr-3">
                                    ${message.user_avatar}
                                </div>
                                <div>
                                    <div class="small text-gray-500">${message.send_date}</div>
                                    <span class="font-weight-bold">${message.title}</span>
                                </div>
                            </a>
                        `);
                        });
                        $('#notifications').append(`
                        <a href="/notifications" class="dropdown-item text-center small text-gray-800" href="#">
                             {{ 'SeeAll'|get_plugin_lang('SchoolPlugin') }}
                        </a>`);

                    } else {
                        $('#notifications').append(`
                        <a class="dropdown-item text-center small text-gray-800" href="#">
                             {{ 'YouHaveNoNewNotifications'|get_plugin_lang('SchoolPlugin') }}
                        </a>`);
                    }
                },
                error: function () {
                    console.error('Failed to fetch notifications.');
                }
            });


        }
        loadNotifications();
        setInterval(loadNotifications, 30000);

    });

    $(document).ready(function() {
        let timeout = null;

        $(".terms-search").on("keyup", function() {
            clearTimeout(timeout);
            let term = $(this).val().trim();
            let resultList = $(".result_search");
            let url_platform = '{{ _p.web_plugin }}';
            let url_courses = '{{ _p.web }}shopping';
            let url_graduates = '{{ _p.web }}shopping?view=graduates';

            if (term.length > 0) {
                $("#loader").show();
                resultList.empty();

                timeout = setTimeout(function() {
                    $.ajax({
                        url: url_platform + "school/src/ajax.php?action=search&term=" + term,
                        method: "GET",
                        dataType: "json",
                        success: function(response) {
                            $("#loader").hide();
                            resultList.empty();

                            if (response.sessions.length > 0) {
                                response.sessions.forEach(function(session) {
                                    let listItem = `
                                    <li class="list-group-item">
                                    <a class="dropdown-item d-flex align-items-center" href="${session.url}">
                                        <div class="mr-3">
                                            <img src="${session.extra.image}" alt="${session.name}" width="100" class="mr-2 rounded-lg">
                                        </div>
                                        <div>
                                            <h4 class="title mt-1 mt-md-3">${session.name}</h4>
                                            <p class="mb-1 mb-md-3">${session.description}</p>
                                        </div>
                                    </a>
                                </li>
                                `;
                                    resultList.append(listItem);
                                });
                                resultList.show(); // Muestra la lista
                            } else {
                                let notFound = `
                                <li class="list-group-item text-muted">
                                    <div class="dropdown-item align-items-center p-4">
                                No se encontraron resultados, puedes visitar nuestro catálogo de <a href="`+url_courses+`">cursos</a>
                                y <a href="`+url_graduates+`">diplomados</a>
                                    </div>
                                </li>`;
                                resultList.append(notFound);
                                resultList.show(); // Muestra la lista
                            }
                        },
                        error: function() {
                            $("#loader").hide();
                            resultList.html('<li class="list-group-item text-danger">Error al obtener datos</li>');
                        }
                    });
                }, 400);
            } else {
                $("#loader").hide();
                resultList.empty().hide();
            }
        });

        // Ocultar los resultados al hacer clic fuera
        $(document).on("click", function(event) {
            if (!$(event.target).closest("#term, #result").length) {
                $("#result").hide();
            }
        });

        // Mostrar resultados cuando el input tenga el foco
        $("#term").on("focus", function() {
            if ($("#result").children().length > 0) {
                $("#result").show();
            }
        });
    });





</script>

</body>
</html>