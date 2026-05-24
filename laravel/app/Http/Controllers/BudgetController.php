<?php

namespace App\Http\Controllers;

use App\Models\Budget;
use App\Models\Wedding;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    public function index()
    {
        $wedding = Wedding::firstOrFail();
        $budgets = $wedding->budgets;
        $totalBudget = $budgets->sum('budget');
        $totalSpent = $budgets->sum('actual');

        return view('budgets.index', compact('wedding', 'budgets', 'totalBudget', 'totalSpent'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'category' => 'required|string|max:255',
            'budget' => 'required|numeric|min:0',
            'actual' => 'required|numeric|min:0',
        ]);

        $wedding = Wedding::firstOrFail();
        Budget::create(array_merge($validated, ['wedding_id' => $wedding->id]));

        return redirect()->route('budgets.index')->with('success', 'Budget berhasil ditambahkan!');
    }

    public function update(Request $request, Budget $budget)
    {
        $validated = $request->validate([
            'category' => 'required|string|max:255',
            'budget' => 'required|numeric|min:0',
            'actual' => 'required|numeric|min:0',
        ]);

        $budget->update($validated);

        return redirect()->route('budgets.index')->with('success', 'Budget berhasil diperbarui!');
    }

    public function destroy(Budget $budget)
    {
        $budget->delete();
        return redirect()->route('budgets.index')->with('success', 'Budget berhasil dihapus!');
    }
}
