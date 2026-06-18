<?php

namespace App\Filament\Resources\AudioRecordings;

use App\Filament\Concerns\ScopesRecordsByUserRole;
use App\Filament\Resources\AudioRecordings\Pages\ManageAudioRecordings;
use App\Filament\Resources\AudioRecordings\Schemas\AudioRecordingForm;
use App\Filament\Resources\AudioRecordings\Tables\AudioRecordingsTable;
use App\Models\Attempt;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use UnitEnum;

class AudioRecordingResource extends Resource
{
    use ScopesRecordsByUserRole;

    protected static ?string $model = Attempt::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedMicrophone;

    protected static string | UnitEnum | null $navigationGroup = 'متابعة الأداء';

    protected static ?string $modelLabel = 'تسجيل صوتي';

    protected static ?string $pluralModelLabel = 'التسجيلات الصوتية';

    protected static ?string $navigationLabel = 'التسجيلات الصوتية ومراجعتها';

    protected static ?string $slug = 'audio-recordings';

    protected static ?int $navigationSort = 2;

    public static function form(Schema $schema): Schema
    {
        return AudioRecordingForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return AudioRecordingsTable::configure($table);
    }

    public static function getEloquentQuery(): Builder
    {
        return static::scopeQueryByChildOwner(
            parent::getEloquentQuery()
                ->whereNotNull('audio_recording_path')
                ->with(['child', 'activity.item'])
        );
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageAudioRecordings::route('/'),
        ];
    }
}
