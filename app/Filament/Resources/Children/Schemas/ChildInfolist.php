<?php

namespace App\Filament\Resources\Children\Schemas;

use App\Models\Attempt;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ChildInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('الملف الشخصي')
                    ->columns(3)
                    ->schema([
                        ImageEntry::make('avatar')
                            ->label('الصورة الشخصية')
                            ->disk('public')
                            ->columnSpanFull()
                            ->height(120),
                        TextEntry::make('name')
                            ->label('الاسم'),
                        TextEntry::make('age')
                            ->label('العمر'),
                        TextEntry::make('gender')
                            ->label('الجنس')
                            ->formatStateUsing(fn ($state) => $state?->label() ?? '—'),
                        TextEntry::make('level')
                            ->label('المستوى'),
                        TextEntry::make('user.name')
                            ->label('ولي الأمر')
                            ->visible(fn (): bool => auth()->user()?->isSpecialist() ?? false),
                        TextEntry::make('created_at')
                            ->label('تاريخ التسجيل')
                            ->dateTime('Y-m-d H:i'),
                    ]),
                Section::make('تقرير الأداء')
                    ->columns(3)
                    ->schema([
                        TextEntry::make('completion_rate')
                            ->label('نسبة الإنجاز')
                            ->state(fn ($record) => $record->completionRate().'%'),
                        TextEntry::make('trained_words')
                            ->label('الكلمات المُدرَّب عليها')
                            ->state(fn ($record) => $record->trainedWordsCount()),
                        TextEntry::make('attempts_total')
                            ->label('عدد المحاولات')
                            ->state(fn ($record) => $record->totalAttemptsCount()),
                        TextEntry::make('completed_attempts')
                            ->label('الأنشطة المكتملة')
                            ->state(fn ($record) => $record->completedAttempts()->count()),
                        TextEntry::make('overall_performance')
                            ->label('مستوى الأداء العام')
                            ->state(fn ($record) => $record->overallPerformanceScore().'%'),
                        TextEntry::make('average_stars')
                            ->label('متوسط النجوم')
                            ->state(fn ($record) => number_format($record->averageStars(), 1).' / '.Attempt::MAX_STARS),
                    ]),
            ]);
    }
}
