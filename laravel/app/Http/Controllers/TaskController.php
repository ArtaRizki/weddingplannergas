<?php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\Wedding;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index()
    {
        $wedding = Wedding::firstOrFail();
        $tasks = $wedding->tasks()->with('phase')->orderBy('due_date')->get();
        $phases = $wedding->phases;

        return view('tasks.index', compact('wedding', 'tasks', 'phases'));
    }

    public function store(Request $request)
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

        Task::create(array_merge($validated, [
            'wedding_id' => $wedding->id,
            'order' => $maxOrder + 1,
        ]));

        return redirect()->back()->with('success', 'Task berhasil ditambahkan!');
    }

    public function toggle(Task $task)
    {
        $task->update([
            'completed' => !$task->completed,
            'completed_at' => !$task->completed ? now() : null,
        ]);

        return redirect()->back()->with('success', 'Status task diperbarui!');
    }

    public function destroy(Task $task)
    {
        $task->delete();
        return redirect()->back()->with('success', 'Task berhasil dihapus!');
    }
}
