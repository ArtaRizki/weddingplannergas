<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index(): JsonResponse
    {
        $wedding = Wedding::firstOrFail();
        $tasks = $wedding->tasks()->with('phase:id,name')->orderBy('due_date')->get()->map(function ($task) {
            return [
                'id' => $task->id,
                'phase_id' => $task->phase_id,
                'phase_name' => $task->phase?->name,
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
            'data' => $tasks,
            'message' => null,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'phase_id' => 'required|exists:phases,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'type' => 'required|in:input,execution',
            'category' => 'required|string',
            'priority' => 'required|in:rendah,sedang,tinggi',
            'due_date' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);

        $wedding = Wedding::firstOrFail();
        $maxOrder = Task::where('phase_id', $validated['phase_id'])->max('order') ?? 0;

        $task = Task::create(array_merge($validated, [
            'wedding_id' => $wedding->id,
            'order' => $maxOrder + 1,
        ]));

        $task->load('phase:id,name');

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $task->id,
                'phase_id' => $task->phase_id,
                'phase_name' => $task->phase?->name,
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
            ],
            'message' => 'Task berhasil ditambahkan.',
        ], 201);
    }

    public function toggle(Task $task): JsonResponse
    {
        $task->update([
            'completed' => ! $task->completed,
            'completed_at' => ! $task->completed ? now() : null,
        ]);

        $task->refresh();

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $task->id,
                'completed' => $task->completed,
                'completed_at' => $task->completed_at?->toIso8601String(),
            ],
            'message' => 'Status task diperbarui.',
        ]);
    }

    public function destroy(Task $task): JsonResponse
    {
        $task->delete();

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'Task berhasil dihapus.',
        ]);
    }
}
