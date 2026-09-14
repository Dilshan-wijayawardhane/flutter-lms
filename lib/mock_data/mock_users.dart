import 'models/mock_instructor_profile.dart';
import 'models/mock_student_profile.dart';
import 'models/mock_user.dart';

/// Local mock users. IDs are local string keys — never Postman variables.
class MockUsers {
  MockUsers._();

  // ---- Users ----
  static const MockUser student1 = MockUser(
    id: 'user_student_001',
    fullName: 'Aisha Rahman',
    email: 'aisha.rahman@example.com',
    role: UserRole.student,
    status: UserStatus.active,
  );

  static const MockUser student2 = MockUser(
    id: 'user_student_002',
    fullName: 'Daniel Okafor',
    email: 'daniel.okafor@example.com',
    role: UserRole.student,
    status: UserStatus.active,
  );

  static const MockUser student3 = MockUser(
    id: 'user_student_003',
    fullName: 'Mai Tanaka',
    email: 'mai.tanaka@example.com',
    role: UserRole.student,
    status: UserStatus.active,
  );

  static const MockUser student4 = MockUser(
    id: 'user_student_004',
    fullName: 'Lucas Silva',
    email: 'lucas.silva@example.com',
    role: UserRole.student,
    status: UserStatus.suspended,
  );

  static const MockUser instructor1 = MockUser(
    id: 'user_instructor_001',
    fullName: 'Dr. Elena Petrov',
    email: 'elena.petrov@example.com',
    role: UserRole.instructor,
    status: UserStatus.active,
  );

  static const MockUser instructor2 = MockUser(
    id: 'user_instructor_002',
    fullName: 'Marcus Lee',
    email: 'marcus.lee@example.com',
    role: UserRole.instructor,
    status: UserStatus.active,
  );

  static const MockUser instructor3 = MockUser(
    id: 'user_instructor_003',
    fullName: 'Sara Al-Mansour',
    email: 'sara.almansour@example.com',
    role: UserRole.instructor,
    status: UserStatus.inactive,
  );

  static const MockUser admin1 = MockUser(
    id: 'user_admin_001',
    fullName: 'Nadia Khan',
    email: 'nadia.khan@example.com',
    role: UserRole.admin,
    status: UserStatus.active,
  );

  static const List<MockUser> all = [
    student1,
    student2,
    student3,
    student4,
    instructor1,
    instructor2,
    instructor3,
    admin1,
  ];

  static List<MockUser> get students =>
      all.where((u) => u.role == UserRole.student).toList();

  static List<MockUser> get instructors =>
      all.where((u) => u.role == UserRole.instructor).toList();

  static List<MockUser> get admins =>
      all.where((u) => u.role == UserRole.admin).toList();

  // ---- Profiles ----
  static const MockStudentProfile studentProfile1 = MockStudentProfile(
    userId: 'user_student_001',
    fullName: 'Aisha Rahman',
    email: 'aisha.rahman@example.com',
    bio: 'Aspiring mobile developer passionate about Flutter.',
    phone: '+8801700000001',
    country: 'Bangladesh',
    educationLevel: 'Undergraduate',
    interests: ['Flutter', 'UI/UX', 'Mobile Apps'],
  );

  static const MockInstructorProfile instructorProfile1 =
  MockInstructorProfile(
    userId: 'user_instructor_001',
    fullName: 'Dr. Elena Petrov',
    email: 'elena.petrov@example.com',
    headline: 'Senior Flutter Engineer & Educator',
    qualification: 'PhD in Computer Science',
    experienceYears: 12,
    expertise: ['Flutter', 'Dart', 'Mobile Architecture', 'Clean Code'],
    bio:
    'Dr. Elena has spent over a decade teaching mobile development and '
        'building production Flutter apps for global teams.',
    totalCourses: 6,
    totalLearners: 4820,
    averageRating: 4.8,
  );
}