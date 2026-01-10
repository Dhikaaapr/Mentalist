<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\CounselorSchedule;
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
}
