import '../../core/utils/mock_role.dart';

/// User role as returned by the backend.
/// Values must match backend string enum exactly when integration starts.
enum UserRole {
  student,
  instructor,
  admin;

  String get wireValue {
    switch (this) {
      case UserRole.student:
        return 'STUDENT';
      case UserRole.instructor:
        return 'INSTRUCTOR';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.admin:
        return 'Admin';
    }
  }

  MockRole toMockRole() {
    switch (this) {
      case UserRole.student:
        return MockRole.student;
      case UserRole.instructor:
        return MockRole.instructor;
      case UserRole.admin:
        return MockRole.admin;
    }
  }
}

/// Account status.
enum UserStatus {
  active,
  inactive,
  suspended;

  String get wireValue {
    switch (this) {
      case UserStatus.active:
        return 'ACTIVE';
      case UserStatus.inactive:
        return 'INACTIVE';
      case UserStatus.suspended:
        return 'SUSPENDED';
    }
  }

  String get label {
    switch (this) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.suspended:
        return 'Suspended';
    }
  }
}

/// Shared user account (all roles).
class MockUser {
  const MockUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    this.profileImageUrl,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final UserStatus status;
  final String? profileImageUrl;
  final DateTime? createdAt;

  MockUser copyWith({
    String? fullName,
    String? email,
    UserStatus? status,
    String? profileImageUrl,
  }) {
    return MockUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
    );
  }

  factory MockUser.fromJson(Map<String, dynamic> json) {
    // TODO(phase-2): Implement fromJson using backend contract.
    throw UnimplementedError('MockUser.fromJson');
  }

  Map<String, dynamic> toJson() {
    // TODO(phase-2): Implement toJson using backend contract.
    throw UnimplementedError('MockUser.toJson');
  }
}