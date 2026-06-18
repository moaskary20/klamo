<?php

namespace App\Filament\Resources\Worlds\Pages;

use App\Filament\Resources\Worlds\WorldResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ManageRecords;

class ManageWorlds extends ManageRecords
{
    protected static string $resource = WorldResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
