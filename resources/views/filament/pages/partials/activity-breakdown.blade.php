@php
    $total = collect($breakdown)->sum('count');
@endphp

<div class="klamo-breakdown">
    @foreach ($breakdown as $item)
        @php
            $percent = $total > 0 ? (int) round(($item['count'] / $total) * 100) : 0;
            $width = max($percent, $item['count'] > 0 ? 8 : 0);
        @endphp
        <div class="klamo-breakdown__row">
            <div class="klamo-breakdown__meta">
                <span>{{ $item['label'] }}</span>
                <strong>{{ $item['count'] }}</strong>
            </div>
            <div class="klamo-breakdown__track">
                <div class="klamo-breakdown__bar" style="width: {{ $width }}%"></div>
            </div>
        </div>
    @endforeach
</div>

<style>
    .klamo-breakdown {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .klamo-breakdown__meta {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 0.75rem;
        margin-bottom: 0.35rem;
        font-size: 0.875rem;
    }

    .klamo-breakdown__meta strong {
        font-weight: 800;
    }

    .klamo-breakdown__track {
        height: 0.5rem;
        overflow: hidden;
        border-radius: 999px;
        background: color-mix(in srgb, var(--gray-200) 80%, transparent);
    }

    .dark .klamo-breakdown__track {
        background: color-mix(in srgb, var(--gray-700) 70%, transparent);
    }

    .klamo-breakdown__bar {
        height: 100%;
        border-radius: 999px;
        background: linear-gradient(to left, #06b6d4, #7c3aed);
    }
</style>
