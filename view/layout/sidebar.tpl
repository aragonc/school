<!-- Sidebar -->
<ul class="navbar-nav bg-gradient-primary sidebar sidebar-dark accordion" id="accordionSidebar">

    <!-- Sidebar - Brand -->
    <a class="sidebar-brand d-flex align-items-center justify-content-center" href="{{ _p.web }}dashboard">
        <div class="sidebar-brand-small">
            {% if sidebar_icon_url %}
                <img src="{{ sidebar_icon_url }}" alt="Icon" class="img-fluid">
            {% else %}
                <i class="fas fa-school fa-2x"></i>
            {% endif %}
        </div>
        <div class="sidebar-brand-large">
            {{ logo_svg }}
        </div>
    </a>

    <!-- Divider -->
    <hr class="sidebar-divider my-0">

    <!-- Nav Item - Pages Collapse Menu -->
    {% for menu in menus %}
    {% if menu.items %}

    {% if menu.current %}
    <li class="nav-item active">
        {% else %}
    <li class="nav-item ">
        {% endif %}
        <a id="menu-{{ menu.name }}" class="nav-link" href="#" title="{{ menu.label }}" data-toggle="collapse" data-target="#collapse-{{ menu.id }}" aria-expanded="true"
           aria-controls="collapse-{{ menu.id }}">
            <i class="fas fa-fw fa-{{ menu.icon }}"></i>
            <span>{{ menu.label }}</span>
        </a>
        {% if menu.items %}
        <div id="collapse-{{ menu.id }}" class="collapse {{ menu.class }}" aria-labelledby="heading-{{ menu.id }}"
             data-parent="#accordionSidebar">
            <div class="bg-white py-2 collapse-inner rounded">
                {% for submenu in menu.items %}
                <a id="submenu-{{ submenu.name }}" class="collapse-item" href="{{ submenu.url }}">{{ submenu.label }}</a>
                {% endfor %}
            </div>
        </div>
        {% endif %}
    </li>
    {% else %}
    <li class="nav-item {{ menu.class }}">
        <a id="menu-{{ menu.name }}" class="nav-link" href="{{ menu.url }}" title="{{ menu.label }}" data-toggle="tooltip" data-placement="right">
            <i class="fas fa-fw fa-{{ menu.icon }}"></i>
            <span>{{ menu.label }}</span>
        </a>
    </li>
    {% endif %}
    {% endfor %}

    <!-- Divider -->
    <hr class="sidebar-divider d-none d-md-block">


    <!-- Sidebar Toggler (Sidebar) -->
    <div class="text-center d-none d-md-inline">
        <button class="rounded-circle border-0" id="sidebarToggle"></button>
    </div>

</ul>
<!-- End of Sidebar -->