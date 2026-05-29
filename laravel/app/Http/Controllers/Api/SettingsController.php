<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    public function index(): JsonResponse
    {
        $wedding = Wedding::firstOrFail();

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $wedding->id,
                'groom_name' => $wedding->groom_name,
                'bride_name' => $wedding->bride_name,
                'wedding_date' => $wedding->wedding_date?->toDateString(),
                'location' => $wedding->location,
                'total_budget' => (float) $wedding->total_budget,
            ],
            'message' => null,
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'groom_name' => 'required|string|max:255',
            'bride_name' => 'required|string|max:255',
            'wedding_date' => 'nullable|date',
            'location' => 'nullable|string|max:255',
            'total_budget' => 'nullable|numeric|min:0|max:9999999999999.99',
        ]);

        $wedding = Wedding::firstOrFail();
        $wedding->update($validated);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $wedding->id,
                'groom_name' => $wedding->groom_name,
                'bride_name' => $wedding->bride_name,
                'wedding_date' => $wedding->wedding_date?->toDateString(),
                'location' => $wedding->location,
                'total_budget' => (float) $wedding->total_budget,
            ],
            'message' => 'Pengaturan berhasil disimpan.',
        ]);
    }
}
