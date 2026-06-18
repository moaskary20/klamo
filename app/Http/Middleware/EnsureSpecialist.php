<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureSpecialist
{
    public function handle(Request $request, Closure $next): Response
    {
        abort_unless($request->user()?->isSpecialist(), 403, 'هذه العملية متاحة للأخصائيين فقط.');

        return $next($request);
    }
}
