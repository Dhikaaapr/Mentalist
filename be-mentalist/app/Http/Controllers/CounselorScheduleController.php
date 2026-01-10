<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\CounselorSchedule;
use App\Models\CounselorWeeklySchedule;
use App\Models\User;
use App\Notifications\CounselorScheduleSubmitted;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Notification;

class CounselorScheduleController extends Controller
{
    /**
     * Store a new schedule request (counselor only)
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'scheduled_date' => 'required|date|after_or_equal:today',
            'start_time' => 'required',
            'end_time' => 'required|after:start_time',
        ]);

        $schedule = CounselorSchedule::create([
            'counselor_id' => $request->user()->id,
            'scheduled_date' => $request->scheduled_date,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
            'status' => 'pending',
        ]);

        // Notify Admins
        $admins = User::whereHas('role', function($q) {
            $q->where('name', 'admin');
        })->get();

        Notification::send($admins, new CounselorScheduleSubmitted($schedule));

        return response()->json([
            'success' => true,
            'message' => 'Jadwal berhasil diajukan dan sedang menunggu persetujuan admin.',
            'data' => $schedule->load('counselor'),
        ]);
    }

    /**
     * Get schedules for the logged in counselor
     */
    public function index(Request $request): JsonResponse
    {
        $schedules = CounselorSchedule::where('counselor_id', $request->user()->id)
            ->orderBy('scheduled_date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $schedules,
        ]);
    }

    /**
     * Get all pending schedules (admin only)
     */
    public function getPendingSchedules(Request $request): JsonResponse
    {
        $schedules = CounselorSchedule::with('counselor')
            ->where('status', 'pending')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $schedules,
        ]);
    }

    /**
     * Approve a schedule (admin only)
     */
    public function approve(Request $request, string $id): JsonResponse
    {
        $schedule = CounselorSchedule::findOrFail($id);
        $schedule->update([
            'status' => 'approved',
            'admin_notes' => $request->admin_notes
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Jadwal berhasil disetujui.',
            'data' => $schedule,
        ]);
    }

    /**
     * Reject a schedule (admin only)
     */
    public function reject(Request $request, string $id): JsonResponse
    {
        $schedule = CounselorSchedule::findOrFail($id);
        $schedule->update([
            'status' => 'rejected',
            'admin_notes' => $request->admin_notes
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Jadwal ditolak.',
            'data' => $schedule,
        ]);
    }

    /**
     * Store a new weekly schedule request (counselor only)
     */
    public function storeWeekly(Request $request): JsonResponse
    {
        $request->validate([
            'day_of_week' => 'required|integer|min:0|max:6',
            'start_time' => 'required',
            'end_time' => 'required|after:start_time',
        ]);

        // Check if there is already an approved or pending schedule for this day/time
        $existing = CounselorWeeklySchedule::where('counselor_id', $request->user()->id)
            ->where('day_of_week', $request->day_of_week)
            ->where(function ($query) use ($request) {
                $query->where(function ($q) use ($request) {
                    $q->where('start_time', '<=', $request->start_time)
                      ->where('end_time', '>', $request->start_time);
                })->orWhere(function ($q) use ($request) {
                    $q->where('start_time', '<', $request->end_time)
                      ->where('end_time', '>=', $request->end_time);
                });
            })
            ->whereIn('status', ['pending', 'approved'])
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah memiliki jadwal (pending/approved) di hari dan waktu yang bertabrakan.',
            ], 422);
        }

        $schedule = CounselorWeeklySchedule::create([
            'counselor_id' => $request->user()->id,
            'day_of_week' => $request->day_of_week,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
            'status' => 'pending',
        ]);

        // Notify Admins
        $admins = User::whereHas('role', function($q) {
            $q->where('name', 'admin');
        })->get();

        Notification::send($admins, new CounselorScheduleSubmitted($schedule));

        return response()->json([
            'success' => true,
            'message' => 'Jadwal mingguan berhasil diajukan.',
            'data' => $schedule->load('counselor'),
        ]);
    }

    /**
     * Get weekly schedules for the logged in counselor
     */
    public function indexWeekly(Request $request): JsonResponse
    {
        $schedules = CounselorWeeklySchedule::where('counselor_id', $request->user()->id)
            ->orderBy('day_of_week', 'asc')
            ->orderBy('start_time', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $schedules,
        ]);
    }

    /**
     * Get all pending weekly schedules (admin only)
     */
    public function getPendingWeeklySchedules(Request $request): JsonResponse
    {
        $schedules = CounselorWeeklySchedule::with('counselor')
            ->where('status', 'pending')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $schedules,
        ]);
    }

    /**
     * Approve a weekly schedule (admin only)
     */
    public function approveWeekly(Request $request, string $id): JsonResponse
    {
        $schedule = CounselorWeeklySchedule::findOrFail($id);
        $schedule->update([
            'status' => 'approved',
            'admin_notes' => $request->admin_notes
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Jadwal mingguan disetujui.',
            'data' => $schedule,
        ]);
    }

    /**
     * Reject a weekly schedule (admin only)
     */
    public function rejectWeekly(Request $request, string $id): JsonResponse
    {
        $schedule = CounselorWeeklySchedule::findOrFail($id);
        $schedule->update([
            'status' => 'rejected',
            'admin_notes' => $request->admin_notes
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Jadwal mingguan ditolak.',
            'data' => $schedule,
        ]);
    }
}
