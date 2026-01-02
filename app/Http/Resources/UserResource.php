<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'profile_photo_url' => $this->profile_photo_url,
            'current_team_id' => $this->current_team_id,
            'current_team' => new TeamResource($this->whenLoaded('currentTeam')),
            'owned_teams' => TeamResource::collection($this->whenLoaded('ownedTeams')),
            'teams' => TeamResource::collection($this->whenLoaded('teams')),
            'all_teams' => TeamResource::collection($this->whenLoaded('ownedTeams', function () {
                return $this->ownedTeams->merge($this->teams);
            })),
            'created_at' => $this->created_at,
        ];
    }
}
