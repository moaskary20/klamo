# Klamo Mobile

تطبيق Flutter للأطفال متصل بـ Laravel API.

## المتطلبات

- Flutter SDK 3.10+
- Laravel backend يعمل على `http://127.0.0.1:8000`

## التشغيل

```bash
cd mobile
flutter pub get
flutter run
```

## عنوان API

| المنصة | العنوان |
|--------|---------|
| Android Emulator | `http://10.0.2.2:8000/api` |
| iOS / Web / Desktop | `http://127.0.0.1:8000/api` |

عدّل `lib/core/constants/api_constants.dart` إذا لزم.

## الشاشات

1. Splash — شعار + تحميل + bootstrap API
2. Auth — دخول / تسجيل / اختيار طفل
3. Create Child — إنشاء ملف طفل
4. Home — العوالم الستة
5. Word Recognition — تعرف على الكلمة
6. Auditory Discrimination — تمييز سمعي
7. Pronunciation — تسجيل نطق + Gemini
8. Rewards — نجوم وتحفيز
9. Progress — مستوى الطفل وإحصائيات

## Laravel Backend

```bash
php artisan serve
php artisan queue:work
```
