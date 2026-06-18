<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChildResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'age' => $this->age,
            'gender' => $this->gender->value,
            'gender_label' => $this->gender->label(),
            'avatar' => MediaUrl::fromRequest($request, $this->avatar),
            'level' => $this->level,
            'user_id' => $this->when($request->user()?->isSpecialist(), $this->user_id),
            'parent' => $this->when(
                $request->user()?->isSpecialist() && $this->relationLoaded('user') && $this->user,
                fn () => [
                    'id' => $this->user->id,
                    'name' => $this->user->name,
                    'email' => $this->user->email,
                ],
            ),
            'completed_attempts_count' => $this->whenCounted('completedAttempts'),
            'average_stars' => round($this->averageStars(), 1),
            'completion_rate' => $this->when(
                $request->user()?->isSpecialist(),
                fn () => $this->completionRate(),
            ),
            'trained_words_count' => $this->when(
                $request->user()?->isSpecialist(),
                fn () => $this->trainedWordsCount(),
            ),
            'total_attempts_count' => $this->when(
                $request->user()?->isSpecialist(),
                fn () => $this->totalAttemptsCount(),
            ),
            'overall_performance_score' => $this->when(
                $request->user()?->isSpecialist(),
                fn () => $this->overallPerformanceScore(),
            ),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
