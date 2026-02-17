<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ 'Receipt'|get_plugin_lang('SchoolPlugin') }} #{{ sale.receipt_number }}</title>
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
            font-size: 14px;
            font-weight: bold;
            text-transform: uppercase;
            margin-top: 5px;
        }
        .receipt-number {
            font-size: 16px;
            font-weight: bold;
            color: #c00;
            margin-top: 3px;
        }
        .receipt-body { margin: 10px 0; }
        .receipt-row {
            display: flex;
            justify-content: space-between;
            padding: 4px 0;
            border-bottom: 1px dotted #ddd;
        }
        .receipt-row:last-child { border-bottom: none; }
        .receipt-label { font-weight: bold; color: #555; width: 40%; }
        .receipt-value { text-align: right; width: 60%; }
        .receipt-section {
            font-weight: bold;
            font-size: 11px;
            text-transform: uppercase;
            color: #666;
            margin-top: 10px;
            margin-bottom: 5px;
            padding-bottom: 3px;
            border-bottom: 1px solid #999;
        }
        .receipt-amount {
            text-align: center;
            margin: 15px 0;
            padding: 10px;
            background: #f0f0f0;
            border-radius: 5px;
        }
        .receipt-amount .amount {
            font-size: 22px;
            font-weight: bold;
            color: #1a7e1a;
        }
        .receipt-amount .amount-label {
            font-size: 10px;
            color: #666;
            text-transform: uppercase;
        }
        .receipt-footer {
            text-align: center;
            margin-top: 15px;
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
        <i class="fas fa-print"></i> {{ 'PrintReceipt'|get_plugin_lang('SchoolPlugin') }}
    </button>
    <button class="btn-back" onclick="history.back()">
        {{ 'Back'|get_plugin_lang('SchoolPlugin') }}
    </button>
</div>

<div class="receipt-container">
    <div class="receipt-header">
        {% if logo %}
        <img src="{{ logo }}" alt="Logo" class="receipt-logo">
        {% endif %}
        <div class="receipt-title">{{ 'SaleReceipt'|get_plugin_lang('SchoolPlugin') }}</div>
        <div class="receipt-number">N° {{ sale.receipt_number }}</div>
    </div>

    <div class="receipt-section">{{ 'StudentData'|get_plugin_lang('SchoolPlugin') }}</div>
    <div class="receipt-body">
        <div class="receipt-row">
            <span class="receipt-label">{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ sale.lastname }}, {{ sale.firstname }}</span>
        </div>
        {% if sale.document_number %}
        <div class="receipt-row">
            <span class="receipt-label">{{ sale.document_type|default('DNI') }}:</span>
            <span class="receipt-value">{{ sale.document_number }}</span>
        </div>
        {% endif %}
        <div class="receipt-row">
            <span class="receipt-label">{{ 'User'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ sale.username }}</span>
        </div>
    </div>

    <div class="receipt-section">{{ 'ProductDetail'|get_plugin_lang('SchoolPlugin') }}</div>
    <div class="receipt-body">
        <div class="receipt-row">
            <span class="receipt-label">{{ 'ProductName'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ sale.product_name }}</span>
        </div>
        <div class="receipt-row">
            <span class="receipt-label">{{ 'Quantity'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ sale.quantity }}</span>
        </div>
        <div class="receipt-row">
            <span class="receipt-label">{{ 'UnitPrice'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">S/ {{ sale.unit_price|number_format(2, '.', ',') }}</span>
        </div>
        {% if sale.discount > 0 %}
        <div class="receipt-row">
            <span class="receipt-label">{{ 'Discount'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">- S/ {{ sale.discount|number_format(2, '.', ',') }}</span>
        </div>
        {% endif %}
    </div>

    <div class="receipt-amount">
        <div class="amount-label">{{ 'Total'|get_plugin_lang('SchoolPlugin') }}</div>
        <div class="amount">S/ {{ sale.total_amount|number_format(2, '.', ',') }}</div>
    </div>

    <div class="receipt-body">
        <div class="receipt-row">
            <span class="receipt-label">{{ 'Date'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ sale.created_at|date('d/m/Y H:i') }}</span>
        </div>
        <div class="receipt-row">
            <span class="receipt-label">{{ 'PaymentMethod'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ method_label }}</span>
        </div>
        {% if sale.reference %}
        <div class="receipt-row">
            <span class="receipt-label">{{ 'Reference'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ sale.reference }}</span>
        </div>
        {% endif %}
    </div>

    <div class="receipt-footer">
        <p>{{ 'ReceiptGenerated'|get_plugin_lang('SchoolPlugin') }}: {{ 'now'|date('d/m/Y H:i') }}</p>
        <p>{{ 'ReceiptDisclaimer'|get_plugin_lang('SchoolPlugin') }}</p>
    </div>
</div>

</body>
</html>
