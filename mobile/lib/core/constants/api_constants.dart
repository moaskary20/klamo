import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Override at build time, e.g. on a physical Android device:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
  ///
  /// Or set [physicalDeviceHost] below to your computer's LAN IP.
  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// Set your computer's LAN IP when testing on a physical phone (same Wi‑Fi).
  /// Example: '192.168.1.10'
  static const String physicalDeviceHost = '192.168.1.44';

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (physicalDeviceHost.isNotEmpty) {
        return 'http://$physicalDeviceHost:8000/api';
      }

      // Works only on the Android emulator (maps to the host machine).
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  static const appName = 'كلامو';

  static String get serverOrigin {
    final uri = Uri.parse(baseUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  /// Rewrites media URLs from the API so they load on emulators and physical devices.
  static String? resolveMediaUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    final apiUri = Uri.parse(baseUrl);

    if (url.startsWith('/')) {
      return '$serverOrigin$url';
    }

    final parsed = Uri.tryParse(url);
    if (parsed == null) return url;

    if (parsed.host == 'localhost' ||
        parsed.host == '127.0.0.1' ||
        parsed.host == '10.0.2.2') {
      return parsed
          .replace(
            scheme: apiUri.scheme,
            host: apiUri.host,
            port: apiUri.hasPort ? apiUri.port : parsed.port,
          )
          .toString();
    }

    return url;
  }
}
