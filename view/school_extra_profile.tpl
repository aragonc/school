<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link" href="/profile">
            {{ 'PersonalData'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link active" href="/extra-profile">
            {{ 'ExtraProfileData'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link" href="/password">
            {{ 'ChangePassword'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link" href="/avatar">
            {{ 'EditAvatar'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>
</ul>

<div class="card">
    <div class="card-body">
        <div class="p-0 p-md-5">
            <div class="row">
                <div class="col-12 col-lg-8">
                    <h5 class="mb-4">
                        <i class="fas fa-id-card"></i> {{ 'ExtraProfileData'|get_plugin_lang('SchoolPlugin') }}
                    </h5>
                    {{ form }}
                </div>
                <div class="col-12 col-lg-4">
                    <div class="d-none d-md-block">
                        <div class="bd-callout bd-callout-info">
                            <p><i class="fas fa-info-circle"></i> {{ 'ExtraProfileHelp'|get_plugin_lang('SchoolPlugin') }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
