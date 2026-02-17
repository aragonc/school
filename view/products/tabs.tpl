<ul class="nav nav-tabs mb-3">
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'catalog' ? 'active' : '' }}" href="{{ _p.web }}products">
            <i class="fas fa-boxes"></i> {{ 'ProductCatalog'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'categories' ? 'active' : '' }}" href="{{ _p.web }}products/categories">
            <i class="fas fa-tags"></i> {{ 'Categories'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'sell' ? 'active' : '' }}" href="{{ _p.web }}products/sell">
            <i class="fas fa-cash-register"></i> {{ 'SellProduct'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'sales' ? 'active' : '' }}" href="{{ _p.web }}products/sales">
            <i class="fas fa-history"></i> {{ 'SalesHistory'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>
