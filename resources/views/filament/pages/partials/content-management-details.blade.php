<div class="klamo-cm">
    <div class="klamo-cm__layout">
        <section class="klamo-cm__panel klamo-cm__panel--wide">
            <div class="klamo-cm__panel-head">
                <div>
                    <h3>نظرة على العوالم</h3>
                    <p>عدد الكلمات في كل عالم تعليمي</p>
                </div>
                <a href="{{ \App\Filament\Resources\Worlds\WorldResource::getUrl() }}">إدارة العوالم</a>
            </div>

            @if ($worlds->isEmpty())
                <div class="klamo-cm__empty">لا توجد عوالم بعد. ابدأ بإضافة أول عالم تعليمي.</div>
            @else
                <div class="klamo-cm__world-grid">
                    @foreach ($worlds as $world)
                        <div class="klamo-cm__world-card">
                            <div class="klamo-cm__world-info">
                                <strong>{{ $world->name }}</strong>
                                <span>ترتيب {{ $world->sort_order }}</span>
                            </div>
                            <span class="klamo-cm__badge">{{ $world->items_count }} كلمة</span>
                        </div>
                    @endforeach
                </div>
            @endif
        </section>

        <div class="klamo-cm__side">
            <section class="klamo-cm__panel">
                <div class="klamo-cm__panel-head">
                    <div>
                        <h3>تنبيهات الجودة</h3>
                        <p>فجوات تحتاج مراجعة</p>
                    </div>
                </div>

                @if (count($alerts) === 0)
                    <div class="klamo-cm__success">
                        <strong>المحتوى يبدو مكتملاً</strong>
                        <span>لا توجد فجوات واضحة في الصور أو الأصوات أو الأنشطة.</span>
                    </div>
                @else
                    <div class="klamo-cm__alerts">
                        @foreach ($alerts as $alert)
                            <a
                                href="{{ $alert['url'] }}"
                                class="klamo-cm__alert klamo-cm__alert--{{ $alert['severity'] }}"
                            >
                                <span>{{ $alert['label'] }}</span>
                                <strong>{{ $alert['count'] }}</strong>
                            </a>
                        @endforeach
                    </div>
                @endif
            </section>

            <section class="klamo-cm__panel">
                <div class="klamo-cm__panel-head">
                    <div>
                        <h3>إجراءات سريعة</h3>
                        <p>اختصارات للإضافة المباشرة</p>
                    </div>
                </div>

                <div class="klamo-cm__actions">
                    @foreach ($quickActions as $action)
                        <a href="{{ $action['url'] }}" class="klamo-cm__action">
                            <x-filament::icon :icon="$action['icon']" class="klamo-cm__action-icon" />
                            <div>
                                <strong>{{ $action['title'] }}</strong>
                                <span>{{ $action['description'] }}</span>
                            </div>
                        </a>
                    @endforeach
                </div>
            </section>
        </div>
    </div>
</div>

