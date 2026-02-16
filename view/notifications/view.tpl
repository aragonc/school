
<div class="card">
    <div class="card-body p-0 p-md-3">
        <div class="return d-block d-md-none">
            <a class="btn btn-primary btn-download" href="/notifications"><i class="fas fa-arrow-left"></i> Volver</a>
        </div>
        <div class="message pt-3">
            <div class="d-flex">
                <div class="flex-grow-1"><h2 class="title">{{ box.message.title }}</h2></div>
                <div class="p-2 d-none d-md-block">
                    <a class="btn btn-primary btn-download" href="/notifications"><i class="fas fa-arrow-left"></i> Volver</a>
                </div>
            </div>
            <div class="program-mobile d-block d-md-none">{{ box.message.session_title_mobile }}</div>
            <div class="info pt-2 pb-3">
                {{ box.message.info }} - <i class="far fa-calendar"></i> {{ box.message.date }}
            </div>
            <div class="program d-none d-md-block">{{ box.message.session_title }}</div>
            <div class="content pt-md-5 pb-2">{{ box.message.content }}</div>
        </div>

    </div>
</div>