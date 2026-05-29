<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BudgetController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\GuestController;
use App\Http\Controllers\Api\PhaseController;
use App\Http\Controllers\Api\RundownController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\VendorController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| All API routes return JSON in the envelope format:
| { "success": true/false, "data": {...}, "message": "..." }
|
*/

// Public routes
Route::post('/login', [AuthController::class, 'login']);

// Authenticated routes (require Sanctum token)
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);

    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // Budgets
    Route::get('/budgets', [BudgetController::class, 'index']);
    Route::post('/budgets', [BudgetController::class, 'store']);
    Route::put('/budgets/{budget}', [BudgetController::class, 'update']);
    Route::delete('/budgets/{budget}', [BudgetController::class, 'destroy']);

    // Guests
    Route::get('/guests', [GuestController::class, 'index']);
    Route::post('/guests', [GuestController::class, 'store']);
    Route::delete('/guests/{guest}', [GuestController::class, 'destroy']);

    // Phases
    Route::get('/phases', [PhaseController::class, 'index']);
    Route::get('/phases/{phase}', [PhaseController::class, 'show']);

    // Tasks
    Route::get('/tasks', [TaskController::class, 'index']);
    Route::post('/tasks', [TaskController::class, 'store']);
    Route::patch('/tasks/{task}/toggle', [TaskController::class, 'toggle']);
    Route::delete('/tasks/{task}', [TaskController::class, 'destroy']);

    // Vendors
    Route::get('/vendors', [VendorController::class, 'index']);
    Route::post('/vendors', [VendorController::class, 'store']);
    Route::delete('/vendors/{vendor}', [VendorController::class, 'destroy']);

    // Rundowns
    Route::get('/rundowns', [RundownController::class, 'index']);
    Route::post('/rundowns', [RundownController::class, 'store']);
    Route::delete('/rundowns/{rundown}', [RundownController::class, 'destroy']);

    // Settings
    Route::get('/settings', [SettingsController::class, 'index']);
    Route::put('/settings', [SettingsController::class, 'update']);
});
