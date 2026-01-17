<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use App\Models\User;
use App\Models\Role;

class CounselorProfileController extends Controller
{
    /**
     * Get list of available counselors (public).
     * Returns only counselors who are accepting patients.
     */
    public function getAvailableCounselors(): JsonResponse
    {
        $counselorRoles = Role::whereIn('name', ['konselor', 'counselor'])->get();

        if ($counselorRoles->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Role konselor tidak ditemukan',
            ], 500);
        }

        $roleIds = $counselorRoles->pluck('id');

        $counselors = User::whereIn('role_id', $roleIds)
            ->whereHas('counselorProfile', function ($query) {
                // Hanya ambil counselor yang statusnya aktif (is_active = true)
                // Jika ingin filter yang sedang menerima pasien juga bisa tambah conditions di sini
                $query->where('is_active', true);
            })
            ->with('counselorProfile')
            ->get()
            ->map(function ($user) {
                return [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'picture' => $user->picture,
                    'bio' => $user->counselorProfile->bio,
                    'specialization' => $user->counselorProfile->specialization,
                    'is_online' => $user->counselorProfile->is_active ?? false,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $counselors,
        ]);
    }
}
