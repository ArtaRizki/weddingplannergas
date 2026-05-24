<?php

use App\Http\Controllers\BudgetController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\GuestController;
use App\Http\Controllers\PhaseController;
use App\Http\Controllers\RundownController;
use App\Http\Controllers\SettingsController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\VendorController;
use Illuminate\Support\Facades\Route;

// Dashboard
Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

// Phases
Route::get('/phases', [PhaseController::class, 'index'])->name('phases.index');
Route::get('/phases/{phase}', [PhaseController::class, 'show'])->name('phases.show');

// Tasks
Route::get('/tasks', [TaskController::class, 'index'])->name('tasks.index');
Route::post('/tasks', [TaskController::class, 'store'])->name('tasks.store');
Route::patch('/tasks/{task}/toggle', [TaskController::class, 'toggle'])->name('tasks.toggle');
Route::delete('/tasks/{task}', [TaskController::class, 'destroy'])->name('tasks.destroy');

// Budgets
Route::get('/budgets', [BudgetController::class, 'index'])->name('budgets.index');
Route::post('/budgets', [BudgetController::class, 'store'])->name('budgets.store');
Route::put('/budgets/{budget}', [BudgetController::class, 'update'])->name('budgets.update');
Route::delete('/budgets/{budget}', [BudgetController::class, 'destroy'])->name('budgets.destroy');

// Vendors
Route::get('/vendors', [VendorController::class, 'index'])->name('vendors.index');
Route::post('/vendors', [VendorController::class, 'store'])->name('vendors.store');
Route::delete('/vendors/{vendor}', [VendorController::class, 'destroy'])->name('vendors.destroy');

// Guests
Route::get('/guests', [GuestController::class, 'index'])->name('guests.index');
Route::post('/guests', [GuestController::class, 'store'])->name('guests.store');
Route::delete('/guests/{guest}', [GuestController::class, 'destroy'])->name('guests.destroy');

// Rundowns
Route::get('/rundowns', [RundownController::class, 'index'])->name('rundowns.index');
Route::post('/rundowns', [RundownController::class, 'store'])->name('rundowns.store');
Route::delete('/rundowns/{rundown}', [RundownController::class, 'destroy'])->name('rundowns.destroy');

// Settings
Route::get('/settings', [SettingsController::class, 'index'])->name('settings.index');
Route::put('/settings', [SettingsController::class, 'update'])->name('settings.update');
