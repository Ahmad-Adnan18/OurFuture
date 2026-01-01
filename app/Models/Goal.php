<?php

namespace App\Models;

use App\Traits\BelongsToTeam;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Goal extends Model
{
    use HasFactory, BelongsToTeam;

    protected $fillable = [
        'team_id',
        'title',
        'target_amount',
        'current_balance',
        'total_collected',
        'start_date',
        'estimated_date',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'target_amount' => 'decimal:2',
            'current_balance' => 'decimal:2',
            'total_collected' => 'decimal:2',
            'start_date' => 'date',
            'estimated_date' => 'date',
        ];
    }

    /**
     * Get the team that owns the goal.
     */
    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Get the transactions for this goal.
     */
    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }

    /**
     * Calculate progress percentage based on total_collected / target_amount.
     */
    public function getProgressPercentAttribute(): float
    {
        if ($this->target_amount <= 0) {
            return 0;
        }
        
        return min(100, ($this->total_collected / $this->target_amount) * 100);
    }
}
