<nav class="navbar navbar-expand navbar-light bg-white topbar mb-4 static-top">
    <button id="sidebarToggleTop" class="btn btn-link d-md-none rounded-circle mr-3">
        <i class="fa fa-bars"></i>
    </button>

    <!-- Topbar Navbar -->
    <ul class="navbar-nav ml-auto">
        <li class="nav-item dropdown no-arrow mx-1">
            <a class="nav-link dropdown-toggle" href="#" id="alertsDropdown" role="button"
               data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                <div class="badge-bell">
                    <i class="fas fa-bell fa-fw text-white"></i>
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
                        <a href="{{ profile_url }}">
                            <img class="img-circle" src="{{ _u.avatar_medium }}" alt="{{ _u.complete_name }}"/>
                            <p class="name">{{ _u.firstname }} {{ _u.lastname }}</p>
                        </a>
                        <p><i class="fas fa-envelope fa-fw"></i> {{ _u.email }}</p>
                    </div>
                </div>
                <div class="dropdown-divider"></div>
                <a class="dropdown-item" href="profile">
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
