<div class="school-quiz-overview">

    {# ── Header bar ── #}
    <div class="overview-header mb-4">
        <a href="{{ back_url }}" class="btn-back">
            <i class="fa fa-arrow-left"></i>
        </a>
        <div class="overview-title-wrap">
            <div class="overview-icon">{{ get_svg_icon('quiz', '', 36) }}</div>
            <h2 class="overview-title">{{ exercise.title }}</h2>
        </div>
    </div>

    {# ── Description ── #}
    {% if exercise.description %}
    <div class="overview-description card mb-3">
        <div class="card-body">
            {{ exercise.description|raw }}
        </div>
    </div>
    {% endif %}

    {# ── Info pills ── #}
    <div class="overview-pills mb-4">
        <span class="pill">
            <i class="fa fa-question-circle"></i>
            {{ exercise.questions }} {{ 'QuizQuestions'|get_plugin_lang('SchoolPlugin') }}
        </span>
        {% if exercise.time_limit > 0 %}
        <span class="pill">
            <i class="fa fa-hourglass-half"></i>
            {{ exercise.time_limit }} min
        </span>
        {% endif %}
        {% if exercise.max_attempts > 0 %}
        <span class="pill">
            <i class="fa fa-repeat"></i>
            {{ attempts_done }}/{{ exercise.max_attempts }} {{ 'QuizAttempts'|get_plugin_lang('SchoolPlugin') }}
        </span>
        {% else %}
        <span class="pill">
            <i class="fa fa-repeat"></i>
            {{ attempts_done }} {{ 'QuizAttempts'|get_plugin_lang('SchoolPlugin') }}
        </span>
        {% endif %}
    </div>

    {# ── Timer (if in-progress with time control) ── #}
    {% if time_control and time_left is not null and time_left > 0 %}
    <div class="alert alert-warning d-flex align-items-center gap-2 mb-3">
        <i class="fa fa-clock-o fa-lg mr-2"></i>
        <span>{{ 'QuizTimeRemaining'|get_plugin_lang('SchoolPlugin') }}:
            <strong id="school-countdown"></strong>
        </span>
    </div>
    {% endif %}

    {# ── Visibility message ── #}
    {% if visibility_msg %}
    <div class="alert alert-warning mb-3">
        <i class="fa fa-lock mr-1"></i> {{ visibility_msg }}
    </div>
    {% endif %}

    {# ── Attempts exhausted ── #}
    {% if exercise.max_attempts > 0 and attempts_left is not null and attempts_left == 0 %}
    <div class="alert alert-info mb-3">
        <i class="fa fa-info-circle mr-1"></i>
        {{ 'QuizAttemptsExhausted'|get_plugin_lang('SchoolPlugin') }}
    </div>
    {% endif %}

    {# ── Start / Continue button ── #}
    {% if can_start %}
    <div class="overview-action mb-4">
        <a href="{{ submit_url }}" class="btn-start-quiz">
            {% if in_progress %}
                <i class="fa fa-play-circle"></i> {{ 'QuizContinue'|get_plugin_lang('SchoolPlugin') }}
            {% else %}
                <i class="fa fa-play"></i> {{ 'QuizStart'|get_plugin_lang('SchoolPlugin') }}
            {% endif %}
        </a>
    </div>
    {% endif %}

    {# ── Previous attempts table ── #}
    {% if attempts is not empty and exercise.hide_attempts_table == 0 %}
    <div class="attempts-section">
        <h4 class="attempts-title">{{ 'QuizPreviousAttempts'|get_plugin_lang('SchoolPlugin') }}</h4>
        <div class="table-responsive">
            <table class="attempts-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>{{ 'QuizAttemptDate'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'QuizAttemptScore'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th>{{ 'QuizAttemptStatus'|get_plugin_lang('SchoolPlugin') }}</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    {% for att in attempts %}
                    <tr>
                        <td class="att-num">{{ att.number }}</td>
                        <td class="att-date">{{ att.date }}</td>
                        <td class="att-score">
                            {% if att.score_pct is not null %}
                                <span class="score-badge {% if att.score_pct >= 60 %}score-pass{% else %}score-fail{% endif %}">
                                    {{ att.score_pct }}%
                                </span>
                            {% else %}
                                <span class="text-muted">—</span>
                            {% endif %}
                        </td>
                        <td class="att-validated">
                            {% if att.validated %}
                                <span class="status-pill status-validated">
                                    <i class="fa fa-check"></i> {{ 'QuizValidated'|get_plugin_lang('SchoolPlugin') }}
                                </span>
                            {% else %}
                                <span class="status-pill status-pending">
                                    <i class="fa fa-clock-o"></i> {{ 'QuizNotValidated'|get_plugin_lang('SchoolPlugin') }}
                                </span>
                            {% endif %}
                        </td>
                        <td class="att-action">
                            {% if att.result_url %}
                            <a href="{{ att.result_url }}" class="btn-result" target="_blank">
                                <i class="fa fa-eye"></i> {{ 'QuizReview'|get_plugin_lang('SchoolPlugin') }}
                            </a>
                            {% endif %}
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
    {% endif %}

</div>

{% if time_control and time_left is not null and time_left > 0 %}
<script>
(function () {
    var secs = {{ time_left }};
    var el   = document.getElementById('school-countdown');
    if (!el) return;
    function tick() {
        if (secs <= 0) {
            window.location.href = '{{ submit_url|escape('js') }}';
            return;
        }
        var h = Math.floor(secs / 3600);
        var m = Math.floor((secs % 3600) / 60);
        var s = secs % 60;
        el.textContent = (h ? (h + 'h ') : '') +
            String(m).padStart(2,'0') + ':' +
            String(s).padStart(2,'0');
        secs--;
        setTimeout(tick, 1000);
    }
    tick();
})();
</script>
{% endif %}

<style>
.school-quiz-overview { padding: 16px 0; }

/* Header */
.overview-header {
    display: flex;
    align-items: center;
    gap: 14px;
}
.btn-back {
    display: flex; align-items: center; justify-content: center;
    width: 36px; height: 36px; border-radius: 50%;
    background: #f0f0f0; color: #555; text-decoration: none; flex-shrink: 0;
}
.btn-back:hover { background: #e0e0e0; color: #222; text-decoration: none; }
.overview-title-wrap {
    display: flex; align-items: center; gap: 10px;
}
.overview-icon { opacity: .75; }
.overview-title {
    font-size: 1.35rem; font-weight: 700; color: #333; margin: 0;
}

/* Description */
.overview-description { border-radius: 10px; }
.overview-description .card-body {
    font-size: .92rem; color: #555; line-height: 1.6;
}

/* Pills */
.overview-pills { display: flex; flex-wrap: wrap; gap: 10px; }
.pill {
    display: inline-flex; align-items: center; gap: 6px;
    background: #f5f5f5; color: #555;
    padding: 6px 14px; border-radius: 20px; font-size: .82rem; font-weight: 500;
}
.pill i { color: #4e73df; }

/* Action button */
.overview-action { display: flex; }
.btn-start-quiz {
    display: inline-flex; align-items: center; gap: 8px;
    background: #4e73df; color: #fff;
    padding: 12px 32px; border-radius: 10px;
    font-size: 1rem; font-weight: 700;
    text-decoration: none; transition: background .15s;
}
.btn-start-quiz:hover { background: #3a5bbf; color: #fff; text-decoration: none; }

/* Attempts table */
.attempts-section { margin-top: 8px; }
.attempts-title {
    font-size: 1rem; font-weight: 600; color: #444; margin-bottom: 12px;
}
.attempts-table {
    width: 100%; border-collapse: collapse; font-size: .88rem;
}
.attempts-table thead th {
    background: #f8f8f8; padding: 10px 12px;
    text-align: left; font-weight: 600; color: #555;
    border-bottom: 2px solid #e8e8e8;
}
.attempts-table tbody tr { border-bottom: 1px solid #f0f0f0; }
.attempts-table tbody tr:last-child { border-bottom: none; }
.attempts-table tbody td { padding: 10px 12px; vertical-align: middle; }
.att-num { color: #999; font-size: .8rem; }
.att-date { color: #555; }

.score-badge {
    display: inline-block;
    padding: 3px 10px; border-radius: 12px;
    font-size: .82rem; font-weight: 700;
}
.score-pass { background: #e8f5e9; color: #2e7d32; }
.score-fail { background: #fce4ec; color: #c62828; }

.status-pill {
    display: inline-flex; align-items: center; gap: 4px;
    padding: 3px 10px; border-radius: 12px; font-size: .78rem; font-weight: 600;
}
.status-validated { background: #e3f2fd; color: #1565c0; }
.status-pending   { background: #fff8e1; color: #f57f17; }

.btn-result {
    display: inline-flex; align-items: center; gap: 5px;
    background: #1cc88a; color: #fff;
    padding: 5px 12px; border-radius: 8px; font-size: .8rem; font-weight: 600;
    text-decoration: none; transition: opacity .15s;
}
.btn-result:hover { opacity: .85; color: #fff; text-decoration: none; }

@media (max-width: 576px) {
    .overview-title { font-size: 1.1rem; }
    .attempts-table thead th:nth-child(2),
    .attempts-table tbody td:nth-child(2) { display: none; }
}
</style>
