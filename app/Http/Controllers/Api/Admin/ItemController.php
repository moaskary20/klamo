<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\ItemResource;
use App\Models\Item;
use App\Models\World;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ItemController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $items = Item::query()
            ->with(['world', 'activities'])
            ->when($request->filled('world_id'), fn ($query) => $query->where('world_id', $request->integer('world_id')))
            ->orderBy('min_level')
            ->orderBy('id')
            ->get();

        return $this->success([
            'items' => $items->map(fn (Item $item) => [
                ...(new ItemResource($item))->resolve(),
                'world_id' => $item->world_id,
                'world_name' => $item->world?->name,
            ]),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'world_id' => ['required', 'integer', 'exists:worlds,id'],
            'word_name' => ['required', 'string', 'max:255'],
            'min_level' => ['nullable', 'integer', 'min:1'],
            'image' => ['nullable', 'image', 'max:5120'],
            'audio' => ['nullable', 'file', 'mimes:mp3,wav,ogg,m4a,aac', 'max:10240'],
        ]);

        $imagePath = $request->hasFile('image')
            ? $request->file('image')->store('items/images', 'public')
            : null;
        $audioPath = $request->hasFile('audio')
            ? $request->file('audio')->store('items/audio', 'public')
            : null;

        $item = Item::query()->create([
            'world_id' => $data['world_id'],
            'word_name' => $data['word_name'],
            'min_level' => $data['min_level'] ?? 1,
            'image_path' => $imagePath,
            'audio_path' => $audioPath,
        ]);

        $item->load('activities');

        return $this->success([
            'item' => new ItemResource($item),
        ], 'تم إنشاء الكلمة بنجاح', 201);
    }

    public function update(Request $request, Item $item): JsonResponse
    {
        $data = $request->validate([
            'world_id' => ['sometimes', 'required', 'integer', 'exists:worlds,id'],
            'word_name' => ['sometimes', 'required', 'string', 'max:255'],
            'min_level' => ['sometimes', 'nullable', 'integer', 'min:1'],
            'image' => ['nullable', 'image', 'max:5120'],
            'audio' => ['nullable', 'file', 'mimes:mp3,wav,ogg,m4a,aac', 'max:10240'],
        ]);

        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('items/images', 'public');
        }

        if ($request->hasFile('audio')) {
            $data['audio_path'] = $request->file('audio')->store('items/audio', 'public');
        }

        unset($data['image'], $data['audio']);
        $item->update($data);
        $item->load('activities');

        return $this->success([
            'item' => new ItemResource($item->fresh(['activities'])),
        ], 'تم تحديث الكلمة بنجاح');
    }

    public function destroy(Item $item): JsonResponse
    {
        $item->delete();

        return $this->success(message: 'تم حذف الكلمة بنجاح');
    }
}
