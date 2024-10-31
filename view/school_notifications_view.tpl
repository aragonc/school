
<div class="card">
    <div class="card-body">
        <div class="message">
            <div class="d-flex">
                <div class="flex-grow-1"><h2 class="title">{{ box.message.title }}</h2></div>
                <div class="p-2">
                    <a class="btn btn-primary btn-download" href="/notifications"><i class="fas fa-arrow-left"></i> Volver</a>
                </div>
            </div>


            <div class="info pt-2 pb-3">
                <i class="far fa-envelope"></i> {{ box.message.info }} - <i class="far fa-calendar"></i> {{ box.message.send_date }}
            </div>
            <div class="program">{{ box.message.session_title }}</div>
            <div class="content pt-5 pb-2">{{ box.message.content }}</div>
        </div>

    </div>
</div>