<?php

namespace App\Filament\Widgets;

use App\Filament\Concerns\ScopesRecordsByUserRole;
use App\Models\Attempt;
use App\Models\Child;
use Filament\Support\Icons\Heroicon;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class DashboardStatsWidget extends StatsOverviewWidget
{
    use ScopesRecordsByUserRole;

    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $childrenQuery = static::scopeQueryForCurrentUser(Child::query());
        $attemptsQuery = static::scopeQueryByChildOwner(
            Attempt::query()->where('is_completed', true)
        );

        $childrenCount = (clone $childrenQuery)->count();
        $completedActivities = (clone $attemptsQuery)->count();
        $averageStars = round((float) (clone $attemptsQuery)->avg('stars_earned'), 1);
        $averagePerformance = $completedActivities > 0
            ? round(($averageStars / Attempt::MAX_STARS) * 100, 1)
            : 0;

        return [
            Stat::make('عدد الأطفال', $childrenCount)
                ->description('إجمالي الأطفال المسجّلين')
                ->descriptionIcon(Heroicon::OutlinedUserGroup)
                ->color('primary')
                ->icon(Heroicon::OutlinedUserGroup),
            Stat::make('الأنشطة المكتملة', $completedActivities)
                ->description('جلسات أنهى فيها الأطفال الأنشطة')
                ->descriptionIcon(Heroicon::OutlinedCheckCircle)
                ->color('success')
                ->icon(Heroicon::OutlinedCheckCircle),
            Stat::make('متوسط الأداء', $averagePerformance.'%')
                ->description("متوسط النجوم: {$averageStars} / ".Attempt::MAX_STARS)
                ->descriptionIcon(Heroicon::OutlinedChartBar)
                ->color('warning')
                ->icon(Heroicon::OutlinedChartBar),
        ];
    }
}
