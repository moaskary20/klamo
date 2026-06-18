<?php

namespace Database\Seeders;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Database\Seeder;

class SpecialistUserSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => env('ADMIN_EMAIL', 'mo.askary@gmail.com')],
            [
                'name' => env('ADMIN_NAME', 'Mohamed Askary'),
                'password' => env('ADMIN_PASSWORD', 'newpassword'),
                'role' => UserRole::Specialist,
            ],
        );
    }
}
