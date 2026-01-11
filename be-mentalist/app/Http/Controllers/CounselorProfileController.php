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
        $counselorRole = Role::where('name', 'konselor')->first();

        if (!$counselorRole) {
            return response()->json([
                'success' => false,
                'message' => 'Role konselor tidak ditemukan',
            ], 500);
        }

        $counselors = User::where('role_id', $counselorRole->id)
            ->whereHas('counselorProfile')
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
