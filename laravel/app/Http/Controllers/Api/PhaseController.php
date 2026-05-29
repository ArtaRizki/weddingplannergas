<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Phase;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;

class PhaseController extends Controller
{
    public function index(): JsonResponse
    {
        $wedding = Wedding::firstOrFail();
        $phases = $wedding->phases()->with('tasks')->get()->map(function ($phase) {
            return [
                'id' => $phase->id,
                'name' => $phase->name,
                'icon' => $phase->icon,
                'start_date' => $phase->start_date?->toDateString(),
                'end_date' => $phase->end_date?->toDateString(),
                'order' => $phase->order,
                'progress' => $phase->progress,
                'completed_tasks' => $phase->completed_tasks_count,
                'total_tasks' => $phase->total_tasks_count,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $phases,
            'message' => null,
        ]);
    }

    public function show(Phase $phase): JsonResponse
    {
        $phase->load(['tasks' => fn($q) => $q->orderBy('order')]);

        $tasks = $phase->tasks->map(function ($task) {
            return [
                'id' => $task->id,
                'title' => $task->title,
                'description' => $task->description,
                'type' => $task->type,
                'category' => $task->category,
                'priority' => $task->priority,
                'due_date' => $task->due_date?->toDateString(),
                'completed' => $task->completed,
                'completed_at' => $task->completed_at?->toIso8601String(),
                'order' => $task->order,
                'notes' => $task->notes,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $phase->id,
                'name' => $phase->name,
                'icon' => $phase->icon,
                'start_date' => $phase->start_date?->toDateString(),
                'end_date' => $phase->end_date?->toDateString(),
                'order' => $phase->order,
                'progress' => $phase->progress,
                'completed_tasks' => $phase->completed_tasks_count,
                'total_tasks' => $phase->total_tasks_count,
                'tasks' => $tasks,
            ],
            'message' => null,
        ]);
    }
}
