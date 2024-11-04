<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link" href="/notifications">
            {{ 'Unread'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_unread }}</span>
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link active" href="/notifications?action=all" >
            {{ 'SeeAll'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_messages }}</span>
        </a>
    </li>
</ul>

<div class="tab-content" id="tab_courses">
    <div class="tab-pane fade show active" id="current_courses" role="tabpanel" aria-labelledby="current_courses-tab">
        {% if list.messages %}
        <div class="card">
            <div class="card-body">
                <nav class="table-responsive">
                    <table id="table-message" class="table table-borderless">
                        <thead>
                        <tr>
                            <th scope="col">#</th>
                            <th scope="col">{{ 'User'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th scope="col">{{ 'Message'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th scope="col">{{ 'Program'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th scope="col">{{ 'Date'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th scope="col">{{ 'Type'|get_plugin_lang('SchoolPlugin') }}</th>
                            <th scope="col">{{ 'Action'|get_plugin_lang('SchoolPlugin') }}</th>
                        </tr>
                        </thead>
                        <tbody>
                        {% for message in list.messages %}
                        <tr class="{{ message.row }}">
                            <th scope="row">{{ message.check_id }}</th>
                            <td>{{ message.user_avatar }}</td>
                            <td><a class="{{ message.class }}" href="{{ message.link }}">{{ message.title }}</a></td>
                            <td><div class="{{ message.class }}">{{ message.session_title }}</div></td>
                            <td><div class="{{ message.class }}">{{ message.send_date }}</div></td>
                            <td>{{ message.type }}</td>
                            <td>{{ message.action }}</td>
                        </tr>
                        {% endfor %}
                        </tbody>
                    </table>

                    <div id="action-bar" class="d-flex justify-content-between align-items-start">

                        <div class="btn-group" role="group" aria-label="Button group with nested dropdown">
                            <button type="button" class="btn btn-outline-secondary">Seleccionat todo</button>
                            <button type="button" class="btn btn-outline-secondary">Anular seleccionar todos</button>

                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-outline-secondary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    Acciones
                                </button>
                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="#">Seleccionat todo</a>
                                    <a class="dropdown-item" href="#">Anular seleccionar todos</a>
                                </div>
                            </div>
                        </div>

                        {% if list.pagination.totalPages >= 2 %}
                            <nav>
                                <ul class="pagination">
                                    {% if list.pagination.currentPage > 1 %}
                                    <li class="page-item"><a class="page-link" href="?action=all&page={{ list.pagination.currentPage - 1 }}">{{ 'Previous'|get_plugin_lang('SchoolPlugin') }}</a></li>
                                    {% endif %}

                                    {% for i in 1..list.pagination.totalPages %}
                                    {% if i == list.pagination.currentPage %}
                                    <li class="page-item disabled"><a class="page-link"><strong>{{ i }}</strong></a></li>
                                    {% else %}
                                    <li class="page-item"><a class="page-link" href="?action=all&page={{ i }}">{{ i }}</a></li>
                                    {% endif %}
                                    {% endfor %}

                                    {% if list.pagination.currentPage < list.pagination.totalPages %}
                                    <li class="page-item"><a class="page-link" href="?action=all&page={{ list.pagination.currentPage + 1 }}">{{ 'Next'|get_plugin_lang('SchoolPlugin') }}</a></li>
                                    {% endif %}
                                </ul>
                            </nav>
                        {% endif %}

                    </div>

                </div>
            </div>
        </div>
        {% endif %}
    </div>
</div>
