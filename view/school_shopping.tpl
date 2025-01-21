
<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link active" href="/shopping">
            {{ 'Courses'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link " href="/shopping?view=all" >
            {{ 'Graduates'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>

<div class="tab-content" id="tab_courses">
    <div class="tab-pane fade show active" id="current_courses" role="tabpanel" aria-labelledby="current_courses-tab">

        {% if total_unread != 0 %}

        {% else %}
        <div class="card">
            <div class="card-body">
                <div class="p-5 text-center">
                    <h3>{{ 'ThereAreNoCoursesAvailable'|get_plugin_lang('SchoolPlugin') }}</h3>
                    {{ img_section }}
                </div>
            </div>
        </div>
        {% endif %}
    </div>
</div>
