
<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link active" href="/dashboard">
            {{ 'Unread'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_courses }}</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link " href="/previous" >
            {{ 'SeeAll'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_history }}</span>
        </a>
    </li>

</ul>

{% if messages %}
<div class="card">
    <div class="card-body">
        <table class="table">
            <thead>
            <tr>
                <th scope="col">#</th>
                <th scope="col">Usuario</th>
                <th scope="col">Mensaje</th>
                <th scope="col">Programa</th>
                <th scope="col">Fecha</th>
                <th scope="col">Tipo</th>
                <th scope="col">Acción</th>
            </tr>
            </thead>
            <tbody>
            {% for message in messages %}
            <tr>
                <th scope="row">{{ message.id }}</th>
                <td>{{ message.title }}</td>
                <td>{{ message.status }}</td>
                <td>{{ message.send_date }}</td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
            {% endfor %}
            </tbody>
        </table>

    </div>
</div>
{% endif %}
