<?php

use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::middleware([
    'auth:sanctum',
    config('jetstream.auth_session'),
    'verified',
])->group(function () {
    Route::get('/dashboard', [\App\Http\Controllers\DashboardController::class, 'index'])->name('dashboard');
    Route::resource('wallets', \App\Http\Controllers\StorageAccountController::class)->names('storage')->except(['create', 'edit', 'show']);
    Route::resource('goals', \App\Http\Controllers\GoalController::class)->except(['create', 'edit', 'show']);
    Route::resource('transactions', \App\Http\Controllers\TransactionController::class)->only(['index', 'create', 'store']);
    Route::get('/export/transactions', [\App\Http\Controllers\ExportController::class, 'transactions'])->name('export.transactions');
});
