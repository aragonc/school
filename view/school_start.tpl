
<ul class="nav nav-tabs" id="myTab" role="tablist">
    <li class="nav-item" role="presentation">
        <button class="nav-link active" id="home-tab" data-toggle="tab" data-target="#current_courses" type="button" role="tab" aria-controls="current_courses" aria-selected="true">
            {{ 'Current'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </li>
    <li class="nav-item" role="presentation">
        <button class="nav-link" id="profile-tab" data-toggle="tab" data-target="#previous_courses" type="button" role="tab" aria-controls="previous_courses" aria-selected="false">
            {{ 'Previous'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </li>

</ul>
<div class="tab-content" id="myTabContent">
    <div class="tab-pane fade show active" id="current_courses" role="tabpanel" aria-labelledby="current_courses-tab">


        {% for category in categories %}
            <div id="category_{{ category.category_id }}" class="category">
                {{ category.category_image }} {{ category.category_name }}
            </div>
            {% for session in category.sessions %}
                <div id="session_{{ session.id }}" class="session">
                    <h3>{{ session.name }}</h3>
                </div>
            {% endfor %}

        {% endfor %}


    </div>
    <div class="tab-pane fade" id="previous_courses" role="tabpanel" aria-labelledby="previous_courses-tab">...</div>
</div>



