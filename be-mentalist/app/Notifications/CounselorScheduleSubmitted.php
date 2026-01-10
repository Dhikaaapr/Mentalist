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
        $isWeekly = isset($this->schedule->day_of_week);
        $days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        
        return [
            'type' => 'approval_request',
            'is_weekly' => $isWeekly,
            'title' => 'Approval Request by ' . $this->schedule->counselor->name,
            'subtitle' => $isWeekly 
                ? 'Weekly schedule for ' . $days[$this->schedule->day_of_week]
                : 'One-time schedule for ' . $this->schedule->scheduled_date,
            'time' => $this->schedule->start_time . ' - ' . $this->schedule->end_time,
            'schedule_id' => $this->schedule->id,
            'counselor_name' => $this->schedule->counselor->name,
        ];
    }
}
