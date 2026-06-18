<?php

namespace App\Filament\Pages;

use App\Enums\ActivityType;
use App\Filament\Resources\Activities\ActivityResource;
use App\Filament\Resources\Items\ItemResource;
use App\Filament\Resources\Worlds\WorldResource;
use App\Models\Activity;
use App\Models\Item;
use App\Models\World;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Pages\Page;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Text;
use Filament\Schemas\Components\View as ViewComponent;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Widgets\StatsOverviewWidget\Stat;
use UnitEnum;

class ContentManagement extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedSquaresPlus;

    protected static string | UnitEnum | null $navigationGroup = 'إدارة المحتوى';

    protected static ?string $navigationLabel = 'إدارة المحتوى';

    protected static ?string $title = 'إدارة المحتوى التعليمي';

    protected static ?int $navigationSort = 0;

    public static function shouldRegisterNavigation(): bool
    {
        return auth()->user()?->isSpecialist() ?? false;
    }

    public function getSubheading(): ?string
    {
        return 'ابدأ بالعوالم، ثم الكلمات، ثم أنشئ الأنشطة الثلاثة لكل كلمة.';
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('addWorld')
                ->label('إضافة عالم')
                ->icon(Heroicon::OutlinedGlobeAlt)
                ->color('info')
                ->url(WorldResource::getUrl()),
            Action::make('addWord')
                ->label('إضافة كلمة')
                ->icon(Heroicon::OutlinedBookOpen)
                ->color('success')
                ->url(ItemResource::getUrl('create')),
            Action::make('addActivity')
                ->label('إنشاء نشاط')
                ->icon(Heroicon::OutlinedPuzzlePiece)
                ->color('warning')
                ->url(ActivityResource::getUrl()),
        ];
    }

    public function content(Schema $schema): Schema
    {
        $itemsCount = Item::count();
        $activitiesCount = Activity::count();
        $expectedActivities = $itemsCount * count(ActivityType::cases());
        $completion = $expectedActivities > 0
            ? (int) round(($activitiesCount / $expectedActivities) * 100)
            : 0;

        return $schema->components([
            Section::make('نظرة سريعة')
                ->description('إحصائيات المحتوى الحالي في التطبيق')
                ->icon(Heroicon::OutlinedChartBarSquare)
                ->schema([
                    Stat::make('العوالم', World::count())
                        ->description('عوالم تعليمية')
                        ->descriptionIcon(Heroicon::OutlinedGlobeAlt)
                        ->icon(Heroicon::OutlinedGlobeAlt)
                        ->color('info')
                        ->url(WorldResource::getUrl()),
                    Stat::make('الكلمات', $itemsCount)
                        ->description('كلمات مع وسائط')
                        ->descriptionIcon(Heroicon::OutlinedBookOpen)
                        ->icon(Heroicon::OutlinedBookOpen)
                        ->color('primary')
                        ->url(ItemResource::getUrl()),
                    Stat::make('الأنشطة', $activitiesCount)
                        ->description("تغطية {$completion}%")
                        ->descriptionIcon(Heroicon::OutlinedPuzzlePiece)
                        ->icon(Heroicon::OutlinedPuzzlePiece)
                        ->color('warning')
                        ->url(ActivityResource::getUrl()),
                ])
                ->columns(3)
                ->contained(false)
                ->gridContainer(),

            Grid::make(['default' => 1, 'xl' => 3])
                ->schema([
                    Section::make('مسار إعداد المحتوى')
                        ->description('اتبع هذا الترتيب لضمان تجربة متكاملة للطفل')
                        ->icon(Heroicon::OutlinedMap)
                        ->schema($this->getWorkflowSchema())
                        ->columnSpan(['default' => 1, 'xl' => 2]),

                    Section::make('توزيع الأنشطة')
                        ->icon(Heroicon::OutlinedChartPie)
                        ->schema([
                            ViewComponent::make('filament.pages.partials.activity-breakdown')
                                ->viewData([
                                    'breakdown' => $this->getActivityTypeBreakdown(),
                                ]),
                        ]),
                ]),

            ViewComponent::make('filament.pages.partials.content-management-details')
                ->viewData([
                    'worlds' => $this->getWorldsOverview(),
                    'alerts' => $this->getContentAlerts(),
                    'quickActions' => $this->getQuickActions(),
                ]),
        ]);
    }

    /**
     * @return list<\Filament\Schemas\Components\Component>
     */
    protected function getWorkflowSchema(): array
    {
        return [
            Text::make('1. العوالم — أنشئ أو عدّل العوالم التعليمية وحدد ترتيب ظهورها.')
                ->icon(Heroicon::OutlinedGlobeAlt)
                ->color('info')
                ->size('sm'),
            Text::make('2. الكلمات — أضف كلمة لكل عالم مع صورة واضحة وملف صوتي للنطق الصحيح.')
                ->icon(Heroicon::OutlinedBookOpen)
                ->color('primary')
                ->size('sm'),
            Text::make('3. الأنشطة — أنشئ 3 أنشطة لكل كلمة: تعرف، تمييز سمعي، وتسجيل نطق.')
                ->icon(Heroicon::OutlinedPuzzlePiece)
                ->color('warning')
                ->size('sm'),
        ];
    }

    /**
     * @return list<array{title: string, description: string, icon: Heroicon, url: string}>
     */
    public function getQuickActions(): array
    {
        return [
            [
                'title' => 'عالم جديد',
                'description' => 'أضف عالماً تعليمياً ورتّبه ضمن المستويات',
                'icon' => Heroicon::OutlinedGlobeAlt,
                'url' => WorldResource::getUrl(),
            ],
            [
                'title' => 'كلمة جديدة',
                'description' => 'ارفع صورة وصوتاً مرجعياً لكلمة عربية',
                'icon' => Heroicon::OutlinedBookOpen,
                'url' => ItemResource::getUrl('create'),
            ],
            [
                'title' => 'نشاط تعليمي',
                'description' => 'اربط نشاطاً بكلمة: تعرف، تمييز، أو نطق',
                'icon' => Heroicon::OutlinedPuzzlePiece,
                'url' => ActivityResource::getUrl(),
            ],
        ];
    }

    /**
     * @return \Illuminate\Support\Collection<int, World>
     */
    public function getWorldsOverview(): \Illuminate\Support\Collection
    {
        return World::query()
            ->withCount('items')
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();
    }

    /**
     * @return list<array{label: string, count: int, severity: string, url: string}>
     */
    public function getContentAlerts(): array
    {
        $missingAudio = Item::query()
            ->where(function ($query): void {
                $query->whereNull('audio_path')->orWhere('audio_path', '');
            })
            ->count();

        $missingImage = Item::query()
            ->where(function ($query): void {
                $query->whereNull('image_path')->orWhere('image_path', '');
            })
            ->count();

        $requiredActivities = count(ActivityType::cases());

        $incompleteActivities = Item::query()
            ->whereRaw(
                '(select count(*) from activities where activities.item_id = items.id) < ?',
                [$requiredActivities],
            )
            ->count();

        return collect([
            [
                'label' => 'كلمات بدون صوت مرجعي',
                'count' => $missingAudio,
                'severity' => 'warning',
                'url' => ItemResource::getUrl(),
            ],
            [
                'label' => 'كلمات بدون صورة',
                'count' => $missingImage,
                'severity' => 'warning',
                'url' => ItemResource::getUrl(),
            ],
            [
                'label' => 'كلمات بأنشطة ناقصة',
                'count' => $incompleteActivities,
                'severity' => 'danger',
                'url' => ActivityResource::getUrl(),
            ],
        ])
            ->filter(fn (array $alert): bool => $alert['count'] > 0)
            ->values()
            ->all();
    }

    public function getActivityTypeBreakdown(): array
    {
        return collect(ActivityType::cases())
            ->map(fn (ActivityType $type): array => [
                'label' => $type->label(),
                'count' => Activity::query()->where('type', $type)->count(),
            ])
            ->all();
    }
}
