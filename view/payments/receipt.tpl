<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ 'Receipt'|get_plugin_lang('SchoolPlugin') }} #{{ payment.receipt_number }}</title>
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
        .receipt-label {
            font-weight: bold;
            color: #555;
            width: 40%;
        }
        .receipt-value {
            text-align: right;
            width: 60%;
        }
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
        .receipt-status {
            text-align: center;
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: bold;
            font-size: 11px;
            display: inline-block;
        }
        .status-paid { background: #d4edda; color: #155724; }
        .status-partial { background: #fff3cd; color: #856404; }
        .status-pending { background: #f8d7da; color: #721c24; }
        .receipt-footer {
            text-align: center;
            margin-top: 15px;
            padding-top: 10px;
            border-top: 2px solid #333;
            font-size: 10px;
            color: #888;
        }
        .receipt-footer p { margin: 2px 0; }

        /* Payment history table */
        .history-table {
            width: 100%;
            border-collapse: collapse;
            margin: 8px 0;
            font-size: 10px;
        }
        .history-table th {
            background: #e9ecef;
            padding: 4px 3px;
            text-align: left;
            font-size: 9px;
            text-transform: uppercase;
            border-bottom: 1px solid #999;
        }
        .history-table td {
            padding: 3px;
            border-bottom: 1px dotted #ddd;
        }
        .history-table .text-right { text-align: right; }
        .history-table .total-row td {
            border-top: 2px solid #333;
            font-weight: bold;
            padding-top: 5px;
        }

        /* Summary box */
        .summary-box {
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 8px;
            margin: 10px 0;
            font-size: 11px;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            padding: 2px 0;
        }
        .summary-row.total {
            border-top: 1px solid #999;
            margin-top: 4px;
            padding-top: 4px;
            font-weight: bold;
            font-size: 12px;
        }

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
    <!-- Header -->
    <div class="receipt-header">
        {% if logo %}
        <img src="{{ logo }}" alt="Logo" class="receipt-logo">
        {% endif %}
        <div class="receipt-title">{{ 'PaymentReceipt'|get_plugin_lang('SchoolPlugin') }}</div>
        <div class="receipt-number">N° {{ payment.receipt_number }}</div>
    </div>

    <!-- Student Info -->
    <div class="receipt-section">{{ 'StudentData'|get_plugin_lang('SchoolPlugin') }}</div>
    <div class="receipt-body">
        <div class="receipt-row">
            <span class="receipt-label">{{ 'FullName'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ payment.lastname }}, {{ payment.firstname }}</span>
        </div>
        {% if payment.document_number %}
        <div class="receipt-row">
            <span class="receipt-label">{{ payment.document_type|default('DNI') }}:</span>
            <span class="receipt-value">{{ payment.document_number }}</span>
        </div>
        {% endif %}
        <div class="receipt-row">
            <span class="receipt-label">{{ 'User'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ payment.username }}</span>
        </div>
    </div>

    <!-- Payment Detail -->
    <div class="receipt-section">{{ 'PaymentDetail'|get_plugin_lang('SchoolPlugin') }}</div>
    <div class="receipt-body">
        <div class="receipt-row">
            <span class="receipt-label">{{ 'SelectPeriod'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ payment.period_name }} ({{ payment.period_year }})</span>
        </div>
        <div class="receipt-row">
            <span class="receipt-label">{{ 'Concept'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ concept_label }}</span>
        </div>
        <div class="receipt-row">
            <span class="receipt-label">{{ 'OriginalAmount'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">S/ {{ payment.original_amount|number_format(2, '.', ',') }}</span>
        </div>
        {% if payment.discount > 0 %}
        <div class="receipt-row">
            <span class="receipt-label">{{ 'Discount'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">- S/ {{ payment.discount|number_format(2, '.', ',') }}</span>
        </div>
        {% endif %}
        <div class="receipt-row">
            <span class="receipt-label">{{ 'AmountToPay'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value"><strong>S/ {{ effective_amount|number_format(2, '.', ',') }}</strong></span>
        </div>
    </div>

    {% if has_multiple_payments %}
    <!-- Payment History (multiple partial payments) -->
    <div class="receipt-section">{{ 'PaymentHistory'|get_plugin_lang('SchoolPlugin') }}</div>
    <table class="history-table">
        <thead>
            <tr>
                <th>#</th>
                <th>{{ 'Date'|get_plugin_lang('SchoolPlugin') }}</th>
                <th>{{ 'PaymentMethod'|get_plugin_lang('SchoolPlugin') }}</th>
                <th>{{ 'Reference'|get_plugin_lang('SchoolPlugin') }}</th>
                <th class="text-right">{{ 'Amount'|get_plugin_lang('SchoolPlugin') }}</th>
            </tr>
        </thead>
        <tbody>
            {% for i, entry in payment_history %}
            <tr>
                <td>{{ i + 1 }}</td>
                <td>{{ entry.date }}</td>
                <td>{{ entry.method }}</td>
                <td>{{ entry.reference|default('-') }}</td>
                <td class="text-right">S/ {{ entry.amount }}</td>
            </tr>
            {% endfor %}
            <tr class="total-row">
                <td colspan="4">{{ 'TotalPaid'|get_plugin_lang('SchoolPlugin') }}</td>
                <td class="text-right">S/ {{ total_paid|number_format(2, '.', ',') }}</td>
            </tr>
        </tbody>
    </table>

    <!-- Summary Box -->
    <div class="summary-box">
        <div class="summary-row">
            <span>{{ 'AmountToPay'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span>S/ {{ effective_amount|number_format(2, '.', ',') }}</span>
        </div>
        <div class="summary-row">
            <span>{{ 'TotalPaid'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span style="color: #1a7e1a;">S/ {{ total_paid|number_format(2, '.', ',') }}</span>
        </div>
        {% if balance > 0 %}
        <div class="summary-row">
            <span>{{ 'Balance'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span style="color: #c00;">S/ {{ balance|number_format(2, '.', ',') }}</span>
        </div>
        {% endif %}
        <div class="summary-row total">
            <span>{{ 'Status'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span><span class="receipt-status status-{{ payment.status }}">{{ status_label }}</span></span>
        </div>
    </div>

    {% else %}
    <!-- Single payment (no history needed) -->
    <div class="receipt-amount">
        <div class="amount-label">{{ 'AmountPaid'|get_plugin_lang('SchoolPlugin') }}</div>
        <div class="amount">S/ {{ total_paid|number_format(2, '.', ',') }}</div>
    </div>

    <div class="receipt-body">
        <div class="receipt-row">
            <span class="receipt-label">{{ 'PaymentDate'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ payment.payment_date }}</span>
        </div>
        <div class="receipt-row">
            <span class="receipt-label">{{ 'PaymentMethod'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ method_label }}</span>
        </div>
        {% if payment.reference %}
        <div class="receipt-row">
            <span class="receipt-label">{{ 'Reference'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">{{ payment.reference }}</span>
        </div>
        {% endif %}
        <div class="receipt-row">
            <span class="receipt-label">{{ 'Status'|get_plugin_lang('SchoolPlugin') }}:</span>
            <span class="receipt-value">
                <span class="receipt-status status-{{ payment.status }}">{{ status_label }}</span>
            </span>
        </div>
    </div>
    {% endif %}

    <!-- Footer -->
    <div class="receipt-footer">
        <p>{{ 'ReceiptGenerated'|get_plugin_lang('SchoolPlugin') }}: {{ 'now'|date('d/m/Y H:i') }}</p>
        <p>{{ 'ReceiptDisclaimer'|get_plugin_lang('SchoolPlugin') }}</p>
    </div>
</div>

</body>
</html>
