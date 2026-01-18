<?php

namespace App\Http\Controllers;

use App\Services\AdminService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AdminController extends Controller
{
    protected AdminService $adminService;

    public function __construct(AdminService $adminService)
    {
        $this->adminService = $adminService;
    }

    /**
     * Get all counselors with their profiles
     */
    public function getAllCounselors(Request $request): JsonResponse
    {
        $result = $this->adminService->getAllCounselors();

        $status = $result['success'] ? 200 : 400;

        return response()->json($result, $status);
    }

    /**
     * Toggle counselor active status
     */
    public function toggleCounselorStatus(Request $request, string $id): JsonResponse
    {
        $result = $this->adminService->toggleCounselorStatus($id);

        $status = $result['success'] ? 200 : 400;

        return response()->json($result, $status);
    }

    /**
     * Get all regular users
     */
    public function getAllUsers(Request $request): JsonResponse
    {
        $result = $this->adminService->getAllUsers();

        $status = $result['success'] ? 200 : 400;

        return response()->json($result, $status);
    }

    /**
     * Toggle user active status
     */
    public function toggleUserStatus(Request $request, string $id): JsonResponse
    {
        $result = $this->adminService->toggleUserStatus($id);

        $status = $result['success'] ? 200 : 400;

        return response()->json($result, $status);
    }

    /**
     * Get report statistics
     */
    public function getReportStats(Request $request): JsonResponse
    {
        $result = $this->adminService->getReportStats();

        $status = $result['success'] ? 200 : 400;

        return response()->json($result, $status);
    }

    /**
     * Get admin notifications
     */
    public function getNotifications(Request $request): JsonResponse
    {
        $notifications = $request->user()->notifications;

        return response()->json([
            'success' => true,
            'data' => $notifications,
        ]);
    }

    /**
     * Mark notification as read
     */
    public function markAsRead(Request $request, string $id): JsonResponse
    {
        $notification = $request->user()->notifications()->findOrFail($id);
        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read',
        ]);
    }

    /**
     * Get all bookings (Therapy Sessions)
     */
    public function getAllBookings(Request $request): JsonResponse
    {
        $result = $this->adminService->getAllBookings();

        $status = $result['success'] ? 200 : 400;

        return response()->json($result, $status);
    }
}
