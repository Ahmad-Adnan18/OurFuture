<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GoalResource extends JsonResource
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
            'title' => $this->title,
            'target_amount' => (float) $this->target_amount,
            'current_balance' => (float) $this->current_balance,
            'total_collected' => (float) $this->total_collected,
            'progress_percent' => $this->when(
                isset($this->progress_percent),
                $this->progress_percent
            ),
            'status' => $this->status,
            'start_date' => $this->start_date,
            'estimated_date' => $this->estimated_date,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
