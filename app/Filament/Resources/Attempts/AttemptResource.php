<?php

namespace App\Filament\Resources\Attempts;

use App\Filament\Concerns\ScopesRecordsByUserRole;
use App\Filament\Resources\Attempts\Pages\ManageAttempts;
use App\Filament\Resources\Attempts\Schemas\AttemptForm;
use App\Filament\Resources\Attempts\Tables\AttemptsTable;
use App\Models\Attempt;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use UnitEnum;

class AttemptResource extends Resource
{
    use ScopesRecordsByUserRole;

    protected static ?string $model = Attempt::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedClipboardDocumentCheck;

    protected static string | UnitEnum | null $navigationGroup = 'متابعة الأداء';

    protected static ?string $modelLabel = 'محاولة';

    protected static ?string $pluralModelLabel = 'متابعة الأداء';

    protected static ?string $navigationLabel = 'متابعة الأداء والتسجيلات';

    protected static ?int $navigationSort = 9;

    public static function shouldRegisterNavigation(): bool
    {
        return false;
    }

    public static function form(Schema $schema): Schema
    {
        return AttemptForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return AttemptsTable::configure($table);
    }

    public static function getEloquentQuery(): Builder
    {
        return static::scopeQueryByChildOwner(
            parent::getEloquentQuery()->with(['child', 'activity.item'])
        );
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageAttempts::route('/'),
        ];
    }
}
