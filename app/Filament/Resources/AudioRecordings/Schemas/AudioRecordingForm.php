<?php

namespace App\Filament\Resources\AudioRecordings\Schemas;

use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class AudioRecordingForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Textarea::make('analysis_text')
                    ->label('نتيجة تحليل النطق')
                    ->helperText('يمكن للأخصائي مراجعة وتعديل نص التحليل المحفوظ مع التسجيل.')
                    ->rows(8)
                    ->columnSpanFull(),
                Toggle::make('is_completed')
                    ->label('مكتمل')
                    ->disabled(),
            ]);
    }
}
