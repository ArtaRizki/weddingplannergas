@extends('layouts.app')
@section('title', 'Vendor List')

@section('content')
<div class="card glass">
    <div class="card-header"><h3>➕ Tambah Vendor</h3></div>
    <div class="card-body">
        <form action="{{ route('vendors.store') }}" method="POST" class="form-grid">
            @csrf
            <div class="form-group"><label>Nama</label><input type="text" name="name" required></div>
            <div class="form-group"><label>Kategori</label>
                <select name="category" required>
                    @foreach(['Fotografi','Videografi','Catering','Dekorasi','Makeup','Venue','Undangan','Lainnya'] as $c)
                    <option>{{ $c }}</option>
                    @endforeach
                </select>
            </div>
            <div class="form-group"><label>Telepon</label><input type="tel" name="phone"></div>
            <div class="form-group"><label>Email</label><input type="email" name="email"></div>
            <div class="form-group"><label>Biaya</label><input type="number" name="cost" step="1000"></div>
            <div class="form-group"><button type="submit" class="btn btn-primary">Tambah</button></div>
        </form>
    </div>
</div>

<div class="vendor-grid">
    @forelse($vendors as $v)
    <div class="card glass vendor-card">
        <div class="vendor-cat-badge">{{ $v->category }}</div>
        <h4>{{ $v->name }}</h4>
        <div class="vendor-detail">📞 {{ $v->phone ?: '-' }}</div>
        <div class="vendor-detail">📧 {{ $v->email ?: '-' }}</div>
        @if($v->cost > 0)<div class="vendor-detail vendor-cost">💰 Rp {{ number_format($v->cost, 0, ',', '.') }}</div>@endif
        <form action="{{ route('vendors.destroy', $v) }}" method="POST" onsubmit="return confirm('Hapus vendor?')">
            @csrf @method('DELETE')
            <button type="submit" class="btn btn-sm btn-danger">🗑️ Hapus</button>
        </form>
    </div>
    @empty
    <div class="empty-state">Belum ada vendor.</div>
    @endforelse
</div>
@endsection
