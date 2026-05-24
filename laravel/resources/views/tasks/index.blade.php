@extends('layouts.app')
@section('title', 'To-Do List')

@section('content')
<!-- Add Task Form -->
<div class="card glass">
    <div class="card-header"><h3>➕ Tambah Task</h3></div>
    <div class="card-body">
        <form action="{{ route('tasks.store') }}" method="POST" class="form-grid">
            @csrf
            <div class="form-group">
                <label>Judul Task</label>
                <input type="text" name="title" required placeholder="Contoh: Booking venue">
            </div>
            <div class="form-group">
                <label>Phase</label>
                <select name="phase_id" required>
                    <option value="">Pilih Phase</option>
                    @foreach($phases as $p)
                    <option value="{{ $p->id }}">{{ $p->icon }} {{ $p->name }}</option>
                    @endforeach
                </select>
            </div>
            <div class="form-group">
                <label>Tipe</label>
                <select name="type" required>
                    <option value="input">📝 Input Data</option>
                    <option value="execution">🔨 Eksekusi</option>
                </select>
            </div>
            <div class="form-group">
                <label>Kategori</label>
                <select name="category" required>
                    <option value="Persiapan">Persiapan</option>
                    <option value="Vendor">Vendor</option>
                    <option value="Budget">Budget</option>
                    <option value="Tamu">Tamu</option>
                    <option value="Lainnya">Lainnya</option>
                </select>
            </div>
            <div class="form-group">
                <label>Prioritas</label>
                <select name="priority" required>
                    <option value="rendah">🟢 Rendah</option>
                    <option value="sedang" selected>🟡 Sedang</option>
                    <option value="tinggi">🔴 Tinggi</option>
                </select>
            </div>
            <div class="form-group">
                <label>Deadline</label>
                <input type="date" name="due_date">
            </div>
            <div class="form-group full-width">
                <label>Deskripsi</label>
                <textarea name="description" rows="2" placeholder="Detail task..."></textarea>
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-primary">Tambah Task</button>
            </div>
        </form>
    </div>
</div>

<!-- Filter -->
<div class="card glass">
    <div class="card-body">
        <div class="filter-row">
            <button class="filter-btn active" onclick="filterTasks('all')">Semua ({{ $tasks->count() }})</button>
            <button class="filter-btn" onclick="filterTasks('execution')">🔨 Eksekusi ({{ $tasks->where('type','execution')->count() }})</button>
            <button class="filter-btn" onclick="filterTasks('input')">📝 Input ({{ $tasks->where('type','input')->count() }})</button>
            <button class="filter-btn" onclick="filterTasks('pending')">⏳ Pending ({{ $tasks->where('completed',false)->count() }})</button>
            <button class="filter-btn" onclick="filterTasks('done')">✅ Selesai ({{ $tasks->where('completed',true)->count() }})</button>
        </div>
    </div>
</div>

<!-- Task List -->
<div class="card glass">
    <div class="card-header"><h3>📋 Daftar Task</h3></div>
    <div class="card-body">
        @forelse($tasks as $task)
        <div class="task-row {{ $task->completed ? 'completed' : '' }} {{ $task->isOverdue() ? 'overdue' : '' }}" data-type="{{ $task->type }}" data-status="{{ $task->completed ? 'done' : 'pending' }}">
            <form action="{{ route('tasks.toggle', $task) }}" method="POST" style="display:inline">
                @csrf @method('PATCH')
                <button type="submit" class="task-check {{ $task->completed ? 'checked' : '' }}">
                    {{ $task->completed ? '✓' : '' }}
                </button>
            </form>
            <div class="task-info">
                <div class="task-title-row">
                    <span class="task-title">{{ $task->title }}</span>
                    <span class="type-badge type-{{ $task->type }}">{{ $task->type === 'execution' ? '🔨 Eksekusi' : '📝 Input' }}</span>
                    <span class="priority-badge priority-{{ $task->priority }}">{{ ucfirst($task->priority) }}</span>
                </div>
                @if($task->description)<div class="task-desc">{{ $task->description }}</div>@endif
                <div class="task-meta">
                    <span>{{ $task->phase->icon ?? '' }} {{ $task->phase->name ?? '' }}</span>
                    <span>📁 {{ $task->category }}</span>
                    @if($task->due_date)<span class="{{ $task->isOverdue() ? 'text-danger' : '' }}">📅 {{ $task->due_date->format('d M Y') }}</span>@endif
                </div>
            </div>
            <form action="{{ route('tasks.destroy', $task) }}" method="POST" onsubmit="return confirm('Hapus task?')">
                @csrf @method('DELETE')
                <button type="submit" class="btn-icon btn-danger-icon">🗑️</button>
            </form>
        </div>
        @empty
        <div class="empty-state">Belum ada task. Tambahkan task pertama!</div>
        @endforelse
    </div>
</div>

@push('scripts')
<script>
function filterTasks(type) {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    event.target.classList.add('active');
    document.querySelectorAll('.task-row').forEach(row => {
        if (type === 'all') { row.style.display = ''; return; }
        if (type === 'done') { row.style.display = row.dataset.status === 'done' ? '' : 'none'; return; }
        if (type === 'pending') { row.style.display = row.dataset.status === 'pending' ? '' : 'none'; return; }
        row.style.display = row.dataset.type === type ? '' : 'none';
    });
}
</script>
@endpush
@endsection
