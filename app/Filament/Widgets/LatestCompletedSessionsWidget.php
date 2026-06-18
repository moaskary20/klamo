<?php

namespace App\Filament\Widgets;

use App\Filament\Concerns\ScopesRecordsByUserRole;
use App\Models\Attempt;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class LatestCompletedSessionsWidget extends TableWidget
{
    use ScopesRecordsByUserRole;

    protected static ?int $sort = 2;

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->heading('آخر الجلسات المكتملة')
            ->query(
                static::scopeQueryByChildOwner(
                    Attempt::query()
                        ->with(['child', 'activity.item'])
                        ->where('is_completed', true)
                        ->latest('updated_at')
                )
            )
            ->columns([
                TextColumn::make('child.name')
                    ->label('الطفل')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('activity.item.word_name')
                    ->label('الكلمة')
                    ->placeholder('—'),
                TextColumn::make('activity.type')
                    ->label('نوع النشاط')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state?->label() ?? '—'),
                TextColumn::make('stars_earned')
                    ->label('النجوم')
                    ->formatStateUsing(fn (int $state): string => str_repeat('★', $state).str_repeat('☆', max(0, 3 - $state)))
                    ->alignCenter(),
                TextColumn::make('updated_at')
                    ->label('تاريخ الإكمال')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
            ])
            ->defaultSort('updated_at', 'desc')
            ->paginated([5, 10])
            ->defaultPaginationPageOption(5);
    }
}
