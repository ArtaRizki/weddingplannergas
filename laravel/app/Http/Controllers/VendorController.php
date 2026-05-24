<?php

namespace App\Http\Controllers;

use App\Models\Vendor;
use App\Models\Wedding;
use Illuminate\Http\Request;

class VendorController extends Controller
{
    public function index()
    {
        $wedding = Wedding::firstOrFail();
        $vendors = $wedding->vendors;

        return view('vendors.index', compact('wedding', 'vendors'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|string',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'cost' => 'nullable|numeric|min:0',
        ]);

        $wedding = Wedding::firstOrFail();
        Vendor::create(array_merge($validated, ['wedding_id' => $wedding->id, 'cost' => $validated['cost'] ?? 0]));

        return redirect()->route('vendors.index')->with('success', 'Vendor berhasil ditambahkan!');
    }

    public function destroy(Vendor $vendor)
    {
        $vendor->delete();
        return redirect()->route('vendors.index')->with('success', 'Vendor berhasil dihapus!');
    }
}
