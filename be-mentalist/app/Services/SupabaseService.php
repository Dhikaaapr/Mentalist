<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Config;

class SupabaseService
{
    protected string $url;
    protected string $anonKey;
    
    public function __construct()
    {
        $this->url = Config::get('supabase.url');
        $this->anonKey = Config::get('supabase.anonymous_key');
    }
    
    /**
     * Verify a Supabase JWT token
     */
    public function verifyToken(string $token): ?array
    {
        // In a real implementation, you would verify the JWT token using Supabase's public key
        // For this example, I'll show how this could be done but it requires more complex JWT handling
        
        try {
            // This is a placeholder - in reality you would:
            // 1. Decode the JWT token without verification first to get the header
            // 2. Fetch the public key from Supabase JWKS endpoint
            // 3. Verify the token signature
            // 4. Return user data from the token
            
            return [
                'sub' => 'some-user-id',
                'email' => 'user@example.com',
                'name' => 'John Doe',
            ];
        } catch (\Exception $e) {
            return null;
        }
    }
    
    /**
     * Get a user from Supabase by ID
     */
    public function getUserById(string $userId): ?array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->anonKey,
            'Content-Type' => 'application/json',
        ])->get($this->url . '/rest/v1/users', [
            'id' => 'eq.' . $userId,
        ]);
        
        if ($response->successful()) {
            $users = $response->json();
            return $users[0] ?? null;
        }
        
        return null;
    }
    
    /**
     * Create a user in Supabase
     */
    public function createUser(array $userData): ?array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->anonKey,
            'Content-Type' => 'application/json',
            'Prefer' => 'return=representation',
        ])->post($this->url . '/rest/v1/users', $userData);
        
        if ($response->successful()) {
            return $response->json();
        }
        
        return null;
    }
}