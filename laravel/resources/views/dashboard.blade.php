@extends('layouts.app')
@section('title', 'Dashboard')

@section('content')
<!-- Wedding Info + Stats -->
<div class="grid grid-2">
    <div class="card glass">
        <div class="card-header"><h3>💒 Informasi Pernikahan</h3></div>
        <div class="card-body">
            <div class="info-grid">
                <div class="info-item"><span class="info-label">Pengantin Pria</span><span class="info-value">{{ $wedding->groom_name ?: '-' }}</span></div>
                <div class="info-item"><span class="info-label">Pengantin Wanita</span><span class="info-value">{{ $wedding->bride_name ?: '-' }}</span></div>
                <div class="info-item"><span class="info-label">Tanggal</span><span class="info-value">{{ $wedding->wedding_date ? $wedding->wedding_date->translatedFormat('d F Y') : '-' }}</span></div>
                <div class="info-item"><span class="info-label">Lokasi</span><span class="info-value">{{ $wedding->location ?: '-' }}</span></div>
            </div>
        </div>
    </div>
    <div class="card glass">
        <div class="card-header"><h3>📈 Statistik</h3></div>
        <div class="card-body">
            <div class="stats-grid">
                <div class="stat-card stat-primary"><span class="stat-num">Rp {{ number_format($totalBudget, 0, ',', '.') }}</span><span class="stat-lbl">Total Budget</span></div>
                <div class="stat-card stat-warning"><span class="stat-num">Rp {{ number_format($totalSpent, 0, ',', '.') }}</span><span class="stat-lbl">Terpakai</span></div>
                <div class="stat-card stat-info"><span class="stat-num">{{ $totalGuests }}</span><span class="stat-lbl">Total Tamu</span></div>
                <div class="stat-card stat-success"><span class="stat-num">{{ $completedTasks }}/{{ $totalTasks }}</span><span class="stat-lbl">Task Selesai</span></div>
            </div>
        </div>
    </div>
</div>

<!-- Overall Progress Ring -->
<div class="card glass">
    <div class="card-header"><h3>🎯 Progress Keseluruhan</h3></div>
    <div class="card-body">
        <div class="progress-overview">
            <div class="progress-ring-container">
                <svg class="progress-ring" viewBox="0 0 120 120">
                    <circle class="progress-ring-bg" cx="60" cy="60" r="52" />
                    <circle class="progress-ring-fill" cx="60" cy="60" r="52" 
                        style="stroke-dasharray: {{ 2 * 3.14159 * 52 }}; stroke-dashoffset: {{ 2 * 3.14159 * 52 * (1 - $overallProgress / 100) }};" />
                </svg>
                <div class="progress-ring-text">{{ $overallProgress }}%</div>
            </div>
            <div class="phase-progress-list">
                @foreach($phases as $phase)
                <div class="phase-bar-item">
                    <div class="phase-bar-header">
                        <span class="phase-bar-icon">{{ $phase->icon }}</span>
                        <span class="phase-bar-name">{{ $phase->name }}</span>
                        <span class="phase-bar-pct" style="color: {{ $phase->color }}">{{ $phase->progress }}%</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: {{ $phase->progress }}%; background: {{ $phase->color }};"></div>
                    </div>
                    <div class="phase-bar-meta">{{ $phase->completed_tasks_count }}/{{ $phase->total_tasks_count }} task</div>
                </div>
                @endforeach
            </div>
        </div>
    </div>
</div>

<!-- Upcoming Actions & Pending Inputs -->
<div class="grid grid-2">
    <div class="card glass card-action">
        <div class="card-header"><h3>🔨 Aksi yang Harus Dilakukan</h3><span class="badge badge-danger">Execution</span></div>
        <div class="card-body">
            @forelse($upcomingActions as $task)
            <div class="action-item {{ $task->isOverdue() ? 'overdue' : '' }}">
                <div class="action-icon">🔨</div>
                <div class="action-content">
                    <div class="action-title">{{ $task->title }}</div>
                    <div class="action-meta">
                        <span class="action-phase">{{ $task->phase->name ?? '' }}</span>
                        @if($task->due_date)
                        <span class="action-due {{ $task->isOverdue() ? 'text-danger' : '' }}">
                            📅 {{ $task->due_date->translatedFormat('d M Y') }}
                            @if($task->days_remaining !== null)
                                ({{ $task->days_remaining > 0 ? $task->days_remaining . ' hari lagi' : ($task->days_remaining == 0 ? 'Hari ini!' : abs($task->days_remaining) . ' hari lewat!') }})
                            @endif
                        </span>
                        @endif
                    </div>
                </div>
                <span class="priority-dot priority-{{ $task->priority }}"></span>
            </div>
            @empty
            <div class="empty-state">✅ Tidak ada aksi yang pending</div>
            @endforelse
        </div>
    </div>

    <div class="card glass card-input">
        <div class="card-header"><h3>📝 Data yang Perlu Diisi</h3><span class="badge badge-info">Input</span></div>
        <div class="card-body">
            @forelse($pendingInputs as $task)
            <div class="action-item">
                <div class="action-icon">📝</div>
                <div class="action-content">
                    <div class="action-title">{{ $task->title }}</div>
                    <div class="action-meta">
                        <span class="action-phase">{{ $task->phase->name ?? '' }}</span>
                        @if($task->due_date)
                        <span class="action-due">📅 {{ $task->due_date->translatedFormat('d M Y') }}</span>
                        @endif
                    </div>
                </div>
                <span class="priority-dot priority-{{ $task->priority }}"></span>
            </div>
            @empty
            <div class="empty-state">✅ Semua data sudah terisi</div>
            @endforelse
        </div>
    </div>
</div>

<!-- Budget Chart -->
<div class="card glass">
    <div class="card-header"><h3>💰 Alokasi Budget</h3></div>
    <div class="card-body">
        <div class="budget-bars">
            @foreach($budgets as $b)
            <div class="budget-bar-item">
                <div class="budget-bar-header">
                    <span>{{ $b->category }}</span>
                    <span>Rp {{ number_format($b->actual, 0, ',', '.') }} / Rp {{ number_format($b->budget, 0, ',', '.') }}</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill {{ $b->percentage > 100 ? 'over-budget' : ($b->percentage > 80 ? 'warning' : '') }}" style="width: {{ min($b->percentage, 100) }}%"></div>
                </div>
            </div>
            @endforeach
        </div>
    </div>
</div>
@endsection
