<?php

namespace App\Policies;

use App\Models\StorageAccount;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class StorageAccountPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return true; // Filtered by BelongsToTeam trait
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, StorageAccount $storageAccount): bool
    {
        return $user->belongsToTeam($storageAccount->team);
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->currentTeam !== null;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, StorageAccount $storageAccount): bool
    {
        return $user->belongsToTeam($storageAccount->team);
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, StorageAccount $storageAccount): bool
    {
        return $user->belongsToTeam($storageAccount->team);
    }
}
