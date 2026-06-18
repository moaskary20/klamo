<?php

namespace App\Filament\Resources\Activities;

use App\Enums\ActivityType;
use App\Filament\Resources\Activities\Pages\ManageActivities;
use App\Models\Activity;
use BackedEnum;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use UnitEnum;

class ActivityResource extends Resource
{
    protected static ?string $model = Activity::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedPuzzlePiece;

    protected static string | UnitEnum | null $navigationGroup = 'إدارة المحتوى';

    protected static ?string $modelLabel = 'نشاط';

    protected static ?string $pluralModelLabel = 'الأنشطة التعليمية';

    protected static ?string $navigationLabel = 'الأنشطة التعليمية';

    protected static ?int $navigationSort = 3;

    public static function shouldRegisterNavigation(): bool
    {
        return auth()->user()?->isSpecialist() ?? false;
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->columns(2)
            ->components([
                Select::make('item_id')
                    ->label('الكلمة')
                    ->relationship('item', 'word_name')
                    ->searchable()
                    ->preload()
                    ->required(),
                Select::make('type')
                    ->label('نوع النشاط')
                    ->options(ActivityType::class)
                    ->required()
                    ->native(false),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('item.word_name')
                    ->label('الكلمة')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('item.world.name')
                    ->label('العالم')
                    ->sortable(),
                TextColumn::make('type')
                    ->label('نوع النشاط')
                    ->formatStateUsing(fn ($state) => $state?->label() ?? '—')
                    ->badge()
                    ->sortable(),
                TextColumn::make('attempts_count')
                    ->label('المحاولات')
                    ->counts('attempts')
                    ->sortable(),
            ])
            ->defaultSort('item.word_name')
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

    public static function getPages(): array
    {
        return [
            'index' => ManageActivities::route('/'),
        ];
    }
}
