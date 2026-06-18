<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ItemResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'word_name' => $this->word_name,
            'min_level' => $this->min_level,
            'image_url' => MediaUrl::fromRequest($request, $this->image_path),
            'audio_url' => MediaUrl::fromRequest($request, $this->audio_path),
            'activities' => ActivityResource::collection($this->whenLoaded('activities')),
        ];
    }
}
