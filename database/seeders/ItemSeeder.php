<?php

namespace Database\Seeders;

use App\Enums\ActivityType;
use App\Models\Activity;
use App\Models\Item;
use App\Models\World;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\File;

class ItemSeeder extends Seeder
{
    /**
     * @return array<string, list<array{word_name: string, image: string, min_level: int}>>
     */
    protected function itemsByWorld(): array
    {
        return [
            'عالم الحيوانات' => [
                ['word_name' => 'قطة', 'image' => 'cat.jpg', 'min_level' => 1],
                ['word_name' => 'كلب', 'image' => 'dog.jpg', 'min_level' => 1],
                ['word_name' => 'أرنب', 'image' => 'rabbit.jpg', 'min_level' => 1],
                ['word_name' => 'سمكة', 'image' => 'fish.jpg', 'min_level' => 1],
                ['word_name' => 'عصفور', 'image' => 'bird.jpg', 'min_level' => 2],
                ['word_name' => 'أسد', 'image' => 'lion.jpg', 'min_level' => 2],
                ['word_name' => 'حصان', 'image' => 'horse.jpg', 'min_level' => 3],
                ['word_name' => 'فيل', 'image' => 'elephant.jpg', 'min_level' => 3],
            ],
            'عالم الفاكهة' => [
                ['word_name' => 'تفاحة', 'image' => 'apple.jpg', 'min_level' => 1],
                ['word_name' => 'موزة', 'image' => 'banana.jpg', 'min_level' => 1],
                ['word_name' => 'برتقالة', 'image' => 'orange_fruit.jpg', 'min_level' => 1],
                ['word_name' => 'عنب', 'image' => 'grapes.jpg', 'min_level' => 2],
                ['word_name' => 'فراولة', 'image' => 'strawberry.jpg', 'min_level' => 2],
                ['word_name' => 'بطيخ', 'image' => 'watermelon.jpg', 'min_level' => 3],
            ],
            'عالم الخضروات' => [
                ['word_name' => 'جزر', 'image' => 'carrot.jpg', 'min_level' => 1],
                ['word_name' => 'طماطم', 'image' => 'tomato.jpg', 'min_level' => 1],
                ['word_name' => 'خيار', 'image' => 'cucumber.jpg', 'min_level' => 1],
                ['word_name' => 'بطاطس', 'image' => 'potato.jpg', 'min_level' => 2],
                ['word_name' => 'بروكلي', 'image' => 'broccoli.jpg', 'min_level' => 2],
                ['word_name' => 'فلفل', 'image' => 'pepper.jpg', 'min_level' => 3],
            ],
            'عالم الملابس' => [
                ['word_name' => 'قميص', 'image' => 'shirt.jpg', 'min_level' => 1],
                ['word_name' => 'فستان', 'image' => 'dress.jpg', 'min_level' => 1],
                ['word_name' => 'بنطال', 'image' => 'pants.jpg', 'min_level' => 1],
                ['word_name' => 'حذاء', 'image' => 'shoe.jpg', 'min_level' => 2],
                ['word_name' => 'قبعة', 'image' => 'hat.jpg', 'min_level' => 2],
                ['word_name' => 'معطف', 'image' => 'coat.jpg', 'min_level' => 3],
            ],
            'عالم المواصلات' => [
                ['word_name' => 'سيارة', 'image' => 'car.jpg', 'min_level' => 1],
                ['word_name' => 'دراجة', 'image' => 'bicycle.jpg', 'min_level' => 1],
                ['word_name' => 'حافلة', 'image' => 'bus.jpg', 'min_level' => 1],
                ['word_name' => 'قطار', 'image' => 'train.jpg', 'min_level' => 2],
                ['word_name' => 'طائرة', 'image' => 'airplane.jpg', 'min_level' => 2],
                ['word_name' => 'سفينة', 'image' => 'ship.jpg', 'min_level' => 3],
            ],
            'عالم الأثاث المنزلي' => [
                ['word_name' => 'كرسي', 'image' => 'chair.jpg', 'min_level' => 1],
                ['word_name' => 'طاولة', 'image' => 'table.jpg', 'min_level' => 1],
                ['word_name' => 'سرير', 'image' => 'bed.jpg', 'min_level' => 1],
                ['word_name' => 'مصباح', 'image' => 'lamp.jpg', 'min_level' => 2],
                ['word_name' => 'خزانة', 'image' => 'wardrobe.jpg', 'min_level' => 2],
                ['word_name' => 'أريكة', 'image' => 'sofa.jpg', 'min_level' => 3],
            ],
        ];
    }

    public function run(): void
    {
        $sourceDir = database_path('seeders/assets/items');
        $targetDir = storage_path('app/public/items/images');

        if (! File::isDirectory($targetDir)) {
            File::makeDirectory($targetDir, 0755, true);
        }

        foreach ($this->itemsByWorld() as $worldName => $items) {
            $world = World::query()->where('name', $worldName)->first();

            if (! $world) {
                continue;
            }

            foreach ($items as $itemData) {
                $sourceImage = $sourceDir.'/'.$itemData['image'];
                $storageImage = 'items/images/'.$itemData['image'];

                if (File::exists($sourceImage)) {
                    File::copy($sourceImage, storage_path('app/public/'.$storageImage));
                }

                $item = Item::query()->updateOrCreate(
                    [
                        'world_id' => $world->id,
                        'word_name' => $itemData['word_name'],
                    ],
                    [
                        'image_path' => File::exists($sourceImage) ? $storageImage : null,
                        'min_level' => $itemData['min_level'],
                    ],
                );

                foreach (ActivityType::cases() as $activityType) {
                    Activity::query()->firstOrCreate([
                        'item_id' => $item->id,
                        'type' => $activityType,
                    ]);
                }
            }
        }
    }
}
