import 'models/mock_course.dart';

class MockCourses {
  MockCourses._();

  static final MockCourse flutterFundamentals = MockCourse(
    id: 'course_001',
    title: 'Flutter Fundamentals',
    instructorId: 'user_instructor_001',
    instructorName: 'Dr. Elena Petrov',
    categoryId: 'category_001',
    categoryName: 'Mobile Development',
    status: CourseStatus.published,
    level: CourseLevel.beginner,
    description:
    'A complete introduction to Flutter. Learn widgets, layout, state, '
        'and build your first production-quality app.',
    shortDescription: 'Start your Flutter journey with hands-on projects.',
    price: 0,
    rating: 4.8,
    ratingCount: 312,
    learnerCount: 4820,
    sectionCount: 4,
    lessonCount: 24,
    totalDurationMinutes: 320,
    isEnrolled: true,
    progressPercent: 45,
    createdAt: DateTime(2025, 1, 10),
    updatedAt: DateTime(2025, 3, 12),
  );

  static final MockCourse advancedFlutterArchitecture = MockCourse(
    id: 'course_002',
    title: 'Advanced Flutter Architecture',
    instructorId: 'user_instructor_001',
    instructorName: 'Dr. Elena Petrov',
    categoryId: 'category_001',
    categoryName: 'Mobile Development',
    status: CourseStatus.published,
    level: CourseLevel.advanced,
    description:
    'Deep dive into scalable Flutter architecture: clean architecture, '
        'state management, testing, and CI/CD.',
    shortDescription: 'Production-grade Flutter patterns.',
    price: 49.99,
    rating: 4.9,
    ratingCount: 128,
    learnerCount: 1240,
    sectionCount: 6,
    lessonCount: 38,
    totalDurationMinutes: 540,
    isEnrolled: true,
    progressPercent: 12,
    createdAt: DateTime(2025, 2, 4),
    updatedAt: DateTime(2025, 4, 20),
  );

  static final MockCourse dartLanguageMastery = MockCourse(
    id: 'course_003',
    title: 'Dart Language Mastery',
    instructorId: 'user_instructor_002',
    instructorName: 'Marcus Lee',
    categoryId: 'category_001',
    categoryName: 'Mobile Development',
    status: CourseStatus.published,
    level: CourseLevel.intermediate,
    description:
    'Master Dart from syntax to advanced async and isolates.',
    price: 29.99,
    rating: 4.6,
    ratingCount: 88,
    learnerCount: 690,
    sectionCount: 5,
    lessonCount: 30,
    totalDurationMinutes: 380,
    createdAt: DateTime(2025, 1, 22),
    updatedAt: DateTime(2025, 3, 30),
  );

  static final MockCourse reactNativeEssentials = MockCourse(
    id: 'course_004',
    title: 'React Native Essentials',
    instructorId: 'user_instructor_002',
    instructorName: 'Marcus Lee',
    categoryId: 'category_001',
    categoryName: 'Mobile Development',
    status: CourseStatus.draft,
    level: CourseLevel.beginner,
    description:
    'Get started with React Native and build cross-platform apps.',
    price: 0,
    learnerCount: 0,
    sectionCount: 2,
    lessonCount: 8,
    totalDurationMinutes: 120,
    createdAt: DateTime(2025, 4, 2),
  );

  static final MockCourse fullstackWeb = MockCourse(
    id: 'course_005',
    title: 'Fullstack Web Development',
    instructorId: 'user_instructor_001',
    instructorName: 'Dr. Elena Petrov',
    categoryId: 'category_002',
    categoryName: 'Web Development',
    status: CourseStatus.published,
    level: CourseLevel.intermediate,
    description:
    'Build fullstack apps with React, Node.js, and PostgreSQL.',
    price: 79.99,
    rating: 4.7,
    ratingCount: 210,
    learnerCount: 2310,
    sectionCount: 7,
    lessonCount: 48,
    totalDurationMinutes: 720,
    createdAt: DateTime(2024, 12, 1),
    updatedAt: DateTime(2025, 2, 14),
  );

  static final MockCourse machineLearningIntro = MockCourse(
    id: 'course_006',
    title: 'Introduction to Machine Learning',
    instructorId: 'user_instructor_002',
    instructorName: 'Marcus Lee',
    categoryId: 'category_003',
    categoryName: 'Data Science',
    status: CourseStatus.published,
    level: CourseLevel.beginner,
    description:
    'Understand the foundations of ML with Python and scikit-learn.',
    price: 59.99,
    rating: 4.5,
    ratingCount: 76,
    learnerCount: 880,
    sectionCount: 5,
    lessonCount: 26,
    totalDurationMinutes: 360,
    createdAt: DateTime(2024, 11, 18),
    updatedAt: DateTime(2025, 1, 9),
  );

  static final MockCourse uiUxDesign = MockCourse(
    id: 'course_007',
    title: 'UI/UX Design Foundations',
    instructorId: 'user_instructor_003',
    instructorName: 'Sara Al-Mansour',
    categoryId: 'category_004',
    categoryName: 'UI/UX Design',
    status: CourseStatus.published,
    level: CourseLevel.beginner,
    description:
    'Learn design thinking, wireframing, prototyping, and usability.',
    price: 0,
    rating: 4.9,
    ratingCount: 154,
    learnerCount: 1620,
    sectionCount: 4,
    lessonCount: 20,
    totalDurationMinutes: 280,
    createdAt: DateTime(2024, 10, 5),
    updatedAt: DateTime(2025, 2, 2),
  );

  static final MockCourse legacyKotlin = MockCourse(
    id: 'course_008',
    title: 'Legacy Android with Kotlin',
    instructorId: 'user_instructor_003',
    instructorName: 'Sara Al-Mansour',
    categoryId: 'category_001',
    categoryName: 'Mobile Development',
    status: CourseStatus.archived,
    level: CourseLevel.intermediate,
    description:
    'Archived Kotlin Android course. Kept for reference only.',
    price: 0,
    rating: 4.2,
    ratingCount: 40,
    learnerCount: 320,
    sectionCount: 3,
    lessonCount: 14,
    totalDurationMinutes: 210,
    createdAt: DateTime(2023, 8, 8),
    updatedAt: DateTime(2024, 6, 1),
  );

  static final List<MockCourse> all = [
    flutterFundamentals,
    advancedFlutterArchitecture,
    dartLanguageMastery,
    reactNativeEssentials,
    fullstackWeb,
    machineLearningIntro,
    uiUxDesign,
    legacyKotlin,
  ];

  static List<MockCourse> get published =>
      all.where((c) => c.status == CourseStatus.published).toList();

  static List<MockCourse> get drafts =>
      all.where((c) => c.status == CourseStatus.draft).toList();

  static List<MockCourse> get archived =>
      all.where((c) => c.status == CourseStatus.archived).toList();

  static List<MockCourse> byInstructor(String instructorId) =>
      all.where((c) => c.instructorId == instructorId).toList();

  static List<MockCourse> get studentEnrolled =>
      all.where((c) => c.isEnrolled).toList();
}