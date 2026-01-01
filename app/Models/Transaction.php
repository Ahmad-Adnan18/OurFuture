<?php

namespace App\Models;

use App\Traits\BelongsToTeam;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Transaction extends Model
{
    use HasFactory, BelongsToTeam;

    protected $fillable = [
        'team_id',
        'user_id',
        'storage_account_id',
        'goal_id',
        'type',
        'amount',
        'date',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'date' => 'date',
        ];
    }

    /**
     * Get the team that owns the transaction.
     */
    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Get the user who created the transaction.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the storage account for this transaction.
     */
    public function storageAccount(): BelongsTo
    {
        return $this->belongsTo(StorageAccount::class);
    }

    /**
     * Get the goal for this transaction (nullable).
     */
    public function goal(): BelongsTo
    {
        return $this->belongsTo(Goal::class);
    }

    /**
     * Check if this is an income transaction (deposit/adjustment positive).
     */
    public function isIncome(): bool
    {
        return in_array($this->type, ['deposit', 'adjustment']) && $this->amount > 0;
    }

    /**
     * Check if this is an outgoing transaction.
     */
    public function isOutgoing(): bool
    {
        return in_array($this->type, ['expense', 'withdrawal']);
    }
}
