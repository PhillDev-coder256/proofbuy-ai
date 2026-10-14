/// Application configuration.
///
/// All environment-specific values come from dart-define so
/// no URLs are ever hardcoded.
class AppConfig {
  AppConfig._();

  /// Backend base URL.
  ///
  /// Set via `--dart-define=BACKEND_URL=http://...` at build/run time.
  /// Defaults to the Android emulator loopback address.
  static String get backendUrl =>
      const String.fromEnvironment('BACKEND_URL', defaultValue: 'http://10.0.2.2:8000');
}
