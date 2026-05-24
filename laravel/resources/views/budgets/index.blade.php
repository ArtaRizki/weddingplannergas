@extends('layouts.app')
@section('title', 'Budgeting')

@section('content')
<div class="card glass">
    <div class="card-header"><h3>➕ Tambah Budget</h3></div>
    <div class="card-body">
        <form action="{{ route('budgets.store') }}" method="POST" class="form-row">
            @csrf
            <input type="text" name="category" required placeholder="Nama Kategori">
            <input type="number" name="budget" required placeholder="Budget" step="1000">
            <input type="number" name="actual" required placeholder="Biaya Aktual" step="1000" value="0">
            <button type="submit" class="btn btn-primary">Tambah</button>
        </form>
    </div>
</div>

<div class="grid grid-3">
    <div class="stat-card stat-primary"><span class="stat-num">Rp {{ number_format($totalBudget, 0, ',', '.') }}</span><span class="stat-lbl">Total Budget</span></div>
    <div class="stat-card stat-warning"><span class="stat-num">Rp {{ number_format($totalSpent, 0, ',', '.') }}</span><span class="stat-lbl">Terpakai</span></div>
    <div class="stat-card {{ ($totalBudget - $totalSpent) >= 0 ? 'stat-success' : 'stat-danger' }}"><span class="stat-num">Rp {{ number_format($totalBudget - $totalSpent, 0, ',', '.') }}</span><span class="stat-lbl">Sisa</span></div>
</div>

<div class="card glass">
    <div class="card-header"><h3>📊 Detail Budget</h3></div>
    <div class="card-body">
        <table class="data-table">
            <thead><tr><th>Kategori</th><th>Budget</th><th>Pengeluaran</th><th>Sisa</th><th>%</th><th>Aksi</th></tr></thead>
            <tbody>
                @foreach($budgets as $b)
                <tr>
                    <td><strong>{{ $b->category }}</strong></td>
                    <td>Rp {{ number_format($b->budget, 0, ',', '.') }}</td>
                    <td>Rp {{ number_format($b->actual, 0, ',', '.') }}</td>
                    <td class="{{ $b->remaining < 0 ? 'text-danger' : 'text-success' }}">Rp {{ number_format($b->remaining, 0, ',', '.') }}</td>
                    <td>
                        <div class="mini-progress"><div class="mini-fill {{ $b->percentage > 100 ? 'over-budget' : '' }}" style="width:{{ min($b->percentage, 100) }}%"></div></div>
                        {{ $b->percentage }}%
                    </td>
                    <td>
                        <form action="{{ route('budgets.destroy', $b) }}" method="POST" onsubmit="return confirm('Hapus?')" style="display:inline">
                            @csrf @method('DELETE')
                            <button type="submit" class="btn-icon btn-danger-icon">🗑️</button>
                        </form>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endsection
