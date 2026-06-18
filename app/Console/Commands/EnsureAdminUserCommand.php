<?php

namespace App\Console\Commands;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Console\Command;

class EnsureAdminUserCommand extends Command
{
    protected $signature = 'klamo:ensure-admin
                            {--email= : Admin email address}
                            {--password= : Admin password}
                            {--name= : Display name}';

    protected $description = 'Create or update the specialist admin user for the Filament panel';

    public function handle(): int
    {
        $email = $this->option('email') ?: env('ADMIN_EMAIL');
        $password = $this->option('password') ?: env('ADMIN_PASSWORD');
        $name = $this->option('name') ?: env('ADMIN_NAME', 'Admin');

        if (! $email || ! $password) {
            $this->error('Provide --email and --password, or set ADMIN_EMAIL and ADMIN_PASSWORD in .env');

            return self::FAILURE;
        }

        $user = User::updateOrCreate(
            ['email' => $email],
            [
                'name' => $name,
                'password' => $password,
                'role' => UserRole::Specialist,
            ],
        );

        $this->info("Specialist admin ready: {$user->email} (id: {$user->id})");
        $this->line('Login at: '.rtrim((string) config('app.url'), '/').'/admin');

        return self::SUCCESS;
    }
}
