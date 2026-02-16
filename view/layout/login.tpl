<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>{{ site_name }} - {{ institution }}</title>
    <link rel="icon" type="image/svg+xml" href="{{ favicon }}">
    <link href="{{ assets }}/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
          rel="stylesheet">

    {{ css_files }}

    {{ js_files }}

    {{ js_file_to_string }}

    {{ extra_headers }}
</head>

<body class="bg-gradient-primary"
      {% if login_bg_image %}
      style="background: url('{{ login_bg_image }}') no-repeat center center fixed; background-size: cover;"
      {% elseif login_bg_color %}
      style="background: {{ login_bg_color }}; background-image: none;"
      {% endif %}
>

    {{ content }}

    <script src="{{ assets }}/jquery/jquery.min.js"></script>
    <script src="{{ assets }}/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script src="{{ assets }}/jquery-easing/jquery.easing.min.js"></script>
</body>
</html>
