<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Http\Request;

class ExportController extends Controller
{
    /**
     * Export transactions to PDF
     */
    public function transactions(Request $request)
    {
        $request->validate([
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        $teamId = $request->user()->current_team_id;
        
        $query = Transaction::where('team_id', $teamId)
            ->with(['storageAccount', 'goal'])
            ->orderBy('date', 'desc');

        if ($request->start_date) {
            $query->whereDate('date', '>=', $request->start_date);
        }

        if ($request->end_date) {
            $query->whereDate('date', '<=', $request->end_date);
        }

        $transactions = $query->get();

        // Calculate totals
        $totalIncome = $transactions->whereIn('type', ['deposit'])->sum('amount');
        $totalExpense = $transactions->whereIn('type', ['expense', 'withdrawal'])->sum(function ($tx) {
            return abs($tx->amount);
        });

        $filename = 'transactions_' . now()->format('Y-m-d') . '.pdf';

        $pdf = Pdf::loadView('exports.transactions-pdf', [
            'transactions' => $transactions,
            'startDate' => $request->start_date ? Carbon::parse($request->start_date)->format('d M Y') : null,
            'endDate' => $request->end_date ? Carbon::parse($request->end_date)->format('d M Y') : null,
            'totalIncome' => $totalIncome,
            'totalExpense' => $totalExpense,
        ]);

        $pdf->setPaper('a4', 'portrait');

        return $pdf->download($filename);
    }
}
