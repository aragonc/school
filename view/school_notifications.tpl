<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link active" href="/notifications">
            {{ 'Unread'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">{{ total_unread }}</span>
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link " href="/notifications?action=all" >
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
                    <table class="table table-borderless">
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
                            <td>{{ message.title }}</td>
                            <td><div class="{{ message.class }}">{{ message.session_title }}</div></td>
                            <td><div class="{{ message.class }}">{{ message.send_date }}</div></td>
                            <td>{{ message.type }}</td>
                            <td></td>
                        </tr>
                        {% endfor %}
                        </tbody>
                    </table>

                    <nav>
                        <ul class="pagination">
                        {% if list.pagination.currentPage > 1 %}
                            <li class="page-item"><a class="page-link" href="?page={{ list.pagination.currentPage - 1 }}">{{ 'Previous'|get_plugin_lang('SchoolPlugin') }}</a></li>
                        {% endif %}

                        {% for i in 1..list.pagination.totalPages %}
                        {% if i == list.pagination.currentPage %}
                            <li class="page-item disabled"><a class="page-link"><strong>{{ i }}</strong></a></li>
                        {% else %}
                            <li class="page-item"><a class="page-link" href="?page={{ i }}">{{ i }}</a></li>
                        {% endif %}
                        {% endfor %}

                        {% if list.pagination.currentPage < list.pagination.totalPages %}
                            <li class="page-item"><a class="page-link" href="?page={{ list.pagination.currentPage + 1 }}">{{ 'Next'|get_plugin_lang('SchoolPlugin') }}</a></li>
                        {% endif %}
                        </ul>
                    </nav>


                </div>
            </div>
        </div>
        {% endif %}
    </div>
</div>