<style>
    .klamo-cm {
        margin-top: 0.25rem;
    }

    .klamo-cm__layout {
        display: grid;
        gap: 1rem;
        grid-template-columns: 1fr;
    }

    @media (min-width: 1280px) {
        .klamo-cm__layout {
            grid-template-columns: 2fr 1fr;
        }
    }

    .klamo-cm__panel {
        padding: 1.25rem;
        border: 1px solid color-mix(in srgb, var(--gray-200) 85%, transparent);
        border-radius: 0.9rem;
        background: var(--fi-section-bg, #fff);
        box-shadow: 0 1px 2px color-mix(in srgb, #000 6%, transparent);
    }

    .dark .klamo-cm__panel {
        border-color: color-mix(in srgb, var(--gray-700) 80%, transparent);
        background: color-mix(in srgb, var(--gray-900) 92%, transparent);
    }

    .klamo-cm__panel-head {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 1rem;
        margin-bottom: 1rem;
    }

    .klamo-cm__panel-head h3 {
        margin: 0;
        font-size: 1.05rem;
        font-weight: 800;
        color: var(--gray-950);
    }

    .dark .klamo-cm__panel-head h3 {
        color: var(--gray-50);
    }

    .klamo-cm__panel-head p {
        margin: 0.25rem 0 0;
        font-size: 0.85rem;
        color: var(--gray-500);
    }

    .klamo-cm__panel-head a {
        font-size: 0.85rem;
        font-weight: 700;
        color: rgb(var(--primary-600));
        text-decoration: none;
        white-space: nowrap;
    }

    .klamo-cm__panel-head a:hover {
        text-decoration: underline;
    }

    .klamo-cm__empty {
        padding: 2rem 1rem;
        border: 1px dashed color-mix(in srgb, var(--gray-300) 80%, transparent);
        border-radius: 0.75rem;
        text-align: center;
        color: var(--gray-500);
        font-size: 0.9rem;
    }

    .klamo-cm__world-grid {
        display: grid;
        gap: 0.75rem;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    }

    .klamo-cm__world-card {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 0.75rem;
        padding: 0.9rem 1rem;
        border: 1px solid color-mix(in srgb, var(--gray-200) 85%, transparent);
        border-radius: 0.75rem;
        background: color-mix(in srgb, var(--gray-50) 80%, transparent);
    }

    .dark .klamo-cm__world-card {
        border-color: color-mix(in srgb, var(--gray-700) 80%, transparent);
        background: color-mix(in srgb, var(--gray-800) 55%, transparent);
    }

    .klamo-cm__world-info {
        min-width: 0;
    }

    .klamo-cm__world-info strong {
        display: block;
        font-size: 0.95rem;
        font-weight: 800;
        color: var(--gray-950);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .dark .klamo-cm__world-info strong {
        color: var(--gray-50);
    }

    .klamo-cm__world-info span {
        font-size: 0.75rem;
        color: var(--gray-500);
    }

    .klamo-cm__badge {
        flex-shrink: 0;
        padding: 0.35rem 0.7rem;
        border-radius: 999px;
        background: color-mix(in srgb, #7c3aed 12%, transparent);
        color: #6d28d9;
        font-size: 0.8rem;
        font-weight: 800;
    }

    .dark .klamo-cm__badge {
        background: color-mix(in srgb, #a78bfa 18%, transparent);
        color: #ddd6fe;
    }

    .klamo-cm__side {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .klamo-cm__success {
        padding: 1rem;
        border-radius: 0.75rem;
        background: color-mix(in srgb, #22c55e 12%, transparent);
        color: #166534;
    }

    .dark .klamo-cm__success {
        background: color-mix(in srgb, #22c55e 16%, transparent);
        color: #bbf7d0;
    }

    .klamo-cm__success strong {
        display: block;
        margin-bottom: 0.25rem;
        font-weight: 800;
    }

    .klamo-cm__success span {
        font-size: 0.85rem;
    }

    .klamo-cm__alerts,
    .klamo-cm__actions {
        display: flex;
        flex-direction: column;
        gap: 0.65rem;
    }

    .klamo-cm__alert,
    .klamo-cm__action {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 0.75rem;
        padding: 0.85rem 1rem;
        border-radius: 0.75rem;
        text-decoration: none;
        transition: opacity 0.15s ease;
    }

    .klamo-cm__alert:hover,
    .klamo-cm__action:hover {
        opacity: 0.92;
    }

    .klamo-cm__alert--warning {
        background: color-mix(in srgb, #f59e0b 14%, transparent);
        color: #92400e;
    }

    .dark .klamo-cm__alert--warning {
        color: #fde68a;
    }

    .klamo-cm__alert--danger {
        background: color-mix(in srgb, #ef4444 14%, transparent);
        color: #991b1b;
    }

    .dark .klamo-cm__alert--danger {
        color: #fecaca;
    }

    .klamo-cm__alert span {
        font-size: 0.875rem;
        font-weight: 600;
    }

    .klamo-cm__alert strong {
        min-width: 1.75rem;
        text-align: center;
        padding: 0.15rem 0.45rem;
        border-radius: 999px;
        background: color-mix(in srgb, #fff 70%, transparent);
        font-size: 0.75rem;
    }

    .klamo-cm__action {
        background: color-mix(in srgb, var(--gray-100) 85%, transparent);
        color: inherit;
    }

    .dark .klamo-cm__action {
        background: color-mix(in srgb, var(--gray-800) 70%, transparent);
    }

    .klamo-cm__action-icon {
        width: 1.25rem;
        height: 1.25rem;
        flex-shrink: 0;
        color: rgb(var(--primary-600));
    }

    .klamo-cm__action strong {
        display: block;
        font-size: 0.9rem;
        font-weight: 800;
        color: var(--gray-950);
    }

    .dark .klamo-cm__action strong {
        color: var(--gray-50);
    }

    .klamo-cm__action span {
        display: block;
        margin-top: 0.15rem;
        font-size: 0.75rem;
        color: var(--gray-500);
        line-height: 1.4;
    }
</style>
