<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Budget extends Model
{
    protected $fillable = ['wedding_id', 'category', 'budget', 'actual'];

    protected $casts = [
        'budget' => 'decimal:2',
        'actual' => 'decimal:2',
    ];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public function getRemainingAttribute(): float
    {
        return $this->budget - $this->actual;
    }

    public function getPercentageAttribute(): float
    {
        if ($this->budget <= 0) return 0;
        return round(($this->actual / $this->budget) * 100, 1);
    }
}
