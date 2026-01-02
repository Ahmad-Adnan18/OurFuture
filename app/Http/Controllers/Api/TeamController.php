<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\TeamResource;
use App\Models\Team;
use Illuminate\Http\Request;
use Laravel\Jetstream\Contracts\AddsTeamMembers;
use Laravel\Jetstream\Contracts\CreatesTeams;
use Laravel\Jetstream\Contracts\InvitesTeamMembers;
use Laravel\Jetstream\Contracts\UpdatesTeamNames;
use Laravel\Jetstream\Features;

class TeamController extends Controller
{
    /**
     * List all teams for current user
     */
    public function index(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'owned_teams' => TeamResource::collection($user->ownedTeams),
            'teams' => TeamResource::collection($user->teams),
            'current_team' => new TeamResource($user->currentTeam),
        ]);
    }

    /**
     * Create a new team
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $creator = app(CreatesTeams::class);
        $team = $creator->create($request->user(), $validated);

        return response()->json([
            'message' => 'Team created successfully',
            'team' => new TeamResource($team),
        ], 201);
    }

    /**
     * Update team name
     */
    public function update(Request $request, Team $team)
    {
        $this->authorize('update', $team);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $updater = app(UpdatesTeamNames::class);
        $updater->update($request->user(), $team, $validated);

        return response()->json([
            'message' => 'Team updated successfully',
            'team' => new TeamResource($team->fresh()),
        ]);
    }

    /**
     * Switch current team
     */
    public function switchTeam(Request $request, Team $team)
    {
        // Verify user belongs to the team
        if (!$request->user()->belongsToTeam($team)) {
            return response()->json([
                'message' => 'You do not belong to this team',
            ], 403);
        }

        $request->user()->switchTeam($team);

        return response()->json([
            'message' => 'Switched to team successfully',
            'current_team' => new TeamResource($team),
        ]);
    }

    /**
     * Invite a member to the team
     */
    public function invite(Request $request, Team $team)
    {
        $this->authorize('addTeamMember', $team);

        $validated = $request->validate([
            'email' => 'required|email',
            'role' => 'required|string',
        ]);

        if (Features::sendsTeamInvitations()) {
            $inviter = app(InvitesTeamMembers::class);
            $inviter->invite(
                $request->user(),
                $team,
                $validated['email'],
                $validated['role']
            );

            return response()->json([
                'message' => 'Invitation sent successfully',
            ]);
        } else {
            $adder = app(AddsTeamMembers::class);
            $adder->add(
                $request->user(),
                $team,
                $validated['email'],
                $validated['role']
            );

            return response()->json([
                'message' => 'Member added successfully',
            ]);
        }
    }
}
