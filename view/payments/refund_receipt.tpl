<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Constancia de Devolución {{ refund_number }}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, Helvetica, sans-serif;
            font-size: 12px;
            color: #333;
            background: #f5f5f5;
        }
        .receipt-container {
            width: 80mm;
            max-width: 100%;
            margin: 20px auto;
            background: #fff;
            padding: 15px;
            border: 1px dashed #ccc;
        }
        .receipt-header {
            text-align: center;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
            margin-bottom: 10px;
        }
        .receipt-logo {
            max-width: 120px;
            max-height: 60px;
            margin-bottom: 5px;
        }
        .receipt-title {
            font-size: 13px;
            font-weight: bold;
            text-transform: uppercase;
            margin-top: 5px;
        }
        .receipt-subtitle {
            font-size: 10px;
            color: #666;
            margin-top: 2px;
        }
        .receipt-number {
            font-size: 15px;
            font-weight: bold;
            color: #c00;
            margin-top: 4px;
        }
        .receipt-body { margin: 10px 0; }
        .receipt-row {
            display: flex;
            justify-content: space-between;
            padding: 4px 0;
            border-bottom: 1px dotted #ddd;
        }
        .receipt-row:last-child { border-bottom: none; }
        .receipt-label {
            font-weight: bold;
            color: #555;
            width: 45%;
        }
        .receipt-value {
            text-align: right;
            width: 55%;
        }
        .receipt-section {
            font-weight: bold;
            font-size: 10px;
            text-transform: uppercase;
            color: #666;
            margin-top: 10px;
            margin-bottom: 5px;
            padding-bottom: 3px;
            border-bottom: 1px solid #999;
        }

        /* Formula box */
        .formula-box {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 8px;
            margin: 8px 0;
            background: #f9f9f9;
            font-size: 10px;
        }
        .formula-row {
            display: flex;
            justify-content: space-between;
            padding: 2px 0;
        }
        .formula-row.formula-calc {
            border-top: 1px dashed #aaa;
            margin-top: 5px;
            padding-top: 5px;
            font-style: italic;
            color: #555;
            font-size: 9px;
        }

        /* Refund amount highlight */
        .refund-amount-box {
            text-align: center;
            margin: 12px 0;
            padding: 10px;
            border-radius: 5px;
            border: 2px solid #c00;
            background: #fff5f5;
        }
        .refund-amount-box .amount-label {
            font-size: 10px;
            color: #666;
            text-transform: uppercase;
        }
        .refund-amount-box .amount {
            font-size: 22px;
            font-weight: bold;
            color: #c00;
        }

        /* Status badge */
        .status-badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 3px;
            font-weight: bold;
            font-size: 10px;
        }
        .status-pending  { background: #fff3cd; color: #856404; }
        .status-processed { background: #d4edda; color: #155724; }

        /* Notes */
        .notes-box {
            background: #fffbe6;
            border: 1px solid #e5c800;
            border-radius: 4px;
            padding: 6px 8px;
            margin: 6px 0;
            font-size: 10px;
            color: #555;
        }

        /* Minedu legal note */
        .legal-note {
            font-size: 9px;
            color: #777;
            text-align: center;
            margin: 10px 0 6px;
            font-style: italic;
            line-height: 1.4;
        }

        .receipt-footer {
            text-align: center;
            margin-top: 12px;
            padding-top: 10px;
            border-top: 2px solid #333;
            font-size: 10px;
            color: #888;
        }
        .receipt-footer p { margin: 2px 0; }

        .no-print {
            text-align: center;
            margin: 15px auto;
            max-width: 80mm;
        }
        .btn-print {
            display: inline-block;
            padding: 10px 25px;
            background: #4e73df;
            color: #fff;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            margin: 5px;
        }
        .btn-print:hover { background: #3a5bc7; }
        .btn-back {
            display: inline-block;
            padding: 10px 25px;
            background: #6c757d;
            color: #fff;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            margin: 5px;
        }
        .btn-back:hover { background: #5a6268; }

        @media print {
            body { background: #fff; }
            .no-print { display: none !important; }
            .receipt-container { margin: 0; border: none; padding: 10px; }
        }
    </style>
</head>
<body>

<div class="no-print">
    <button class="btn-print" onclick="window.print()">
        &#128438; Imprimir Constancia
    </button>
    <button class="btn-back" onclick="history.back()">
        &#8592; Volver
    </button>
</div>

<div class="receipt-container">

    <!-- Header -->
    <div class="receipt-header">
        {% if logo %}
        <img src="{{ logo }}" alt="Logo" class="receipt-logo">
        {% endif %}
        <div class="receipt-title">Constancia de Devolución</div>
        <div class="receipt-subtitle">Cuota de Ingreso &mdash; Norma Minedu</div>
        <div class="receipt-number">{{ refund_number }}</div>
    </div>

    <!-- Student Info -->
    <div class="receipt-section">Datos del Alumno</div>
    <div class="receipt-body">
        <div class="receipt-row">
            <span class="receipt-label">Alumno:</span>
            <span class="receipt-value"><strong>{{ refund.full_name }}</strong></span>
        </div>
        {% if refund.dni %}
        <div class="receipt-row">
            <span class="receipt-label">DNI:</span>
            <span class="receipt-value">{{ refund.dni }}</span>
        </div>
        {% endif %}
        {% if refund.level_name %}
        <div class="receipt-row">
            <span class="receipt-label">Nivel:</span>
            <span class="receipt-value">{{ refund.level_name }}</span>
        </div>
        {% endif %}
        {% if refund.grade_name %}
        <div class="receipt-row">
            <span class="receipt-label">Grado:</span>
            <span class="receipt-value">{{ refund.grade_name }}</span>
        </div>
        {% endif %}
    </div>

    <!-- Refund Calculation -->
    <div class="receipt-section">Cálculo de Devolución (Art. 14° D.S. 009-2006-ED)</div>

    <div class="formula-box">
        <div class="formula-row">
            <span>Años pactados:</span>
            <span><strong>{{ contracted }}</strong></span>
        </div>
        <div class="formula-row">
            <span>Años cursados:</span>
            <span><strong>{{ attended }}</strong></span>
        </div>
        <div class="formula-row">
            <span>Años sin cursar:</span>
            <span><strong>{{ remaining }}</strong></span>
        </div>
        <div class="formula-row">
            <span>Cuota de ingreso pagada:</span>
            <span><strong>S/ {{ admission_paid|number_format(2, '.', ',') }}</strong></span>
        </div>
        <div class="formula-row formula-calc">
            <span>Fórmula:</span>
            <span>S/ {{ admission_paid|number_format(2, '.', ',') }} &times; ({{ remaining }}/{{ contracted }})</span>
        </div>
    </div>

    <!-- Refund Amount -->
    <div class="refund-amount-box">
        <div class="amount-label">Monto a Devolver</div>
        <div class="amount">S/ {{ refund_amount|number_format(2, '.', ',') }}</div>
    </div>

    <!-- Status -->
    <div class="receipt-body">
        <div class="receipt-row">
            <span class="receipt-label">Estado:</span>
            <span class="receipt-value">
                {% if refund.status == 'processed' %}
                <span class="status-badge status-processed">&#10003; Entregada</span>
                {% else %}
                <span class="status-badge status-pending">&#9679; Pendiente</span>
                {% endif %}
            </span>
        </div>
        {% if refund.processed_date %}
        <div class="receipt-row">
            <span class="receipt-label">Fecha entrega:</span>
            <span class="receipt-value">{{ refund.processed_date }}</span>
        </div>
        {% endif %}
        <div class="receipt-row">
            <span class="receipt-label">Fecha registro:</span>
            <span class="receipt-value">{{ refund.created_at|date('d/m/Y') }}</span>
        </div>
    </div>

    {% if refund.notes %}
    <!-- Notes -->
    <div class="notes-box">
        <strong>Observaciones:</strong> {{ refund.notes }}
    </div>
    {% endif %}

    <!-- Legal note -->
    <div class="legal-note">
        Devolución calculada conforme al Art. 14° del D.S. N° 009-2006-ED y modificatorias,
        que establece la devolución proporcional de la cuota de ingreso
        en caso de retiro del alumno.
    </div>

    <!-- Footer -->
    <div class="receipt-footer">
        <p>Emitido: {{ 'now'|date('d/m/Y H:i') }}</p>
        <p>Documento de constancia interna</p>
    </div>

</div>

</body>
</html>
