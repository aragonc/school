<nav class="navbar navbar-expand navbar-light bg-white topbar mb-4 static-top shadow">
    <!-- Sidebar Toggle (Topbar) -->
    <button id="sidebarToggleTop" class="btn btn-link d-md-none rounded-circle mr-3">
        <i class="fa fa-bars"></i>
    </button>
    {% if platform_name %}
    <span class="d-none d-lg-inline-block text-gray-600 font-weight-bold ml-2">{{ platform_name }}{% if institution_name %} - {{ institution_name }}{% endif %}</span>
    {% endif %}

    {% if enabled_search %}
    <form class="d-none d-sm-inline-block form-inline ml-auto my-2 my-md-0 mw-100 navbar-search">
        <div id="loader"><img src="{{ image_url }}spinner.gif" alt="Cargando..." width="20"></div>
        <div class="input-group">
            <input id="term1" name="term" type="text" class="terms-search form-control bg-light border-0 small" placeholder="{{ 'SearchCourses'|get_plugin_lang('SchoolPlugin') }}"
                   aria-label="Search" aria-describedby="basic-addon2">
        </div>
        <div class="dropdown-list">
            <ul class="result_search list-group" id="result"></ul>
        </div>
    </form>
    {% else %}
        <div class="ml-auto my-2 my-md-0 mw-100 "></div>
    {% endif %}

    <!-- Topbar Navbar -->
    <ul class="navbar-nav">
        {% if enabled_search %}
        <!-- Nav Item - Search Dropdown (Visible Only XS) -->
        <li class="nav-item dropdown no-arrow d-sm-none">

            <a class="nav-link dropdown-toggle" href="#" id="searchDropdown" role="button"
               data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                <div class="icon-search">
                    <i class="fas fa-search fa-fw"></i>
                </div>
            </a>

            <!-- Dropdown - Messages -->
            <div class="dropdown-menu dropdown-menu-right p-3 shadow animated--grow-in"
                 aria-labelledby="searchDropdown">
                <form class="form-inline mr-auto w-100 navbar-search">
                    <div class="input-group">
                        <input id="term2" name="term" type="text" class="form-control terms-search bg-light border-0 small"
                               placeholder="{{ 'SearchCourses'|get_plugin_lang('SchoolPlugin') }}" aria-label="Search"
                               aria-describedby="basic-addon2">
                    </div>
                    <div class="dropdown-list">
                        <ul class="result_search list-group" id="result"></ul>
                    </div>
                </form>
            </div>
        </li>
        {% endif %}

        {% if show_back_to_portal and (_u.is_admin or _u.status == 1) %}
        <li class="nav-item mr-2">
            {% if _u.is_admin %}
            <a class="btn btn-sm btn-outline-secondary" href="{{ _p.web }}main/admin/index.php">
                <i class="fas fa-arrow-left fa-sm mr-1"></i>
                {{ 'BackToPreviousPortal'|get_plugin_lang('SchoolPlugin') }}
            </a>
            {% else %}
            <a class="btn btn-sm btn-outline-secondary" href="{{ _p.web }}user_portal.php">
                <i class="fas fa-arrow-left fa-sm mr-1"></i>
                {{ 'BackToPreviousPortal'|get_plugin_lang('SchoolPlugin') }}
            </a>
            {% endif %}
        </li>
        {% endif %}

        {% if show_alerts_dropdown %}
        <li class="nav-item dropdown no-arrow mx-1">
            <a class="nav-link dropdown-toggle" href="#" id="alertsDropdown" role="button"
               data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                <div class="badge-bell">
                    <i class="fas fa-bell fa-fw"></i>
                    <span id="badge-counter" class="badge badge-danger badge-counter">0</span>
                </div>
            </a>
            <div class="dropdown-list dropdown-menu dropdown-menu-right shadow animated--grow-in"
                 aria-labelledby="alertsDropdown">
                <h6 class="dropdown-header">
                    {{ 'YourRecentNotifications'|get_plugin_lang('SchoolPlugin') }}
                </h6>
                <div id="notifications">

                </div>
            </div>
        </li>
        <li class="topbar-divider d-none d-sm-block"></li>
        {% endif %}
        <li class="nav-item dropdown no-arrow">
                <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button"
                   data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <div class="username-dropdown">
                    <span class="mr-2 d-none d-lg-inline text-gray-600 small">{{ _u.firstName }}</span>
                    <img class="img-profile rounded-circle"
                         src="{{ _u.avatar_medium }}" alt="{{ _u.complete_name }}">
                    </div>
                </a>
            <div class="dropdown-menu dropdown-menu-right shadow animated--grow-in"
                 aria-labelledby="userDropdown">
                <div class="user-header">
                    <div class="text-center">
                        <a href="{{ _p.web }}profile">
                            <img class="img-circle" src="{{ _u.avatar_medium }}" alt="{{ _u.complete_name }}"/>
                            <p class="name">{{ _u.firstname }} {{ _u.lastname }}</p>
                        </a>
                        <p><i class="fas fa-envelope fa-fw"></i> {{ _u.email }}</p>
                    </div>
                </div>
                <div class="dropdown-divider"></div>
                {% if _u.is_admin %}
                <a class="dropdown-item" href="{{ _p.web }}main/admin/index.php">
                    <i class="fas fa-cogs fa-sm fa-fw mr-2 text-gray-800"></i>
                    {{ 'Administration'|get_lang }}
                </a>
                {% endif %}
                {% if _u.status == 1 and not _u.is_admin %}
                <a class="dropdown-item" href="{{ _p.web }}user_portal.php">
                    <i class="fas fa-chalkboard-teacher fa-sm fa-fw mr-2 text-gray-800"></i>
                    {{ 'MyCourses'|get_lang }}
                </a>
                {% endif %}
                <a class="dropdown-item" href="{{ _p.web }}profile">
                    <i class="fas fa-user fa-sm fa-fw mr-2 text-gray-800"></i>
                    {{ 'EditProfile'|get_plugin_lang('SchoolPlugin') }}
                </a>
                <a class="dropdown-item" href="#" data-toggle="modal" data-target="#logoutModal">
                    <i class="fas fa-sign-out-alt fa-sm fa-fw mr-2 text-gray-800"></i>
                    {{ 'Logout'|get_plugin_lang('SchoolPlugin') }}
                </a>
            </div>
        </li>
    </ul>
</nav>

<!-- End of Topbar -->
