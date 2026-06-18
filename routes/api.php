<?php

use App\Http\Controllers\Api\ActivityController;
use App\Http\Controllers\Api\Admin\ActivityController as AdminActivityController;
use App\Http\Controllers\Api\Admin\ContentController;
use App\Http\Controllers\Api\Admin\ItemController as AdminItemController;
use App\Http\Controllers\Api\Admin\UserController as AdminUserController;
use App\Http\Controllers\Api\Admin\WorldController as AdminWorldController;
use App\Http\Controllers\Api\AttemptController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BootstrapController;
use App\Http\Controllers\Api\ChildController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\WorldController;
use Illuminate\Support\Facades\Route;

Route::get('bootstrap', BootstrapController::class);

Route::prefix('auth')->group(function (): void {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
    });
});

Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('dashboard/stats', [DashboardController::class, 'stats']);
    Route::get('dashboard/recent-sessions', [DashboardController::class, 'recentSessions']);

    Route::get('children/reports', [ChildController::class, 'reports']);
    Route::get('children', [ChildController::class, 'index']);
    Route::post('children', [ChildController::class, 'store']);
    Route::get('children/{child}', [ChildController::class, 'show']);
    Route::match(['put', 'patch'], 'children/{child}', [ChildController::class, 'update']);
    Route::delete('children/{child}', [ChildController::class, 'destroy']);
    Route::get('children/{child}/progress', [ChildController::class, 'progress']);
    Route::get('children/{child}/attempts', [ChildController::class, 'attempts']);

    Route::get('worlds', [WorldController::class, 'index']);
    Route::get('worlds/{world}', [WorldController::class, 'show']);

    Route::get('activities/{activity}', [ActivityController::class, 'show']);

    Route::get('attempts', [AttemptController::class, 'index']);
    Route::get('attempts/{attempt}', [AttemptController::class, 'show']);
    Route::patch('attempts/{attempt}/analysis', [AttemptController::class, 'updateAnalysis']);
    Route::post('attempts', [AttemptController::class, 'store']);

    Route::middleware('specialist')->prefix('admin')->group(function (): void {
        Route::get('content/stats', [ContentController::class, 'stats']);
        Route::get('content/worlds', [ContentController::class, 'worlds']);

        Route::get('users/parents', [AdminUserController::class, 'parents']);
        Route::get('users', [AdminUserController::class, 'index']);
        Route::post('users', [AdminUserController::class, 'store']);
        Route::match(['put', 'patch'], 'users/{user}', [AdminUserController::class, 'update']);
        Route::delete('users/{user}', [AdminUserController::class, 'destroy']);

        Route::post('worlds', [AdminWorldController::class, 'store']);
        Route::match(['put', 'patch'], 'worlds/{world}', [AdminWorldController::class, 'update']);
        Route::delete('worlds/{world}', [AdminWorldController::class, 'destroy']);

        Route::get('items', [AdminItemController::class, 'index']);
        Route::post('items', [AdminItemController::class, 'store']);
        Route::match(['put', 'patch'], 'items/{item}', [AdminItemController::class, 'update']);
        Route::delete('items/{item}', [AdminItemController::class, 'destroy']);

        Route::get('activities', [AdminActivityController::class, 'index']);
        Route::post('activities', [AdminActivityController::class, 'store']);
        Route::match(['put', 'patch'], 'activities/{activity}', [AdminActivityController::class, 'update']);
        Route::delete('activities/{activity}', [AdminActivityController::class, 'destroy']);
    });
});
