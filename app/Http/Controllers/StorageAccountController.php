<?php

namespace App\Http\Controllers;

use App\Models\StorageAccount;
use Illuminate\Http\Request;
use Inertia\Inertia;

class StorageAccountController extends Controller
{
    public function index()
    {
        return Inertia::render('Storage/Index', [
            'accounts' => StorageAccount::where('team_id', auth()->user()->current_team_id)
                ->orderBy('name')
                ->get(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|in:bank,e-wallet,investment,cash',
            'balance' => 'required|numeric|min:0',
        ]);

        $request->user()->currentTeam->storageAccounts()->create($validated);

        return redirect()->back();
    }

    public function update(Request $request, StorageAccount $storageAccount)
    {
        $this->authorize('update', $storageAccount);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|in:bank,e-wallet,investment,cash',
            'balance' => 'required|numeric|min:0',
        ]);

        $storageAccount->update($validated);

        return redirect()->back();
    }

    public function destroy(StorageAccount $storageAccount)
    {
        $this->authorize('delete', $storageAccount);
        $storageAccount->delete();

        return redirect()->back();
    }
}
