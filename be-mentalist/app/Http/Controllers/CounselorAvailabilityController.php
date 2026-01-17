<?php

namespace App\Http\Controllers;

use App\Models\CounselorWeeklyAvailability;
use App\Models\AvailableTimeSlot;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class CounselorAvailabilityController extends Controller
{
    /**
     * Check if counselor has already set up weekly availability.
     */
    public function hasWeeklySetup(): JsonResponse
    {
        $user = Auth::user();

        $hasSetup = CounselorWeeklyAvailability::where('counselor_id', $user->id)
            ->exists();

        return response()->json([
            'success' => true,
            'has_setup' => $hasSetup,
        ]);
    }

    /**
     * Get counselor's weekly availability.
     */
    public function getWeeklyAvailability(): JsonResponse
    {
        $user = Auth::user();

        $schedules = CounselorWeeklyAvailability::where('counselor_id', $user->id)
            ->orderBy('day_of_week', 'asc')
            ->get()
            ->map(function ($schedule) {
                return [
                    'id' => $schedule->id,
                    'day_of_week' => $schedule->day_of_week,
                    'day_name' => $schedule->day_name,
                    'start_time' => $schedule->start_time,
                    'end_time' => $schedule->end_time,
                    'is_active' => $schedule->is_active,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $schedules,
        ]);
    }

    /**
     * Save weekly availability (once per counselor).
     * Expects an array of day schedules.
     */
    public function saveWeeklyAvailability(Request $request): JsonResponse
    {
        $user = Auth::user();

        // Check if already setup
        $existingCount = CounselorWeeklyAvailability::where('counselor_id', $user->id)->count();
        if ($existingCount > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal mingguan sudah diatur sebelumnya.',
            ], 422);
        }

        $request->validate([
            'schedules' => 'required|array|min:1',
            'schedules.*.day_of_week' => 'required|integer|min:0|max:6',
            'schedules.*.start_time' => 'required|date_format:H:i',
            'schedules.*.end_time' => 'required|date_format:H:i|after:schedules.*.start_time',
        ]);

        $createdSchedules = [];

        foreach ($request->schedules as $schedule) {
            $created = CounselorWeeklyAvailability::create([
                'counselor_id' => $user->id,
                'day_of_week' => $schedule['day_of_week'],
                'start_time' => $schedule['start_time'],
                'end_time' => $schedule['end_time'],
                'is_active' => false, // Inactive until admin approves
            ]);

            $createdSchedules[] = $created;
        }

        // Notify admins (optional - can add notification later)
        
        return response()->json([
            'success' => true,
            'message' => 'Jadwal mingguan berhasil disimpan. Menunggu persetujuan admin.',
            'data' => $createdSchedules,
        ], 201);
    }

    /**
     * Admin: Get all pending (inactive) weekly schedules.
     */
    public function getPendingSchedules(): JsonResponse
    {
        $schedules = CounselorWeeklyAvailability::with('counselor')
            ->where('is_active', false)
            ->orderBy('created_at', 'asc')
            ->get()
            ->groupBy('counselor_id')
            ->map(function ($counselorSchedules) {
                $counselor = $counselorSchedules->first()->counselor;
                return [
                    'counselor_id' => $counselor->id,
                    'counselor_name' => $counselor->name,
                    'counselor_picture' => $counselor->picture,
                    'schedules' => $counselorSchedules->map(function ($s) {
                        return [
                            'id' => $s->id,
                            'day_of_week' => $s->day_of_week,
                            'day_name' => $s->day_name,
                            'start_time' => $s->start_time,
                            'end_time' => $s->end_time,
                        ];
                    })->values(),
                    'created_at' => $counselorSchedules->first()->created_at,
                ];
            })
            ->values();

        return response()->json([
            'success' => true,
            'data' => $schedules,
        ]);
    }

    /**
     * Admin: Approve all schedules for a counselor.
     * This will activate the schedules and generate time slots.
     */
    public function approveSchedules(Request $request, string $counselorId): JsonResponse
    {
        // Activate all schedules for this counselor
        CounselorWeeklyAvailability::where('counselor_id', $counselorId)
            ->where('is_active', false)
            ->update(['is_active' => true]);

        // Generate time slots for the next 4 weeks
        $this->generateTimeSlots($counselorId, 4);

        return response()->json([
            'success' => true,
            'message' => 'Jadwal counselor berhasil disetujui dan slot waktu telah dibuat.',
        ]);
    }

    /**
     * Admin: Reject all pending schedules for a counselor.
     */
    public function rejectSchedules(Request $request, string $counselorId): JsonResponse
    {
        CounselorWeeklyAvailability::where('counselor_id', $counselorId)
            ->where('is_active', false)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Jadwal counselor ditolak.',
        ]);
    }

    /**
     * Generate available time slots from weekly availability.
     */
    private function generateTimeSlots(string $counselorId, int $weeks = 4): void
    {
        $schedules = CounselorWeeklyAvailability::where('counselor_id', $counselorId)
            ->where('is_active', true)
            ->get();

        // Start from Today instead of Tomorrow
        $startDate = Carbon::now();
        $endDate = Carbon::now()->addWeeks($weeks);

        $currentDate = $startDate->copy();
        $now = Carbon::now();

        while ($currentDate->lte($endDate)) {
            $dayOfWeek = $currentDate->dayOfWeek; // 0 = Sunday, 6 = Saturday

            // Find schedules for this day of week
            $daySchedules = $schedules->where('day_of_week', $dayOfWeek);

            foreach ($daySchedules as $schedule) {
                // Parse start and end times
                $startTime = Carbon::parse($schedule->start_time);
                $endTime = Carbon::parse($schedule->end_time);

                // Generate hourly slots
                $slotTime = $startTime->copy();
                while ($slotTime->lt($endTime)) {
                    
                    // Specific check for Today: Don't generate past slots
                    $slotDateTime = Carbon::createFromFormat(
                        'Y-m-d H:i:s', 
                        $currentDate->format('Y-m-d') . ' ' . $slotTime->format('H:i:s')
                    );

                    if ($slotDateTime->gt($now)) {
                        // Create slot if it doesn't exist
                        AvailableTimeSlot::firstOrCreate([
                            'counselor_id' => $counselorId,
                            'slot_date' => $currentDate->toDateString(),
                            'slot_time' => $slotTime->format('H:i:s'),
                        ], [
                            'is_available' => true,
                        ]);
                    }

                    $slotTime->addHour();
                }
            }

            $currentDate->addDay();
        }
    }

    /**
     * Public: Get available slots for a counselor on a specific date.
     */
    public function getAvailableSlots(Request $request, string $counselorId): JsonResponse
    {
        $request->validate([
            'date' => 'required|date|after_or_equal:today',
        ]);

        $slots = AvailableTimeSlot::where('counselor_id', $counselorId)
            ->where('slot_date', $request->date)
            ->where('is_available', true)
            ->orderBy('slot_time', 'asc')
            ->get()
            ->map(function ($slot) {
                return [
                    'id' => $slot->id,
                    'time' => Carbon::parse($slot->slot_time)->format('H:i'),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $slots,
        ]);
    }

    /**
     * Public: Get counselors with approved schedules.
     */
    public function getApprovedCounselors(): JsonResponse
    {
        $counselorIds = CounselorWeeklyAvailability::where('is_active', true)
            ->distinct()
            ->pluck('counselor_id');

        $counselors = User::whereIn('id', $counselorIds)
            ->with('counselorProfile')
            ->get()
            ->map(function ($user) {
                return [
                    'id' => $user->id,
                    'name' => $user->name,
                    'picture' => $user->picture,
                    'specialization' => $user->counselorProfile?->specialization,
                    'bio' => $user->counselorProfile?->bio,
                    'is_online' => $user->is_online ?? false,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $counselors,
        ]);
    }
}
