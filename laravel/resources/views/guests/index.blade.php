@extends('layouts.app')
@section('title', 'Tamu & Undangan')

@section('content')
<div class="card glass">
    <div class="card-header"><h3>➕ Tambah Tamu</h3></div>
    <div class="card-body">
        <form action="{{ route('guests.store') }}" method="POST" class="form-row">
            @csrf
            <input type="text" name="name" required placeholder="Nama Tamu">
            <select name="side" required><option value="Pria">Pihak Pria</option><option value="Wanita">Pihak Wanita</option><option value="Keluarga">Keluarga</option></select>
            <input type="tel" name="phone" placeholder="Telepon">
            <input type="email" name="email" placeholder="Email">
            <select name="status" required><option>Belum Diundang</option><option>Diundang</option><option>Konfirmasi</option><option>Hadir</option><option>Tidak Hadir</option></select>
            <button type="submit" class="btn btn-primary">Tambah</button>
        </form>
    </div>
</div>

<div class="grid grid-3">
    <div class="stat-card stat-primary"><span class="stat-num">{{ $totalGuests }}</span><span class="stat-lbl">Total Tamu</span></div>
    <div class="stat-card stat-success"><span class="stat-num">{{ $confirmed }}</span><span class="stat-lbl">Konfirmasi</span></div>
    <div class="stat-card stat-warning"><span class="stat-num">{{ $pending }}</span><span class="stat-lbl">Pending</span></div>
</div>

<div class="card glass">
    <div class="card-header"><h3>📋 Daftar Tamu</h3></div>
    <div class="card-body">
        <table class="data-table">
            <thead><tr><th>Nama</th><th>Pihak</th><th>Telepon</th><th>Status</th><th>Aksi</th></tr></thead>
            <tbody>
                @foreach($guests as $g)
                <tr>
                    <td><strong>{{ $g->name }}</strong></td>
                    <td>{{ $g->side }}</td>
                    <td>{{ $g->phone ?: '-' }}</td>
                    <td><span class="status-badge status-{{ strtolower(str_replace(' ', '-', $g->status)) }}">{{ $g->status }}</span></td>
                    <td>
                        <form action="{{ route('guests.destroy', $g) }}" method="POST" onsubmit="return confirm('Hapus?')" style="display:inline">@csrf @method('DELETE')<button type="submit" class="btn-icon btn-danger-icon">🗑️</button></form>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endsection
