<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Task extends Model
{
    protected $fillable = [
        'wedding_id', 'phase_id', 'title', 'description', 'type',
        'category', 'priority', 'due_date', 'completed', 'completed_at',
        'order', 'notes',
    ];

    protected $casts = [
        'due_date' => 'date',
        'completed' => 'boolean',
        'completed_at' => 'datetime',
    ];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public function phase(): BelongsTo
    {
        return $this->belongsTo(Phase::class);
    }

    public function isExecution(): bool
    {
        return $this->type === 'execution';
    }

    public function isInput(): bool
    {
        return $this->type === 'input';
    }

    public function isOverdue(): bool
    {
        return !$this->completed && $this->due_date && $this->due_date->isPast();
    }

    public function getDaysRemainingAttribute(): ?int
    {
        if (!$this->due_date) return null;
        return (int) now()->diffInDays($this->due_date, false);
    }
}
