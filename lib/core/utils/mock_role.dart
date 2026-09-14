/// Temporary role enum used ONLY for local mock navigation in Phase 1.
/// In Phase 2, the role will come from the backend login response.
enum MockRole {
  student,
  instructor,
  admin;

  String get label {
    switch (this) {
      case MockRole.student:
        return 'Student';
      case MockRole.instructor:
        return 'Instructor';
      case MockRole.admin:
        return 'Admin';
    }
  }
}