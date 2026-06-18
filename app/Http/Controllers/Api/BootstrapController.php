<?php

namespace App\Http\Controllers\Api;

use App\Http\Resources\ChildResource;
use App\Http\Resources\UserResource;
use App\Http\Resources\WorldResource;
use App\Models\Child;
use App\Models\World;
use App\Support\ScopesApiByUserRole;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BootstrapController extends ApiController
{
    public function __invoke(Request $request): JsonResponse
    {
        $user = $request->user('sanctum');

        $worlds = World::query()
            ->orderBy('sort_order')
            ->get(['id', 'name', 'icon', 'sort_order']);

        $payload = [
            'app' => [
                'name' => config('app.name', 'كلامو'),
                'version' => '1.0.0',
                'locale' => config('app.locale', 'ar'),
                'direction' => 'rtl',
            ],
            'worlds' => WorldResource::collection($worlds),
            'authenticated' => (bool) $user,
        ];

        if ($user) {
            $user->loadCount('children');
            $payload['user'] = new UserResource($user);
            $childrenQuery = ScopesApiByUserRole::scopeChildrenForUser(Child::query(), $user)
                ->withCount('completedAttempts')
                ->latest();

            if ($user->isSpecialist()) {
                $childrenQuery->with('user');
            }

            $payload['children'] = ChildResource::collection($childrenQuery->get());
        }

        return $this->success($payload, 'تم جلب البيانات الأساسية بنجاح');
    }
}
