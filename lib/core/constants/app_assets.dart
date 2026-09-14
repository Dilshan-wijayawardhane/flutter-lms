/// Central asset path constants.
/// Assets are not bundled yet in Phase 1; these are placeholders so
/// references are ready once assets are added.
class AppAssets {
  AppAssets._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  static const String logo = '$_images/logo.png';
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.png';

  static const String placeholderAvatar = '$_images/avatar_placeholder.png';
  static const String placeholderThumbnail =
      '$_images/course_placeholder.png';

  static const String iconStudent = '$_icons/student.svg';
  static const String iconInstructor = '$_icons/instructor.svg';
  static const String iconAdmin = '$_icons/admin.svg';
}