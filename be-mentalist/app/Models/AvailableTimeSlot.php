<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class AvailableTimeSlot extends Model
{
    use HasUuids;

    protected $table = 'available_time_slots';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'counselor_id',
        'slot_date',
        'slot_time',
        'is_available',
    ];

    protected function casts(): array
    {
        return [
            'slot_date' => 'date',
            'is_available' => 'boolean',
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    /**
     * Get the counselor (user).
     */
    public function counselor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'counselor_id');
    }

    /**
     * Scope for available slots.
     */
    public function scopeAvailable($query)
    {
        return $query->where('is_available', true);
    }

    /**
     * Scope for upcoming slots.
     */
    public function scopeUpcoming($query)
    {
        return $query->where('slot_date', '>=', now()->toDateString());
    }
}
