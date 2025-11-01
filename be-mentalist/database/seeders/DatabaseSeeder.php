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
        $roles = collect([
            ['name' => 'admin', 'display_name' => 'Administrator'],
            ['name' => 'user', 'display_name' => 'User'],
        ])->mapWithKeys(function (array $role) {
            $model = Role::updateOrCreate(
                ['name' => $role['name']],
                ['display_name' => $role['display_name']]
            );

            return [$role['name'] => $model];
        });

        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'role_id' => $roles['user']->id,
        ]);
    }
}
