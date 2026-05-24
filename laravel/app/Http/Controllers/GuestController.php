<?php

namespace App\Http\Controllers;

use App\Models\Guest;
use App\Models\Wedding;
use Illuminate\Http\Request;

class GuestController extends Controller
{
    public function index()
    {
        $wedding = Wedding::firstOrFail();
        $guests = $wedding->guests;
        $totalGuests = $guests->count();
        $confirmed = $guests->whereIn('status', ['Konfirmasi', 'Hadir'])->count();
        $pending = $guests->whereIn('status', ['Belum Diundang', 'Diundang'])->count();

        return view('guests.index', compact('wedding', 'guests', 'totalGuests', 'confirmed', 'pending'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'side' => 'required|in:Pria,Wanita,Keluarga',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'status' => 'required|string',
        ]);

        $wedding = Wedding::firstOrFail();
        Guest::create(array_merge($validated, ['wedding_id' => $wedding->id]));

        return redirect()->route('guests.index')->with('success', 'Tamu berhasil ditambahkan!');
    }

    public function destroy(Guest $guest)
    {
        $guest->delete();
        return redirect()->route('guests.index')->with('success', 'Tamu berhasil dihapus!');
    }
}
