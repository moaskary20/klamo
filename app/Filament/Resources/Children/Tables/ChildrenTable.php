<?php

namespace App\Filament\Resources\Children\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ChildrenTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('avatar')
                    ->label('الصورة')
                    ->disk('public')
                    ->circular(),
                TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('age')
                    ->label('العمر')
                    ->sortable(),
                TextColumn::make('gender')
                    ->label('الجنس')
                    ->formatStateUsing(fn ($state) => $state?->label() ?? '—')
                    ->badge(),
                TextColumn::make('level')
                    ->label('المستوى')
                    ->sortable(),
                TextColumn::make('user.name')
                    ->label('ولي الأمر')
                    ->visible(fn (): bool => auth()->user()?->isSpecialist() ?? false)
                    ->toggleable(),
                TextColumn::make('completion_rate')
                    ->label('نسبة الإنجاز')
                    ->state(fn ($record) => $record->completionRate().'%')
                    ->badge(),
                TextColumn::make('completed_attempts_count')
                    ->label('أنشطة مكتملة')
                    ->counts('completedAttempts')
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label('تاريخ الإضافة')
                    ->dateTime('Y-m-d')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
