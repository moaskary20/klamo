<?php

namespace App\Support;

use App\Models\Child;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

class ScopesApiByUserRole
{
    public static function scopeChildrenForUser(Builder $query, User $user): Builder
    {
        if ($user->isSpecialist()) {
            return $query;
        }

        return $query->where('user_id', $user->id);
    }

    public static function scopeAttemptsForUser(Builder $query, User $user): Builder
    {
        if ($user->isSpecialist()) {
            return $query;
        }

        return $query->whereHas('child', fn (Builder $childQuery) => $childQuery->where('user_id', $user->id));
    }

    public static function canAccessChild(User $user, Child $child): bool
    {
        return $user->isSpecialist() || $child->user_id === $user->id;
    }

    public static function resolveChild(User $user, int $childId): Child
    {
        return static::scopeChildrenForUser(Child::query(), $user)
            ->whereKey($childId)
            ->firstOrFail();
    }
}
