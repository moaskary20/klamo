<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Item extends Model
{
    protected $fillable = [
        'world_id',
        'word_name',
        'image_path',
        'audio_path',
        'min_level',
    ];

    protected function casts(): array
    {
        return [
            'min_level' => 'integer',
        ];
    }

    public function world(): BelongsTo
    {
        return $this->belongsTo(World::class);
    }

    public function activities(): HasMany
    {
        return $this->hasMany(Activity::class);
    }
}
