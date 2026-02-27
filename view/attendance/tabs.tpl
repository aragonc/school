<!-- Tabs Navigation -->
<ul class="nav nav-tabs mb-4" id="attendanceTabs" role="tablist">
    {% if is_admin %}
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'today' ? 'active' : '' }}" href="{{ _p.web }}attendance/today">
            <i class="fas fa-calendar-day"></i> {{ 'TodayAttendance'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'manual' ? 'active' : '' }}" href="{{ _p.web }}attendance/manual">
            <i class="fas fa-id-badge"></i> {{ 'AttendancePersonal'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'manual_students' ? 'active' : '' }}" href="{{ _p.web }}attendance/manual_students">
            <i class="fas fa-user-graduate"></i> {{ 'AttendanceStudents'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'schedules' ? 'active' : '' }}" href="{{ _p.web }}attendance/schedules">
            <i class="fas fa-clock"></i> {{ 'Schedules'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'reports' ? 'active' : '' }}" href="{{ _p.web }}attendance/reports">
            <i class="fas fa-chart-bar"></i> {{ 'Reports'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'calendar' ? 'active' : '' }}" href="{{ _p.web }}attendance/calendar">
            <i class="fas fa-calendar-alt"></i> {{ 'AttendanceCalendar'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    {% endif %}
    <li class="nav-item">
        <a class="nav-link {{ active_tab == 'my' ? 'active' : '' }}" href="{{ _p.web }}attendance/my">
            <i class="fas fa-user-clock"></i> {{ 'MyAttendance'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>
