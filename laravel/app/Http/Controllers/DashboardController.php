<?php

namespace App\Http\Controllers;

use App\Models\Wedding;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        $wedding = Wedding::first();
        if (!$wedding) {
            $wedding = Wedding::create([
                'groom_name' => '',
                'bride_name' => '',
                'total_budget' => 0,
            ]);
        }

        $phases = $wedding->phases()->with('tasks')->get();
        $totalTasks = $wedding->tasks()->count();
        $completedTasks = $wedding->tasks()->where('completed', true)->count();
        $overallProgress = $totalTasks > 0 ? round(($completedTasks / $totalTasks) * 100, 1) : 0;

        $totalBudget = $wedding->budgets()->sum('budget');
        $totalSpent = $wedding->budgets()->sum('actual');
        $totalGuests = $wedding->guests()->count();
        $confirmedGuests = $wedding->guests()->whereIn('status', ['Konfirmasi', 'Hadir'])->count();

        // Upcoming execution tasks (not completed, sorted by due date)
        $upcomingActions = $wedding->tasks()
            ->where('type', 'execution')
            ->where('completed', false)
            ->whereNotNull('due_date')
            ->orderBy('due_date')
            ->limit(5)
            ->get();

        // Pending data input tasks
        $pendingInputs = $wedding->tasks()
            ->where('type', 'input')
            ->where('completed', false)
            ->whereNotNull('due_date')
            ->orderBy('due_date')
            ->limit(5)
            ->get();

        // Budget data for chart
        $budgets = $wedding->budgets;

        return view('dashboard', compact(
            'wedding', 'phases', 'totalTasks', 'completedTasks', 'overallProgress',
            'totalBudget', 'totalSpent', 'totalGuests', 'confirmedGuests',
            'upcomingActions', 'pendingInputs', 'budgets'
        ));
    }
}
