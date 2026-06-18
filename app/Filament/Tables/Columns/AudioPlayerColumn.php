<?php

namespace App\Filament\Tables\Columns;

use Filament\Tables\Columns\ViewColumn;

class AudioPlayerColumn extends ViewColumn
{
    protected string $view = 'filament.tables.columns.audio-player';

    public static function make(?string $name = null): static
    {
        return parent::make($name ?? 'audio_recording_path')
            ->label('التسجيل الصوتي');
    }
}
