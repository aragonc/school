<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Certificado Alumno Regular</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            color: #000;
            font-size: 14px;
            margin: 40px;
        }
        .text-center {
            text-align: center;
        }
        .logo {
            width: 200px;
            margin-bottom: 20px;
        }
        .titulo {
            font-weight: bold;
            font-size: 25px;
            margin-bottom: 40px;
        }
        .firma-block {
            margin-top: 40px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .firma {
            width: 400px;
            text-align: center;
            border-top: 1px solid #000;
            margin-top: 20px;
        }
        .barcode {
            margin-top: 30px;
            font-weight: bold;
            font-size: 13px;
        }
        .footer {
            font-size: 11px;
            margin-top: 40px;
            text-align: center;
            color: #555;
        }
        .timbre-block{
            position: absolute;
            right: 10%;
        }
    </style>
</head>
<body>

<div class="text-center">
    <img src="{{ logo_path }}" class="logo" alt="Logo Educación Chile">
    <div class="titulo">CERTIFICADO<br>ALUMNO REGULAR</div>
    <p>Santiago, {{ data.date_current }}</p>
</div>

<p>FUNDACIÓN EDUCHILE certifica que <strong>{{ data.firstname }} {{ data.lastname }}</strong>, con RUN <strong>{{ data.rut }}</strong>,
    se encuentra como alumno regular del Programa: <strong>{{ data.course_name }}</strong> con
    fecha de inicio: <strong>{{ data.display_start_date }}</strong> y término <strong>{{ data.display_end_date }}</strong>, con una duración de <strong>{{ duracion }}</strong>.</p>

<p>Se extiende el presente certificado, para los fines que estime conveniente.</p>

<p><strong>Fecha de emisión del Certificado:</strong> {{ data.date_current }}</p>

<div class="timbre-block">
    <img src="{{ timbre_path }}" alt="Firma" style="width:150px;">
</div>

<div class="firma-block" style="text-align: center;">
    <div>
        <img src="{{ signature_path }}" alt="Firma" style="width:300px;">
        <div style="text-align: center; width: 400px;  border-top: 1px solid #000; display: inline-block; margin: auto;">
            <strong>FUNDACIÓN EDUCHILE</strong><br>
            Pablo Rodríguez<br>
            Director Académico
        </div>
    </div>
</div>

<div class="barcode text-center">
    {{ qr_code }}
</div>

<div class="footer">
    Badajoz #100 oficina 502 – Las Condes, Santiago<br>
    Email: contacto@educacionchile.cl – Teléfono: +56976417387
</div>

</body>
</html>
