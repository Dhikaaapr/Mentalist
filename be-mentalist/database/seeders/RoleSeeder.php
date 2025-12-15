<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create Admin role
        Role::firstOrCreate([
            'name' => 'admin'
        ], [
            'id' => Str::uuid(),
            'display_name' => 'Administrator',
        ]);

        // Create Konselor role
        Role::firstOrCreate([
            'name' => 'konselor'
        ], [
            'id' => Str::uuid(),
            'display_name' => 'Konselor',
        ]);

        // Create User role
        Role::firstOrCreate([
            'name' => 'user'
        ], [
            'id' => Str::uuid(),
            'display_name' => 'User',
        ]);
    }
}