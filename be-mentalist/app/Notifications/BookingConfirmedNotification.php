<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class BookingConfirmedNotification extends Notification
{
    use Queueable;

    protected $booking;

    public function __construct($booking)
    {
        $this->booking = $booking;
    }

    public function via($notifiable)
    {
        return ['database'];
    }

    public function toArray($notifiable)
    {
        return [
            'type' => 'booking_confirmed',
            'title' => 'Booking Confirmed! ✅',
            'subtitle' => 'Your session with ' . ($this->booking->counselor?->name ?? 'counselor') . ' has been confirmed.',
            'time' => $this->booking->scheduled_at->format('H:i'),
            'date' => $this->booking->scheduled_at->format('Y-m-d'),
            'booking_id' => $this->booking->id,
            'counselor_name' => $this->booking->counselor?->name ?? 'Counselor',
        ];
    }
}
