<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class NewBookingNotification extends Notification
{
    use Queueable;

    protected $booking;

    /**
     * Create a new notification instance.
     */
    public function __construct($booking)
    {
        $this->booking = $booking;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'type' => 'new_booking',
            'title' => 'New Session Booked',
            'subtitle' => 'A new session has been booked by ' . ($this->booking->user->name ?? 'a patient'),
            'time' => \Carbon\Carbon::parse($this->booking->booking_time)->format('H:i'),
            'date' => $this->booking->booking_date->format('Y-m-d'),
            'booking_id' => $this->booking->id,
            'patient_name' => $this->booking->user->name ?? 'Unknown',
        ];
    }
}
