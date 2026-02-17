{% include 'products/tabs.tpl' with {'active_tab': 'categories'} %}

<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="fas fa-tags"></i> {{ 'Categories'|get_plugin_lang('SchoolPlugin') }}</span>
        <button class="btn btn-primary btn-sm" onclick="openCategoryModal()">
            <i class="fas fa-plus"></i> {{ 'AddCategory'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
                <thead class="thead-light">
                    <tr>
                        <th>#</th>
                        <th>{{ 'CategoryName'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-center">{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th class="text-center">{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for cat in categories %}
                    <tr>
                        <td>{{ cat.id }}</td>
                        <td><strong>{{ cat.name }}</strong></td>
                        <td class="text-center">
                            {% if cat.active %}
                                <span class="badge badge-success">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% else %}
                                <span class="badge badge-secondary">{{ 'Inactive'|get_plugin_lang('SchoolPlugin') }}</span>
                            {% endif %}
                        </td>
                        <td class="text-center">
                            <button class="btn btn-warning btn-sm" onclick="editCategory({{ cat.id }}, '{{ cat.name|e('js') }}', {{ cat.active }})">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-danger btn-sm" onclick="deleteCategory({{ cat.id }})">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                    {% else %}
                    <tr>
                        <td colspan="4" class="text-center text-muted py-4">
                            <i class="fas fa-tags fa-2x mb-2 d-block"></i>
                            {{ 'NoCategories'|get_plugin_lang('SchoolPlugin') }}
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Category Modal -->
<div class="modal fade" id="categoryModal" tabindex="-1">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="categoryModalTitle">{{ 'AddCategory'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="cat_id" value="0">
                <div class="form-group">
                    <label>{{ 'CategoryName'|get_plugin_lang('SchoolPlugin') }} *</label>
                    <input type="text" id="cat_name" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}</label>
                    <select id="cat_active" class="form-control">
                        <option value="1">{{ 'Active'|get_plugin_lang('SchoolPlugin') }}</option>
                        <option value="0">{{ 'Inactive'|get_plugin_lang('SchoolPlugin') }}</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ 'Cancel'|get_plugin_lang('SchoolPlugin') }}</button>
                <button type="button" class="btn btn-primary" onclick="saveCategory()">
                    <i class="fas fa-save"></i> {{ 'Save'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';

function openCategoryModal() {
    document.getElementById('cat_id').value = 0;
    document.getElementById('cat_name').value = '';
    document.getElementById('cat_active').value = '1';
    document.getElementById('categoryModalTitle').textContent = '{{ 'AddCategory'|get_plugin_lang('SchoolPlugin') }}';
    $('#categoryModal').modal('show');
}

function editCategory(id, name, active) {
    document.getElementById('cat_id').value = id;
    document.getElementById('cat_name').value = name;
    document.getElementById('cat_active').value = active;
    document.getElementById('categoryModalTitle').textContent = '{{ 'EditCategory'|get_plugin_lang('SchoolPlugin') }}';
    $('#categoryModal').modal('show');
}

function saveCategory() {
    var name = document.getElementById('cat_name').value.trim();
    if (!name) {
        alert('{{ 'FillRequiredFields'|get_plugin_lang('SchoolPlugin') }}');
        return;
    }
    $.ajax({
        url: ajaxUrl,
        type: 'POST',
        data: {
            action: 'save_category',
            id: document.getElementById('cat_id').value,
            name: name,
            active: document.getElementById('cat_active').value
        },
        success: function(response) {
            if (response.success) {
                location.reload();
            } else {
                alert(response.message || 'Error');
            }
        }
    });
}

function deleteCategory(id) {
    if (!confirm('{{ 'ConfirmDelete'|get_plugin_lang('SchoolPlugin') }}')) return;
    $.ajax({
        url: ajaxUrl,
        type: 'POST',
        data: { action: 'delete_category', id: id },
        success: function(response) {
            if (response.success) {
                location.reload();
            }
        }
    });
}
</script>
