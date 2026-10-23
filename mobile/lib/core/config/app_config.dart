/// Application configuration.
///
/// All environment-specific values come from dart-define so
/// no sensitive keys or URLs are strictly hardcoded, but default
/// values are provided for the PayPal Sandbox environment.
class AppConfig {
  AppConfig._();

  /// App Name for PayPal Developer / Hackathon submission
  static const String appName = 'payproof ai';

  /// Backend base URL.
  ///
  /// Set via `--dart-define=BACKEND_URL=http://...` at build/run time.
  /// Defaults to the Android emulator loopback address.
  static String get backendUrl => const String.fromEnvironment(
        'BACKEND_URL',
        defaultValue: 'http://10.0.2.2:8000',
      );

  /// PayPal Sandbox Client ID
  static String get paypalClientId => const String.fromEnvironment(
        'PAYPAL_CLIENT_ID',
        defaultValue:
            'EAhfCjhFBAj-anJpOzGUyaFzaU0vnlP6aDmeIPuCpPpB1scSlkixDQ6KpnCXLjGVRqgb4gp_4ZOe4vOi',
      );

  /// PayPal Sandbox Client Secret
  static String get paypalClientSecret => const String.fromEnvironment(
        'PAYPAL_CLIENT_SECRET',
        defaultValue:
            'BAAC7adqjJGW6WYK5AXqHWfQQIXb1xqDjygUqOC-lrLUL36vhTlIGdJmNLv2FN-CprP2BTGARofLf414hc',
      );
}
