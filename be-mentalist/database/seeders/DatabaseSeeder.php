<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call(RoleSeeder::class);

        // Get the created roles
        $adminRole = Role::where('name', 'admin')->first();
        $konselorRole = Role::where('name', 'konselor')->first();
        $userRole = Role::where('name', 'user')->first();

        // Create Admin User
        User::factory()->create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'role_id' => $adminRole->id,
        ]);

        // Create Konselor User
        User::factory()->create([
            'name' => 'Konselor User',
            'email' => 'konselor@example.com',
            'role_id' => $konselorRole->id,
        ]);

        // Create Regular User
        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'role_id' => $userRole->id,
        ]);
    }
}
