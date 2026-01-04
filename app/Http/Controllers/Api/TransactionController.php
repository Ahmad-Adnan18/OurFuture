<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\TransactionResource;
use App\Models\Goal;
use App\Models\StorageAccount;
use App\Models\Transaction;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    /**
     * List all transactions for current team with pagination
     */
    public function index(Request $request)
    {
        $transactions = Transaction::with(['storageAccount', 'goal', 'user'])
            ->where('team_id', auth()->user()->current_team_id)
            ->when($request->type, function ($query, $type) {
                return $query->where('type', $type);
            })
            ->when($request->month, function ($query, $month) {
                return $query->whereMonth('date', substr($month, 5, 2))
                    ->whereYear('date', substr($month, 0, 4));
            })
            ->latest('date')
            ->latest('created_at')
            ->paginate($request->per_page ?? 20);

        return TransactionResource::collection($transactions);
    }

    /**
     * Create a new transaction
     */
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
                return response()->json(['message' => 'Amount cannot be zero'], 422);
            }
        } else {
            // Other types must be positive
            if ($validated['amount'] <= 0) {
                return response()->json(['message' => 'Amount must be positive'], 422);
            }
        }

        // Verify storage account belongs to user's team
        $storageAccount = StorageAccount::where('id', $validated['storage_account_id'])
            ->where('team_id', auth()->user()->current_team_id)
            ->firstOrFail();

        // Verify goal belongs to user's team if provided
        if (!empty($validated['goal_id'])) {
            Goal::where('id', $validated['goal_id'])
                ->where('team_id', auth()->user()->current_team_id)
                ->firstOrFail();
        }

        // Create transaction (Observer handles balance updates)
        $transaction = $request->user()->currentTeam->transactions()->create(array_merge($validated, [
            'user_id' => $request->user()->id,
        ]));

        return response()->json([
            'message' => 'Transaction created successfully',
            'transaction' => new TransactionResource($transaction->load(['storageAccount', 'goal', 'user'])),
        ], 201);
    }

    /**
     * Get a single transaction
     */
    public function show(Transaction $transaction)
    {
        $this->authorize('view', $transaction);

        return new TransactionResource($transaction->load(['storageAccount', 'goal', 'user']));
    }

    /**
     * Delete a transaction
     */
    public function destroy(Transaction $transaction)
    {
        $this->authorize('delete', $transaction);

        $transaction->delete();

        return response()->json([
            'message' => 'Transaction deleted successfully',
        ]);
    }
}
