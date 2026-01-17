<?php

namespace App\Services;

use App\Models\Booking;
use App\Models\User;
use App\Models\Role;
use App\Notifications\NewBookingNotification;
use App\Notifications\BookingConfirmedNotification;

class BookingService
{
    /**
     * Create a new booking.
     */
    /**
     * Create a new booking.
     */
    public function createBooking(string $userId, array $data): array
    {
        return \Illuminate\Support\Facades\DB::transaction(function () use ($userId, $data) {
            // Check if counselor exists and is accepting patients
            $counselor = User::with(['role', 'counselorProfile'])->find($data['counselor_id']);

            if (!$counselor) {
                return [
                    'success' => false,
                    'message' => 'Konselor tidak ditemukan',
                ];
            }

            if ($counselor->role->name !== 'konselor') {
                return [
                    'success' => false,
                    'message' => 'User yang dipilih bukan konselor',
                ];
            }

            if (!$counselor->counselorProfile || !$counselor->counselorProfile->is_accepting_patients) {
                return [
                    'success' => false,
                    'message' => 'Konselor sedang tidak menerima pasien',
                ];
            }

            // Find and lock the slot
            $slot = \App\Models\AvailableTimeSlot::where('id', $data['slot_id'])
                ->lockForUpdate()
                ->first();

            if (!$slot) {
                return [
                    'success' => false,
                    'message' => 'Slot waktu tidak ditemukan',
                ];
            }

            if (!$slot->is_available) {
                return [
                    'success' => false,
                    'message' => 'Slot waktu ini sudah tidak tersedia',
                ];
            }

            // Mark slot as unavailable
            $slot->update(['is_available' => false]);

            // Get slot date and time for booking
            $slotDate = $slot->slot_date;
            $slotTime = $slot->slot_time;

            // Create booking with booking_date and booking_time
            $booking = Booking::create([
                'user_id' => $userId,
                'counselor_id' => $data['counselor_id'],
                'slot_id' => $slot->id,
                'booking_date' => $slotDate->format('Y-m-d'),
                'booking_time' => $slotTime,
                'notes' => $data['notes'] ?? null,
                'status' => 'pending',
            ]);

            // Notify counselor
            $counselor->notify(new NewBookingNotification($booking));

            return [
                'success' => true,
                'message' => 'Booking berhasil dibuat',
                'data' => $this->formatBooking($booking),
            ];
        });
    }

    public function getBookings(string $userId, ?string $status = null): array
    {
        $user = User::with('role')->find($userId);

        $query = Booking::with(['user', 'counselor']);

        // If user is konselor, show bookings where they are the counselor
        // If user is regular user, show their own bookings
        if ($user->role->name === 'konselor') {
            $query->where('counselor_id', $userId);
        } else {
            $query->where('user_id', $userId);
        }

        if ($status) {
            $query->where('status', $status);
        }

        $bookings = $query->orderBy('booking_date', 'desc')
            ->orderBy('booking_time', 'desc')
            ->get();

        return [
            'success' => true,
            'data' => $bookings->map(fn($b) => $this->formatBooking($b)),
        ];
    }

    /**
     * Get bookings for today.
     */
    public function getTodayBookings(string $userId): array
    {
        $user = User::with('role')->find($userId);
        $query = Booking::with(['user', 'counselor']);

        if ($user->role->name === 'konselor') {
            $query->where('counselor_id', $userId);
        } else {
            $query->where('user_id', $userId);
        }

        // Filter for today
        $bookings = $query->where('booking_date', now()->toDateString())
            ->orderBy('booking_time', 'asc')
            ->get();

        return [
            'success' => true,
            'data' => $bookings->map(fn($b) => $this->formatBooking($b)),
        ];
    }

    /**
     * Get booking detail.
     */
    public function getBooking(string $userId, string $bookingId): array
    {
        $booking = Booking::with(['user', 'counselor'])->find($bookingId);

        if (!$booking) {
            return [
                'success' => false,
                'message' => 'Booking tidak ditemukan',
            ];
        }

        // Check access
        if ($booking->user_id !== $userId && $booking->counselor_id !== $userId) {
            return [
                'success' => false,
                'message' => 'Anda tidak memiliki akses ke booking ini',
            ];
        }

        return [
            'success' => true,
            'data' => $this->formatBooking($booking),
        ];
    }

    /**
     * Cancel booking (by user).
     */
    public function cancelBooking(string $userId, string $bookingId): array
    {
        $booking = Booking::find($bookingId);

        if (!$booking) {
            return [
                'success' => false,
                'message' => 'Booking tidak ditemukan',
            ];
        }

        if ($booking->user_id !== $userId) {
            return [
                'success' => false,
                'message' => 'Anda tidak memiliki akses untuk membatalkan booking ini',
            ];
        }

        if (!in_array($booking->status, ['pending', 'confirmed'])) {
            return [
                'success' => false,
                'message' => 'Booking tidak dapat dibatalkan',
            ];
        }

        $booking->update(['status' => 'cancelled']);

        // Restore slot availability
        if ($booking->slot_id) {
            \App\Models\AvailableTimeSlot::where('id', $booking->slot_id)
                ->update(['is_available' => true]);
        }

        return [
            'success' => true,
            'message' => 'Booking berhasil dibatalkan',
            'data' => $this->formatBooking($booking->fresh()),
        ];
    }

