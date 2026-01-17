<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use App\Services\BookingService;

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
}
