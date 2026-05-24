@extends('layouts.app')
@section('title', 'Progress & Phase')

@section('content')
<!-- Phase Timeline Diagram -->
<div class="card glass">
    <div class="card-header"><h3>📊 Diagram Timeline Persiapan</h3></div>
    <div class="card-body">
        <div class="timeline-diagram">
            @foreach($phases as $i => $phase)
            <div class="timeline-node {{ $phase->progress >= 100 ? 'done' : ($phase->progress > 0 ? 'active' : '') }}">
                <div class="timeline-dot" style="background: {{ $phase->color }}">{{ $phase->icon }}</div>
                <div class="timeline-info">
                    <div class="timeline-name">{{ $phase->name }}</div>
                    <div class="timeline-pct" style="color: {{ $phase->color }}">{{ $phase->progress }}%</div>
                </div>
                @if(!$loop->last)<div class="timeline-connector" style="background: {{ $phase->progress >= 100 ? $phase->color : '#e2e8f0' }}"></div>@endif
            </div>
            @endforeach
        </div>
    </div>
</div>

<!-- Flow Diagram: Input vs Execution -->
<div class="card glass">
    <div class="card-header"><h3>🔄 Alur Kerja: Input Data vs Eksekusi</h3></div>
    <div class="card-body">
        <div class="flow-legend">
            <span class="flow-legend-item"><span class="flow-dot flow-input"></span> 📝 Input Data — Mengisi/memperbarui data di sistem</span>
            <span class="flow-legend-item"><span class="flow-dot flow-exec"></span> 🔨 Eksekusi — Aksi nyata di dunia nyata</span>
        </div>
    </div>
</div>

<!-- Phase Cards -->
@foreach($phases as $phase)
<div class="card glass phase-card" style="border-left: 4px solid {{ $phase->color }}">
    <div class="card-header">
        <h3>
            <span style="font-size:1.2em">{{ $phase->icon }}</span>
            Phase {{ $phase->order }}: {{ $phase->name }}
        </h3>
        <div class="phase-meta-row">
            <span class="badge" style="background: {{ $phase->color }}; color: #fff">{{ $phase->progress }}%</span>
            <span class="phase-date">
                @if($phase->start_date && $phase->end_date)
                {{ $phase->start_date->format('d M') }} — {{ $phase->end_date->format('d M Y') }}
                @endif
            </span>
        </div>
    </div>
    <div class="card-body">
        <p class="phase-desc">{{ $phase->description }}</p>
        <div class="progress-bar mb-1">
            <div class="progress-fill" style="width: {{ $phase->progress }}%; background: {{ $phase->color }}"></div>
        </div>

        <!-- Step-by-step tasks -->
        <div class="step-list">
            @foreach($phase->tasks as $task)
            <div class="step-item {{ $task->completed ? 'completed' : '' }} {{ $task->isOverdue() ? 'overdue' : '' }}">
                <div class="step-number" style="border-color: {{ $phase->color }}; {{ $task->completed ? 'background:'.$phase->color.'; color:#fff;' : '' }}">
                    @if($task->completed) ✓ @else {{ $loop->iteration }} @endif
                </div>
                <div class="step-content">
                    <div class="step-title">
                        {{ $task->title }}
                        <span class="type-badge type-{{ $task->type }}">{{ $task->type === 'execution' ? '🔨 Eksekusi' : '📝 Input' }}</span>
                        <span class="priority-badge priority-{{ $task->priority }}">{{ ucfirst($task->priority) }}</span>
                    </div>
                    @if($task->description)<div class="step-desc">{{ $task->description }}</div>@endif
                    <div class="step-meta">
                        @if($task->due_date)
                        <span class="{{ $task->isOverdue() ? 'text-danger' : '' }}">📅 {{ $task->due_date->format('d M Y') }}</span>
                        @endif
                        @if($task->completed_at)<span class="text-success">✅ {{ \Carbon\Carbon::parse($task->completed_at)->format('d M Y') }}</span>@endif
                    </div>
                </div>
                <form action="{{ route('tasks.toggle', $task) }}" method="POST" class="step-action">
                    @csrf @method('PATCH')
                    <button type="submit" class="btn-toggle {{ $task->completed ? 'done' : '' }}" title="{{ $task->completed ? 'Tandai belum selesai' : 'Tandai selesai' }}">
                        {{ $task->completed ? '↩️' : '✓' }}
                    </button>
                </form>
            </div>
            @endforeach
        </div>
    </div>
</div>
@endforeach
@endsection
