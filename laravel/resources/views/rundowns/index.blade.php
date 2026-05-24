@extends('layouts.app')
@section('title', 'Rundown Acara')

@section('content')
<div class="card glass">
    <div class="card-header"><h3>➕ Tambah Acara</h3></div>
    <div class="card-body">
        <form action="{{ route('rundowns.store') }}" method="POST" class="form-row">
            @csrf
            <input type="text" name="name" required placeholder="Nama Acara">
            <input type="time" name="time" required>
            <input type="text" name="location" placeholder="Lokasi">
            <input type="text" name="pic" placeholder="PIC">
            <textarea name="notes" placeholder="Catatan" rows="1"></textarea>
            <button type="submit" class="btn btn-primary">Tambah</button>
        </form>
    </div>
</div>

<div class="card glass">
    <div class="card-header"><h3>⏱️ Timeline Acara</h3></div>
    <div class="card-body">
        <div class="rundown-timeline">
            @forelse($rundowns as $r)
            <div class="rundown-item">
                <div class="rundown-time-badge">{{ $r->time }}</div>
                <div class="rundown-content">
                    <h4>{{ $r->name }}</h4>
                    <div class="rundown-meta">
                        @if($r->location)<span>📍 {{ $r->location }}</span>@endif
                        @if($r->pic)<span>👤 {{ $r->pic }}</span>@endif
                    </div>
                    @if($r->notes)<p class="rundown-notes">📝 {{ $r->notes }}</p>@endif
                </div>
                <form action="{{ route('rundowns.destroy', $r) }}" method="POST" onsubmit="return confirm('Hapus?')">
                    @csrf @method('DELETE')
                    <button type="submit" class="btn-icon btn-danger-icon">🗑️</button>
                </form>
            </div>
            @empty
            <div class="empty-state">Belum ada rundown.</div>
            @endforelse
        </div>
    </div>
</div>
@endsection
