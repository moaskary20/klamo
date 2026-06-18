<?php

namespace App\Filament\Resources\AudioRecordings\Tables;

use App\Filament\Tables\Columns\AudioPlayerColumn;
use App\Models\Attempt;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class AudioRecordingsTable
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
                TextColumn::make('stars_earned')
                    ->label('التقييم')
                    ->formatStateUsing(fn ($state, $record) => $record->isAnalysisPending()
                        ? 'جاري التحليل...'
                        : ($state.' / '.Attempt::MAX_STARS))
                    ->badge()
                    ->color(fn ($record) => $record->isAnalysisPending() ? 'gray' : 'warning'),
                TextColumn::make('ai_analysis_status')
                    ->label('حالة التحليل')
                    ->formatStateUsing(fn ($state) => $state?->label() ?? '—')
                    ->badge()
                    ->color(fn ($state) => match ($state?->value) {
                        'completed' => 'success',
                        'processing' => 'info',
                        'pending' => 'warning',
                        'failed' => 'danger',
                        default => 'gray',
                    }),
                TextColumn::make('heard_transcription')
                    ->label('ما سُمع')
                    ->state(fn ($record) => data_get($record->ai_analysis_result, 'heard_transcription'))
                    ->placeholder('—')
                    ->limit(40)
                    ->toggleable(),
                TextColumn::make('match_percentage')
                    ->label('الدقة')
                    ->state(fn ($record) => $record->getMatchPercentage())
                    ->suffix('%')
                    ->placeholder('—')
                    ->badge()
                    ->color(fn ($state) => match (true) {
                        $state === null => 'gray',
                        $state >= 70 => 'success',
                        $state >= 50 => 'warning',
                        default => 'danger',
                    }),
                TextColumn::make('created_at')
                    ->label('تاريخ النشاط')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
                AudioPlayerColumn::make('audio_recording_path')
                    ->label('تسجيل الطفل'),
                TextColumn::make('analysis_text')
                    ->label('تحليل النطق')
                    ->state(fn ($record) => $record->getAnalysisText())
                    ->limit(80)
                    ->tooltip(fn ($record) => $record->getAnalysisText())
                    ->wrap(),
            ])
            ->filters([
                SelectFilter::make('ai_analysis_status')
                    ->label('حالة التحليل')
                    ->options([
                        'completed' => 'مكتمل',
                        'pending' => 'قيد الانتظار',
                        'processing' => 'جاري التحليل',
                        'failed' => 'فشل',
                    ]),
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
                    ->label('مراجعة التحليل')
                    ->modalHeading('مراجعة التسجيل الصوتي وتحليل النطق')
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
