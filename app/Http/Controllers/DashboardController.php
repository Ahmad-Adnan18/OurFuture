<?php

namespace App\Http\Controllers;

use App\Models\Goal;
use App\Models\StorageAccount;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Inertia\Inertia;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $teamId = $request->user()->current_team_id;

        // 1. Total Assets: Sum of all storage accounts
        $totalAssets = StorageAccount::where('team_id', $teamId)->sum('balance');

        // 2. Total allocated to goals
        $totalAllocated = Goal::where('team_id', $teamId)->sum('current_balance');

        // 3. Unallocated: Assets - Allocated
        // Prevent negative unallocated (logic safety, though ideally shouldn't happen if bookkeeping is strict)
        $unallocatedFunds = max(0, $totalAssets - $totalAllocated);

        // 4. Active Goals
        $activeGoals = Goal::where('team_id', $teamId)
            ->where('status', 'active')
            ->orderBy('created_at', 'desc')
            ->get()
            ->append('progress_percent');

        // 5. Recent Transactions
        $recentTransactions = Transaction::with(['storageAccount', 'goal', 'user'])
            ->where('team_id', $teamId)
            ->latest('date')
            ->latest('created_at')
            ->limit(5)
            ->get();

        return Inertia::render('Dashboard', [
            'totalAssets' => (float) $totalAssets,
            'unallocatedFunds' => (float) $unallocatedFunds,
            'activeGoals' => $activeGoals,
            'recentTransactions' => $recentTransactions,
        ]);
    }
}
