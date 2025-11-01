<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Exception;
use App\Services\SupabaseService;

class GoogleAuthController extends Controller
{
    private SupabaseService $supabaseService;
    
    public function __construct(SupabaseService $supabaseService)
    {
        $this->supabaseService = $supabaseService;
    }

    /**
     * Handle Google login with ID token from Flutter app.
     * This method verifies the Google ID token and creates/updates the user in the local database,
     * which would be synchronized with Supabase in a production environment.
     */
    public function handleGoogleLogin(Request $request): JsonResponse
    {
        $request->validate([
            'id_token' => 'required|string',
        ]);

        $tokenInfo = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $request->id_token,
        ]);

        if (!$tokenInfo->successful()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid Google ID token.',
            ], 400);
        }

        $payload = $tokenInfo->json();

        $allowedAudiences = collect(config('services.google.allowed_audiences', []))
            ->filter()
            ->all();
        $audience = $payload['aud']
            ?? $payload['audience']
            ?? $payload['azp']
            ?? null;

        if (!empty($allowedAudiences)
            && $audience
            && !in_array('*', $allowedAudiences, true)
            && !in_array($audience, $allowedAudiences, true)
        ) {
            Log::warning('Google login rejected due to audience mismatch', [
                'audience' => $audience,
                'allowed' => $allowedAudiences,
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Google token audience is not allowed.',
            ], 400);
        }

        if (!isset($payload['email'])) {
            return response()->json([
                'success' => false,
                'message' => 'Google account does not provide an email address.',
            ], 400);
        }

        $email = $payload['email'];
        $name = $payload['name'] ?? $email;
        $googleId = $payload['sub'] ?? null;
        $picture = $payload['picture'] ?? null;

        $defaultRole = Role::firstOrCreate(
            ['name' => 'user'],
            ['display_name' => 'User']
        );

        $user = User::query()
            ->where('google_id', $googleId)
            ->orWhere('email', $email)
            ->first();

        if ($user) {
            $user->fill([
                'name' => $name,
                'picture' => $picture,
            ]);

            if (!$user->google_id) {
                $user->google_id = $googleId;
            }

            if (!$user->role_id) {
                $user->role_id = $defaultRole->id;
            }

            if ($user->isDirty()) {
                $user->save();
            }
        } else {
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'google_id' => $googleId,
                'picture' => $picture,
                'role_id' => $defaultRole->id,
                'password' => Hash::make(Str::random(32)),
            ]);

            try {
                $this->supabaseService->createUser([
                    'id' => $user->id,
                    'email' => $user->email,
                    'name' => $user->name,
                ]);
            } catch (Exception $e) {
                // Supabase sync is best-effort; ignore failures for local auth.
            }
        }

        $token = $user->createToken('google-auth')->plainTextToken;

        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'picture' => $user->picture,
                'role' => [
                    'id' => $user->role?->id,
                    'name' => $user->role?->name,
                    'display_name' => $user->role?->display_name,
                ],
            ],
            'token' => $token,
            'token_type' => 'Bearer',
        ]);
    }
}
