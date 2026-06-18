<?php

namespace App\Filament\Resources\Items\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class ItemForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(2)
            ->components([
                Select::make('world_id')
                    ->label('العالم')
                    ->relationship('world', 'name')
                    ->searchable()
                    ->preload()
                    ->required(),
                TextInput::make('word_name')
                    ->label('اسم الكلمة')
                    ->required()
                    ->maxLength(255),
                TextInput::make('min_level')
                    ->label('المستوى المطلوب')
                    ->required()
                    ->numeric()
                    ->minValue(1)
                    ->default(1),
                FileUpload::make('image_path')
                    ->label('صورة الكلمة')
                    ->helperText('ارفع صورة واضحة للعنصر (مثل: تفاحة، كلب...)')
                    ->image()
                    ->directory('items/images')
                    ->disk('public')
                    ->imageEditor()
                    ->columnSpanFull(),
                FileUpload::make('audio_path')
                    ->label('الملف الصوتي المرجعي')
                    ->helperText('ارفع ملف MP3/WAV لنطق الكلمة الصحيح')
                    ->acceptedFileTypes(['audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/mp4', 'audio/x-m4a'])
                    ->directory('items/audio')
                    ->disk('public')
                    ->downloadable()
                    ->openable()
                    ->columnSpanFull(),
            ]);
    }
}
