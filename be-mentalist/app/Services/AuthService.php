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
        ];
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
}