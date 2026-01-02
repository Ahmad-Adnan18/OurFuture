<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\StorageAccountResource;
use App\Models\StorageAccount;
use Illuminate\Http\Request;

class StorageAccountController extends Controller
{
    /**
     * List all storage accounts (wallets) for current team
     */
    public function index()
    {
        $accounts = StorageAccount::where('team_id', auth()->user()->current_team_id)
            ->orderBy('name')
            ->get();

        return StorageAccountResource::collection($accounts);
    }

    /**
     * Create a new storage account
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|in:bank,e-wallet,investment,cash',
            'balance' => 'required|numeric|min:0',
        ]);

        $account = $request->user()->currentTeam->storageAccounts()->create($validated);

        return response()->json([
            'message' => 'Wallet created successfully',
            'wallet' => new StorageAccountResource($account),
        ], 201);
    }

    /**
     * Get a single storage account
     */
    public function show(StorageAccount $wallet)
    {
        $this->authorize('view', $wallet);

        return new StorageAccountResource($wallet);
    }

    /**
     * Update a storage account
     */
    public function update(Request $request, StorageAccount $wallet)
    {
        $this->authorize('update', $wallet);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|in:bank,e-wallet,investment,cash',
            'balance' => 'required|numeric|min:0',
        ]);

        $wallet->update($validated);

        return response()->json([
            'message' => 'Wallet updated successfully',
            'wallet' => new StorageAccountResource($wallet->fresh()),
        ]);
    }

    /**
     * Delete a storage account
     */
    public function destroy(StorageAccount $wallet)
    {
        $this->authorize('delete', $wallet);

        $wallet->delete();

        return response()->json([
            'message' => 'Wallet deleted successfully',
        ]);
    }
}
