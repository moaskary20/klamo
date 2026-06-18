<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\WorldResource;
use App\Models\World;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WorldController extends ApiController
{
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'icon' => ['nullable', 'image', 'max:5120'],
        ]);

        $iconPath = null;
        if ($request->hasFile('icon')) {
            $iconPath = $request->file('icon')->store('worlds/icons', 'public');
        }

        $world = World::query()->create([
            'name' => $data['name'],
            'sort_order' => $data['sort_order'] ?? 0,
            'icon' => $iconPath,
        ]);

        return $this->success([
            'world' => new WorldResource($world),
        ], 'تم إنشاء العالم بنجاح', 201);
    }

    public function update(Request $request, World $world): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'sort_order' => ['sometimes', 'nullable', 'integer', 'min:0'],
            'icon' => ['nullable', 'image', 'max:5120'],
        ]);

        if ($request->hasFile('icon')) {
            $data['icon'] = $request->file('icon')->store('worlds/icons', 'public');
        }

        $world->update($data);

        return $this->success([
            'world' => new WorldResource($world->fresh()),
        ], 'تم تحديث العالم بنجاح');
    }

    public function destroy(World $world): JsonResponse
    {
        $world->delete();

        return $this->success(message: 'تم حذف العالم بنجاح');
    }
}
