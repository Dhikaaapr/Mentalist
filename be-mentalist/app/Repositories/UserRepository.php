<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserRepository implements UserRepositoryInterface
{
    /**
     * Find user by email with role information.
     */
    public function findByEmail(string $email): ?array
    {
        $users = DB::select("
            SELECT
                u.id,
                u.name,
                u.email,
                u.picture,
                u.password,
                u.role_id,
                u.deleted_at,
                r.name as role_name,
                r.display_name as role_display_name
            FROM users u
            LEFT JOIN roles r ON u.role_id = r.id
            WHERE u.email = ?
        ", [$email]);

        return !empty($users) ? (array) $users[0] : null;
    }

    /**
     * Find user by ID with role information.
     */
    public function findById(string $id): ?array
    {
        $users = DB::select("
            SELECT 
                u.id,
                u.name,
                u.email,
                u.picture,
                u.role_id,
                r.name as role_name,
                r.display_name as role_display_name
            FROM users u
            LEFT JOIN roles r ON u.role_id = r.id
            WHERE u.id = ?
        ", [$id]);

        return !empty($users) ? (array) $users[0] : null;
    }

    /**
     * Create a new user.
     */
    public function create(array $data): array
    {
        $userId = $data['id'] ?? Str::uuid();
        $now = now();

        // Hash password if provided
        $hashedPassword = isset($data['password']) ? Hash::make($data['password']) : null;

        // Insert user
        DB::insert("
            INSERT INTO users (id, name, email, password, picture, role_id, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ", [
            $userId,
            $data['name'],
            $data['email'],
            $hashedPassword,
            $data['picture'] ?? null,
            $data['role_id'],
            $now,
            $now
        ]);

        // Return the created user data
        return [
            'id' => $userId,
            'name' => $data['name'],
            'email' => $data['email'],
            'picture' => $data['picture'] ?? null,
            'role_id' => $data['role_id'],
        ];
    }

    /**
     * Update user data.
     */
    public function update(string $id, array $data): bool
    {
        $setParts = [];
        $bindings = [];

        foreach ($data as $key => $value) {
            if ($key !== 'id') {
                $setParts[] = "$key = ?";
                $bindings[] = $value;
            }
        }

        if (empty($setParts)) {
            return true; // Nothing to update
        }

        $bindings[] = $id;

        $query = "UPDATE users SET " . implode(', ', $setParts) . " WHERE id = ?";

        DB::update($query, $bindings);

        return true;
    }

    /**
     * Delete user (soft delete).
     */
    public function delete(string $id): bool
    {
        DB::update("
            UPDATE users 
            SET deleted_at = NOW() 
            WHERE id = ?
        ", [$id]);

        return true;
    }

    /**
     * Get user with role information by ID.
     */
    public function getUserWithRole(string $id): ?array
    {
        $users = DB::select("
            SELECT
                u.id,
                u.name,
                u.email,
                u.picture,
                u.password,
                u.role_id,
                r.name as role_name,
                r.display_name as role_display_name
            FROM users u
            LEFT JOIN roles r ON u.role_id = r.id
            WHERE u.id = ?
        ", [$id]);

        return !empty($users) ? (array) $users[0] : null;
    }

    /**
     * Get user with role information by email.
     */
    public function getUserByEmailWithRole(string $email): ?array
    {
        $users = DB::select("
            SELECT
                u.id,
                u.name,
                u.email,
                u.picture,
                u.password,
                u.role_id,
                r.name as role_name,
                r.display_name as role_display_name
            FROM users u
            LEFT JOIN roles r ON u.role_id = r.id
            WHERE u.email = ? AND u.deleted_at IS NULL
        ", [$email]);

        return !empty($users) ? (array) $users[0] : null;
    }
}