<?php

namespace App\Http\Controllers\Api\Admin;

use App\Enums\ActivityType;
use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\ActivityResource;
use App\Models\Activity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ActivityController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $activities = Activity::query()
            ->with(['item.world'])
            ->when($request->filled('item_id'), fn ($query) => $query->where('item_id', $request->integer('item_id')))
            ->latest()
            ->get();

        return $this->success([
            'activities' => $activities->map(fn (Activity $activity) => [
                ...(new ActivityResource($activity))->resolve(),
                'item_id' => $activity->item_id,
                'word_name' => $activity->item?->word_name,
                'world_name' => $activity->item?->world?->name,
            ]),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'item_id' => ['required', 'integer', 'exists:items,id'],
            'type' => ['required', Rule::enum(ActivityType::class)],
        ]);

        $activity = Activity::query()->create($data);
        $activity->load('item.world');

        return $this->success([
            'activity' => new ActivityResource($activity),
        ], 'تم إنشاء النشاط بنجاح', 201);
    }

    public function update(Request $request, Activity $activity): JsonResponse
    {
        $data = $request->validate([
            'item_id' => ['sometimes', 'required', 'integer', 'exists:items,id'],
            'type' => ['sometimes', 'required', Rule::enum(ActivityType::class)],
        ]);

        $activity->update($data);

        return $this->success([
            'activity' => new ActivityResource($activity->fresh(['item.world'])),
        ], 'تم تحديث النشاط بنجاح');
    }

    public function destroy(Activity $activity): JsonResponse
    {
        $activity->delete();

        return $this->success(message: 'تم حذف النشاط بنجاح');
    }
}
