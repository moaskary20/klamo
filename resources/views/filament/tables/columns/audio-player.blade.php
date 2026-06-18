@php
    $path = $getState();
    $url = $path ? url('/storage/' . ltrim($path, '/')) : null;
    $mime = match (strtolower(pathinfo((string) $path, PATHINFO_EXTENSION))) {
        'wav' => 'audio/wav',
        'mp3' => 'audio/mpeg',
        'ogg' => 'audio/ogg',
        'm4a', 'mp4', 'aac' => 'audio/mp4',
        default => null,
    };
@endphp

<div class="min-w-[12rem]">
    @if ($url)
        <audio controls preload="none" class="w-full max-w-xs h-9">
            <source src="{{ $url }}" @if ($mime) type="{{ $mime }}" @endif>
            متصفحك لا يدعم تشغيل الصوت.
        </audio>
    @else
        <span class="text-sm text-gray-400">لا يوجد تسجيل</span>
    @endif
</div>
