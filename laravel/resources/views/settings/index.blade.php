@extends('layouts.app')
@section('title', 'Pengaturan')

@section('content')
<div class="card glass">
    <div class="card-header"><h3>💒 Informasi Pernikahan</h3></div>
    <div class="card-body">
        <form action="{{ route('settings.update') }}" method="POST" class="form-grid">
            @csrf @method('PUT')
            <div class="form-group"><label>Nama Pengantin Pria</label><input type="text" name="groom_name" value="{{ $wedding->groom_name }}" required></div>
            <div class="form-group"><label>Nama Pengantin Wanita</label><input type="text" name="bride_name" value="{{ $wedding->bride_name }}" required></div>
            <div class="form-group"><label>Tanggal Pernikahan</label><input type="date" name="wedding_date" value="{{ $wedding->wedding_date?->format('Y-m-d') }}"></div>
            <div class="form-group"><label>Lokasi</label><input type="text" name="location" value="{{ $wedding->location }}"></div>
            <div class="form-group"><label>Total Budget</label><input type="number" name="total_budget" value="{{ $wedding->total_budget }}" step="1000"></div>
            <div class="form-group"><label>Warna Utama</label><input type="color" name="primary_color" value="{{ $wedding->primary_color }}"></div>
            <div class="form-group"><label>Warna Sekunder</label><input type="color" name="secondary_color" value="{{ $wedding->secondary_color }}"></div>
            <div class="form-group"><label>Warna Aksen</label><input type="color" name="accent_color" value="{{ $wedding->accent_color }}"></div>
            <div class="form-group full-width"><button type="submit" class="btn btn-primary">💾 Simpan Pengaturan</button></div>
        </form>
    </div>
</div>
@endsection
