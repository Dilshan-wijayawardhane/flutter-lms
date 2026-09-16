/// Global application configuration.
///
/// The base URL intentionally does NOT include `/api/v1` because every
/// endpoint path already carries that prefix (see the Postman collection).
class AppConfig {
  AppConfig._();

  /// Backend host for the Android emulator.
  ///
  /// - Android emulator  → 10.0.2.2   (host loopback)
  /// - iOS simulator     → localhost
  /// - Physical device   → your LAN IP
  /// - Desktop / web     → localhost
  ///
  /// Keep this as the single source of truth. Never hardcode the base URL
  /// anywhere else in the app.
  static const String baseUrl = 'http://10.0.2.2:5000';

  // ---- Timeouts ----
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ---- API prefix (used only where an endpoint path doesn't carry it) ----
  static const String apiPrefix = '/api/v1';

  // ---- App-wide ----
  static const String appName = 'Flutter LMS';
  static const bool isProduction = false;
}