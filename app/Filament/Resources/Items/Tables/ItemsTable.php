<?php

namespace App\Filament\Resources\Items\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ItemsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image_path')
                    ->label('الصورة')
                    ->disk('public'),
                TextColumn::make('word_name')
                    ->label('الكلمة')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('min_level')
                    ->label('المستوى')
                    ->sortable(),
                TextColumn::make('world.name')
                    ->label('العالم')
                    ->sortable()
                    ->searchable(),
                TextColumn::make('activities_count')
                    ->label('الأنشطة')
                    ->counts('activities')
                    ->sortable(),
                TextColumn::make('audio_path')
                    ->label('ملف صوتي')
                    ->formatStateUsing(fn (?string $state): string => $state ? 'متوفر' : '—')
                    ->badge()
                    ->color(fn (?string $state): string => $state ? 'success' : 'gray'),
            ])
            ->defaultSort('word_name')
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
