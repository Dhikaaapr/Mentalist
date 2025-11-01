<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<\App\Models\Role>
 */
class RoleFactory extends Factory
{
    public function definition(): array
    {
        $name = fake()->unique()->jobTitle();

        return [
            'name' => str($name)->slug('_'),
            'display_name' => $name,
        ];
    }
}
