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

    {{ css_files }}

    {{ js_files }}

    {{ js_file_to_string }}

    {{ extra_headers }}

    <link href="{{ assets }}/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
    <!-- Custom fonts for this template-->
    <link href="{{ _p.web }}/plugin/school/css/style-reset.css" rel="stylesheet" type="text/css">
    <!-- Custom styles for this template-->
    {% if _s.language_interface %}
    <script src="{{ _p.web }}web/build/main.{{ _s.language_interface }}.js"></script>
    {% else %}{# language_interface *should* always be defined, so we should never come here #}
    <script src="{{ _p.web }}web/build/main.js"></script>
    {% endif %}
</head>

<body id="page-top">
<!-- Page Wrapper -->
<div id="wrapper">

    <!-- Content Wrapper -->
    <div id="content-wrapper" class="d-flex flex-column">
        <!-- Main Content -->
        <div id="content">

            <!-- Begin Page Content -->
            <div class="container page-container">
                {% block content %}
                {{ content }}
                {% endblock %}
            </div>
            <!-- /.container-fluid -->
        </div>
        <!-- End of Main Content -->
    </div>
    <!-- End of Content Wrapper -->
</div>
<section class="bar-bottom">
    <div class="element-container"></div>
</section>
<!-- End of Page Wrapper -->
<!-- Scroll to Top Button-->
<a class="scroll-to-top rounded" href="#page-top">
    <i class="fas fa-angle-up"></i>
</a>

</body>
</html>