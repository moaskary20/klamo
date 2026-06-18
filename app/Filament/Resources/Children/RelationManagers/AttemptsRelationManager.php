<?php

namespace App\Filament\Resources\Children\RelationManagers;

use App\Filament\Tables\Columns\AudioPlayerColumn;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AttemptsRelationManager extends RelationManager
{
    protected static string $relationship = 'attempts';

    protected static ?string $title = 'سجل المحاولات والتقارير';

    public function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('activity.item.word_name')
                    ->label('الكلمة'),
                TextColumn::make('activity.type')
                    ->label('النشاط')
                    ->formatStateUsing(fn ($state) => $state?->label() ?? '—')
                    ->badge(),
                TextColumn::make('stars_earned')
                    ->label('النجوم')
                    ->formatStateUsing(fn (int $state): string => str_repeat('★', $state).str_repeat('☆', max(0, 3 - $state))),
                IconColumn::make('is_completed')
                    ->label('مكتمل')
                    ->boolean(),
                TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->dateTime('Y-m-d H:i'),
                AudioPlayerColumn::make(),
                TextColumn::make('analysis_text')
                    ->label('تحليل AI')
                    ->state(fn ($record) => $record->getAnalysisText())
                    ->limit(40),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
