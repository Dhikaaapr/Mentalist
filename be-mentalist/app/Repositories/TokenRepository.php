<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TokenRepository implements TokenRepositoryInterface
{
    /**
     * Create a new authentication token.
     */
    public function createToken(string $userId, string $name, array $abilities = ['*']): string
    {
        $token = $userId . '_' . Str::random(60);
        $hashedToken = hash('sha256', $token);
        $now = now();

        DB::insert("
            INSERT INTO personal_access_tokens (tokenable_type, tokenable_id, name, token, abilities, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ", [
            'App\Models\User',
            $userId,
            $name,
            $hashedToken,
            json_encode($abilities),
            $now,
            $now
        ]);

        return $token;
    }

    /**
     * Delete a token.
     */
    public function deleteToken(string $token): bool
    {
        $hashedToken = hash('sha256', $token);

        DB::delete("
            DELETE FROM personal_access_tokens 
            WHERE token = ?
        ", [$hashedToken]);

        return true;
    }

    /**
     * Validate if a token exists.
     */
    public function validateToken(string $token): bool
    {
        $hashedToken = hash('sha256', $token);

        $result = DB::select("
            SELECT id 
            FROM personal_access_tokens 
            WHERE token = ?
            LIMIT 1
        ", [$hashedToken]);

        return !empty($result);
    }
}