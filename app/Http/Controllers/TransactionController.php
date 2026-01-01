<?php

namespace App\Http\Controllers;

use App\Models\Goal;
use App\Models\StorageAccount;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Inertia\Inertia;

class TransactionController extends Controller
{
    public function index(Request $request)
    {
        $transactions = Transaction::with(['storageAccount', 'goal', 'user'])
            ->where('team_id', auth()->user()->current_team_id)
            ->latest('date')
            ->latest('created_at')
            ->paginate(50)
            ->withQueryString();

        return Inertia::render('Transactions/Index', [
            'transactions' => $transactions,
            'filters' => $request->all(['date', 'type']),
        ]);
    }

    public function create()
    {
        return Inertia::render('Transactions/Create', [
            'storageAccounts' => StorageAccount::where('team_id', auth()->user()->current_team_id)->get(),
            'goals' => Goal::where('team_id', auth()->user()->current_team_id)->where('status', 'active')->get(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'date' => 'required|date',
            'type' => 'required|in:deposit,expense,withdrawal,adjustment',
            'storage_account_id' => 'required|exists:storage_accounts,id',
            'amount' => 'required|numeric|min:1',
            'goal_id' => 'nullable|exists:goals,id',
            'notes' => 'nullable|string',
        ]);

        // Logic validation could be here or via a FormRequest, specifically checking balance.
        // For now, reliance on Observer logic (Phase 2) to handle balances.
        // But verifying ownership is important.
        
        // Create transaction
        $request->user()->currentTeam->transactions()->create(array_merge($validated, [
            'user_id' => $request->user()->id,
        ]));

        return redirect()->route('dashboard'); // Or back to transactions
    }
}
