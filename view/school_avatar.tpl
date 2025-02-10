<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link " href="/profile">
            {{ 'PersonalData'|get_plugin_lang('SchoolPlugin') }}
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link " href="/password" >
            {{ 'ChangePassword'|get_plugin_lang('SchoolPlugin') }}
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

                </div>
            </div>
        </div>
    </div>
</div>
<script>
    $(document).ready(function () {
        $('#form_avatar_submit').hide();
        $('#picture_crop_button').on('click', function () {
            // Habilitar el botón
            $('#form_avatar_submit').show();
            $('#form_avatar_submit').prop('disabled', false);
        });
    });
</script>
