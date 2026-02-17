<ul class="nav nav-tabs mb-4">
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'classrooms' ? 'active' : '' }}" href="{{ _p.web }}academic">
            <i class="fas fa-chalkboard"></i> {{ 'Classrooms'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    {% if is_admin is defined and is_admin %}
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'settings' ? 'active' : '' }}" href="{{ _p.web }}academic/settings">
            <i class="fas fa-cogs"></i> {{ 'AcademicSettings'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    {% endif %}
</ul>
