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

        return rtrim($request->getSchemeAndHttpHost(), '/').'/storage/'.ltrim($path, '/');
    }
}
