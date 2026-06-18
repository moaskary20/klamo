<?php

namespace App\Models;

use App\Enums\Gender;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Child extends Model
{
    protected $fillable = [
        'user_id',
        'name',
        'age',
        'gender',
        'avatar',
        'level',
    ];

    protected function casts(): array
    {
        return [
            'age' => 'integer',
            'level' => 'integer',
            'gender' => Gender::class,
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function parent(): BelongsTo
    {
        return $this->user();
    }

    public function attempts(): HasMany
    {
        return $this->hasMany(Attempt::class);
    }

    public function completedAttempts(): HasMany
    {
        return $this->attempts()->where('is_completed', true);
    }

    public function averageStars(): float
    {
        return (float) ($this->completedAttempts()->avg('stars_earned') ?? 0);
    }

    public function totalAttemptsCount(): int
    {
        return $this->attempts()->count();
    }

    public function availableActivitiesCount(): int
    {
        return Activity::query()
            ->whereHas('item', fn ($query) => $query->where('min_level', '<=', $this->level))
            ->count();
    }

    public function completedUniqueActivitiesCount(): int
    {
        return (int) $this->completedAttempts()->distinct()->count('activity_id');
    }

    public function trainedWordsCount(): int
    {
        return (int) $this->completedAttempts()
            ->join('activities', 'attempts.activity_id', '=', 'activities.id')
            ->distinct('activities.item_id')
            ->count('activities.item_id');
    }

    public function completionRate(): float
    {
        $available = $this->availableActivitiesCount();

        if ($available === 0) {
            return 0;
        }

        return round(($this->completedUniqueActivitiesCount() / $available) * 100, 1);
    }

    public function overallPerformanceScore(): float
    {
        $completed = $this->completedAttempts()->count();

        if ($completed === 0) {
            return 0;
        }

        return round(($this->averageStars() / Attempt::MAX_STARS) * 100, 1);
    }
}
