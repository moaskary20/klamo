<?php

namespace App\Http\Controllers\Api;

use App\Enums\ActivityType;
use App\Http\Requests\Api\StoreChildRequest;
use App\Http\Requests\Api\UpdateChildRequest;
use App\Http\Resources\AttemptResource;
use App\Http\Resources\ChildResource;
use App\Models\Activity;
use App\Models\Attempt;
use App\Models\Child;
use App\Models\World;
use App\Support\ScopesApiByUserRole;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class ChildController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $children = ScopesApiByUserRole::scopeChildrenForUser(Child::query(), $user)
            ->withCount('completedAttempts')
            ->when($user->isSpecialist(), fn ($query) => $query->with('user'))
            ->latest()
            ->get();

        return $this->success([
            'children' => ChildResource::collection($children),
        ]);
    }

    public function reports(Request $request): JsonResponse
    {
        $children = ScopesApiByUserRole::scopeChildrenForUser(Child::query(), $request->user())
            ->withCount('completedAttempts')
            ->when($request->user()->isSpecialist(), fn ($query) => $query->with('user'))
            ->orderBy('name')
            ->get();

        return $this->success([
            'reports' => $children->map(fn (Child $child) => [
                'child' => (new ChildResource($child))->resolve(),
                'completion_rate' => $child->completionRate(),
                'trained_words_count' => $child->trainedWordsCount(),
                'total_attempts_count' => $child->totalAttemptsCount(),
                'overall_performance_score' => $child->overallPerformanceScore(),
                'average_stars' => round($child->averageStars(), 1),
                'completed_activities_count' => $child->completed_attempts_count ?? $child->completedAttempts()->count(),
            ]),
        ]);
    }

    public function store(StoreChildRequest $request): JsonResponse
    {
        $data = $request->validated();
        $avatarPath = null;

        if ($request->hasFile('avatar')) {
            $avatarPath = $request->file('avatar')->store('children/avatars', 'public');
        }

        $userId = $request->user()->isSpecialist()
            ? ($data['user_id'] ?? $request->user()->id)
            : $request->user()->id;

        $child = Child::query()->create([
            'user_id' => $userId,
            'name' => $data['name'],
            'age' => $data['age'],
            'gender' => $data['gender'],
            'avatar' => $avatarPath,
            'level' => $data['level'] ?? 1,
        ]);

        if ($request->user()->isSpecialist()) {
            $child->load('user');
        }

        return $this->success([
            'child' => new ChildResource($child),
        ], 'تم إنشاء ملف الطفل بنجاح', 201);
    }

    public function show(Request $request, Child $child): JsonResponse
    {
        $this->authorizeChild($request, $child);

        $child->loadCount('completedAttempts');
        if ($request->user()->isSpecialist()) {
            $child->load('user');
        }

        return $this->success([
            'child' => new ChildResource($child),
        ]);
    }

    public function update(UpdateChildRequest $request, Child $child): JsonResponse
    {
        $this->authorizeChild($request, $child);

        $data = $request->validated();

        if ($request->hasFile('avatar')) {
            $data['avatar'] = $request->file('avatar')->store('children/avatars', 'public');
        }

        if (! $request->user()->isSpecialist()) {
            unset($data['user_id']);
        }

        $child->update($data);
        $child->loadCount('completedAttempts');

        if ($request->user()->isSpecialist()) {
            $child->load('user');
        }

        return $this->success([
            'child' => new ChildResource($child->fresh()),
        ], 'تم تحديث بيانات الطفل بنجاح');
    }

    public function destroy(Request $request, Child $child): JsonResponse
    {
        $this->authorizeChild($request, $child);
        $child->delete();

        return $this->success(message: 'تم حذف الطفل بنجاح');
    }

    public function attempts(Request $request, Child $child): JsonResponse
    {
        $this->authorizeChild($request, $child);

        $attempts = $child->attempts()
            ->with(['activity.item.world'])
            ->latest()
            ->paginate(min($request->integer('per_page', 20), 50));

        return $this->success([
            'attempts' => AttemptResource::collection($attempts->getCollection())->resolve(),
            'meta' => [
                'current_page' => $attempts->currentPage(),
                'last_page' => $attempts->lastPage(),
                'total' => $attempts->total(),
            ],
        ]);
    }

    public function progress(Request $request, Child $child): JsonResponse
    {
        $this->authorizeChild($request, $child);

        $completedAttempts = $child->completedAttempts()
            ->with(['activity.item.world'])
            ->latest()
            ->get();

        $totalStars = (int) $completedAttempts->sum('stars_earned');

        $byActivityType = collect(ActivityType::cases())->map(function (ActivityType $type) use ($completedAttempts) {
            $typeAttempts = $completedAttempts->filter(
                fn ($attempt) => $attempt->activity?->type === $type
            );

            return [
                'type' => $type->value,
                'label' => $type->label(),
                'count' => $typeAttempts->count(),
                'stars' => (int) $typeAttempts->sum('stars_earned'),
            ];
        })->values();

        $worlds = World::query()->orderBy('sort_order')->get();
        $byWorld = $worlds->map(function (World $world) use ($child, $completedAttempts) {
            $available = Activity::query()
                ->whereHas('item', fn ($query) => $query
                    ->where('world_id', $world->id)
                    ->where('min_level', '<=', $child->level))
                ->count();

            $worldAttempts = $completedAttempts->filter(
                fn ($attempt) => $attempt->activity?->item?->world_id === $world->id
            );

            $completedUnique = $worldAttempts
                ->pluck('activity_id')
                ->unique()
                ->count();

            return [
                'world_id' => $world->id,
                'world_name' => $world->name,
                'completed' => $completedUnique,
                'stars' => (int) $worldAttempts->sum('stars_earned'),
                'total_available' => $available,
            ];
        })->values();

        $starsDistribution = collect(range(1, Attempt::MAX_STARS))->map(function (int $stars) use ($completedAttempts) {
            return [
                'stars' => $stars,
                'count' => $completedAttempts->where('stars_earned', $stars)->count(),
            ];
        })->values();

        $recentActivities = $completedAttempts
            ->take(10)
            ->map(function (Attempt $attempt) {
                $activity = $attempt->activity;
                $item = $activity?->item;

                return [
                    'word_name' => $item?->word_name,
                    'activity_type' => $activity?->type?->value,
                    'activity_label' => $activity?->type?->label(),
                    'world_name' => $item?->world?->name,
                    'stars_earned' => $attempt->stars_earned,
                    'completed_at' => $attempt->created_at?->toIso8601String(),
                ];
            })
            ->values();

        $weeklyActivity = collect(range(6, 0))->map(function (int $daysAgo) use ($completedAttempts) {
            $date = Carbon::today()->subDays($daysAgo);

            return [
                'label' => $this->arabicWeekdayLabel($date),
                'date' => $date->toDateString(),
                'count' => $completedAttempts
                    ->filter(fn ($attempt) => $attempt->created_at?->isSameDay($date))
                    ->count(),
            ];
        })->values();

        return $this->success([
            'child' => new ChildResource($child->loadCount('completedAttempts')),
            'progress' => [
                'level' => $child->level,
                'completed_activities_count' => $completedAttempts->count(),
                'unique_activities_count' => $child->completedUniqueActivitiesCount(),
                'total_attempts_count' => $child->totalAttemptsCount(),
                'trained_words_count' => $child->trainedWordsCount(),
                'available_activities_count' => $child->availableActivitiesCount(),
                'completion_rate' => $child->completionRate(),
                'overall_performance_score' => $child->overallPerformanceScore(),
                'total_stars' => $totalStars,
                'average_stars' => round((float) $completedAttempts->avg('stars_earned'), 1),
                'max_stars_per_activity' => Attempt::MAX_STARS,
                'by_activity_type' => $byActivityType,
                'by_world' => $byWorld,
                'stars_distribution' => $starsDistribution,
                'recent_activities' => $recentActivities,
                'weekly_activity' => $weeklyActivity,
            ],
        ]);
    }

    protected function arabicWeekdayLabel(Carbon $date): string
    {
        return match ($date->dayOfWeek) {
            Carbon::SATURDAY => 'السبت',
            Carbon::SUNDAY => 'الأحد',
            Carbon::MONDAY => 'الإثنين',
            Carbon::TUESDAY => 'الثلاثاء',
            Carbon::WEDNESDAY => 'الأربعاء',
            Carbon::THURSDAY => 'الخميس',
            Carbon::FRIDAY => 'الجمعة',
            default => $date->translatedFormat('D'),
        };
    }

    protected function authorizeChild(Request $request, Child $child): void
    {
        abort_unless(
            ScopesApiByUserRole::canAccessChild($request->user(), $child),
            403,
            'غير مصرح بالوصول لهذا الطفل.',
        );
    }
}
