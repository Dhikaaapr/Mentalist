<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
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
        try {
            $request->validate([
                'id_token' => 'required|string',
            ]);

            // Verify the ID token with Google
            $idToken = $request->id_token;
            
            // Verify the token using Google's API
            $googleApiUrl = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=" . $idToken;
            $response = json_decode(file_get_contents($googleApiUrl), true);
            
            // Check if token is valid
            if (isset($response['error']) || !isset($response['email'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid Google ID token'
                ], 400);
            }

            // Extract user info from the token
            $email = $response['email'];
            $name = $response['name'] ?? $response['email'];
            $googleId = $response['sub'];
            $picture = $response['picture'] ?? null;

            // Check if user already exists in local database
            $user = User::where('email', $email)->first();
            
            if ($user) {
                // User already exists, update their info if needed
                $user->update([
                    'name' => $name,
                ]);
                
                // In a real implementation, you might also update the Supabase user
                // $this->supabaseService->updateUser($user->id, ['name' => $name]);
            } else {
                // Create new user in local database
                $user = User::create([
                    'name' => $name,
                    'email' => $email,
                    'password' => Hash::make(Str::random(16)), // Generate random password for Google users
                ]);
                
                // In a real implementation, you might also create the user in Supabase
                // $this->supabaseService->createUser([
                //     'id' => $user->id,
                //     'email' => $email,
                //     'name' => $name
                // ]);
            }
            
            // Generate token for API authentication
            $token = $user->createToken('GoogleAuthToken')->plainTextToken;
            
            return response()->json([
                'success' => true,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
                'token' => $token,
                'token_type' => 'Bearer'
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to process Google authentication: ' . $e->getMessage()
            ], 500);
        }
    }
}