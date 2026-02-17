{% include 'academic/tabs.tpl' with {'active_tab': 'classrooms', 'is_admin': is_admin} %}

<div class="mb-3">
    <a href="{{ _p.web }}academic?year_id={{ classroom.academic_year_id }}" class="btn btn-outline-secondary btn-sm">
        <i class="fas fa-arrow-left"></i> {{ 'BackToClassrooms'|get_plugin_lang('SchoolPlugin') }}
    </a>
</div>

<!-- Classroom Info -->
<div class="card mb-4">
    <div class="card-header">
        <i class="fas fa-chalkboard"></i>
        <strong>{{ classroom.year_name }} — {{ classroom.level_name }} — {{ classroom.grade_name }} "{{ classroom.section_name }}"</strong>
    </div>
    <div class="card-body">
        <div class="row">
            <div class="col-md-6">
                <!-- Tutor -->
                <div class="card mb-3">
                    <div class="card-body d-flex align-items-center">
                        {% if classroom.tutor_avatar %}
                            <img src="{{ classroom.tutor_avatar }}" class="rounded-circle mr-3" width="50" height="50" alt="Tutor">
                        {% else %}
                            <div class="rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center mr-3" style="width:50px;height:50px;">
                                <i class="fas fa-user-tie"></i>
                            </div>
                        {% endif %}
                        <div>
                            <small class="text-muted">{{ 'Tutor'|get_plugin_lang('SchoolPlugin') }}</small>
                            <div class="font-weight-bold">
                                {% if classroom.tutor_name %}
                                    {{ classroom.tutor_name }}
                                {% else %}
                                    <span class="text-muted">{{ 'NoTutor'|get_plugin_lang('SchoolPlugin') }}</span>
                                {% endif %}
                            </div>
                        </div>
                        <button class="btn btn-outline-primary btn-sm ml-auto" data-toggle="modal" data-target="#tutorModal">
                            <i class="fas fa-exchange-alt"></i> {{ 'ChangeTutor'|get_plugin_lang('SchoolPlugin') }}
                        </button>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body py-2">
                        <small class="text-muted">{{ 'Students'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div class="h4 mb-0">{{ students|length }} / {{ classroom.capacity }}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body py-2">
                        <small class="text-muted">{{ 'Capacity'|get_plugin_lang('SchoolPlugin') }}</small>
                        <div class="h4 mb-0">{{ classroom.capacity }}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Students -->
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="fas fa-users"></i> {{ 'Students'|get_plugin_lang('SchoolPlugin') }} ({{ students|length }})</span>
        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addStudentModal">
            <i class="fas fa-user-plus"></i> {{ 'AddStudent'|get_plugin_lang('SchoolPlugin') }}
        </button>
    </div>
    <div class="card-body p-0">
        {% if students|length > 0 %}
        <table class="table table-hover table-sm mb-0">
            <thead class="thead-light">
                <tr>
                    <th style="width:50px">#</th>
                    <th style="width:50px"></th>
                    <th>{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Username'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'Email'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th>{{ 'EnrolledAt'|get_plugin_lang('SchoolPlugin') }}</th>
                    <th style="width:80px">{{ 'Actions'|get_plugin_lang('SchoolPlugin') }}</th>
                </tr>
            </thead>
            <tbody>
                {% for i, student in students %}
                <tr>
                    <td>{{ i + 1 }}</td>
                    <td>
                        {% if student.avatar %}
                            <img src="{{ student.avatar }}" class="rounded-circle" width="30" height="30" alt="">
                        {% else %}
                            <div class="rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center" style="width:30px;height:30px;font-size:12px;">
                                <i class="fas fa-user"></i>
                            </div>
                        {% endif %}
                    </td>
                    <td><strong>{{ student.lastname }}, {{ student.firstname }}</strong></td>
                    <td>{{ student.username }}</td>
                    <td>{{ student.email }}</td>
                    <td>{{ student.enrolled_at|date('d/m/Y') }}</td>
                    <td>
                        <button class="btn btn-danger btn-sm" onclick="removeStudent({{ student.user_id }})" title="{{ 'Remove'|get_plugin_lang('SchoolPlugin') }}">
                            <i class="fas fa-user-minus"></i>
                        </button>
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
        {% else %}
        <div class="p-3">
            <div class="alert alert-info mb-0">
                <i class="fas fa-info-circle"></i> {{ 'NoStudentsInClassroom'|get_plugin_lang('SchoolPlugin') }}
            </div>
        </div>
        {% endif %}
    </div>
</div>

<!-- Change Tutor Modal -->
<div class="modal fade" id="tutorModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">{{ 'ChangeTutor'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>{{ 'SearchTeacher'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" class="form-control" id="tutor_search" placeholder="{{ 'TypeToSearch'|get_plugin_lang('SchoolPlugin') }}" autocomplete="off">
                </div>
                <div id="tutor_results" style="max-height:250px; overflow-y:auto;"></div>
                <hr>
                <button class="btn btn-outline-secondary btn-sm" onclick="saveTutor(0)">
                    <i class="fas fa-user-slash"></i> {{ 'RemoveTutor'|get_plugin_lang('SchoolPlugin') }}
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Add Student Modal -->
<div class="modal fade" id="addStudentModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">{{ 'AddStudent'|get_plugin_lang('SchoolPlugin') }}</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>{{ 'SearchStudent'|get_plugin_lang('SchoolPlugin') }}</label>
                    <input type="text" class="form-control" id="student_search" placeholder="{{ 'TypeToSearch'|get_plugin_lang('SchoolPlugin') }}" autocomplete="off">
                </div>
                <div id="student_results" style="max-height:300px; overflow-y:auto;"></div>
            </div>
        </div>
    </div>
</div>

<script>
var ajaxUrl = '{{ ajax_url }}';
var classroomId = {{ classroom.id }};
var searchTimeout;

// =========================================================================
// TUTOR SEARCH
// =========================================================================
document.getElementById('tutor_search').addEventListener('input', function() {
    clearTimeout(searchTimeout);
    var query = this.value.trim();
    if (query.length < 2) {
        document.getElementById('tutor_results').innerHTML = '';
        return;
    }
    searchTimeout = setTimeout(function() {
        fetch(ajaxUrl + '?action=search_teachers&q=' + encodeURIComponent(query))
            .then(r => r.json())
            .then(data => {
                var html = '';
                if (data.data && data.data.length > 0) {
                    data.data.forEach(function(t) {
                        html += '<div class="d-flex align-items-center p-2 border-bottom" style="cursor:pointer" onclick="saveTutor(' + t.user_id + ')">';
                        html += '<i class="fas fa-user-tie text-muted mr-2"></i>';
                        html += '<div><strong>' + t.lastname + ', ' + t.firstname + '</strong><br><small class="text-muted">' + t.username + '</small></div>';
                        html += '</div>';
                    });
                } else {
                    html = '<div class="text-muted p-2">{{ 'NoResults'|get_plugin_lang('SchoolPlugin') }}</div>';
                }
                document.getElementById('tutor_results').innerHTML = html;
            });
    }, 300);
});

function saveTutor(tutorId) {
    var fd = new FormData();
    fd.append('action', 'update_tutor');
    fd.append('classroom_id', classroomId);
    fd.append('tutor_id', tutorId);
    fetch(ajaxUrl, {method:'POST', body:fd}).then(r=>r.json()).then(d=>{if(d.success)location.reload();});
}

// =========================================================================
// STUDENT SEARCH
// =========================================================================
document.getElementById('student_search').addEventListener('input', function() {
    clearTimeout(searchTimeout);
    var query = this.value.trim();
    if (query.length < 2) {
        document.getElementById('student_results').innerHTML = '';
        return;
    }
    searchTimeout = setTimeout(function() {
        fetch(ajaxUrl + '?action=search_students&q=' + encodeURIComponent(query))
            .then(r => r.json())
            .then(data => {
                var html = '';
                if (data.data && data.data.length > 0) {
                    data.data.forEach(function(s) {
                        html += '<div class="d-flex align-items-center p-2 border-bottom">';
                        html += '<i class="fas fa-user text-muted mr-2"></i>';
                        html += '<div class="flex-grow-1"><strong>' + s.lastname + ', ' + s.firstname + '</strong><br><small class="text-muted">' + s.username + '</small></div>';
                        html += '<button class="btn btn-success btn-sm" onclick="addStudent(' + s.user_id + ')"><i class="fas fa-plus"></i></button>';
                        html += '</div>';
                    });
                } else {
                    html = '<div class="text-muted p-2">{{ 'NoResults'|get_plugin_lang('SchoolPlugin') }}</div>';
                }
                document.getElementById('student_results').innerHTML = html;
            });
    }, 300);
});

function addStudent(userId) {
    var fd = new FormData();
    fd.append('action', 'add_student');
    fd.append('classroom_id', classroomId);
    fd.append('user_id', userId);
    fetch(ajaxUrl, {method:'POST', body:fd}).then(r=>r.json()).then(d=>{
        if(d.success) {
            location.reload();
        } else {
            alert(d.message || 'Error');
        }
    });
}

function removeStudent(userId) {
    if (!confirm('{{ 'ConfirmRemoveStudent'|get_plugin_lang('SchoolPlugin') }}')) return;
    var fd = new FormData();
    fd.append('action', 'remove_student');
    fd.append('classroom_id', classroomId);
    fd.append('user_id', userId);
    fetch(ajaxUrl, {method:'POST', body:fd}).then(r=>r.json()).then(d=>{if(d.success)location.reload();});
}
</script>
