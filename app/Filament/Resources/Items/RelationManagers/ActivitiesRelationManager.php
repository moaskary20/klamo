<?php

namespace App\Filament\Resources\Items\RelationManagers;

use App\Enums\ActivityType;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ActivitiesRelationManager extends RelationManager
{
    protected static string $relationship = 'activities';

    protected static ?string $title = 'أنشطة الكلمة';

    public function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('type')
                ->label('نوع النشاط')
                ->options(ActivityType::class)
                ->required()
                ->native(false),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('type')
                    ->label('نوع النشاط')
                    ->formatStateUsing(fn ($state) => $state?->label() ?? '—')
                    ->badge(),
                TextColumn::make('attempts_count')
                    ->label('المحاولات')
                    ->counts('attempts'),
            ])
            ->headerActions([
                CreateAction::make()
                    ->label('إنشاء نشاط جديد'),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ]);
    }
}
