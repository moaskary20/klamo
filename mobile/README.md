# Klamo Mobile

تطبيق Flutter للأطفال متصل بـ Laravel API.

## المتطلبات

- Flutter SDK 3.10+
- Laravel backend (محلي أو على سيرفر خارجي)

## التشغيل المحلي (تطوير)

```bash
cd mobile
flutter pub get
flutter run
```

| المنصة | العنوان الافتراضي |
|--------|-------------------|
| Android Emulator | `http://10.0.2.2:8000/api` |
| جهاز Android حقيقي | `http://<IP-الكمبيوتر>:8000/api` |
| iOS / Desktop | `http://127.0.0.1:8000/api` |

عدّل `lib/core/config/api_env.dart` → `kDevPhysicalDeviceHost` لجهازك الحقيقي.

شغّل Laravel:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

## السيرفر الخارجي (إنتاج)

### 1) على السيرفر (Laravel)

```env
APP_URL=https://your-domain.com
APP_ENV=production
APP_DEBUG=false

DB_CONNECTION=mysql
# ...
```

```bash
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link
php artisan config:cache
```

تأكد أن هذا الرابط يعمل من المتصفح:

`https://your-domain.com/api/bootstrap`

### 2) في التطبيق

افتح `lib/core/config/api_env.dart` وغيّر:

```dart
const String kProductionApiBaseUrl = 'https://your-domain.com/api';
```

### 3) بناء APK للإنتاج

```bash
cd mobile
flutter pub get
flutter build apk --release
```

الملف: `build/app/outputs/flutter-apk/app-release.apk`

### بديل بدون تعديل الملف

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-domain.com/api
```

### اختبار السيرفر الخارجي أثناء التطوير

```bash
flutter run --dart-define=USE_PRODUCTION=true \
  --dart-define=API_BASE_URL=https://your-domain.com/api
```

## الشاشات

1. Splash — شعار + تحميل + bootstrap API
2. Auth — دخول / تسجيل / اختيار طفل
3. Create Child — إنشاء ملف طفل
4. Home — العوالم الستة
5. Word Recognition — تعرّف على الكلمة
6. Auditory Discrimination — تمييز سمعي
7. Pronunciation — تسجيل نطق + تحليل
8. Rewards — نجوم وتحفيز
9. Progress — مستوى الطفل وإحصائيات

## Laravel Backend

```bash
php artisan serve
php artisan queue:work
```
