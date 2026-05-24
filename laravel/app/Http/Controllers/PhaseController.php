<?php

namespace App\Http\Controllers;

use App\Models\Phase;
use App\Models\Wedding;
use Illuminate\Http\Request;

class PhaseController extends Controller
{
    public function index()
    {
        $wedding = Wedding::firstOrFail();
        $phases = $wedding->phases()->with('tasks')->get();

        return view('phases.index', compact('wedding', 'phases'));
    }

    public function show(Phase $phase)
    {
        $phase->load(['tasks' => fn($q) => $q->orderBy('order'), 'wedding']);

        return view('phases.show', compact('phase'));
    }
}
