<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Rundown;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RundownController extends Controller
{
    public function index(): JsonResponse
    {
        $wedding = Wedding::firstOrFail();
        $rundowns = $wedding->rundowns()->orderBy('time')->get()->map(function ($rundown) {
            return [
                'id' => $rundown->id,
                'name' => $rundown->name,
                'time' => $rundown->time,
                'location' => $rundown->location,
                'pic' => $rundown->pic,
                'notes' => $rundown->notes,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $rundowns,
            'message' => null,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'time' => 'required|string',
            'location' => 'nullable|string',
            'pic' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        $wedding = Wedding::firstOrFail();
        $rundown = Rundown::create(array_merge($validated, ['wedding_id' => $wedding->id]));

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $rundown->id,
                'name' => $rundown->name,
                'time' => $rundown->time,
                'location' => $rundown->location,
                'pic' => $rundown->pic,
                'notes' => $rundown->notes,
            ],
            'message' => 'Rundown berhasil ditambahkan.',
        ], 201);
    }

    public function destroy(Rundown $rundown): JsonResponse
    {
        $rundown->delete();

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'Rundown berhasil dihapus.',
        ]);
    }
}
