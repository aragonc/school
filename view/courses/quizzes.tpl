<div class="school-quizzes">

    <div class="page-header-bar mb-4">
        <a href="{{ back_url }}" class="btn-back">
            <i class="fa fa-arrow-left"></i>
        </a>
        <h2 class="page-title">{{ 'QuizzesTitle'|get_plugin_lang('SchoolPlugin') }}</h2>
    </div>

    {% if quizzes is empty %}
        <div class="empty-state">
            <div class="empty-icon">{{ get_svg_icon('quiz', '', 64) }}</div>
            <p>{{ 'QuizzesEmpty'|get_plugin_lang('SchoolPlugin') }}</p>
        </div>
    {% else %}
        <div class="quizzes-grid">
            {% for quiz in quizzes %}
                <div class="quiz-card quiz-status-{{ quiz.status }}">
                    <div class="quiz-card-header">
                        <div class="quiz-icon-wrap">
                            {{ get_svg_icon('quiz', '', 40) }}
                        </div>
                        <span class="quiz-badge badge-{{ quiz.status }}">
                            {% if quiz.status == 'available' %}
                                <i class="fa fa-play-circle"></i> {{ 'QuizStatusAvailable'|get_plugin_lang('SchoolPlugin') }}
                            {% elseif quiz.status == 'pending' %}
                                <i class="fa fa-clock-o"></i> {{ 'QuizStatusPending'|get_plugin_lang('SchoolPlugin') }}
                            {% elseif quiz.status == 'expired' %}
                                <i class="fa fa-times-circle"></i> {{ 'QuizStatusExpired'|get_plugin_lang('SchoolPlugin') }}
                            {% else %}
                                <i class="fa fa-check-circle"></i> {{ 'QuizStatusDone'|get_plugin_lang('SchoolPlugin') }}
                            {% endif %}
                        </span>
                    </div>

                    <div class="quiz-card-body">
                        <h3 class="quiz-title">{{ quiz.title }}</h3>
                        {% if quiz.description %}
                            <p class="quiz-description">{{ quiz.description }}</p>
                        {% endif %}

                        <div class="quiz-meta">
                            <span class="meta-item" title="{{ 'QuizQuestions'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fa fa-question-circle"></i> {{ quiz.questions }}
                            </span>
                            {% if quiz.time_limit > 0 %}
                            <span class="meta-item" title="{{ 'QuizTimeLimit'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fa fa-hourglass-half"></i> {{ quiz.time_limit }} min
                            </span>
                            {% endif %}
                            {% if quiz.max_attempt > 0 %}
                            <span class="meta-item" title="{{ 'QuizAttempts'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fa fa-repeat"></i> {{ quiz.attempts_done }}/{{ quiz.max_attempt }}
                            </span>
                            {% else %}
                            <span class="meta-item" title="{{ 'QuizAttempts'|get_plugin_lang('SchoolPlugin') }}">
                                <i class="fa fa-repeat"></i> {{ quiz.attempts_done }}
                            </span>
                            {% endif %}
                        </div>

                        {% if quiz.start_time or quiz.end_time %}
                        <div class="quiz-dates">
                            {% if quiz.start_time %}
                            <span class="date-item"><i class="fa fa-calendar-o"></i> {{ quiz.start_time }}</span>
                            {% endif %}
                            {% if quiz.end_time %}
                            <span class="date-item"><i class="fa fa-calendar-times-o"></i> {{ quiz.end_time }}</span>
                            {% endif %}
                        </div>
                        {% endif %}

                        {% if quiz.best_score is not null %}
                        <div class="quiz-score">
                            <span class="score-label">{{ 'QuizBestScore'|get_plugin_lang('SchoolPlugin') }}</span>
                            <span class="score-value {% if quiz.best_score >= 60 %}score-pass{% else %}score-fail{% endif %}">
                                {{ quiz.best_score }}%
                            </span>
                        </div>
                        {% endif %}
                    </div>

                    <div class="quiz-card-footer">
                        {% if quiz.status == 'available' %}
                            <a href="{{ quiz.link }}" class="btn-start">
                                <i class="fa fa-play"></i> {{ 'QuizStart'|get_plugin_lang('SchoolPlugin') }}
                            </a>
                        {% elseif quiz.status == 'done' %}
                            <a href="{{ quiz.link }}" class="btn-review">
                                <i class="fa fa-eye"></i> {{ 'QuizReview'|get_plugin_lang('SchoolPlugin') }}
                            </a>
                        {% else %}
                            <span class="btn-disabled">
                                {% if quiz.status == 'pending' %}
                                    <i class="fa fa-lock"></i> {{ 'QuizNotYet'|get_plugin_lang('SchoolPlugin') }}
                                {% else %}
                                    <i class="fa fa-ban"></i> {{ 'QuizClosed'|get_plugin_lang('SchoolPlugin') }}
                                {% endif %}
                            </span>
                        {% endif %}
                    </div>
                </div>
            {% endfor %}
        </div>
    {% endif %}

