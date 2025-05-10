{% include 'layout/header.tpl' %}

{{ flash_messages }}

<div class="row">
    <div class="col-12 col-lg-8">
        {% if title_string %}
        <!-- Page Heading -->
        <h1 class="title-page mb-4">
            {{ title_string }}
        </h1>
        {% endif %}
    </div>
    <div class="col-12 col-lg-4">
        {{ form_filter }}
    </div>
</div>

{% block content %}
{{ content }}
{% endblock %}

{% include 'layout/footer.tpl' %}