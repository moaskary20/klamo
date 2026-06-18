import 'package:flutter/foundation.dart';

import 'package:klamo_mobile/core/config/api_env.dart';

class ApiConstants {
  /// Highest priority — set at build time:
  /// `flutter run --dart-define=API_BASE_URL=https://your-domain.com/api`
  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// Force production URL even in debug builds:
  /// `flutter run --dart-define=USE_PRODUCTION=true`
  static const bool _forceProduction =
      bool.fromEnvironment('USE_PRODUCTION', defaultValue: false);

  static bool get isProduction => _forceProduction || kReleaseMode;

  static String get baseUrl {
    if (_override.isNotEmpty) {
      return _normalizeApiUrl(_override);
    }

    if (isProduction) {
      return _normalizeApiUrl(kProductionApiBaseUrl);
    }

    return _normalizeApiUrl(_developmentBaseUrl);
  }

  static String get _developmentBaseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (kDevPhysicalDeviceHost.isNotEmpty) {
        return 'http://$kDevPhysicalDeviceHost:$kDevApiPort/api';
      }

      // Android emulator → host machine.
      return 'http://10.0.2.2:$kDevApiPort/api';
    }

    return 'http://127.0.0.1:$kDevApiPort/api';
  }

  static String _normalizeApiUrl(String url) {
    var trimmed = url.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) return trimmed;

    if (!trimmed.endsWith('/api')) {
      trimmed = '$trimmed/api';
    }

    return trimmed;
  }

  static const appName = 'كلامو';

  static bool get isConfiguredForProduction {
    if (_override.isNotEmpty) {
      return !_override.contains('YOUR-DOMAIN');
    }

    return !kProductionApiBaseUrl.contains('YOUR-DOMAIN');
  }

  static String get serverOrigin {
    final uri = Uri.parse(baseUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  /// Rewrites media URLs from the API so they load on emulators and devices.
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
