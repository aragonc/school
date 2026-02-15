<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>{{ institution_name }} - {{ site_name }}</title>
    <link rel="stylesheet" href="{{ fa_css }}">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #f0f2f5; color: #333; overflow: hidden;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .kiosk-container {
            display: flex; height: 100vh; width: 100vw;
        }
        .kiosk-left {
            flex: 1; display: flex; flex-direction: column;
            align-items: center; overflow: hidden;
        }
        .kiosk-right {
            width: 400px; background: #16213e; display: flex;
            flex-direction: column; border-left: 2px solid #0f3460;
        }
        .clock-container {
            width: 100%; padding: 15px 20px;
            background: #FFFFFF;
            box-shadow: 0 10px 30px 0 rgba(82, 63, 105, .08);
        }
        .clock-header {
            display: flex; align-items: center; width: 100%;
        }
        .clock-logo {
            flex: 0 0 auto; margin-right: 20px;
        }
        .clock-logo img {
            max-height: 50px; max-width: 180px; object-fit: contain;
        }
        .clock-center {
            flex: 1; text-align: center;
        }
        .clock-time {
            font-size: 3rem; font-weight: 700;
            font-variant-numeric: tabular-nums;
            letter-spacing: 2px; color: #e94560;
        }
        .clock-date { font-size: 1rem; color: #6c757d; margin-top: 4px; }
        .camera-section {
            flex: 1; display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            padding: 20px; width: 100%;
        }
        .camera-wrapper {
            position: relative; width: 100%; max-width: 640px;
            border-radius: 16px; overflow: hidden;
            box-shadow: 0 0 40px rgba(233, 69, 96, 0.3);
            border: 3px solid #e94560;
        }
        .camera-wrapper video {
            width: 100%; display: block; background: #000;
        }
        .camera-wrapper canvas { display: none; }
        .scan-overlay {
            position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            display: flex; align-items: center; justify-content: center;
            pointer-events: none;
        }
        .scan-frame {
            width: 250px; height: 250px;
            border: 3px solid rgba(233, 69, 96, 0.8);
            border-radius: 16px;
            animation: pulse-border 2s infinite;
        }
        @keyframes pulse-border {
            0%, 100% { border-color: rgba(233, 69, 96, 0.4); box-shadow: 0 0 20px rgba(233, 69, 96, 0.1); }
            50% { border-color: rgba(233, 69, 96, 1); box-shadow: 0 0 30px rgba(233, 69, 96, 0.4); }
        }
        .scan-label {
            text-align: center; margin-top: 20px;
            font-size: 1.2rem; color: #6c757d;
        }
        .scan-label i { color: #e94560; margin-right: 8px; }

        /* Result overlay */
        .result-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.85); display: none;
            align-items: center; justify-content: center; z-index: 1000;
        }
        .result-overlay.show { display: flex; }
        .result-card {
            background: #16213e; border-radius: 20px; padding: 40px;
            text-align: center; min-width: 400px; max-width: 500px;
            animation: slideUp 0.4s ease-out;
            border: 2px solid #0f3460; color: #fff;
        }
        @keyframes slideUp {
            from { transform: translateY(60px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .result-avatar {
            width: 120px; height: 120px; border-radius: 50%;
            object-fit: cover; margin-bottom: 16px;
            border: 4px solid #e94560;
        }
        .result-avatar-placeholder {
            width: 120px; height: 120px; border-radius: 50%;
            background: #0f3460; display: flex; align-items: center;
            justify-content: center; margin: 0 auto 16px;
            font-size: 3rem; color: #e94560;
            border: 4px solid #e94560;
        }
        .result-name { font-size: 1.8rem; font-weight: 700; margin-bottom: 8px; }
        .result-time { font-size: 2.5rem; font-weight: 700; color: #e94560; margin: 12px 0; }
        .result-status {
            display: inline-block; padding: 8px 24px;
            border-radius: 50px; font-size: 1.1rem; font-weight: 600;
        }
        .status-on_time { background: #28a745; color: #fff; }
        .status-late { background: #ffc107; color: #212529; }
        .status-already { background: #6c757d; color: #fff; }
        .status-error { background: #dc3545; color: #fff; }
        .result-countdown {
            margin-top: 16px; font-size: 0.9rem; color: #a8a8b3;
        }

        /* Records list */
        .records-header {
            padding: 12px 16px; font-size: 1rem; font-weight: 600;
            background: #0f3460; color: #e94560;
        }
        .records-list { flex: 1; overflow-y: auto; padding: 0; color: #fff; }
        .record-item {
            display: flex; align-items: center; padding: 10px 16px;
            border-bottom: 1px solid #0f3460;
            animation: fadeIn 0.3s ease-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateX(20px); }
            to { opacity: 1; transform: translateX(0); }
        }
        .record-item:nth-child(odd) { background: rgba(15, 52, 96, 0.3); }
        .record-info { flex: 1; }
        .record-name { font-size: 0.9rem; font-weight: 600; }
        .record-time-sm { font-size: 0.8rem; color: #a8a8b3; }
        .record-badge {
            padding: 3px 10px; border-radius: 12px;
            font-size: 0.75rem; font-weight: 600;
        }
        .badge-on_time { background: #28a745; color: #fff; }
        .badge-late { background: #ffc107; color: #212529; }
        .badge-absent { background: #dc3545; color: #fff; }

        .total-counter {
            padding: 12px 16px; background: #0f3460; color: #fff;
            text-align: center; font-size: 0.9rem;
            border-top: 2px solid #533483;
        }
        .total-counter span { color: #e94560; font-weight: 700; }

        @media (max-width: 900px) {
            .kiosk-container { flex-direction: column; }
            .kiosk-right { width: 100%; height: 40vh; border-left: none; border-top: 2px solid #0f3460; }
            .kiosk-left { height: 60vh; }
            .clock-time { font-size: 2rem; }
            .camera-wrapper { max-width: 90%; }
        }
    </style>
</head>
<body>

<div class="kiosk-container">
    <!-- Left: Camera + Clock -->
    <div class="kiosk-left">
        <div class="clock-container">
            <div class="clock-header">
                <div class="clock-logo">
                    {% if kiosk_logo %}
                    <img src="{{ kiosk_logo }}" alt="{{ institution_name }}">
                    {% endif %}
                </div>
                <div class="clock-center">
                    <div class="clock-time" id="clockTime">--:--:--</div>
                    <div class="clock-date" id="clockDate"></div>
                </div>
                <div class="clock-logo" style="visibility:hidden;">
                    {% if kiosk_logo %}
                    <img src="{{ kiosk_logo }}" alt="">
                    {% endif %}
                </div>
            </div>
        </div>

        <div class="camera-section">
            <div class="camera-wrapper">
                <video id="video" autoplay playsinline muted></video>
                <canvas id="canvas"></canvas>
                <div class="scan-overlay">
                    <div class="scan-frame"></div>
                </div>
            </div>
            <div class="scan-label">
                <i class="fas fa-qrcode"></i> Escanea tu código QR frente a la cámara
            </div>
        </div>
    </div>

    <!-- Right: Records -->
    <div class="kiosk-right">
        <div class="records-header">
            <i class="fas fa-list"></i> Últimos registros de hoy
        </div>
        <div class="records-list" id="recordsList">
            <div class="record-item" style="justify-content:center;color:#a8a8b3;">
                <i class="fas fa-clipboard-list" style="margin-right:8px;"></i> Sin registros aún
            </div>
        </div>
        <div class="total-counter" id="totalCounter">
            Total: <span>0</span> registros hoy
        </div>
    </div>
</div>

<!-- Result Overlay -->
<div class="result-overlay" id="resultOverlay">
    <div class="result-card">
        <div id="resultAvatarContainer"></div>
        <div class="result-name" id="resultName"></div>
        <div class="result-time" id="resultTime"></div>
        <div id="resultStatusContainer"></div>
        <div class="result-countdown" id="resultCountdown"></div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.js"></script>
<script>
(function() {
    var ajaxUrl = '{{ ajax_url }}';
    var serverTimeStr = '{{ server_time }}';
    var scanning = true;
    var processing = false;

    // ---- CLOCK ----
    var serverTime = new Date(serverTimeStr.replace(' ', 'T'));
    var clientOffset = Date.now() - serverTime.getTime();

    function getServerNow() {
        return new Date(Date.now() - clientOffset);
    }

    function updateClock() {
        var now = getServerNow();
        var h = String(now.getHours()).padStart(2, '0');
        var m = String(now.getMinutes()).padStart(2, '0');
        var s = String(now.getSeconds()).padStart(2, '0');
        document.getElementById('clockTime').textContent = h + ':' + m + ':' + s;

        var days = ['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'];
        var months = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
        document.getElementById('clockDate').textContent =
            days[now.getDay()] + ', ' + now.getDate() + ' de ' + months[now.getMonth()] + ' de ' + now.getFullYear();
    }
    updateClock();
    setInterval(updateClock, 1000);

    // ---- CAMERA ----
    var video = document.getElementById('video');
    var canvas = document.getElementById('canvas');
    var ctx = canvas.getContext('2d', { willReadFrequently: true });

    function initCamera() {
        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            document.querySelector('.scan-label').innerHTML =
                '<i class="fas fa-exclamation-triangle" style="color:#dc3545;"></i> ' +
                'Tu navegador no soporta acceso a la cámara.<br>' +
                '<small style="color:#ffc107;">La cámara requiere HTTPS o localhost (127.0.0.1).<br>' +
                'En Chrome: chrome://flags/#unsafely-treat-insecure-origin-as-secure<br>' +
                'Agrega tu URL (ej: http://192.168.x.x) y reinicia Chrome.</small>';
            return;
        }

        navigator.mediaDevices.getUserMedia({
            video: { facingMode: 'environment', width: { ideal: 640 }, height: { ideal: 480 } }
        }).then(function(stream) {
            video.srcObject = stream;
            video.play();
            requestAnimationFrame(scanLoop);
        }).catch(function(err) {
            console.error('Camera error:', err);
            var msg = '<i class="fas fa-exclamation-triangle" style="color:#dc3545;"></i> ';
            if (err.name === 'NotAllowedError') {
                msg += 'Permiso de cámara denegado. Permite el acceso en la configuración del navegador.';
            } else if (err.name === 'NotFoundError') {
                msg += 'No se encontró ninguna cámara conectada.';
            } else if (err.name === 'NotReadableError') {
                msg += 'La cámara está siendo usada por otra aplicación.';
            } else {
                msg += 'Error de cámara: ' + err.message;
            }
            if (location.protocol !== 'https:' && location.hostname !== 'localhost' && location.hostname !== '127.0.0.1') {
                msg += '<br><small style="color:#ffc107;">Estás accediendo sin HTTPS. En Chrome ve a:<br>' +
                    'chrome://flags/#unsafely-treat-insecure-origin-as-secure<br>' +
                    'Agrega: ' + location.origin + ' y reinicia Chrome.</small>';
            }
            document.querySelector('.scan-label').innerHTML = msg;
        });
    }

    initCamera();

    // ---- QR SCAN LOOP ----
    var lastScanTime = 0;

    function scanLoop() {
        if (video.readyState === video.HAVE_ENOUGH_DATA && scanning && !processing) {
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

            var imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
            var code = jsQR(imageData.data, imageData.width, imageData.height, {
                inversionAttempts: 'dontInvert'
            });

            if (code && code.data && (Date.now() - lastScanTime > 2000)) {
                lastScanTime = Date.now();
                processQR(code.data);
            }
        }
        requestAnimationFrame(scanLoop);
    }

    // ---- PROCESS QR ----
    function processQR(data) {
        if (processing) return;
        processing = true;

        var username = data.trim();
        if (!username) {
            processing = false;
            return;
        }

        var formData = new FormData();
        formData.append('action', 'scan_qr_kiosk');
        formData.append('username', username);

        fetch(ajaxUrl, { method: 'POST', body: formData })
            .then(function(r) { return r.json(); })
            .then(function(response) {
                showResult(response);
                if (response.today_records) {
                    updateRecordsList(response.today_records);
                }
            })
            .catch(function(err) {
                console.error('Scan error:', err);
                showResult({
                    success: false,
                    message: 'Error de conexión',
                    user_info: { firstname: '', lastname: '', avatar_url: '' }
                });
            });
    }

    // ---- SHOW RESULT ----
    function showResult(data) {
        var overlay = document.getElementById('resultOverlay');
        var avatarContainer = document.getElementById('resultAvatarContainer');
        var nameEl = document.getElementById('resultName');
        var timeEl = document.getElementById('resultTime');
        var statusContainer = document.getElementById('resultStatusContainer');
        var countdownEl = document.getElementById('resultCountdown');

        // Avatar
        if (data.user_info && data.user_info.avatar_url) {
            avatarContainer.innerHTML = '<img class="result-avatar" src="' + data.user_info.avatar_url + '" alt="Avatar">';
        } else if (data.user_info && data.user_info.firstname) {
            var initials = (data.user_info.firstname.charAt(0) + data.user_info.lastname.charAt(0)).toUpperCase();
            avatarContainer.innerHTML = '<div class="result-avatar-placeholder">' + initials + '</div>';
        } else {
            avatarContainer.innerHTML = '<div class="result-avatar-placeholder"><i class="fas fa-user"></i></div>';
        }

        // Name
        if (data.user_info) {
            nameEl.textContent = data.user_info.firstname + ' ' + data.user_info.lastname;
        } else {
            nameEl.textContent = 'Usuario no encontrado';
        }

        // Time
        timeEl.textContent = data.check_in_time || getServerNow().toTimeString().substring(0, 8);

        // Status
        var statusClass = 'status-error';
        var statusText = 'Error';

        if (data.success) {
            if (data.status === 'on_time') {
                statusClass = 'status-on_time';
                statusText = 'Puntual';
            } else if (data.status === 'late') {
                statusClass = 'status-late';
                statusText = 'Tardanza';
            } else {
                statusClass = 'status-on_time';
                statusText = 'Registrado';
            }
        } else {
            if (data.message === 'AttendanceAlreadyRegistered') {
                statusClass = 'status-already';
                statusText = 'Ya registrado hoy';
                if (data.status === 'on_time') {
                    statusText += ' (Puntual)';
                } else if (data.status === 'late') {
                    statusText += ' (Tardanza)';
                }
            } else if (data.message === 'UserNotFound') {
                statusText = 'Usuario no encontrado';
            } else {
                statusText = data.message || 'Error';
            }
        }

        statusContainer.innerHTML = '<div class="result-status ' + statusClass + '">' + statusText + '</div>';

        overlay.classList.add('show');

        // Countdown to auto-close
        var seconds = 5;
        countdownEl.textContent = 'Volviendo al escáner en ' + seconds + 's...';
        var countdownInterval = setInterval(function() {
            seconds--;
            if (seconds <= 0) {
                clearInterval(countdownInterval);
                overlay.classList.remove('show');
                processing = false;
            } else {
                countdownEl.textContent = 'Volviendo al escáner en ' + seconds + 's...';
            }
        }, 1000);
    }

    // ---- UPDATE RECORDS LIST ----
    function updateRecordsList(records) {
        var list = document.getElementById('recordsList');
        var counter = document.getElementById('totalCounter');

        if (!records || records.length === 0) {
            list.innerHTML = '<div class="record-item" style="justify-content:center;color:#a8a8b3;">' +
                '<i class="fas fa-clipboard-list" style="margin-right:8px;"></i> Sin registros aún</div>';
            counter.innerHTML = 'Total: <span>0</span> registros hoy';
            return;
        }

        var html = '';
        for (var i = 0; i < records.length; i++) {
            var r = records[i];
            var badgeClass = 'badge-' + (r.status || 'on_time');
            var statusLabel = r.status === 'on_time' ? 'Puntual' : (r.status === 'late' ? 'Tarde' : 'Ausente');
            var checkTime = r.check_in ? r.check_in.substring(11, 19) : '--:--:--';
            var initials = ((r.firstname || '').charAt(0) + (r.lastname || '').charAt(0)).toUpperCase();

            html += '<div class="record-item">';
            html += '<div style="width:36px;height:36px;border-radius:50%;background:#0f3460;display:flex;align-items:center;justify-content:center;margin-right:10px;font-size:0.8rem;font-weight:700;color:#e94560;border:2px solid #533483;">' + initials + '</div>';
            html += '<div class="record-info">';
            html += '<div class="record-name">' + (r.lastname || '') + ', ' + (r.firstname || '') + '</div>';
            html += '<div class="record-time-sm">' + checkTime + '</div>';
            html += '</div>';
            html += '<div class="record-badge ' + badgeClass + '">' + statusLabel + '</div>';
            html += '</div>';
        }
        list.innerHTML = html;
        counter.innerHTML = 'Total: <span>' + records.length + '</span> registros hoy';
    }

    // ---- INITIAL LOAD OF TODAY'S RECORDS ----
    function loadTodayRecords() {
        fetch(ajaxUrl + '?action=get_attendance_list&date=' + getServerNow().toISOString().substring(0, 10))
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success && data.data) {
                    var reversed = data.data.slice().reverse().slice(0, 10);
                    updateRecordsList(reversed);
                }
            })
            .catch(function() {});
    }
    loadTodayRecords();

})();
</script>

</body>
</html>
