<?php

namespace App\Services;

use App\Repositories\UserRepositoryInterface;
use App\Repositories\RoleRepositoryInterface;
use App\Repositories\TokenRepositoryInterface;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Exception;
use App\Services\SupabaseService;

class GoogleAuthService
{
    protected UserRepositoryInterface $userRepository;
    protected RoleRepositoryInterface $roleRepository;
    protected TokenRepositoryInterface $tokenRepository;
    protected SupabaseService $supabaseService;

    public function __construct(
        UserRepositoryInterface $userRepository,
        RoleRepositoryInterface $roleRepository,
        TokenRepositoryInterface $tokenRepository,
        SupabaseService $supabaseService
    ) {
        $this->userRepository = $userRepository;
        $this->roleRepository = $roleRepository;
        $this->tokenRepository = $tokenRepository;
        $this->supabaseService = $supabaseService;
    }

    /**
     * Handle Google login with ID token.
     */
    public function handleGoogleLogin(string $idToken): array
    {
        $tokenInfo = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $idToken,
        ]);

        if (!$tokenInfo->successful()) {
            Log::error('Google ID token verification failed', [
                'status' => $tokenInfo->status(),
                'body' => $tokenInfo->body(),
                'token_prefix' => substr($idToken, 0, 10) . '...',
            ]);
            return [
                'success' => false,
                'message' => 'Invalid Google ID token.',
            ];
        }

        $payload = $tokenInfo->json();

        $allowedAudiences = collect(config('services.google.allowed_audiences', []))
            ->filter()
            ->all();
        $audience = $payload['aud']
            ?? $payload['audience']
            ?? $payload['azp']
            ?? null;

        if (
            !empty($allowedAudiences)
            && $audience
            && !in_array('*', $allowedAudiences, true)
            && !in_array($audience, $allowedAudiences, true)
        ) {
            Log::warning('Google login rejected due to audience mismatch', [
                'audience' => $audience,
                'allowed' => $allowedAudiences,
                'client_id' => config('services.google.client_id'),
            ]);
            return [
                'success' => false,
                'message' => 'Google token audience is not allowed.',
            ];
        }

        if (!isset($payload['email'])) {
            Log::warning('Google login rejected: email missing in payload', [
                'payload_keys' => array_keys($payload),
            ]);
            return [
                'success' => false,
                'message' => 'Google account does not provide an email address.',
            ];
        }

        $email = $payload['email'];
        $name = $payload['name'] ?? $email;
        $googleId = $payload['sub'] ?? null;
        $picture = $payload['picture'] ?? null;

        // Get default role
        $defaultRole = $this->roleRepository->findByName('user');
        if (!$defaultRole) {
            // Create default role if it doesn't exist
            $defaultRole = $this->createDefaultRole();
            if (!$defaultRole) {
                return [
                    'success' => false,
                    'message' => 'Failed to create default role.',
                ];
            }
        }

        // Find user by google_id or email
        $existingUser = $this->findOrCreateUser($googleId, $email, $name, $picture, $defaultRole['id']);

        if (!$existingUser) {
            return [
                'success' => false,
                'message' => 'Failed to create or update user.',
            ];
        }

        // Create token
        $token = $this->tokenRepository->createToken(
            $existingUser['id'],
            'google-auth'
        );

        return [
            'success' => true,
            'user' => [
                'id' => $existingUser['id'],
                'name' => $existingUser['name'],
                'email' => $existingUser['email'],
                'picture' => $existingUser['picture'],
                'role' => [
                    'id' => $existingUser['role_id'],
                    'name' => $existingUser['role_name'],
                    'display_name' => $existingUser['role_display_name'],
                ],
            ],
            'token' => $token,
            'token_type' => 'Bearer',
        ];
    }

    /**
     * Find existing user or create new one based on Google ID or email.
     */
    private function findOrCreateUser(string $googleId, string $email, string $name, ?string $picture, string $roleId): ?array
    {
        // First try to find user by google_id
        $user = $this->userRepository->findByEmail($email);
        if ($user && !empty($user['google_id'])) {
            // Update existing user with Google info
            $updateData = [
                'name' => $name,
                'picture' => $picture,
            ];
            
            if (empty($user['google_id'])) {
                $updateData['google_id'] = $googleId;
            }
            
            if (empty($user['role_id'])) {
                $updateData['role_id'] = $roleId;
            }
            
            $this->userRepository->update($user['id'], $updateData);
            
            return $this->userRepository->getUserWithRole($user['id']);
        }

        // If not found by google_id, try to find by email
        if ($user) {
            // Update existing user with Google info
            $updateData = [
                'name' => $name,
                'picture' => $picture,
                'google_id' => $googleId,
            ];
            
            if (empty($user['role_id'])) {
                $updateData['role_id'] = $roleId;
            }
            
            $this->userRepository->update($user['id'], $updateData);
            
            return $this->userRepository->getUserWithRole($user['id']);
        }

        // Create new user
        $userData = [
            'name' => $name,
            'email' => $email,
            'google_id' => $googleId,
            'picture' => $picture,
            'role_id' => $roleId,
            'password' => Str::random(32), // Random password for Google auth
        ];

        $newUser = $this->userRepository->create($userData);

        // Try to sync with Supabase
        try {
            $this->supabaseService->createUser([
                'id' => $newUser['id'],
                'email' => $newUser['email'],
                'name' => $newUser['name'],
            ]);
        } catch (Exception $e) {
            // Supabase sync is best-effort; ignore failures for local auth.
            Log::warning('Supabase sync failed: ' . $e->getMessage());
        }

        return $this->userRepository->getUserWithRole($newUser['id']);
    }

    /**
     * Create default 'user' role if it doesn't exist.
     */
    private function createDefaultRole(): ?array
    {
        // Check if role exists first
        $existingRole = $this->roleRepository->findByName('user');
        if ($existingRole) {
            return $existingRole;
        }

        // Create the role using raw SQL
        $roleId = \Illuminate\Support\Str::uuid();
        $now = \Illuminate\Support\Facades\Date::now();

        \Illuminate\Support\Facades\DB::insert("
            INSERT INTO roles (id, name, display_name, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?)
        ", [$roleId, 'user', 'User', $now, $now]);

        return $this->roleRepository->findById($roleId);
    }
}