import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration class that provides access to
/// configurable environment variables.
///
/// Supports two configuration mechanisms (in priority order):
/// 1. Compile-time `--dart-define` variables (recommended for CI/CD and production)
///    Example: `flutter run --dart-define=API_BASE_URL=https://api.example.com`
/// 2. Runtime `.env` file via `flutter_dotenv` (convenient for local development)
///
/// The `--dart-define` value takes precedence over the `.env` file value.

class Env {
  /// Default API base URL for Android emulator pointing to host machine.
  static const String _defaultBaseUrl = 'http://10.0.2.2:8000/api';

  /// Compile-time value from `--dart-define=API_BASE_URL=...`
  /// This is empty string if not provided at compile time.
  static const String _dartDefineBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Loads the .env file for runtime configuration.
  /// Must be called before accessing env variables that rely on .env.
  /// Typically called in main() before runApp().
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  /// The base URL for the Laravel API.
  ///
  /// Resolution order:
  /// 1. `--dart-define=API_BASE_URL=...` (compile-time, highest priority)
  /// 2. `API_BASE_URL` from `.env` file (runtime)
  /// 3. Default: `http://10.0.2.2:8000/api` (Android emulator localhost)
  static String get apiBaseUrl {
    // Prefer compile-time dart-define value
    if (_dartDefineBaseUrl.isNotEmpty) {
      return _dartDefineBaseUrl;
    }
    // Fall back to .env file value, then default
    return dotenv.env['API_BASE_URL'] ?? _defaultBaseUrl;
  }
}
