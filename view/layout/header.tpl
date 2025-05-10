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