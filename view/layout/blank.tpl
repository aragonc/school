<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <title> {{_s.institution }} - {{_s.site_name }}</title>
    <link rel="icon" type="image/svg+xml" href="{{ favicon }}">
    <!-- Custom fonts for this template-->
    <link href="{{ assets }}/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
            rel="stylesheet">
    <!-- Custom styles for this template-->
    {{ css_files }}

    {{ js_files }}

    {{ js_file_to_string }}

    {{ extra_headers }}

    {% if _s.language_interface %}
    <script src="{{ _p.web }}web/build/main.{{ _s.language_interface }}.js"></script>
    {% else %}{# language_interface *should* always be defined, so we should never come here #}
    <script src="{{ _p.web }}web/build/main.js"></script>
    {% endif %}
</head>

<body id="page-top" class="sidebar-toggled">
<!-- Page Wrapper -->
<div id="wrapper">

    {% include 'layout/sidebar.tpl' %}

    <!-- Content Wrapper -->
    <div id="content-wrapper" class="d-flex flex-column">
        <!-- Main Content -->
        <div id="content">

            {% include 'layout/navbar.tpl' %}

            <!-- Begin Page Content -->
            <div class="container page-container">

                {{ flash_messages }}

                <div class="row">
                    <div class="col-8">
                        {% if title_string %}
                        <!-- Page Heading -->
                        <h1 class="title-page mb-4">
                            {{ title_string }}
                        </h1>
                        {% endif %}
                    </div>
                    <div class="col-4">
                        {{ form_filter }}
                    </div>
                </div>


                {% block content %}
                {{ content }}
                {% endblock %}
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

<!-- Bootstrap core JavaScript-->

<script>

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

    $(document).ready(function () {

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

        $("#term").on("keyup", function() {
            clearTimeout(timeout);
            let term = $(this).val().trim();
            let resultList = $("#result");
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
                                            <img src="${session.extra.image}" alt="${session.name}" width="100" class="mr-2">
                                        </div>
                                        <div>
                                            <h4 class="title mt-3">${session.name}</h4>
                                            <p>${session.description}</p>
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
                                No se encontraron resultados, puedes visitar nuestro catalogo de <a href="`+url_courses+`">cursos</a>
                                y <a href="`+url_graduates+`">diplomados</a>
                                    </div>
                                </li>`;
                                resultList.append(notFound);
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