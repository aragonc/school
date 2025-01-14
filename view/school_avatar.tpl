<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link" href="/profile">
            {{ 'EditProfile'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link active" href="/avatar" >
            {{ 'EditAvatar'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>

</ul>

<div class="card">
    <div class="card-body">
        <div class="p-5">
            <div class="row">
                <div class="col">
                    {{ form }}
                </div>
                <div class="col">
                    <div class="text-center">
                        {{ img_section }}
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>