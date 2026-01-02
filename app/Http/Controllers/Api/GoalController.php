<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\GoalResource;
use App\Models\Goal;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    /**
     * List all goals for current team
     */
    public function index(Request $request)
    {
        $status = $request->input('status', 'active');

        $goals = Goal::where('team_id', auth()->user()->current_team_id)
            ->when($status === 'archived', function ($query) {
                return $query->whereIn('status', ['completed', 'archived']);
            }, function ($query) {
                return $query->where('status', 'active');
            })
            ->orderBy('created_at', 'desc')
            ->get()
            ->append('progress_percent');

        return GoalResource::collection($goals);
    }

    /**
     * Create a new goal
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'target_amount' => 'required|numeric|min:0',
            'estimated_date' => 'nullable|date',
            'start_date' => 'required|date',
        ]);

        $goal = $request->user()->currentTeam->goals()->create(array_merge($validated, [
            'current_balance' => 0,
            'total_collected' => 0,
            'status' => 'active',
        ]));

        return response()->json([
            'message' => 'Goal created successfully',
            'goal' => new GoalResource($goal->append('progress_percent')),
        ], 201);
    }

    /**
     * Get a single goal
     */
    public function show(Goal $goal)
    {
        $this->authorize('view', $goal);

        return new GoalResource($goal->append('progress_percent'));
    }

    /**
     * Update a goal
     */
    public function update(Request $request, Goal $goal)
    {
        $this->authorize('update', $goal);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'target_amount' => 'required|numeric|min:0',
            'estimated_date' => 'nullable|date',
            'status' => 'sometimes|in:active,completed,archived',
        ]);

        $goal->update($validated);

        return response()->json([
            'message' => 'Goal updated successfully',
            'goal' => new GoalResource($goal->fresh()->append('progress_percent')),
        ]);
    }

    /**
     * Delete a goal
     */
    public function destroy(Goal $goal)
    {
        $this->authorize('delete', $goal);

        $goal->delete();

        return response()->json([
            'message' => 'Goal deleted successfully',
        ]);
    }
}
