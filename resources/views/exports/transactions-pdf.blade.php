<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Transaction Report</title>
    <style>
        * {
            font-family: 'DejaVu Sans', sans-serif;
        }
        body {
            font-size: 12px;
            color: #333;
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #10b981;
        }
        .header h1 {
            color: #10b981;
            margin: 0 0 5px 0;
            font-size: 24px;
        }
        .header p {
            color: #666;
            margin: 0;
        }
        .summary {
            display: flex;
            margin-bottom: 20px;
        }
        .summary-box {
            background: #f8fafc;
            padding: 10px 15px;
            border-radius: 8px;
            margin-right: 10px;
        }
        .summary-box h3 {
            margin: 0 0 5px 0;
            font-size: 11px;
            color: #64748b;
            text-transform: uppercase;
        }
        .summary-box p {
            margin: 0;
            font-size: 16px;
            font-weight: bold;
        }
        .income { color: #10b981; }
        .expense { color: #ef4444; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        th {
            background: #10b981;
            color: white;
            padding: 10px 8px;
            text-align: left;
            font-size: 11px;
            text-transform: uppercase;
        }
        td {
            padding: 10px 8px;
            border-bottom: 1px solid #e2e8f0;
        }
        tr:nth-child(even) {
            background: #f8fafc;
        }
        .type-badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .type-deposit { background: #d1fae5; color: #059669; }
        .type-expense { background: #fee2e2; color: #dc2626; }
        .type-withdrawal { background: #fef3c7; color: #d97706; }
        .type-allocate { background: #ede9fe; color: #7c3aed; }
        .type-adjustment { background: #e0f2fe; color: #0284c7; }
        .amount-positive { color: #10b981; font-weight: bold; }
        .amount-negative { color: #ef4444; font-weight: bold; }
        .footer {
            margin-top: 30px;
            text-align: center;
            color: #94a3b8;
            font-size: 10px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>💑 OurFuture</h1>
        <p>Transaction Report</p>
        <p style="font-size: 11px; margin-top: 5px;">
            @if($startDate && $endDate)
                {{ $startDate }} - {{ $endDate }}
            @elseif($startDate)
                From {{ $startDate }}
            @elseif($endDate)
                Until {{ $endDate }}
            @else
                All Transactions
            @endif
        </p>
    </div>

    <table style="width: auto; border: none; margin-bottom: 20px;">
        <tr>
            <td style="border: none; background: #d1fae5; padding: 8px 15px; border-radius: 8px;">
                <div style="font-size: 10px; color: #059669; text-transform: uppercase;">Total Income</div>
                <div style="font-size: 16px; font-weight: bold; color: #059669;">Rp {{ number_format($totalIncome, 0, ',', '.') }}</div>
            </td>
            <td style="border: none; width: 10px;"></td>
            <td style="border: none; background: #fee2e2; padding: 8px 15px; border-radius: 8px;">
                <div style="font-size: 10px; color: #dc2626; text-transform: uppercase;">Total Expense</div>
                <div style="font-size: 16px; font-weight: bold; color: #dc2626;">Rp {{ number_format($totalExpense, 0, ',', '.') }}</div>
            </td>
            <td style="border: none; width: 10px;"></td>
            <td style="border: none; background: #f0fdf4; padding: 8px 15px; border-radius: 8px;">
                <div style="font-size: 10px; color: #16a34a; text-transform: uppercase;">Net</div>
                <div style="font-size: 16px; font-weight: bold; color: #16a34a;">Rp {{ number_format($totalIncome - $totalExpense, 0, ',', '.') }}</div>
            </td>
        </tr>
    </table>

    <table>
        <thead>
            <tr>
                <th style="width: 80px;">Date</th>
                <th style="width: 70px;">Type</th>
                <th>Wallet</th>
                <th>Goal</th>
                <th>Notes</th>
                <th style="text-align: right;">Amount</th>
            </tr>
        </thead>
        <tbody>
            @foreach($transactions as $tx)
            <tr>
                <td>{{ \Carbon\Carbon::parse($tx->date)->format('d M Y') }}</td>
                <td>
                    <span class="type-badge type-{{ $tx->type }}">{{ $tx->type }}</span>
                </td>
                <td>{{ $tx->storageAccount?->name ?? '-' }}</td>
                <td>{{ $tx->goal?->title ?? 'Unallocated' }}</td>
                <td>{{ $tx->notes ?? '-' }}</td>
                <td style="text-align: right;" class="{{ in_array($tx->type, ['expense', 'withdrawal']) ? 'amount-negative' : 'amount-positive' }}">
                    {{ in_array($tx->type, ['expense', 'withdrawal']) ? '-' : '+' }} Rp {{ number_format(abs($tx->amount), 0, ',', '.') }}
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <div class="footer">
        <p>Generated on {{ now()->format('d M Y H:i') }} • OurFuture - Financial Planning for Couples</p>
    </div>
</body>
</html>
