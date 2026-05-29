<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Guest;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GuestController extends Controller
{
    public function index(): JsonResponse
    {
        $wedding = Wedding::firstOrFail();
        $guests = $wedding->guests->map(function ($guest) {
            return [
                'id' => $guest->id,
                'name' => $guest->name,
                'side' => $guest->side,
                'phone' => $guest->phone,
                'email' => $guest->email,
                'status' => $guest->status,
            ];
        });

        $totalGuests = $guests->count();
        $confirmed = $guests->whereIn('status', ['Konfirmasi', 'Hadir'])->count();
        $pending = $guests->whereIn('status', ['Belum Diundang', 'Diundang'])->count();

        return response()->json([
            'success' => true,
            'data' => [
                'guests' => $guests->values(),
                'total' => $totalGuests,
                'confirmed' => $confirmed,
                'pending' => $pending,
            ],
            'message' => null,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'side' => 'required|in:Pria,Wanita,Keluarga',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'status' => 'required|string',
        ]);

        $wedding = Wedding::firstOrFail();
        $guest = Guest::create(array_merge($validated, ['wedding_id' => $wedding->id]));

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $guest->id,
                'name' => $guest->name,
                'side' => $guest->side,
                'phone' => $guest->phone,
                'email' => $guest->email,
                'status' => $guest->status,
            ],
            'message' => 'Tamu berhasil ditambahkan.',
        ], 201);
    }

    public function destroy(Guest $guest): JsonResponse
    {
        $guest->delete();

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'Tamu berhasil dihapus.',
        ]);
    }
}
