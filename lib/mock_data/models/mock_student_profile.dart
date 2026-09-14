/// Student-specific profile data.
class MockStudentProfile {
  const MockStudentProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.phone,
    this.dateOfBirth,
    this.country,
    this.educationLevel,
    this.interests = const [],
  });

  final String userId;
  final String fullName;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? country;
  final String? educationLevel;
  final List<String> interests;

  MockStudentProfile copyWith({
    String? fullName,
    String? bio,
    String? phone,
    String? country,
    String? educationLevel,
    List<String>? interests,
    String? profileImageUrl,
  }) {
    return MockStudentProfile(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth,
      country: country ?? this.country,
      educationLevel: educationLevel ?? this.educationLevel,
      interests: interests ?? this.interests,
    );
  }

  factory MockStudentProfile.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockStudentProfile.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockStudentProfile.toJson');
  }
}