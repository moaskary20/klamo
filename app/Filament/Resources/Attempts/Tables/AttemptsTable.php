<?php

namespace App\Filament\Resources\Attempts\Tables;

use App\Filament\Tables\Columns\AudioPlayerColumn;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class AttemptsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('child.name')
                    ->label('الطفل')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('activity.item.word_name')
                    ->label('الكلمة')
                    ->searchable(),
                TextColumn::make('activity.type')
                    ->label('نوع النشاط')
                    ->formatStateUsing(fn ($state) => $state?->label() ?? '—')
                    ->badge(),
                TextColumn::make('stars_earned')
                    ->label('النجوم')
                    ->formatStateUsing(fn (int $state): string => str_repeat('★', $state).str_repeat('☆', max(0, 3 - $state)))
                    ->alignCenter()
                    ->sortable(),
                IconColumn::make('is_completed')
                    ->label('مكتمل')
                    ->boolean(),
                TextColumn::make('created_at')
                    ->label('تاريخ المحاولة')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
                AudioPlayerColumn::make(),
                TextColumn::make('analysis_text')
                    ->label('تحليل الذكاء الاصطناعي')
                    ->state(fn ($record) => $record->getAnalysisText())
                    ->limit(60)
                    ->tooltip(fn ($record) => $record->getAnalysisText())
                    ->wrap(),
            ])
            ->filters([
                TernaryFilter::make('is_completed')
                    ->label('الحالة')
                    ->trueLabel('مكتمل')
                    ->falseLabel('غير مكتمل'),
                SelectFilter::make('child')
                    ->label('الطفل')
                    ->relationship(
                        name: 'child',
                        titleAttribute: 'name',
                        modifyQueryUsing: fn ($query) => auth()->user()?->isParent()
                            ? $query->where('user_id', auth()->id())
                            : $query,
                    ),
            ])
            ->recordActions([
                EditAction::make()
                    ->label('مراجعة')
                    ->modalHeading('مراجعة المحاولة وتحليل الذكاء الاصطناعي')
                    ->mutateRecordDataUsing(function (array $data, $record): array {
                        $data['analysis_text'] = $record->getAnalysisText();
                        $data['is_completed'] = $record->is_completed;

                        return $data;
                    })
                    ->using(function ($record, array $data) {
                        $record->setAnalysisText($data['analysis_text'] ?? null);
                        $record->save();

                        return $record;
                    }),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
