<?php

namespace Database\Seeders;

use App\Models\World;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\File;

class WorldSeeder extends Seeder
{
    public function run(): void
    {
        $worlds = [
            ['name' => 'عالم الحيوانات', 'sort_order' => 1, 'icon' => 'worlds/icons/animals.jpg'],
            ['name' => 'عالم الفاكهة', 'sort_order' => 2, 'icon' => 'worlds/icons/fruits.jpg'],
            ['name' => 'عالم الخضروات', 'sort_order' => 3, 'icon' => 'worlds/icons/vegetables.jpg'],
            ['name' => 'عالم الملابس', 'sort_order' => 4, 'icon' => 'worlds/icons/clothes.jpg'],
            ['name' => 'عالم المواصلات', 'sort_order' => 5, 'icon' => 'worlds/icons/transport.jpg'],
            ['name' => 'عالم الأثاث المنزلي', 'sort_order' => 6, 'icon' => 'worlds/icons/furniture.jpg'],
        ];

        $sourceDir = database_path('seeders/assets/worlds');
        $targetDir = storage_path('app/public/worlds/icons');

        if (! File::isDirectory($targetDir)) {
            File::makeDirectory($targetDir, 0755, true);
        }

        if (File::isDirectory($sourceDir)) {
            File::copyDirectory($sourceDir, $targetDir);
        }

        foreach ($worlds as $world) {
            World::query()->updateOrCreate(
                ['name' => $world['name']],
                [
                    'sort_order' => $world['sort_order'],
                    'icon' => $world['icon'],
                ],
            );
        }
    }
}
