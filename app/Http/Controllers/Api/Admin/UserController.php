<?php

namespace App\Http\Controllers\Api\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\Admin\StoreUserRequest;
use App\Http\Requests\Api\Admin\UpdateUserRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $users = User::query()
            ->withCount('children')
            ->when($request->filled('role'), fn ($query) => $query->where('role', $request->string('role')))
            ->latest()
            ->get();

        return $this->success([
            'users' => $users->map(fn (User $user) => [
                ...(new UserResource($user))->resolve(),
                'children_count' => $user->children_count,
            ]),
        ]);
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $data = $request->validated();

        $user = User::query()->create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
            'role' => $data['role'],
        ]);

        return $this->success([
            'user' => new UserResource($user),
        ], 'تم إنشاء المستخدم بنجاح', 201);
    }

    public function update(UpdateUserRequest $request, User $user): JsonResponse
    {
        $data = $request->validated();

        $user->fill([
            'name' => $data['name'] ?? $user->name,
            'email' => $data['email'] ?? $user->email,
            'role' => $data['role'] ?? $user->role,
        ]);

        if (! empty($data['password'])) {
            $user->password = $data['password'];
        }

        $user->save();

        return $this->success([
            'user' => new UserResource($user->fresh()),
        ], 'تم تحديث المستخدم بنجاح');
    }

    public function destroy(User $user): JsonResponse
    {
        abort_if($user->id === auth()->id(), 403, 'لا يمكنك حذف حسابك.');

        $user->delete();

        return $this->success(message: 'تم حذف المستخدم بنجاح');
    }

    public function parents(): JsonResponse
    {
        $parents = User::query()
            ->where('role', UserRole::Parent)
            ->orderBy('name')
            ->get(['id', 'name', 'email']);

        return $this->success([
            'parents' => $parents,
        ]);
    }
}
