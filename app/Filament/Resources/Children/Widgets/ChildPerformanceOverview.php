<?php

namespace App\Filament\Resources\Children\Widgets;

use App\Models\Attempt;
use App\Models\Child;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class ChildPerformanceOverview extends StatsOverviewWidget
{
    public ?Child $record = null;

    protected function getStats(): array
    {
        if (! $this->record) {
            return [];
        }

        $child = $this->record;

        return [
            Stat::make('نسبة الإنجاز', $child->completionRate().'%')
                ->description("{$child->completedUniqueActivitiesCount()} / {$child->availableActivitiesCount()} نشاط"),
            Stat::make('كلمات مُدرَّب عليها', $child->trainedWordsCount())
                ->description('كلمات مختلفة تم إكمال أنشطتها'),
            Stat::make('عدد المحاولات', $child->totalAttemptsCount())
                ->description('إجمالي المحاولات المسجّلة'),
            Stat::make('مستوى الأداء', $child->overallPerformanceScore().'%')
                ->description('متوسط النجوم: '.number_format($child->averageStars(), 1).' / '.Attempt::MAX_STARS),
        ];
    }
}
