/// Local-only form validators.
/// Phase 2: backend errors will be mapped onto these same fields.
class Validators {
  Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain a letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain a number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final regex = RegExp(r'^[0-9+\-\s()]{6,20}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the code';
    }
    if (value.trim().length != length) {
      return 'Enter all $length digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Code must contain only digits';
    }
    return null;
  }

  static String? experience(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0 || parsed > 60) {
      return 'Enter a valid number of years (0–60)';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    if (value.trim().length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > max) {
      return '$field must be at most $max characters';
    }
    return null;
  }
}