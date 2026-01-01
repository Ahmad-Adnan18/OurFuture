<?php

namespace App\Observers;

use App\Models\Transaction;

class TransactionObserver
{
    /**
     * Handle the Transaction "created" event.
     */
    public function created(Transaction $transaction): void
    {
        $this->applyBalanceChanges($transaction, 'add');
    }

    /**
     * Handle the Transaction "updated" event.
     */
    public function updated(Transaction $transaction): void
    {
        // Revert old values first
        $oldTransaction = new Transaction($transaction->getOriginal());
        $this->applyBalanceChanges($oldTransaction, 'subtract');
        
        // Apply new values
        $this->applyBalanceChanges($transaction, 'add');
    }

    /**
     * Handle the Transaction "deleted" event.
     */
    public function deleted(Transaction $transaction): void
    {
        $this->applyBalanceChanges($transaction, 'subtract');
    }

    /**
     * Apply balance changes based on transaction type.
     * 
     * Business Rules:
     * - Deposit: storage(+), goal.current(+), goal.total(+)
     * - Expense: storage(-), goal.current(-), goal.total(=)
     * - Withdrawal: storage(-), goal.current(-), goal.total(-)
     * - Adjustment: storage(+/-), no goal changes
     */
    private function applyBalanceChanges(Transaction $transaction, string $operation): void
    {
        $amount = $transaction->amount;
        $multiplier = $operation === 'add' ? 1 : -1;
        
        $storageAccount = $transaction->storageAccount;
        $goal = $transaction->goal;
        
        switch ($transaction->type) {
            case 'deposit':
                // Storage balance increases
                $storageAccount->increment('balance', $amount * $multiplier);
                
                // Goal balances increase (if goal exists)
                if ($goal) {
                    $goal->increment('current_balance', $amount * $multiplier);
                    $goal->increment('total_collected', $amount * $multiplier);
                }
                break;
                
            case 'expense':
                // Storage balance decreases
                $storageAccount->decrement('balance', $amount * $multiplier);
                
                // Goal current_balance decreases, but total_collected stays same
                if ($goal) {
                    $goal->decrement('current_balance', $amount * $multiplier);
                    // total_collected NOT changed - progress bar stays!
                }
                break;
                
            case 'withdrawal':
                // Storage balance decreases
                $storageAccount->decrement('balance', $amount * $multiplier);
                
                // Both goal balances decrease (bad performance indicator)
                if ($goal) {
                    $goal->decrement('current_balance', $amount * $multiplier);
                    $goal->decrement('total_collected', $amount * $multiplier);
                }
                break;
                
            case 'adjustment':
                // Only storage balance changes, no goal involved
                $storageAccount->increment('balance', $amount * $multiplier);
                break;
        }
    }
}
