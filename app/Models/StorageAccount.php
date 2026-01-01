<?php

namespace App\Models;

use App\Traits\BelongsToTeam;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class StorageAccount extends Model
{
    use HasFactory, BelongsToTeam;

    protected $fillable = [
        'team_id',
        'name',
        'type',
        'balance',
    ];

    protected function casts(): array
    {
        return [
            'balance' => 'decimal:2',
        ];
    }

    /**
     * Get the team that owns the storage account.
     */
    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Get the transactions for this storage account.
     */
    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }
}
