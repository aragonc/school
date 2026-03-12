<div class="card mb-4">
    <div class="card-body">
        {{ form }}
    </div>
</div>

{% if settings_saved %}
<div class="alert alert-success alert-dismissible fade show" role="alert">
    Configuración guardada correctamente.
    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
</div>
{% endif %}

<div class="card mb-4">
    <div class="card-header">
        <h6 class="m-0 font-weight-bold text-primary"><i class="fas fa-id-card mr-1"></i> Configuración de Matrículas</h6>
    </div>
    <div class="card-body">
        <form method="post" action="{{ settings_url }}">
            <input type="hidden" name="save_matricula_settings" value="1">
            <div class="form-group mb-3">
                <div class="custom-control custom-switch">
                    <input type="checkbox" class="custom-control-input" id="reniec_visible"
                           name="reniec_visible" value="1" {{ reniec_visible ? 'checked' : '' }}>
                    <label class="custom-control-label" for="reniec_visible">
                        Mostrar botón <strong>RENIEC</strong> en la ficha de matrícula
                    </label>
                </div>
                <small class="form-text text-muted ml-4">
                    Cuando está activo, aparece el botón para consultar apellidos y nombres desde RENIEC al ingresar un DNI peruano.
                </small>
            </div>
            <button type="submit" class="btn btn-primary btn-sm">
                <i class="fas fa-save mr-1"></i> Guardar configuración
            </button>
        </form>
    </div>
</div>

<div class="card mb-4">
    <div class="card-header">
        <h6 class="m-0 font-weight-bold text-primary"><i class="fab fa-google mr-1"></i> Configuración de Inicio de Sesión</h6>
    </div>
    <div class="card-body">
        <form method="post" action="{{ settings_url }}">
            <input type="hidden" name="save_login_settings" value="1">
            <div class="form-group mb-3">
                <div class="custom-control custom-switch">
                    <input type="checkbox" class="custom-control-input" id="google_only_login"
                           name="google_only_login" value="1" {{ google_only_login ? 'checked' : '' }}>
                    <label class="custom-control-label" for="google_only_login">
                        Permitir <strong>solo inicio de sesión con Google</strong>
                    </label>
                </div>
                <small class="form-text text-muted ml-4">
                    Cuando está activo, se oculta el formulario de usuario/contraseña y solo se muestra el botón de Google.
                </small>
            </div>
            <div class="form-group mb-3">
                <label for="login_info_message" class="font-weight-bold">Mensaje informativo en el login</label>
                <textarea class="form-control" id="login_info_message" name="login_info_message" rows="3"
                          placeholder="Ej: Para ingresar al aula virtual debes usar la cuenta Google institucional que te proporcionó la institución.">{{ login_info_message }}</textarea>
                <small class="form-text text-muted">
                    Este mensaje se mostrará como aviso informativo en la pantalla de inicio de sesión. Déjalo en blanco para no mostrar ningún aviso.
                </small>
            </div>
            <button type="submit" class="btn btn-primary btn-sm">
                <i class="fas fa-save mr-1"></i> Guardar configuración
            </button>
        </form>
    </div>
</div>

<div class="card mb-4">
    <div class="card-header">
        <h6 class="m-0 font-weight-bold text-primary"><i class="fas fa-clock mr-1"></i> Configuración de Asistencia</h6>
    </div>
    <div class="card-body">
        <form method="post" action="{{ settings_url }}">
            <input type="hidden" name="save_attendance_settings" value="1">
            <div class="form-group mb-3">
                <div class="custom-control custom-switch">
                    <input type="checkbox" class="custom-control-input" id="attendance_show_checkin_time"
                           name="attendance_show_checkin_time" value="1" {{ attendance_show_checkin_time ? 'checked' : '' }}>
                    <label class="custom-control-label" for="attendance_show_checkin_time">
                        Mostrar <strong>hora de ingreso</strong> al alumno en su historial de asistencia
                    </label>
                </div>
                <small class="form-text text-muted ml-4">
                    Cuando está desactivado, el alumno solo verá su estado (Puntual / Tarde / Ausente) sin la hora exacta de registro.
                </small>
            </div>
            <button type="submit" class="btn btn-primary btn-sm">
                <i class="fas fa-save mr-1"></i> Guardar configuración
            </button>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h6 class="m-0 font-weight-bold text-primary">Favicon (PNG)</h6>
    </div>
    <div class="card-body">

        {% if favicon_msg == 'success' %}
            <div class="alert alert-success">Favicon actualizado correctamente.</div>
        {% elseif favicon_msg == 'invalid' %}
            <div class="alert alert-danger">El archivo debe ser una imagen PNG válida.</div>
        {% elseif favicon_msg == 'error' %}
            <div class="alert alert-danger">Error al subir el archivo.</div>
        {% elseif favicon_msg == 'deleted' %}
            <div class="alert alert-info">Favicon eliminado. Se usará el SVG por defecto.</div>
        {% endif %}

        {% if favicon_exists %}
            <div class="mb-3 d-flex align-items-center">
                <img src="{{ favicon_web_url }}?t={{ 'now'|date('U') }}" alt="Favicon actual"
                     style="width:48px;height:48px;object-fit:contain;border:1px solid #dee2e6;border-radius:4px;padding:4px;margin-right:12px;">
                <div>
                    <div class="text-muted" style="font-size:13px;">Favicon actual (PNG)</div>
                    <form method="post" action="{{ settings_url }}" class="d-inline mt-1">
                        <input type="hidden" name="delete_favicon" value="1">
                        <button type="submit" class="btn btn-sm btn-outline-danger"
                                onclick="return confirm('¿Eliminar favicon PNG y volver al SVG por defecto?')">
                            <i class="fas fa-trash"></i> Eliminar
                        </button>
                    </form>
                </div>
            </div>
        {% else %}
            <p class="text-muted" style="font-size:13px;">No hay favicon PNG configurado. Se usa el SVG por defecto.</p>
        {% endif %}

        <form method="post" action="{{ settings_url }}" enctype="multipart/form-data">
            <div class="form-group">
                <label for="favicon_png" class="font-weight-bold">Subir nuevo favicon PNG</label>
                <div class="custom-file" style="max-width:320px;">
                    <input type="file" class="custom-file-input" id="favicon_png" name="favicon_png" accept="image/png">
                    <label class="custom-file-label" for="favicon_png">Seleccionar archivo PNG...</label>
                </div>
                <small class="form-text text-muted">Se recomienda un tamaño de 32×32 o 64×64 píxeles.</small>
            </div>
            <button type="submit" class="btn btn-primary">
                <i class="fas fa-upload"></i> Subir favicon
            </button>
        </form>

    </div>
</div>

<script>
document.getElementById('favicon_png').addEventListener('change', function () {
    var label = this.nextElementSibling;
    label.textContent = this.files.length ? this.files[0].name : 'Seleccionar archivo PNG...';
});
</script>
