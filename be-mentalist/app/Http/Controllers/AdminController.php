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
}
