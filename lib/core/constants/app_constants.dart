/// Global, non-UI constants used across the app.
class AppConstants {
  AppConstants._();

  static const String appName = 'Flutter LMS';
  static const String appVersion = '0.1.0';

  // Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);

  // Layout
  static const double maxContentWidth = 640;
  static const double defaultPagePadding = 16;
  static const double listItemSpacing = 12;

  // OTP
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  // Pagination (UI only for now)
  static const int defaultPageSize = 10;
}