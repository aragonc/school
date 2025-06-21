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

<!-- Bootstrap core JavaScript-->

<script>
    $(function () {
        $('[data-toggle="tooltip"]').tooltip();
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

        // Obtiene el contenido del calendario oculto
        const calendarHtml = $('#data_tool_calendar').html();

        // Inserta el contenido en el body del modal
        $('#generalModalBody').html(calendarHtml);

        // Establece el título del modal (opcional)
        $('#generalModalLabel').text('Calendario Académico');

        // Muestra el modal
        $('#generalModal').modal('show');
    });


    $(document).on('click', '.open_description', function(e) {
        e.preventDefault();
        const descriptionHtml = $('#data_tool_description').html();
        $('#generalModalBody').html(descriptionHtml);
        $('#generalModalLabel').text('Sobre el curso');
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

    $(document).ready(function () {
        var $nav = $(".nav-mobile");
        var $toggle = $("#sidebarToggleTop");
        var $close = $("#closeMobile");
        var $body = $("body");
        var $overlay = $(".menu-overlay");

        function openMenu() {
            $nav.addClass("is-active");
            $body.addClass("no-scroll");
        }

        function closeMenu() {
            $nav.removeClass("is-active");
            $body.removeClass("no-scroll");
        }

        if ($nav.length) {
            if ($toggle.length) {
                $toggle.on("click", function (e) {
                    e.stopPropagation();
                    if ($nav.hasClass("is-active")) {
                        closeMenu();
                    } else {
                        openMenu();
                    }
                });
            }

            if ($close.length) {
                $close.on("click", function (e) {
                    e.stopPropagation();
                    closeMenu();
                });
            }

            if ($overlay.length) {
                $overlay.on("click", function () {
                    closeMenu();
                });
            }

            $(document).on("keydown", function (e) {
                if (e.key === "Escape") {
                    closeMenu();
                }
            });

            $(".logo-site").on("click", function (e) {
                closeMenu();
            });

            $(document).on("click", function (e) {

            });
        }
    });




</script>

</body>
</html>