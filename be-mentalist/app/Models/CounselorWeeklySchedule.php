<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CounselorWeeklySchedule extends Model
{
    use \Illuminate\Database\Eloquent\Factories\HasFactory;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'counselor_id',
        'day_of_week',
        'start_time',
        'end_time',
        'status',
        'admin_notes',
    ];

    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->{$model->getKeyName()})) {
                $model->{$model->getKeyName()} = \Illuminate\Support\Str::uuid()->toString();
            }
        });
    }

    public function counselor()
    {
        return $this->belongsTo(User::class, 'counselor_id');
    }
}
