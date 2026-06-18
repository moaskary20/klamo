<?php

namespace App\Filament\Resources\Children\Schemas;

use App\Enums\Gender;
use App\Enums\UserRole;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class ChildForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(2)
            ->components([
                Select::make('user_id')
                    ->label('ولي الأمر / الأخصائي')
                    ->relationship(
                        name: 'user',
                        titleAttribute: 'name',
                        modifyQueryUsing: fn ($query) => $query->where('role', UserRole::Parent),
                    )
                    ->searchable()
                    ->preload()
                    ->required()
                    ->visible(fn (): bool => auth()->user()?->isSpecialist() ?? false)
                    ->columnSpanFull(),
                Hidden::make('user_id')
                    ->default(fn (): int => auth()->id())
                    ->visible(fn (): bool => auth()->user()?->isParent() ?? false),
                TextInput::make('name')
                    ->label('اسم الطفل')
                    ->required()
                    ->maxLength(255),
                TextInput::make('age')
                    ->label('العمر')
                    ->required()
                    ->numeric()
                    ->minValue(1)
                    ->maxValue(18),
                Select::make('gender')
                    ->label('الجنس')
                    ->options(Gender::class)
                    ->required()
                    ->native(false),
                TextInput::make('level')
                    ->label('المستوى')
                    ->required()
                    ->numeric()
                    ->minValue(1)
                    ->default(1),
                FileUpload::make('avatar')
                    ->label('الصورة الشخصية')
                    ->image()
                    ->directory('children/avatars')
                    ->disk('public')
                    ->imageEditor()
                    ->columnSpanFull(),
            ]);
    }
}
