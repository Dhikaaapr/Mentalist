<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Booking extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'consultation_bookings';

    /**
     * The primary key is stored as a UUID string.
     */
    public $incrementing = false;
    protected $keyType = 'string';

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'user_id',
        'counselor_id',
        'slot_id',
        'booking_date',
        'booking_time',
        'status',
        'notes',
    ];

    /**
     * The attributes that should be cast.
     */
    protected function casts(): array
    {
        return [
            'booking_date' => 'date',
        ];
    }

    /**
     * Get the scheduled_at attribute as valid Carbon instance.
     */
    public function getScheduledAtAttribute()
    {
        try {
            if ($this->booking_date && $this->booking_time) {
                // booking_date might be Carbon (cast) or string
                $dateStr = $this->booking_date instanceof \DateTimeInterface 
                    ? $this->booking_date->format('Y-m-d') 
                    : $this->booking_date;

                return \Carbon\Carbon::parse($dateStr . ' ' . $this->booking_time);
            }
        } catch (\Throwable $e) {
            return null;
        }
        return null;
    }

    /**
     * Get the user who made the booking.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Get the counselor for this booking.
     */
    public function counselor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'counselor_id');
    }
    
    /**
     * Get the time slot.
     */
    public function slot(): BelongsTo
    {
        return $this->belongsTo(AvailableTimeSlot::class, 'slot_id');
    }

    /**
     * Scope for pending bookings.
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope for confirmed bookings.
     */
    public function scopeConfirmed($query)
    {
        return $query->where('status', 'confirmed');
    }
}
