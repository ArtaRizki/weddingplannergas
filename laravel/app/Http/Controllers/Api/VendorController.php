<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Vendor;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VendorController extends Controller
{
    public function index(): JsonResponse
    {
        $wedding = Wedding::firstOrFail();
        $vendors = $wedding->vendors->map(function ($vendor) {
            return [
                'id' => $vendor->id,
                'name' => $vendor->name,
                'category' => $vendor->category,
                'phone' => $vendor->phone,
                'email' => $vendor->email,
                'cost' => (float) $vendor->cost,
                'status' => $vendor->status ?? 'Aktif',
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $vendors,
            'message' => null,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|string',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'cost' => 'nullable|numeric|min:0',
        ]);

        $wedding = Wedding::firstOrFail();
        $vendor = Vendor::create(array_merge($validated, [
            'wedding_id' => $wedding->id,
            'cost' => $validated['cost'] ?? 0,
        ]));

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $vendor->id,
                'name' => $vendor->name,
                'category' => $vendor->category,
                'phone' => $vendor->phone,
                'email' => $vendor->email,
                'cost' => (float) $vendor->cost,
                'status' => $vendor->status ?? 'Aktif',
            ],
            'message' => 'Vendor berhasil ditambahkan.',
        ], 201);
    }

    public function destroy(Vendor $vendor): JsonResponse
    {
        $vendor->delete();

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'Vendor berhasil dihapus.',
        ]);
    }
}
