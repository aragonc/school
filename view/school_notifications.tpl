{% if total > 0 %}
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

        {% if total_unread != 0 %}
        {% if list.messages %}
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <form id="form_message_inbox_id" method="post" action="{{ _p.web }}notifications" name="form_message_inbox">
                    <input type="hidden" name="action">
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
                            <td><a class="{{ message.class }}" href="{{ message.link }}">{{ message.user_avatar }}</a></td>
                            <td><a class="{{ message.class }}" href="{{ message.link }}">{{ message.title }}</a></td>
                            <td>
                                <a class="{{ message.class }}" href="{{ message.link }}">
                                    <div class="{{ message.class }}">{{ message.session_title }}</div>
                                </a>
                            </td>
                            <td><div class="{{ message.class }}">{{ message.send_date }}</div></td>
                            <td>{{ message.type }}</td>
                            <td>{{ message.action }}</td>
                        </tr>
                        {% endfor %}
                        </tbody>
                    </table>

                    <div id="action-bar" class="d-flex justify-content-between align-items-start">

                        <div class="btn-group" role="group" aria-label="Button group with nested dropdown">
                            <a href="#" onclick="javascript: setCheckboxTable(true, 'form_message_inbox_id'); return false;" class="btn btn-outline-secondary">{{ 'SelectAll'|get_plugin_lang('SchoolPlugin') }}</a>
                            <a href="#" onclick="javascript: setCheckboxTable(false, 'form_message_inbox_id'); return false;" class="btn btn-outline-secondary">{{ 'CancelSelected'|get_plugin_lang('SchoolPlugin') }}</a>

                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-outline-secondary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    {{ 'Actions'|get_plugin_lang('SchoolPlugin') }}
                                </button>
                                <div class="dropdown-menu">
                                    <a data-action="mark_as_unread" onclick="javascript:action_click_table(this, 'form_message_inbox_id');" class="dropdown-item" href="#">{{ 'MarkAsUnread'|get_plugin_lang('SchoolPlugin') }}</a>
                                    <a data-action="mark_as_read" onclick="javascript:action_click_table(this, 'form_message_inbox_id');" class="dropdown-item" href="#">{{ 'MarkAsRead'|get_plugin_lang('SchoolPlugin') }}</a>
                                </div>
                            </div>
                        </div>

                        {% if list.pagination.totalPages >= 2 %}
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
                        {% endif %}
                    </div>
                    </form>
                </div>
            </div>
        </div>
        {% endif %}
        {% else %}
            <div class="card">
                <div class="card-body">
                    <div class="p-5 text-center">
                        <h3>{{ 'YouHaveNoNewNotifications'|get_plugin_lang('SchoolPlugin') }}</h3>
                        {{ img_section }}
                    </div>
                </div>
            </div>
        {% endif %}
    </div>
</div>
{% else %}
<div class="card">
    <div class="card-body">
        <div class="p-5 text-center">
            <h3>{{ 'HereYourNotificationsWillBe'|get_plugin_lang('SchoolPlugin') }}</h3>
            {{ img_section }}
        </div>
    </div>
</div>
{% endif %}