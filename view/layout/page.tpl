{% include 'layout/header.tpl' %}

{{ flash_messages }}

<div class="card shadow">
    <div class="card-body">
        {% block content %}
        {{ content }}
        {% endblock %}
    </div>
</div>

{% include 'layout/footer.tpl' %}