    /**
     * Confirm booking (by counselor).
     */
    public function confirmBooking(string $counselorId, string $bookingId): array
    {
        $booking = Booking::find($bookingId);

        if (!$booking) {
            return [
                'success' => false,
                'message' => 'Booking tidak ditemukan',
            ];
        }

        if ($booking->counselor_id !== $counselorId) {
            return [
                'success' => false,
                'message' => 'Anda tidak memiliki akses ke booking ini',
            ];
        }

        if ($booking->status !== 'pending') {
            return [
                'success' => false,
                'message' => 'Hanya booking pending yang dapat dikonfirmasi',
            ];
        }

        $booking->update(['status' => 'confirmed']);

        // Notify user if exists
        if ($booking->user) {
            $booking->user->notify(new BookingConfirmedNotification($booking));
        }

        return [
            'success' => true,
            'message' => 'Booking berhasil dikonfirmasi',
            'data' => $this->formatBooking($booking->fresh()),
        ];
    }

    /**
     * Reject booking (by counselor).
     */
    public function rejectBooking(string $counselorId, string $bookingId, ?string $reason = null): array
    {
        $booking = Booking::find($bookingId);

        if (!$booking) {
            return [
                'success' => false,
                'message' => 'Booking tidak ditemukan',
            ];
        }

        if ($booking->counselor_id !== $counselorId) {
            return [
                'success' => false,
                'message' => 'Anda tidak memiliki akses ke booking ini',
            ];
        }

        if ($booking->status !== 'pending') {
            return [
                'success' => false,
                'message' => 'Hanya booking pending yang dapat ditolak',
            ];
        }

        $booking->update([
            'status' => 'rejected',
            'rejection_reason' => $reason,
        ]);

        // Restore slot availability
        if ($booking->slot_id) {
            \App\Models\AvailableTimeSlot::where('id', $booking->slot_id)
                ->update(['is_available' => true]);
        }

        return [
            'success' => true,
            'message' => 'Booking berhasil ditolak',
            'data' => $this->formatBooking($booking->fresh()),
        ];
    }

    /**
     * Reschedule booking (by user or counselor).
     */
    public function rescheduleBooking(string $userId, string $bookingId, string $newSchedule): array
    {
        $booking = Booking::find($bookingId);

        if (!$booking) {
            return [
                'success' => false,
                'message' => 'Booking tidak ditemukan',
            ];
        }

        // Allow both user and counselor to reschedule
        if ($booking->user_id !== $userId && $booking->counselor_id !== $userId) {
            return [
                'success' => false,
                'message' => 'Anda tidak memiliki akses ke booking ini',
            ];
        }

        if (!in_array($booking->status, ['pending', 'confirmed'])) {
            return [
                'success' => false,
                'message' => 'Booking tidak dapat dijadwalkan ulang',
            ];
        }

        // Parse new schedule
        $newDate = \Carbon\Carbon::parse($newSchedule);

        $booking->update([
            'booking_date' => $newDate->format('Y-m-d'),
            'booking_time' => $newDate->format('H:i:s'),
            'status' => 'pending', // Reset to pending after reschedule
        ]);

        return [
            'success' => true,
            'message' => 'Booking berhasil dijadwalkan ulang',
            'data' => $this->formatBooking($booking->fresh()),
        ];
    }

    /**
     * Complete booking (by counselor).
     */
    public function completeBooking(string $counselorId, string $bookingId): array
    {
        $booking = Booking::find($bookingId);

        if (!$booking) {
            return [
                'success' => false,
                'message' => 'Booking tidak ditemukan',
            ];
        }

        if ($booking->counselor_id !== $counselorId) {
            return [
                'success' => false,
                'message' => 'Anda tidak memiliki akses ke booking ini',
            ];
        }

        if ($booking->status !== 'confirmed') {
            return [
                'success' => false,
                'message' => 'Hanya booking yang sudah dikonfirmasi yang dapat diselesaikan',
            ];
        }

        $booking->update(['status' => 'completed']);

        return [
            'success' => true,
            'message' => 'Booking berhasil diselesaikan',
            'data' => $this->formatBooking($booking->fresh()),
        ];
    }

    /**
     * Format booking for response.
     */
    private function formatBooking(Booking $booking): array
    {
        $booking->load(['user', 'counselor']);

        // Construct scheduled_at from booking_date and booking_time
        $scheduledAt = null;
        if ($booking->booking_date && $booking->booking_time) {
            $date = $booking->booking_date instanceof \DateTime 
                ? $booking->booking_date->format('Y-m-d') 
                : $booking->booking_date;
            $scheduledAt = \Carbon\Carbon::parse($date . ' ' . $booking->booking_time)->toIso8601String();
        } elseif ($booking->scheduled_at) {
            $scheduledAt = $booking->scheduled_at->toIso8601String();
        }

        return [
            'id' => $booking->id,
            'scheduled_at' => $scheduledAt,
            'booking_date' => $booking->booking_date ? \Carbon\Carbon::parse($booking->booking_date)->format('Y-m-d') : null,
            'booking_time' => $booking->booking_time,
            'status' => $booking->status,
            'notes' => $booking->notes,
            'rejection_reason' => $booking->rejection_reason,
            'user' => [
                'id' => $booking->user->id,
                'name' => $booking->user->name,
                'email' => $booking->user->email,
                'picture' => $booking->user->picture,
            ],
            'counselor' => [
                'id' => $booking->counselor->id,
                'name' => $booking->counselor->name,
                'email' => $booking->counselor->email,
                'picture' => $booking->counselor->picture,
            ],
            'created_at' => $booking->created_at->toIso8601String(),
            'updated_at' => $booking->updated_at->toIso8601String(),
        ];
    }
}
