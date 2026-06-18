/// Production API URL (live server).
const String kProductionApiBaseUrl = 'https://klamo.caesar-agency.co.uk/api';

/// When true, debug and release builds use [kProductionApiBaseUrl].
/// Set to false only for local development against `php artisan serve`.
const bool kUseProductionApi = true;

/// LAN IP of your dev machine when testing on a physical phone (same Wi‑Fi).
/// Leave empty to use the Android emulator address (`10.0.2.2`).
const String kDevPhysicalDeviceHost = '192.168.1.44';

/// Local dev API port (with `php artisan serve --port=8000`).
const int kDevApiPort = 8000;
