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
            'type' => 'required|in:deposit,expense,withdrawal,adjustment,allocate',
            'storage_account_id' => 'required|exists:storage_accounts,id',
            'amount' => 'required|numeric', // Allow any numeric, type-specific validation below
            'goal_id' => 'nullable|exists:goals,id',
            'notes' => 'nullable|string',
        ]);

        // Type-specific amount validation
        if ($request->type === 'adjustment') {
            // Adjustment allows negative (for subtract) but not zero
            if ($validated['amount'] == 0) {
                return back()->withErrors(['amount' => 'Amount cannot be zero']);
            }
        } else {
            // Other types must be positive
            if ($validated['amount'] <= 0) {
                return back()->withErrors(['amount' => 'Amount must be positive']);
            }
        }

        // Security: Verify storage account belongs to user's team
        $storageAccount = StorageAccount::where('id', $validated['storage_account_id'])
            ->where('team_id', auth()->user()->current_team_id)
            ->first();

        if (!$storageAccount) {
            return back()->withErrors(['storage_account_id' => 'Invalid wallet selected']);
        }

        // Security: Verify goal belongs to user's team if provided
        if (!empty($validated['goal_id'])) {
            $goal = Goal::where('id', $validated['goal_id'])
                ->where('team_id', auth()->user()->current_team_id)
                ->first();

            if (!$goal) {
                return back()->withErrors(['goal_id' => 'Invalid goal selected']);
            }
        }

        // Create transaction
        $request->user()->currentTeam->transactions()->create(array_merge($validated, [
            'user_id' => $request->user()->id,
        ]));

        return redirect()->route('dashboard');
    }
}
