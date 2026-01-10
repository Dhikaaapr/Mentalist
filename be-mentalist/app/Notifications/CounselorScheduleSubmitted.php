<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class CounselorScheduleSubmitted extends Notification
{
    use Queueable;

    protected $schedule;

    /**
     * Create a new notification instance.
     */
    public function __construct($schedule)
    {
        $this->schedule = $schedule;
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
            'type' => 'approval_request',
            'title' => 'Approval Request by ' . $this->schedule->counselor->name,
            'subtitle' => 'for ' . $this->schedule->scheduled_date,
            'time' => $this->schedule->start_time . ' - ' . $this->schedule->end_time,
            'schedule_id' => $this->schedule->id,
            'counselor_name' => $this->schedule->counselor->name,
        ];
    }
}
