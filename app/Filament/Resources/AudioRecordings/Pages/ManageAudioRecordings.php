<?php

namespace App\Filament\Resources\AudioRecordings\Pages;

use App\Filament\Resources\AudioRecordings\AudioRecordingResource;
use Filament\Resources\Pages\ManageRecords;

class ManageAudioRecordings extends ManageRecords
{
    protected static string $resource = AudioRecordingResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
