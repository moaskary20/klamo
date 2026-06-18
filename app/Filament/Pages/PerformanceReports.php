<?php

namespace App\Filament\Pages;

use App\Filament\Concerns\ScopesRecordsByUserRole;
use App\Filament\Resources\Children\ChildResource;
use App\Models\Attempt;
use App\Models\Child;
use BackedEnum;
use Filament\Actions\ViewAction;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Concerns\InteractsWithTable;
use Filament\Tables\Contracts\HasTable;
use Filament\Tables\Table;
use UnitEnum;

class PerformanceReports extends Page implements HasTable
{
    use InteractsWithTable;
    use ScopesRecordsByUserRole;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedChartBarSquare;

    protected static string | UnitEnum | null $navigationGroup = 'متابعة الأداء';

    protected static ?string $navigationLabel = 'تقارير الأداء';

    protected static ?string $title = 'تقارير أداء الأطفال';

    protected static ?int $navigationSort = 1;

    protected string $view = 'filament.pages.performance-reports';

    public function table(Table $table): Table
    {
        return $table
            ->query(static::scopeQueryForCurrentUser(Child::query()))
            ->columns([
                TextColumn::make('name')
                    ->label('الطفل')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('level')
                    ->label('المستوى')
                    ->sortable(),
                TextColumn::make('completion_rate')
                    ->label('نسبة الإنجاز')
                    ->state(fn (Child $record): string => $record->completionRate().'%')
                    ->badge()
                    ->color(fn (Child $record): string => match (true) {
                        $record->completionRate() >= 70 => 'success',
                        $record->completionRate() >= 40 => 'warning',
                        default => 'danger',
                    }),
                TextColumn::make('trained_words')
                    ->label('كلمات مُدرَّب عليها')
                    ->state(fn (Child $record): int => $record->trainedWordsCount()),
                TextColumn::make('attempts_count')
                    ->label('عدد المحاولات')
                    ->state(fn (Child $record): int => $record->totalAttemptsCount()),
                TextColumn::make('overall_performance')
                    ->label('مستوى الأداء العام')
                    ->state(fn (Child $record): string => $record->overallPerformanceScore().'%')
                    ->description(fn (Child $record): string => 'متوسط النجوم: '.number_format($record->averageStars(), 1).' / '.Attempt::MAX_STARS),
                TextColumn::make('completed_attempts_count')
                    ->label('أنشطة مكتملة')
                    ->state(fn (Child $record): int => $record->completedAttempts()->count()),
            ])
            ->recordActions([
                ViewAction::make()
                    ->label('عرض التقرير')
                    ->url(fn (Child $record): string => ChildResource::getUrl('view', ['record' => $record])),
            ])
            ->defaultSort('name');
    }
}
