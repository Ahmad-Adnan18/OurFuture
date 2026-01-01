<?php

namespace App\Http\Controllers;

use App\Models\Goal;
use Illuminate\Http\Request;
use Inertia\Inertia;

class GoalController extends Controller
{
    public function index(Request $request)
    {
        $status = $request->input('status', 'active');

        return Inertia::render('Goals/Index', [
            'goals' => Goal::where('team_id', auth()->user()->current_team_id)
                ->when($status === 'archived', function ($query) {
                    return $query->whereIn('status', ['completed', 'archived']);
                }, function ($query) {
                    return $query->where('status', 'active');
                })
                ->orderBy('created_at', 'desc')
                ->get()
                ->append('progress_percent'), // Append accessor
            'filters' => [
                'status' => $status,
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'target_amount' => 'required|numeric|min:0',
            'estimated_date' => 'nullable|date',
            'start_date' => 'required|date',
        ]);

        $request->user()->currentTeam->goals()->create(array_merge($validated, [
            'current_balance' => 0,
            'total_collected' => 0,
            'status' => 'active',
        ]));

        return redirect()->back();
    }

    public function update(Request $request, Goal $goal)
    {
        $this->authorize('update', $goal);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'target_amount' => 'required|numeric|min:0',
            'estimated_date' => 'nullable|date',
            'status' => 'required|in:active,completed,archived',
        ]);

        $goal->update($validated);

        return redirect()->back();
    }

    public function destroy(Goal $goal)
    {
        $this->authorize('delete', $goal);
        $goal->delete();

        return redirect()->back();
    }
}
