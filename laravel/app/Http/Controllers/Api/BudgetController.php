<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Budget;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    public function index(): JsonResponse
    {
        $wedding = Wedding::firstOrFail();
        $budgets = $wedding->budgets->map(function ($budget) {
            return [
                'id' => $budget->id,
                'category' => $budget->category,
                'budget' => (float) $budget->budget,
                'actual' => (float) $budget->actual,
                'remaining' => $budget->remaining,
                'percentage' => $budget->percentage,
            ];
        });

        $totalBudget = (float) $wedding->budgets()->sum('budget');
        $totalSpent = (float) $wedding->budgets()->sum('actual');

        return response()->json([
            'success' => true,
            'data' => [
                'budgets' => $budgets,
                'total_budget' => $totalBudget,
                'total_spent' => $totalSpent,
            ],
            'message' => null,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'category' => 'required|string|max:255',
            'budget' => 'required|numeric|min:0',
            'actual' => 'required|numeric|min:0',
        ]);

        $wedding = Wedding::firstOrFail();
        $budget = Budget::create(array_merge($validated, ['wedding_id' => $wedding->id]));

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $budget->id,
                'category' => $budget->category,
                'budget' => (float) $budget->budget,
                'actual' => (float) $budget->actual,
                'remaining' => $budget->remaining,
                'percentage' => $budget->percentage,
            ],
            'message' => 'Budget berhasil ditambahkan.',
        ], 201);
    }

    public function update(Request $request, Budget $budget): JsonResponse
    {
        $validated = $request->validate([
            'category' => 'required|string|max:255',
            'budget' => 'required|numeric|min:0',
            'actual' => 'required|numeric|min:0',
        ]);

        $budget->update($validated);
        $budget->refresh();

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $budget->id,
                'category' => $budget->category,
                'budget' => (float) $budget->budget,
                'actual' => (float) $budget->actual,
                'remaining' => $budget->remaining,
                'percentage' => $budget->percentage,
            ],
            'message' => 'Budget berhasil diperbarui.',
        ]);
    }

    public function destroy(Budget $budget): JsonResponse
    {
        $budget->delete();

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'Budget berhasil dihapus.',
        ]);
    }
}
