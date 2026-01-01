<?php

namespace App\Traits;

use Illuminate\Database\Eloquent\Builder;

trait BelongsToTeam
{
    /**
     * Boot the trait.
     */
    protected static function bootBelongsToTeam(): void
    {
        // Auto-scope queries to current team
        static::addGlobalScope('team', function (Builder $query) {
            if (auth()->check() && auth()->user()->currentTeam) {
                $query->where('team_id', auth()->user()->currentTeam->id);
            }
        });

        // Auto-set team_id when creating
        static::creating(function ($model) {
            if (auth()->check() && auth()->user()->currentTeam && empty($model->team_id)) {
                $model->team_id = auth()->user()->currentTeam->id;
            }
        });
    }

    /**
     * Scope to a specific team.
     */
    public function scopeForTeam(Builder $query, int $teamId): Builder
    {
        return $query->withoutGlobalScope('team')->where('team_id', $teamId);
    }
}
