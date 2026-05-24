<?php

namespace App\Http\Controllers;

use App\Models\Rundown;
use App\Models\Wedding;
use Illuminate\Http\Request;

class RundownController extends Controller
{
    public function index()
    {
        $wedding = Wedding::firstOrFail();
        $rundowns = $wedding->rundowns()->orderBy('time')->get();

        return view('rundowns.index', compact('wedding', 'rundowns'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'time' => 'required|string',
            'location' => 'nullable|string',
            'pic' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        $wedding = Wedding::firstOrFail();
        Rundown::create(array_merge($validated, ['wedding_id' => $wedding->id]));

        return redirect()->route('rundowns.index')->with('success', 'Rundown berhasil ditambahkan!');
    }

    public function destroy(Rundown $rundown)
    {
        $rundown->delete();
        return redirect()->route('rundowns.index')->with('success', 'Rundown berhasil dihapus!');
    }
}
