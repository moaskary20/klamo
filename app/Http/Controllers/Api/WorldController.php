<?php

namespace App\Http\Controllers\Api;

use App\Http\Resources\WorldResource;
use App\Models\Child;
use App\Models\World;
use App\Support\ScopesApiByUserRole;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WorldController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $child = $this->resolveChild($request);

        $worlds = World::query()
            ->orderBy('sort_order')
            ->when($child, fn ($query) => $query->withCount([
                'items as items_count' => fn ($itemsQuery) => $itemsQuery->where('min_level', '<=', $child->level),
            ]))
            ->get();

        return $this->success([
            'child_level' => $child?->level,
            'worlds' => WorldResource::collection($worlds),
        ]);
    }

    public function show(Request $request, World $world): JsonResponse
    {
        if (! $request->filled('child_id')) {
            return $this->error('معرّف الطفل مطلوب لجلب محتوى العالم.', 422);
        }

        $child = $this->resolveChild($request);

        $world->load([
            'items' => fn ($query) => $query
                ->where('min_level', '<=', $child->level)
                ->with('activities')
                ->orderBy('min_level')
                ->orderBy('id'),
        ]);

        return $this->success([
            'child_level' => $child->level,
            'world' => new WorldResource($world),
        ]);
    }

    protected function resolveChild(Request $request): ?Child
    {
        $childId = $request->integer('child_id');

        if (! $childId) {
            return null;
        }

        return ScopesApiByUserRole::resolveChild($request->user(), $childId);
    }
}
