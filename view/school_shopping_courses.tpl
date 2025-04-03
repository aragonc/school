<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link active" href="/shopping">
            {{ 'Courses'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link " href="/shopping?view=graduates">
            {{ 'Graduates'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>
<div class="tab-content" id="tab_courses">
    <div class="tab-pane fade show active" id="current_courses" role="tabpanel" aria-labelledby="current_courses-tab">
        <div class="card">
            <div class="card-body">
                <div class="p-5">

                    <div class="container-fluid">
                        <div class="row">
                            {% if sessions %}
                            {% for session in sessions %}
                            <div class="col-4 mb-4">
                                <div class="card h-100 card-course " style="width: 22rem;">
                                    <div class="card-image">
                                        <a href="{{ _p.web ~ 'view/course/' ~ session.id  }}">
                                            <img alt="{{ session.name }}" class="card-img-top"
                                             src="{{ session.image ? session.image : 'session_default.png'|icon() }}">
                                        </a>
                                        <div class="price">
                                            {{ session.price_new }}
                                        </div>
                                    </div>
                                    <div class="card-body card-course-body">
                                        <div class="tags">
                                            {{ session.tags }}
                                        </div>
                                        <h5 class="card-title">
                                            <a href="{{ _p.web ~ 'view/course/' ~ session.id  }}">{{ session.name }}</a>
                                        </h5>
                                        <div class="date">
                                            {{ session.description }}
                                        </div>
                                        {% if session.enrolled.checking == "YES" %}
                                        <div class="alert alert-success">
                                            <em class="fa fa-check-square-o fa-fw"></em> {{ 'TheUserIsAlreadyRegisteredInTheSession'|get_plugin_lang('BuyCoursesPlugin') }}
                                        </div>
                                        {% endif %}

                                    </div>

                                    <div class="card-footer text-center">
                                        {% if session.enrolled.checking == "NO" %}
                                        <a href="{{ _p.web_plugin ~ 'payments/process-check.php?' ~ {'item': session.id, 'type': 2}|url_encode() }}"
                                           class="btn btn-block btn-primary">
                                            <em class="fa fa-shopping-cart"></em>
                                            {{ 'Buy'|get_plugin_lang('BuyCoursesPlugin') }}
                                        </a>
                                        {% endif %}
                                    </div>

                                </div>
                            </div>
                            {% endfor %}
                        </div>
                    </div>
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
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        $('#search_filter_tag').change(function() {
            $('#search_filter').submit();
        });
    });
</script>