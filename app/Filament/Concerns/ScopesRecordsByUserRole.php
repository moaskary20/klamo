<?php

namespace App\Filament\Concerns;

use App\Enums\UserRole;
use Illuminate\Database\Eloquent\Builder;

trait ScopesRecordsByUserRole
{
    protected static function scopeQueryForCurrentUser(Builder $query, string $userColumn = 'user_id'): Builder
    {
        $user = auth()->user();

        if (! $user || $user->role === UserRole::Specialist) {
            return $query;
        }

        return $query->where($userColumn, $user->id);
    }

    protected static function scopeQueryByChildOwner(Builder $query): Builder
    {
        $user = auth()->user();

        if (! $user || $user->role === UserRole::Specialist) {
            return $query;
        }

        return $query->whereHas('child', fn (Builder $childQuery) => $childQuery->where('user_id', $user->id));
    }
}