</div>

<style>
.school-quizzes {
    padding: 16px 0;
}
.page-header-bar {
    display: flex;
    align-items: center;
    gap: 14px;
}
.btn-back {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: #f0f0f0;
    color: #555;
    text-decoration: none;
    flex-shrink: 0;
}
.btn-back:hover { background: #e0e0e0; color: #222; text-decoration: none; }
.page-title {
    font-size: 1.4rem;
    font-weight: 600;
    color: #333;
    margin: 0;
}
.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: #999;
}
.empty-icon { margin-bottom: 16px; opacity: .4; }

.quizzes-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
}
.quiz-card {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,.08);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    transition: box-shadow .2s;
}
.quiz-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.14); }

.quiz-card-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    padding: 16px 16px 8px;
}
.quiz-icon-wrap { opacity: .75; }
.quiz-badge {
    font-size: .72rem;
    font-weight: 600;
    padding: 4px 10px;
    border-radius: 20px;
    white-space: nowrap;
}
.badge-available  { background: #e8f5e9; color: #2e7d32; }
.badge-pending    { background: #fff8e1; color: #f57f17; }
.badge-expired    { background: #fce4ec; color: #c62828; }
.badge-done       { background: #e3f2fd; color: #1565c0; }

.quiz-card-body {
    padding: 0 16px 12px;
    flex: 1;
}
.quiz-title {
    font-size: 1rem;
    font-weight: 600;
    color: #333;
    margin: 0 0 6px;
    line-height: 1.3;
}
.quiz-description {
    font-size: .82rem;
    color: #777;
    margin: 0 0 10px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
.quiz-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-bottom: 8px;
}
.meta-item {
    font-size: .8rem;
    color: #666;
    display: flex;
    align-items: center;
    gap: 4px;
}
.quiz-dates {
    display: flex;
    flex-direction: column;
    gap: 3px;
    margin-bottom: 8px;
}
.date-item {
    font-size: .75rem;
    color: #888;
}
.quiz-score {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 6px;
}
.score-label { font-size: .78rem; color: #666; }
.score-value { font-size: 1rem; font-weight: 700; }
.score-pass { color: #2e7d32; }
.score-fail { color: #c62828; }

.quiz-card-footer {
    padding: 12px 16px 16px;
    border-top: 1px solid #f0f0f0;
}
.btn-start, .btn-review {
    display: block;
    text-align: center;
    padding: 9px 0;
    border-radius: 8px;
    font-size: .88rem;
    font-weight: 600;
    text-decoration: none;
    transition: opacity .15s;
}
.btn-start:hover, .btn-review:hover { opacity: .85; text-decoration: none; }
.btn-start  { background: #4e73df; color: #fff; }
.btn-review { background: #1cc88a; color: #fff; }
.btn-disabled {
    display: block;
    text-align: center;
    padding: 9px 0;
    border-radius: 8px;
    font-size: .88rem;
    font-weight: 600;
    background: #f5f5f5;
    color: #aaa;
    cursor: default;
}

@media (max-width: 576px) {
    .quizzes-grid { grid-template-columns: 1fr; }
}
</style>
