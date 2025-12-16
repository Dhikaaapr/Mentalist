<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

class RoleRepository implements RoleRepositoryInterface
{
    /**
     * Find role by name.
     */
    public function findByName(string $name): ?array
    {
        $roles = DB::select("
            SELECT id, name, display_name
            FROM roles
            WHERE name = ?
            LIMIT 1
        ", [$name]);

        return !empty($roles) ? (array) $roles[0] : null;
    }

    /**
     * Find role by ID.
     */
    public function findById(string $id): ?array
    {
        $roles = DB::select("
            SELECT id, name, display_name
            FROM roles
            WHERE id = ?
            LIMIT 1
        ", [$id]);

        return !empty($roles) ? (array) $roles[0] : null;
    }
}