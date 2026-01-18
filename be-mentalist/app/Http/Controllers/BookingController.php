<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use App\Services\BookingService;
use App\Models\Booking;

class BookingController extends Controller
{
    protected BookingService $bookingService;

    public function __construct(BookingService $bookingService)
    {
        $this->bookingService = $bookingService;
    }

    /**
     * Create a new booking.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'counselor_id' => 'required|uuid',
            'slot_id' => 'required|uuid|exists:available_time_slots,id',
            'notes' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->bookingService->createBooking(
            $request->user()->id,
            $request->all()
        );

        return response()->json($result, $result['success'] ? 201 : 400);
    }

    public function index(Request $request): JsonResponse
    {
        $status = $request->query('status');

        $result = $this->bookingService->getBookings(
            $request->user()->id,
            $status
        );

        return response()->json($result);
    }

    /**
     * Get bookings for today.
     */
    public function today(Request $request): JsonResponse
    {
        $result = $this->bookingService->getTodayBookings(
            $request->user()->id
        );

        return response()->json($result);
    }

    /**
     * Get booking detail.
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $result = $this->bookingService->getBooking(
            $request->user()->id,
            $id
        );

        return response()->json($result, $result['success'] ? 200 : 404);
    }

    /**
     * Cancel booking (user).
     */
    public function cancel(Request $request, string $id): JsonResponse
    {
        $result = $this->bookingService->cancelBooking(
            $request->user()->id,
            $id
        );

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Confirm booking (counselor).
     */
    public function confirm(Request $request, string $id): JsonResponse
    {
        $result = $this->bookingService->confirmBooking(
            $request->user()->id,
            $id
        );

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Reject booking (counselor).
     */
    public function reject(Request $request, string $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->bookingService->rejectBooking(
            $request->user()->id,
            $id,
            $request->input('reason')
        );

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Reschedule booking (counselor).
     */
    public function reschedule(Request $request, string $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'scheduled_at' => 'required|date|after:now',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->bookingService->rescheduleBooking(
            $request->user()->id,
            $id,
            $request->input('scheduled_at')
        );

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Complete booking (counselor).
     */
    public function complete(Request $request, string $id): JsonResponse
    {
        $result = $this->bookingService->completeBooking(
            $request->user()->id,
            $id
        );

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Get dashboard statistics for counselor.
     */
    public function dashboardStats(Request $request): JsonResponse
    {
        $result = $this->bookingService->getDashboardStats(
            $request->user()->id
        );

        return response()->json($result);
    }

    /**
     * Get active clients list.
     * Clients who have at least one booking (any status) with this counselor.
     */
    public function getActiveClients(Request $request): JsonResponse
    {
        $counselorId = $request->user()->id;

        // Get unique users from bookings
        $clients = Booking::where('counselor_id', $counselorId)
            ->with('user')
            ->select('user_id', \Illuminate\Support\Facades\DB::raw('MAX(booking_date) as last_booking'))
            ->groupBy('user_id')
            ->get()
            ->map(function ($booking) use ($counselorId) {
                $user = $booking->user;
                if (!$user) return null;

                // Calculate total sessions (completed)
                $totalSessions = Booking::where('counselor_id', $counselorId)
                    ->where('user_id', $booking->user_id)
                    ->where('status', 'completed')
                    ->count();
                
                // Determine status (active if has future or recent booking)
                $hasActiveBooking = Booking::where('counselor_id', $counselorId)
                    ->where('user_id', $booking->user_id)
                    ->whereIn('status', ['pending', 'confirmed'])
                    ->exists();

                return [
                    'id' => $booking->user_id,
                    'name' => $user->name ?? 'Unknown',
                    'picture' => $user->picture,
                    'last_booking_date' => $booking->last_booking,
                    'total_sessions' => $totalSessions,
                    'status' => $hasActiveBooking ? 'Active' : 'Past',
                    // Dummy progress calculation (e.g. max 12 sessions)
                    'progress' => ($totalSessions % 12), 
                    'target_sessions' => 12
                ];
            })
            ->filter()
            ->values();

        return response()->json(['success' => true, 'data' => $clients]);
    }

    /**
     * Get counseling notes list (completed sessions).
     */
    public function getCounselingNotesList(Request $request): JsonResponse
    {
        $counselorId = $request->user()->id;

        // Get unique users who have COMPLETED sessions to show in the list
        // Or should we show list of NOTES? The UI shows list of PEOPLE.
        // Assuming "Counseling Notes" page lists CLIENTS to view their notes.
        $notes = Booking::where('counselor_id', $counselorId)
            ->where('status', 'completed')
            ->with('user')
            ->orderBy('booking_date', 'desc')
            ->get()
            ->unique('user_id')
            ->map(function ($booking) {
                return [
                    'user_id' => $booking->user_id,
                    'name' => $booking->user->name ?? 'Unknown',
                    'picture' => $booking->user->picture,
                    'last_note_date' => $booking->booking_date, // Last session date
                ];
            })
            ->values();

        return response()->json(['success' => true, 'data' => $notes]);
    }
}
