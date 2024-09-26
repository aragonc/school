
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

        <div class="accordion" id="sessions_accordion">
            {% for session in category.sessions %}
            <div class="card">
                <div class="card-header" id="heading_session_{{ session.id }}">
                    <h2 class="mb-0">
                        <button class="btn btn-link btn-block text-left" type="button" data-toggle="collapse" data-target="#collapse_session_{{ session.id }}" aria-expanded="true" aria-controls="collapse_session_{{ session.id }}">
                            {{ session.session_image }} {{ session.name }}
                        </button>
                    </h2>
                </div>

                <div id="collapse_session_{{ session.id }}" class="collapse" aria-labelledby="heading_session_{{ session.id }}" data-parent="#sessions_accordion">
                    <div class="card-body">

                        <ul>
                            {% for course in session.courses %}
                            <li>
                                {{ course.title }}
                            </li>
                            {% endfor %}
                        </ul>

                    </div>
                </div>
            </div>
            {% endfor %}
        </div>






                <div id="session_" class="session">
                    <h4></h4>
                </div>


        {% endfor %}


    </div>
    <div class="tab-pane fade" id="previous_courses" role="tabpanel" aria-labelledby="previous_courses-tab">...</div>
</div>



