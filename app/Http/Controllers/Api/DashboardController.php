<?php

namespace App\Http\Controllers\Api;

use App\Http\Resources\AttemptResource;
use App\Models\Attempt;
use App\Models\Child;
use App\Support\ScopesApiByUserRole;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends ApiController
{
    public function stats(Request $request): JsonResponse
    {
        $user = $request->user();

        $childrenQuery = ScopesApiByUserRole::scopeChildrenForUser(Child::query(), $user);
        $attemptsQuery = ScopesApiByUserRole::scopeAttemptsForUser(
            Attempt::query()->where('is_completed', true),
            $user,
        );

        $childrenCount = (clone $childrenQuery)->count();
        $completedActivities = (clone $attemptsQuery)->count();
        $averageStars = round((float) (clone $attemptsQuery)->avg('stars_earned'), 1);
        $averagePerformance = $completedActivities > 0
            ? round(($averageStars / Attempt::MAX_STARS) * 100, 1)
            : 0;

        return $this->success([
            'children_count' => $childrenCount,
            'completed_activities_count' => $completedActivities,
            'average_stars' => $averageStars,
            'average_performance_percent' => $averagePerformance,
            'max_stars' => Attempt::MAX_STARS,
        ]);
    }

    public function recentSessions(Request $request): JsonResponse
    {
        $limit = min($request->integer('limit', 10), 50);

        $attempts = ScopesApiByUserRole::scopeAttemptsForUser(
            Attempt::query()
                ->where('is_completed', true)
                ->with(['child', 'activity.item.world'])
                ->latest(),
            $request->user(),
        )->limit($limit)->get();

        return $this->success([
            'sessions' => $attempts->map(fn (Attempt $attempt) => [
                'id' => $attempt->id,
                'child_id' => $attempt->child_id,
                'child_name' => $attempt->child?->name,
                'word_name' => $attempt->activity?->item?->word_name,
                'activity_type' => $attempt->activity?->type?->value,
                'activity_label' => $attempt->activity?->type?->label(),
                'world_name' => $attempt->activity?->item?->world?->name,
                'stars_earned' => $attempt->stars_earned,
                'completed_at' => $attempt->created_at?->toIso8601String(),
            ]),
        ]);
    }
}
