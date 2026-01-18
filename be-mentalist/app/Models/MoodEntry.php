<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MoodEntry extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'user_id',
        'mood_label',
        'entry_date',
    ];

    protected $casts = [
        'entry_date' => 'date',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
