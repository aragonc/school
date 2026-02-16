<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link active" href="#">
            {{ 'Current'|get_plugin_lang('SchoolPlugin') }} <span class="badge badge-info">0</span>
        </a>
    </li>
</ul>
<div class="card">
    <div class="card-body">
        <div class="p-5 text-center">
            <h3>{{ 'HereWillBeYourTrainings'|get_plugin_lang('SchoolPlugin') }}</h3>
            <p>{{ 'CatalogueOfCoursesAndDiplomas'|get_plugin_lang('SchoolPlugin') }}            </p>
            {{ img_section }}
        </div>
    </div>
</div>
{% if show_profile_completion_modal %}
{% include 'profile/completion_modal.tpl' %}
{% endif %}
