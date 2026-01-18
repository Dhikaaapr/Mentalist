<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\User;
use App\Models\CounselorProfile;
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
        User::updateOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'Admin User',
                'role_id' => $adminRole->id,
                'password' => 'password123',
            ]
        );

        // Create Konselor User
        $konselor = User::updateOrCreate(
            ['email' => 'konselor@example.com'],
            [
                'name' => 'Konselor User',
                'role_id' => $konselorRole->id,
                'password' => 'password123',
            ]
        );

        // Create counselor profile for konselor user
        CounselorProfile::updateOrCreate(
            ['user_id' => $konselor->id],
            [
                'is_accepting_patients' => true,
                'is_active' => true,
                'bio' => 'Konselor profesional dengan pengalaman 5 tahun di bidang kesehatan mental.',
                'specialization' => 'Anxiety & Depression',
            ]
        );

        // Create Regular User
        User::updateOrCreate(
            ['email' => 'test@example.com'],
            [
                'name' => 'Test User',
                'role_id' => $userRole->id,
                'password' => 'password123',
            ]
        );

        // Create Google User (Konselor role)
        $googleKonselor = User::updateOrCreate(
            ['email' => 'andhika.saputra@students.paramadina.ac.id'],
            [
                'name' => 'Andhika Presha Saputra',
                'picture' => 'https://via.placeholder.com/200x200.png/007755?text=AS',
                'role_id' => $konselorRole->id,
                'google_id' => '112233445566778899001', // Sample Google ID
                'password' => null, // No password since using Google login
                'email_verified_at' => now(),
            ]
        );

        // Create counselor profile for Google konselor
        CounselorProfile::updateOrCreate(
            ['user_id' => $googleKonselor->id],
            [
                'is_accepting_patients' => true,
                'is_active' => true,
                'bio' => 'Psikolog klinis yang berfokus pada terapi kognitif behavioral.',
                'specialization' => 'CBT & Mindfulness',
            ]
        );

        // Create Dummy Bookings for Reports
        $users = User::whereHas('role', function ($q) {
            $q->where('name', 'user');
        })->get();
        $counselors = User::whereHas('role', function ($q) {
            $q->where('name', 'konselor');
        })->get();

        if ($users->isNotEmpty() && $counselors->isNotEmpty()) {
            foreach ($counselors as $index => $counselor) {
                // Create 3-5 bookings for each counselor in the last 30 days
                for ($i = 1; $i <= (3 + $index); $i++) {
                    \App\Models\Booking::create([
                        'user_id' => $users->random()->id,
                        'counselor_id' => $counselor->id,
                        'scheduled_at' => now()->subDays(rand(1, 25)),
                        'status' => 'confirmed',
                        'notes' => 'Sesi terapi dummy untuk laporan.',
                    ]);
                }
            }
        }

        // Create Dummy Schedules & Notifications
        $admin = User::whereHas('role', function ($q) {
            $q->where('name', 'admin');
        })->first();
        if ($admin && $counselors->isNotEmpty()) {
            foreach ($counselors as $counselor) {
                $schedule = \App\Models\CounselorSchedule::create([
                    'counselor_id' => $counselor->id,
                    'scheduled_date' => now()->addDays(rand(1, 5))->format('Y-m-d'),
                    'start_time' => '09:00:00',
                    'end_time' => '11:00:00',
                    'status' => 'pending',
                ]);

                // Manually trigger notification for admin
                $admin->notify(new \App\Notifications\CounselorScheduleSubmitted($schedule));
            }
        }
    }
}
