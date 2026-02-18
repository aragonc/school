<ul class="nav nav-tabs mb-3">
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'periods' ? 'active' : '' }}" href="{{ _p.web }}payments">
            <i class="fas fa-calendar-alt"></i> {{ 'PaymentPeriods'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'pricing' ? 'active' : '' }}" href="{{ _p.web }}payments/pricing">
            <i class="fas fa-tags"></i> {{ 'Pricing'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'discounts' ? 'active' : '' }}" href="{{ _p.web }}payments/discounts">
            <i class="fas fa-percentage"></i> {{ 'Discounts'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'reports' ? 'active' : '' }}" href="{{ _p.web }}payments/reports">
            <i class="fas fa-chart-bar"></i> {{ 'PaymentReports'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>
