<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\WorldResource;
use App\Models\Activity;
use App\Models\Item;
use App\Models\World;
use Illuminate\Http\JsonResponse;

class ContentController extends ApiController
{
    public function stats(): JsonResponse
    {
        return $this->success([
            'worlds_count' => World::query()->count(),
            'items_count' => Item::query()->count(),
            'activities_count' => Activity::query()->count(),
        ]);
    }

    public function worlds(): JsonResponse
    {
        $worlds = World::query()
            ->withCount('items')
            ->orderBy('sort_order')
            ->get();

        return $this->success([
            'worlds' => WorldResource::collection($worlds),
        ]);
    }
}
