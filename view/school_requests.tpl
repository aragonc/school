<div class="card">
    <div class="card-body">

        {% if action == 'create' %}
            {{ form }}
        {% endif %}

        {% if action == 'list' %}

        <a class="btn btn-primary btn-download" href="?action=create">{{ 'CreateNewRequest'|get_plugin_lang('SchoolPlugin') }}</a>
        <table id="table-request" class="table table-borderless">
            <thead>
                <tr>
                    <th scope="col">#</th>
                    <th scope="col">{{ 'TitleRequest'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th scope="col">{{ 'Program'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th scope="col">{{ 'Description'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th scope="col">{{ 'Phase'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th scope="col">{{ 'Date'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th scope="col">{{ 'Action'|get_plugin_lang('SchoolPlugin') }}</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>

        {% endif %}
    </div>
</div>