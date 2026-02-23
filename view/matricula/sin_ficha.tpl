<div class="card shadow mb-4">
    <div class="card-header py-3 d-flex justify-content-between align-items-center">
        <h6 class="m-0 font-weight-bold text-primary">
            <i class="fas fa-user-times mr-1"></i>
            {{ 'StudentsWithoutEnrollment'|get_plugin_lang('SchoolPlugin') }}
        </h6>
        <span class="badge badge-warning badge-pill">{{ students|length }}</span>
    </div>
    <div class="card-body">

        <form method="get" class="mb-3">
            <div class="input-group" style="max-width:400px;">
                <input type="text" name="search" class="form-control"
                       placeholder="{{ 'Search'|get_lang }}"
                       value="{{ search }}">
                <div class="input-group-append">
                    <button class="btn btn-primary" type="submit">
                        <i class="fas fa-search"></i>
                    </button>
                    {% if search %}
                    <a href="?" class="btn btn-outline-secondary">
                        <i class="fas fa-times"></i>
                    </a>
                    {% endif %}
                </div>
            </div>
        </form>

        {% if students|length == 0 %}
        <div class="alert alert-success">
            <i class="fas fa-check-circle mr-1"></i>
            Todos los alumnos activos tienen ficha de matrícula.
        </div>
        {% else %}
        <div class="table-responsive">
            <table class="table table-bordered table-hover table-sm" id="tabla-sin-ficha">
                <thead class="thead-light">
                    <tr>
                        <th>Apellidos y nombres</th>
                        <th>Usuario</th>
                        <th>Correo</th>
                        <th>Registro</th>
                        <th class="text-center">Acción</th>
                    </tr>
                </thead>
                <tbody>
                    {% for s in students %}
                    <tr>
                        <td>{{ s.lastname }}, {{ s.firstname }}</td>
                        <td><code>{{ s.username }}</code></td>
                        <td>{{ s.email }}</td>
                        <td>{{ s.registration_date|date('d/m/Y') }}</td>
                        <td class="text-center">
                            <a href="{{ form_url }}?user_id={{ s.user_id }}"
                               class="btn btn-sm btn-success">
                                <i class="fas fa-file-medical mr-1"></i>
                                Crear ficha de matrícula
                            </a>
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
        {% endif %}

    </div>
</div>

<script>
$(document).ready(function () {
    if ($.fn.DataTable) {
        $('#tabla-sin-ficha').DataTable({
            language: { url: '//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json' },
            order: [[0, 'asc']],
            pageLength: 25,
            columnDefs: [{ orderable: false, targets: 4 }]
        });
    }
});
</script>
