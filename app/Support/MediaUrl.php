<?php

namespace App\Support;

use Illuminate\Http\Request;

class MediaUrl
{
    public static function fromRequest(Request $request, ?string $path): ?string
    {
        if (! $path) {
            return null;
        }

        $origin = rtrim(self::requestOrigin($request), '/');

        return $origin.'/storage/'.ltrim($path, '/');
    }

    private static function requestOrigin(Request $request): string
    {
        $host = $request->getHost();

        if (in_array($host, ['localhost', '127.0.0.1', '10.0.2.2'], true)) {
            return rtrim((string) config('app.url'), '/');
        }

        return $request->getSchemeAndHttpHost();
    }
}
