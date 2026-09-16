/// Student registration request body. Adjust field names to match your
/// Postman collection exactly.
class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
  });

  final String fullName;
  final String email;
  final String password;
  final String? phone;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone,
    };
  }
}

/// Instructor registration request body. Adjust to match Postman.
class InstructorRegisterRequest {
  const InstructorRegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.headline,
    required this.qualification,
    required this.experienceYears,
    required this.expertise,
    required this.bio,
  });

  final String fullName;
  final String email;
  final String password;
  final String headline;
  final String qualification;
  final int experienceYears;
  final List<String> expertise;
  final String bio;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'headline': headline,
      'qualification': qualification,
      'experienceYears': experienceYears,
      'expertise': expertise,
      'bio': bio,
    };
  }
}