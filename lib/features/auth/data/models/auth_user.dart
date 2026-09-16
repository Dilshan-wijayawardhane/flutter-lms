/// Minimal user returned by login. Full profile comes later.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.isEmailVerified = false,
  });

  final String id;
  final String email;
  final String fullName;
  final String role; // 'STUDENT' | 'INSTRUCTOR' | 'ADMIN'
  final bool isEmailVerified;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: (json['email'] ?? '') as String,
      fullName: (json['fullName'] ?? json['name'] ?? '') as String,
      role: ((json['role'] ?? 'STUDENT') as String).toUpperCase(),
      isEmailVerified:
      json['isEmailVerified'] == true || json['emailVerified'] == true,
    );
  }
}