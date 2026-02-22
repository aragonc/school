<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <title> {{_s.institution }} - {{_s.site_name }}</title>
    <link rel="icon" type="{{ favicon_type }}" href="{{ favicon }}">
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

    {% if custom_logo_width or custom_logo_height or custom_primary_color or custom_sidebar_brand_color or custom_sidebar_color or custom_sidebar_item_color or custom_sidebar_item_active_text or custom_sidebar_text_color %}
    <style>
        {% if custom_logo_width or custom_logo_height %}
        .sidebar-brand .logo-site,
        .logo-campus .logo-site {
            {% if custom_logo_width %}
            width: {{ custom_logo_width }}px !important;
            {% endif %}
            {% if custom_logo_height %}
            height: {{ custom_logo_height }}px !important;
            {% endif %}
            object-fit: contain;
        }
        {% endif %}
        {% if custom_sidebar_brand_color %}
        .bg-gradient-primary .sidebar-brand {
            background: {{ custom_sidebar_brand_color }} !important;
        }
        {% endif %}
        {% if custom_sidebar_color %}
        .bg-gradient-primary {
            background: {{ custom_sidebar_color }} !important;
            background-image: none !important;
        }
        {% endif %}
        {% if custom_primary_color %}
        .sidebar-dark .nav-item.active .nav-link {
            background: {{ custom_primary_color }} !important;
        }
        .sidebar-dark #sidebarToggle {
            background-color: {{ custom_primary_color }} !important;
        }
        .sidebar-dark #sidebarToggle:hover {
            opacity: 0.8;
        }
        {% endif %}
        {% if custom_sidebar_item_active_text %}
        .sidebar-dark .nav-item.active .nav-link {
            color: {{ custom_sidebar_item_active_text }} !important;
        }
        .sidebar-dark .nav-item.active .nav-link i {
            color: {{ custom_sidebar_item_active_text }} !important;
        }
        {% endif %}
        {% if custom_sidebar_text_color %}
        .sidebar-dark .nav-item .nav-link {
            color: {{ custom_sidebar_text_color }} !important;
        }
        .sidebar-dark .nav-item .nav-link i {
            color: {{ custom_sidebar_text_color }} !important;
        }
        {% endif %}
    </style>
    {% endif %}
</head>

<body id="page-top">
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
