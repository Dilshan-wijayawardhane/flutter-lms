/// Full authenticated user profile returned by
/// GET /api/v1/users/me/full-profile
///
/// The backend may return the data in a few shapes. This model accepts
/// several common ones so it stays stable across minor API differences.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.isEmailVerified,
    required this.fullName,
    this.profileImageUrl,
    this.phone,
    this.bio,
    this.country,
    this.educationLevel,
    this.learningGoals = const [],
    this.interests = const [],
    this.createdAt,
    this.headline,
    this.qualification,
    this.experienceYears,
    this.expertise = const [],
    this.totalCourses,
    this.totalLearners,
    this.averageRating,
  });

  final String id;
  final String email;
  final String role; // 'STUDENT' | 'INSTRUCTOR' | 'ADMIN'
  final String status; // 'ACTIVE' | 'INACTIVE' | 'SUSPENDED'
  final bool isEmailVerified;
  final String fullName;
  final String? profileImageUrl;
  final String? phone;
  final String? bio;
  final String? country;
  final String? educationLevel;
  final List<String> learningGoals;
  final List<String> interests;
  final DateTime? createdAt;
  // Instructor-specific fields (null for students / admins)
  final String? headline;
  final String? qualification;
  final int? experienceYears;
  final List<String> expertise;
  final int? totalCourses;
  final int? totalLearners;
  final double? averageRating;

  UserProfile copyWith({
    String? fullName,
    String? profileImageUrl,
    String? phone,
    String? bio,
    String? country,
    String? educationLevel,
    List<String>? learningGoals,
    List<String>? interests,
  }) {
    return UserProfile(
      id: id,
      email: email,
      role: role,
      status: status,
      isEmailVerified: isEmailVerified,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      educationLevel: educationLevel ?? this.educationLevel,
      learningGoals: learningGoals ?? this.learningGoals,
      interests: interests ?? this.interests,
      createdAt: createdAt,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Unwrap { data: {...} } if present.
    final data =
        (json['data'] as Map<String, dynamic>?) ?? json;

    // The user object may sit at `user` or be the data itself.
    final userJson =
        (data['user'] as Map<String, dynamic>?) ?? data;

    // Student / instructor profile may be nested under several keys.
    final profileJson =
        (data['studentProfile'] as Map<String, dynamic>?) ??
            (data['instructorProfile'] as Map<String, dynamic>?) ??
            (data['profile'] as Map<String, dynamic>?) ??
            data;

    List<String> toStringList(dynamic value) {
      if (value is List) {
        return value
            .whereType<Object>()
            .map((e) => e.toString())
            .toList();
      }
      return const [];
    }

    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    return UserProfile(
      id: (userJson['id'] ?? userJson['_id'] ?? '').toString(),
      email: (userJson['email'] ?? '').toString(),
      role: ((userJson['role'] ?? 'STUDENT') as String).toUpperCase(),
      status: ((userJson['status'] ?? 'ACTIVE') as String).toUpperCase(),
      isEmailVerified:
      userJson['isEmailVerified'] == true ||
          userJson['emailVerified'] == true,
      fullName: (profileJson['fullName'] ??
          userJson['fullName'] ??
          userJson['name'] ??
          '')
          .toString(),
      profileImageUrl: (profileJson['profileImageUrl'] ??
          userJson['profileImageUrl'])
          ?.toString(),
      phone:
      (profileJson['phone'] ?? userJson['phone'])?.toString(),
      bio: (profileJson['bio'] ?? userJson['bio'])?.toString(),
      country: (profileJson['country'] ?? userJson['country'])
          ?.toString(),
      educationLevel:
      (profileJson['educationLevel'] ?? userJson['educationLevel'])
          ?.toString(),
      learningGoals:
      toStringList(profileJson['learningGoals'] ?? userJson['learningGoals']),
      interests:
      toStringList(profileJson['interests'] ?? userJson['interests']),
      createdAt: parseDate(userJson['createdAt']),
    );
  }
}