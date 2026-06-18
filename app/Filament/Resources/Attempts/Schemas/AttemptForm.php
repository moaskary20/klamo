<?php

namespace App\Filament\Resources\Attempts\Schemas;

use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class AttemptForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Textarea::make('analysis_text')
                    ->label('نتيجة تحليل الذكاء الاصطناعي (Gemini)')
                    ->helperText('يمكن للأخصائي مراجعة وتعديل النص الناتج عن التحليل الآلي.')
                    ->rows(6)
                    ->columnSpanFull(),
                Toggle::make('is_completed')
                    ->label('مكتمل')
                    ->disabled(),
            ]);
    }
}
