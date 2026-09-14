/// Instructor-specific profile data.
class MockInstructorProfile {
  const MockInstructorProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
    this.headline,
    this.qualification,
    this.experienceYears = 0,
    this.expertise = const [],
    this.bio,
    this.totalCourses = 0,
    this.totalLearners = 0,
    this.averageRating = 0,
  });

  final String userId;
  final String fullName;
  final String email;
  final String? profileImageUrl;
  final String? headline;
  final String? qualification;
  final int experienceYears;
  final List<String> expertise;
  final String? bio;
  final int totalCourses;
  final int totalLearners;
  final double averageRating;

  MockInstructorProfile copyWith({
    String? fullName,
    String? headline,
    String? qualification,
    int? experienceYears,
    List<String>? expertise,
    String? bio,
    String? profileImageUrl,
  }) {
    return MockInstructorProfile(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      headline: headline ?? this.headline,
      qualification: qualification ?? this.qualification,
      experienceYears: experienceYears ?? this.experienceYears,
      expertise: expertise ?? this.expertise,
      bio: bio ?? this.bio,
      totalCourses: totalCourses,
      totalLearners: totalLearners,
      averageRating: averageRating,
    );
  }

  factory MockInstructorProfile.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockInstructorProfile.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockInstructorProfile.toJson');
  }
}