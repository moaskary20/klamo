<?php

namespace App\Http\Controllers\Api;

use App\Enums\ActivityType;
use App\Http\Resources\ActivityResource;
use App\Http\Resources\ChildResource;
use App\Http\Resources\ItemResource;
use App\Models\Activity;
use App\Models\Child;
use App\Models\Item;
use App\Support\MediaUrl;
use App\Support\ScopesApiByUserRole;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ActivityController extends ApiController
{
    public function show(Request $request, Activity $activity): JsonResponse
    {
        if (! $request->filled('child_id')) {
            return $this->error('معرّف الطفل مطلوب.', 422);
        }

        $child = $this->resolveChild($request);
        $activity->load(['item.world', 'item.activities']);

        if ($activity->item->min_level > $child->level) {
            return $this->error('هذا النشاط غير متاح لمستوى الطفل الحالي.', 403);
        }

        $payload = [
            'activity' => new ActivityResource($activity),
            'item' => new ItemResource($activity->item),
            'world' => [
                'id' => $activity->item->world->id,
                'name' => $activity->item->world->name,
            ],
        ];

        if ($activity->type === ActivityType::AuditoryDiscrimination) {
            $choices = Item::query()
                ->where('world_id', $activity->item->world_id)
                ->where('min_level', '<=', $child->level)
                ->inRandomOrder()
                ->limit(4)
                ->get();

            if (! $choices->contains('id', $activity->item_id)) {
                $choices = $choices->take(3)->push($activity->item);
            }

            $payload['question'] = [
                'text' => 'فين '.$activity->item->word_name.'؟',
                'audio_url' => MediaUrl::fromRequest($request, $activity->item->audio_path),
            ];
            $payload['choices'] = ItemResource::collection($choices->shuffle()->values());
        }

        if ($activity->type === ActivityType::WordRecognition) {
            $payload['instruction'] = 'تعرّف على الكلمة';
        }

        if ($activity->type === ActivityType::PronunciationRecording) {
            $payload['instruction'] = 'انطق الكلمة بصوت واضح';
        }

        return $this->success($payload);
    }

    protected function resolveChild(Request $request): Child
    {
        return ScopesApiByUserRole::resolveChild(
            $request->user(),
            $request->integer('child_id'),
        );
    }
}
