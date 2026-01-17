<?php

namespace App\Services;

use App\Repositories\UserRepositoryInterface;
use App\Repositories\TokenRepositoryInterface;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthService
{
    protected UserRepositoryInterface $userRepository;
    protected TokenRepositoryInterface $tokenRepository;

    public function __construct(
        UserRepositoryInterface $userRepository,
        TokenRepositoryInterface $tokenRepository
    ) {
        $this->userRepository = $userRepository;
        $this->tokenRepository = $tokenRepository;
    }

    /**
     * Authenticate user with email and password.
     */
    public function authenticate(string $email, string $password): array
    {
        $user = $this->userRepository->getUserByEmailWithRole($email);

        if (!$user) {
            return [
                'success' => false,
                'message' => 'Email atau password salah'
            ];
        }

        // Check if user has a password set (especially for Google users)
        if (empty($user['password'])) {
            return [
                'success' => false,
                'message' => 'Akun tidak memiliki password. Gunakan login Google.'
            ];
        }

        if (!Hash::check($password, $user['password'])) {
            return [
                'success' => false,
                'message' => 'Email atau password salah'
            ];
        }

        // Check if user is a counselor and if their account is active
        if ($user['role_name'] === 'konselor') {
            $userModel = \App\Models\User::with('counselorProfile')->find($user['id']);
            $counselorProfile = $userModel->counselorProfile;
            
            if ($counselorProfile && !$counselorProfile->is_active) {
                return [
                    'success' => false,
                    'message' => 'Akun konselor tidak aktif. Hubungi administrator.'
                ];
            }
        }

        // Check if user is a regular user and if their account is active
        if ($user['role_name'] === 'user') {
            $userModel = \App\Models\User::find($user['id']);
            if (!$userModel->is_active) {
                return [
                    'success' => false,
                    'message' => 'Akun Anda telah dinonaktifkan. Hubungi administrator.'
                ];
            }
        }

        // Create token
        $token = $this->tokenRepository->createToken(
            $user['id'],
            'login-token'
        );

        return [
            'success' => true,
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'picture' => $user['picture'],
                'role' => [
                    'id' => $user['role_id'],
                    'name' => $user['role_name'],
                    'display_name' => $user['role_display_name'],
                ],
            ],
            'token' => $token,
            'token_type' => 'Bearer',
        ];
    }

    /**
     * Register a new user.
     */
    public function register(array $userData): array
    {
        // Check if user already exists
        $existingUser = $this->userRepository->findByEmail($userData['email']);
        if ($existingUser) {
            return [
                'success' => false,
                'message' => 'Email sudah terdaftar'
            ];
        }

        // Validate required fields
        if (empty($userData['name']) || empty($userData['email']) || empty($userData['password'])) {
            return [
                'success' => false,
                'message' => 'Nama, email, dan password harus diisi'
            ];
        }

        // Validate password confirmation if provided
        if (isset($userData['password_confirmation'])) {
            if ($userData['password'] !== $userData['password_confirmation']) {
                return [
                    'success' => false,
                    'message' => 'Password dan konfirmasi password tidak sama'
                ];
            }
        }

        // Create the user
        $user = $this->userRepository->create([
            'name' => $userData['name'],
            'email' => $userData['email'],
            'password' => $userData['password'],
            'role_id' => $userData['role_id'],
            'picture' => $userData['picture'] ?? null,
        ]);

        // Create token
        $token = $this->tokenRepository->createToken(
            $user['id'],
            'register-token'
        );

        // Get full user data with role
        $userWithRole = $this->userRepository->getUserWithRole($user['id']);

        return [
            'success' => true,
            'message' => 'Registrasi berhasil',
            'user' => [
                'id' => $userWithRole['id'],
                'name' => $userWithRole['name'],
                'email' => $userWithRole['email'],
                'picture' => $userWithRole['picture'],
                'role' => [
                    'id' => $userWithRole['role_id'],
                    'name' => $userWithRole['role_name'],
                    'display_name' => $userWithRole['role_display_name'],
                ],
            ],
            'token' => $token,
            'token_type' => 'Bearer',
        ];
    }

    /**
     * Get authenticated user profile.
     * Includes counselor_profile if user is a konselor.
     */
    public function getProfile(string $userId): array
    {
        $user = $this->userRepository->getUserWithRole($userId);

        if (!$user) {
            return [
                'success' => false,
                'message' => 'User tidak ditemukan'
            ];
        }

        $response = [
            'success' => true,
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'picture' => $user['picture'],
                'role' => [
                    'id' => $user['role_id'],
                    'name' => $user['role_name'],
                    'display_name' => $user['role_display_name'],
                ],
            ],
        ];

        // Include counselor_profile if user is a konselor
        if ($user['role_name'] === 'konselor') {
            $userModel = \App\Models\User::with('counselorProfile')->find($userId);
            $counselorProfile = $userModel->counselorProfile;
            
            if (!$counselorProfile) {
                // Create counselor profile if doesn't exist
                $counselorProfile = \App\Models\CounselorProfile::create([
                    'user_id' => $userId,
                    'is_accepting_patients' => false,
                ]);
            }

            $response['user']['counselor_profile'] = [
                'id' => $counselorProfile->id,
                'is_accepting_patients' => $counselorProfile->is_accepting_patients,
                'bio' => $counselorProfile->bio,
                'specialization' => $counselorProfile->specialization,
            ];
        }

        return $response;
    }

    /**
     * Update user profile.
     * For konselor, also updates counselor_profile fields.
     */
    public function updateProfile(string $userId, array $data): array
    {
        $user = $this->userRepository->getUserWithRole($userId);

        if (!$user) {
            return [
                'success' => false,
                'message' => 'User tidak ditemukan'
            ];
        }

        // Update basic user fields
        $userModel = \App\Models\User::find($userId);
        
        $userUpdates = [];
        if (isset($data['name'])) {
            $userUpdates['name'] = $data['name'];
        }
        if (isset($data['picture'])) {
            $userUpdates['picture'] = $data['picture'];
        }
        
        if (!empty($userUpdates)) {
            $userModel->update($userUpdates);
        }

        // Update counselor profile if user is konselor
        if ($user['role_name'] === 'konselor') {
            $counselorProfile = $userModel->counselorProfile;
            
            if (!$counselorProfile) {
                $counselorProfile = \App\Models\CounselorProfile::create([
                    'user_id' => $userId,
                    'is_accepting_patients' => false,
                ]);
            }

            $counselorUpdates = [];
            if (isset($data['bio'])) {
                $counselorUpdates['bio'] = $data['bio'];
            }
            if (isset($data['specialization'])) {
                $counselorUpdates['specialization'] = $data['specialization'];
            }
            if (isset($data['is_accepting_patients'])) {
                // Handle string "true"/"false" from form-data
                $value = $data['is_accepting_patients'];
                if (is_string($value)) {
                    $counselorUpdates['is_accepting_patients'] = filter_var($value, FILTER_VALIDATE_BOOLEAN);
                } else {
                    $counselorUpdates['is_accepting_patients'] = (bool) $value;
                }
            }

            if (!empty($counselorUpdates)) {
                $counselorProfile->update($counselorUpdates);
            }
        }

        // Return updated profile
        return $this->getProfile($userId);
    }

    /**
     * Logout user by deleting their token.
     */
    public function logout(string $token): array
    {
        $this->tokenRepository->deleteToken($token);

        return [
            'success' => true,
            'message' => 'Logout berhasil'
        ];
    }

    /**
     * Get user notifications.
     */
    public function getNotifications(string $userId): array
    {
        $user = \App\Models\User::find($userId);

        if (!$user) {
            return ['success' => false, 'message' => 'User not found'];
        }

        return [
            'success' => true,
            'data' => $user->notifications
        ];
    }
}