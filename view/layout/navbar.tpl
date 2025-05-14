<nav class="navbar navbar-expand navbar-light bg-white topbar mb-4 static-top">
    <button id="sidebarToggleTop" class="btn btn-link d-md-none rounded-circle">
        <i class="fa fa-bars"></i>
    </button>

    <div class="logo-campus d-sm-inline-block d-md-none">
        {{ logo }}
    </div>

    <form class="d-none d-sm-inline-block form-inline ml-auto mr-md-3 my-2 my-md-0 mw-100 navbar-search">
        <div id="loader"><img src="{{ image_url }}spinner.gif" alt="Cargando..." width="20"></div>
        <div class="input-group">
            <input id="term" name="term" type="text" class="form-control bg-light border-0 small" placeholder="{{ 'SearchCourses'|get_plugin_lang('SchoolPlugin') }}"
                   aria-label="Search" aria-describedby="basic-addon2">
        </div>
        <div class="dropdown-list">
            <ul class="list-group" id="result"></ul>
        </div>

    </form>

    <!-- Topbar Navbar -->
    <ul class="navbar-nav ">

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
