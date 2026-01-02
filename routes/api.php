<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\GoalController;
use App\Http\Controllers\Api\StorageAccountController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\TeamController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes (no auth required)
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Protected routes (auth required)
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/user', [AuthController::class, 'user']);
    Route::post('/auth/user', [AuthController::class, 'updateProfile']);

    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // Goals - prefix with 'api.' to avoid conflict with web routes
    Route::apiResource('goals', GoalController::class)->names([
        'index' => 'api.goals.index',
        'store' => 'api.goals.store',
        'show' => 'api.goals.show',
        'update' => 'api.goals.update',
        'destroy' => 'api.goals.destroy',
    ]);

    // Storage Accounts (Wallets) - prefix with 'api.'
    Route::apiResource('wallets', StorageAccountController::class)->names([
        'index' => 'api.wallets.index',
        'store' => 'api.wallets.store',
        'show' => 'api.wallets.show',
        'update' => 'api.wallets.update',
        'destroy' => 'api.wallets.destroy',
    ]);

    // Transactions - prefix with 'api.'
    Route::apiResource('transactions', TransactionController::class)->except(['update'])->names([
        'index' => 'api.transactions.index',
        'store' => 'api.transactions.store',
        'show' => 'api.transactions.show',
        'destroy' => 'api.transactions.destroy',
    ]);

    // Teams
    Route::get('/teams', [TeamController::class, 'index']);
    Route::post('/teams', [TeamController::class, 'store']);
    Route::put('/teams/{team}', [TeamController::class, 'update']);
    Route::put('/teams/switch/{team}', [TeamController::class, 'switchTeam']);
    Route::post('/teams/{team}/invite', [TeamController::class, 'invite']);
    Route::delete('/teams/{team}', [TeamController::class, 'destroy']);
});
