class ContentAssets {
  static const worlds = <String, String>{
    'عالم الحيوانات': 'assets/images/worlds/animals.jpg',
    'عالم الفاكهة': 'assets/images/worlds/fruits.jpg',
    'عالم الخضروات': 'assets/images/worlds/vegetables.jpg',
    'عالم الملابس': 'assets/images/worlds/clothes.jpg',
    'عالم المواصلات': 'assets/images/worlds/transport.jpg',
    'عالم الأثاث المنزلي': 'assets/images/worlds/furniture.jpg',
  };

  static const activities = <String, String>{
    'word_recognition': 'assets/images/activities/word_recognition.jpg',
    'auditory_discrimination': 'assets/images/activities/auditory_discrimination.jpg',
    'pronunciation_recording': 'assets/images/activities/pronunciation_recording.jpg',
  };

  static const items = <String, String>{
    'قطة': 'assets/images/items/cat.jpg',
    'كلب': 'assets/images/items/dog.jpg',
    'أرنب': 'assets/images/items/rabbit.jpg',
    'سمكة': 'assets/images/items/fish.jpg',
    'عصفور': 'assets/images/items/bird.jpg',
    'أسد': 'assets/images/items/lion.jpg',
    'حصان': 'assets/images/items/horse.jpg',
    'فيل': 'assets/images/items/elephant.jpg',
    'تفاحة': 'assets/images/items/apple.jpg',
    'موزة': 'assets/images/items/banana.jpg',
    'برتقالة': 'assets/images/items/orange_fruit.jpg',
    'عنب': 'assets/images/items/grapes.jpg',
    'فراولة': 'assets/images/items/strawberry.jpg',
    'بطيخ': 'assets/images/items/watermelon.jpg',
    'جزر': 'assets/images/items/carrot.jpg',
    'طماطم': 'assets/images/items/tomato.jpg',
    'خيار': 'assets/images/items/cucumber.jpg',
    'بطاطس': 'assets/images/items/potato.jpg',
    'بروكلي': 'assets/images/items/broccoli.jpg',
    'فلفل': 'assets/images/items/pepper.jpg',
    'قميص': 'assets/images/items/shirt.jpg',
    'فستان': 'assets/images/items/dress.jpg',
    'بنطال': 'assets/images/items/pants.jpg',
    'حذاء': 'assets/images/items/shoe.jpg',
    'قبعة': 'assets/images/items/hat.jpg',
    'معطف': 'assets/images/items/coat.jpg',
    'سيارة': 'assets/images/items/car.jpg',
    'دراجة': 'assets/images/items/bicycle.jpg',
    'حافلة': 'assets/images/items/bus.jpg',
    'قطار': 'assets/images/items/train.jpg',
    'طائرة': 'assets/images/items/airplane.jpg',
    'سفينة': 'assets/images/items/ship.jpg',
    'كرسي': 'assets/images/items/chair.jpg',
    'طاولة': 'assets/images/items/table.jpg',
    'سرير': 'assets/images/items/bed.jpg',
    'مصباح': 'assets/images/items/lamp.jpg',
    'خزانة': 'assets/images/items/wardrobe.jpg',
    'أريكة': 'assets/images/items/sofa.jpg',
  };

  static String? worldImage(String name) => worlds[name];

  static String? activityImage(String type) => activities[type];

  static String? itemImage(String word) => items[word];
}
