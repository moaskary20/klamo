/// Production API URL for release builds (APK / App Store).
///
/// Replace with your live server address before building for production.
/// Must include `/api` at the end.
///
/// Example: `https://klamo.example.com/api`
const String kProductionApiBaseUrl = 'https://YOUR-DOMAIN.com/api';

/// LAN IP of your dev machine when testing on a physical phone (same Wi‑Fi).
/// Leave empty to use the Android emulator address (`10.0.2.2`).
const String kDevPhysicalDeviceHost = '192.168.1.44';

/// Local dev API port (with `php artisan serve --port=8000`).
const int kDevApiPort = 8000;
