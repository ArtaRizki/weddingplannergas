<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function index(): JsonResponse
    {
        $wedding = Wedding::first();

        if (! $wedding) {
            $wedding = Wedding::create([
                'groom_name' => '',
                'bride_name' => '',
                'total_budget' => 0,
            ]);
        }

        $totalTasks = $wedding->tasks()->count();
        $completedTasks = $wedding->tasks()->where('completed', true)->count();
        $overallProgress = $totalTasks > 0 ? round(($completedTasks / $totalTasks) * 100, 1) : 0;

        $totalBudget = (float) $wedding->budgets()->sum('budget');
        $totalSpent = (float) $wedding->budgets()->sum('actual');
        $totalGuests = $wedding->guests()->count();
        $confirmedGuests = $wedding->guests()->whereIn('status', ['Konfirmasi', 'Hadir'])->count();

        $upcomingActions = $wedding->tasks()
            ->where('type', 'execution')
            ->where('completed', false)
            ->whereNotNull('due_date')
            ->orderBy('due_date')
            ->limit(5)
            ->get(['id', 'title', 'due_date']);

        $pendingInputs = $wedding->tasks()
            ->where('type', 'input')
            ->where('completed', false)
            ->whereNotNull('due_date')
            ->orderBy('due_date')
            ->limit(5)
            ->get(['id', 'title', 'due_date']);

        return response()->json([
            'success' => true,
            'data' => [
                'wedding' => [
                    'id' => $wedding->id,
                    'groom_name' => $wedding->groom_name,
                    'bride_name' => $wedding->bride_name,
                    'wedding_date' => $wedding->wedding_date?->toDateString(),
                    'location' => $wedding->location,
                    'total_budget' => (float) $wedding->total_budget,
                ],
                'overall_progress' => $overallProgress,
                'total_tasks' => $totalTasks,
                'completed_tasks' => $completedTasks,
                'total_budget' => $totalBudget,
                'total_spent' => $totalSpent,
                'total_guests' => $totalGuests,
                'confirmed_guests' => $confirmedGuests,
                'upcoming_actions' => $upcomingActions,
                'pending_inputs' => $pendingInputs,
            ],
            'message' => null,
        ]);
    }
}
