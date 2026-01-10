<?php

namespace App\Services;

use App\Models\User;
use App\Models\CounselorProfile;
use Illuminate\Support\Facades\Log;

class AdminService
{
    /**
     * Get all counselors with their profiles
     */
    public function getAllCounselors()
    {
        try {
            // Get all users with role 'konselor' and eager load their counselor_profile and role
            $counselors = User::with(['counselorProfile', 'role'])
                ->whereHas('role', function ($query) {
                    $query->where('name', 'konselor');
                })
                ->get();

            return [
                'success' => true,
                'counselors' => $counselors,
            ];
        } catch (\Exception $e) {
            Log::error('[ADMIN_SERVICE] Error getting counselors: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Gagal mengambil data konselor',
            ];
        }
    }

    /**
     * Toggle counselor active status
     */
    public function toggleCounselorStatus(string $userId)
    {
        try {
            // Find user and verify it's a counselor
            $user = User::with(['counselorProfile', 'role'])->find($userId);

            if (!$user) {
                return [
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                ];
            }

            if ($user->role->name !== 'konselor') {
                return [
                    'success' => false,
                    'message' => 'User bukan konselor',
                ];
            }

            if (!$user->counselorProfile) {
                return [
                    'success' => false,
                    'message' => 'Counselor profile tidak ditemukan',
                ];
            }

            // Toggle is_active status
            $currentStatus = $user->counselorProfile->is_active;
            $newStatus = !$currentStatus;
            
            $user->counselorProfile->update([
                'is_active' => $newStatus,
            ]);

            $statusText = $newStatus ? 'diaktifkan' : 'dinonaktifkan';

            Log::info("[ADMIN_SERVICE] Counselor {$user->name} status changed to: " . ($newStatus ? 'active' : 'inactive'));

            return [
                'success' => true,
                'message' => "Konselor berhasil $statusText",
                'counselor' => $user->load('counselorProfile'),
                'new_status' => $newStatus,
            ];
        } catch (\Exception $e) {
            Log::error('[ADMIN_SERVICE] Error toggling status: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Gagal mengubah status konselor',
            ];
        }
    }

    /**
     * Get all regular users (role 'user')
     */
    public function getAllUsers()
    {
        try {
            // Get all users with role 'user'
            $users = User::with(['role'])
                ->whereHas('role', function ($query) {
                    $query->where('name', 'user');
                })
                ->get();

            return [
                'success' => true,
                'users' => $users,
            ];
        } catch (\Exception $e) {
            Log::error('[ADMIN_SERVICE] Error getting users: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Gagal mengambil data user',
            ];
        }
    }

    /**
     * Toggle user active status
     */
    public function toggleUserStatus(string $userId)
    {
        try {
            // Find user and verify it's a regular user
            $user = User::with(['role'])->find($userId);

            if (!$user) {
                return [
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                ];
            }

            if ($user->role->name !== 'user') {
                return [
                    'success' => false,
                    'message' => 'Bukan user biasa',
                ];
            }

            // Toggle is_active status
            $currentStatus = $user->is_active;
            $newStatus = !$currentStatus;
            
            $user->update([
                'is_active' => $newStatus,
            ]);

            $statusText = $newStatus ? 'diaktifkan' : 'dinonaktifkan';

            Log::info("[ADMIN_SERVICE] User {$user->name} status changed to: " . ($newStatus ? 'active' : 'inactive'));

            return [
                'success' => true,
                'message' => "User berhasil $statusText",
                'user' => $user->fresh(),
                'new_status' => $newStatus,
            ];
        } catch (\Exception $e) {
            Log::error('[ADMIN_SERVICE] Error toggling user status: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Gagal mengubah status user',
            ];
        }
    }
}
