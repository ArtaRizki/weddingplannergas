<?php

namespace App\Http\Controllers;

use App\Models\Wedding;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    public function index()
    {
        $wedding = Wedding::firstOrFail();
        return view('settings.index', compact('wedding'));
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'groom_name' => 'required|string|max:255',
            'bride_name' => 'required|string|max:255',
            'wedding_date' => 'nullable|date',
            'location' => 'nullable|string|max:255',
            'total_budget' => 'nullable|numeric|min:0',
            'primary_color' => 'nullable|string',
            'secondary_color' => 'nullable|string',
            'accent_color' => 'nullable|string',
        ]);

        $wedding = Wedding::firstOrFail();
        $wedding->update($validated);

        return redirect()->route('settings.index')->with('success', 'Pengaturan berhasil disimpan!');
    }
}
