<!-- Sidebar -->
<ul class="navbar-nav bg-sidebar sidebar sidebar-dark accordion d-none d-lg-block toggled" id="accordionSidebar">

    <!-- Sidebar - Brand -->
    <a class="sidebar-brand d-flex align-items-center justify-content-center" href="{{ _p.web }}">
        <div class="sidebar-brand-icon">
            {{ logo_icon }}
        </div>
        <div class="sidebar-brand-big">
            {{ logo_svg }}
        </div>
    </a>

    <div class="pb-5"></div>
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


    <!--<div class="text-center d-none d-md-inline">
        <button class="rounded-circle border-0" id="sidebarToggle"></button>
    </div>-->

</ul>
<!-- End of Sidebar -->
<!-- Sidebar Mobile -->
<div class="menu-overlay"></div>
<div class="nav-mobile d-sm-block d-md-block d-lg-none"  tabindex="0">
    <nav class="nav-items">
        <div class="d-flex flex-row justify-content-between align-items-center">
            <div class="logo-campus">
                <a href="{{ _p.web }}">{{ logo }}</a>
            </div>
            <div class="p-2">
                <button type="button" id="closeMobile" class="btn btn-outline-primary">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        </div>

        {% for menu in menus %}
        <a id="menu-{{ menu.name }}" class="nav-item {{ menu.class }}" href="{{ menu.url }}" title="{{ menu.label }}">
            <i class="fas fa-fw fa-{{ menu.icon }}"></i>
            <span>{{ menu.label }}</span>
        </a>
        {% endfor %}
    </nav>
</div>
<!-- End of Sidebar Mobile -->