<?php

namespace App\Http\Controllers;

use App\Models\CounselorWeeklySchedule;
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

        $hasSetup = CounselorWeeklySchedule::where('counselor_id', $user->id)
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

        $schedules = CounselorWeeklySchedule::where('counselor_id', $user->id)
            ->orderBy('day_of_week', 'asc')
            ->get()
            ->map(function ($schedule) {
                return [
                    'id' => $schedule->id,
                    'day_of_week' => $schedule->day_of_week,
                    'start_time' => Carbon::parse($schedule->start_time)->format('H:i'),
                    'end_time' => Carbon::parse($schedule->end_time)->format('H:i'),
                    'status' => $schedule->status,
                    'is_active' => $schedule->status === 'approved', // Backward compatibility for frontend
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
        $existingCount = CounselorWeeklySchedule::where('counselor_id', $user->id)->count();
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
            $created = CounselorWeeklySchedule::create([
                'counselor_id' => $user->id,
                'day_of_week' => $schedule['day_of_week'],
                'start_time' => $schedule['start_time'],
                'end_time' => $schedule['end_time'],
                'status' => 'pending', // Default status
            ]);

            $createdSchedules[] = $created;
        }

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
        $schedules = CounselorWeeklySchedule::with('counselor')
            ->where('status', 'pending')
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
                        // Map day number number to name manually if needed, or rely on frontend
                        $days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
                        return [
                            'id' => $s->id,
                            'day_of_week' => $s->day_of_week,
                            'day_name' => $days[$s->day_of_week] ?? '',
                            'start_time' => Carbon::parse($s->start_time)->format('H:i'),
                            'end_time' => Carbon::parse($s->end_time)->format('H:i'),
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
        CounselorWeeklySchedule::where('counselor_id', $counselorId)
            ->where('status', 'pending')
            ->update(['status' => 'approved']);

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
        $reason = $request->input('reason', '');

        CounselorWeeklySchedule::where('counselor_id', $counselorId)
            ->where('status', 'pending')
            ->update([
                'status' => 'rejected',
                'admin_notes' => $reason
            ]);
            
        // Alternatively, delete them if you want them to re-submit completely
        // For now, setting to rejected allows history tracking, but you might want to delete 
        // if user requirement implies "allow re-submit".
        // Use requirement: "if already setup... > 0". So if rejected, they verify "hasSetup" is true. 
        // If we want them to re-submit, we might need to delete. 
        // User asked: "hanya sekali, sehabis mengisi tidak akan muncul lagi". 
        // If rejected, does it appear again? 
        // Usually, if rejected, they should be able to try again. 
        // But let's stick to status update for now. If user wants delete on reject, we can change.
        // Actually, if status is 'rejected', hasSetup() will still return TRUE. 
        // Meaning user CANNOT resubmit. This might be a blocker.
        // Let's DELETE on reject so they can resubmit.
        
        CounselorWeeklySchedule::where('counselor_id', $counselorId)
            ->where('status', 'rejected') 
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
        $schedules = CounselorWeeklySchedule::where('counselor_id', $counselorId)
            ->where('status', 'approved')
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
        $counselorIds = CounselorWeeklySchedule::where('status', 'approved')
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
