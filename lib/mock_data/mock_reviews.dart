import 'models/mock_review.dart';

class MockReviews {
  MockReviews._();

  static final List<MockReview> course1 = [
    MockReview(
      id: 'review_001',
      courseId: 'course_001',
      courseName: 'Flutter Fundamentals',
      studentId: 'user_student_002',
      studentName: 'Daniel Okafor',
      rating: 5,
      comment:
      'Excellent course. The instructor explains complex topics clearly.',
      visibility: ReviewVisibility.visible,
      createdAt: DateTime(2025, 3, 15),
    ),
    MockReview(
      id: 'review_002',
      courseId: 'course_001',
      courseName: 'Flutter Fundamentals',
      studentId: 'user_student_003',
      studentName: 'Mai Tanaka',
      rating: 4,
      comment:
      'Great content. Would love more examples on state management.',
      visibility: ReviewVisibility.visible,
      createdAt: DateTime(2025, 3, 20),
    ),
  ];

  static final List<MockReview> all = [
    ...course1,
    MockReview(
      id: 'review_003',
      courseId: 'course_002',
      courseName: 'Advanced Flutter Architecture',
      studentId: 'user_student_001',
      studentName: 'Aisha Rahman',
      rating: 5,
      comment: 'The most useful course on architecture I have taken.',
      visibility: ReviewVisibility.visible,
      createdAt: DateTime(2025, 4, 2),
    ),
    MockReview(
      id: 'review_004',
      courseId: 'course_005',
      courseName: 'Fullstack Web Development',
      studentId: 'user_student_002',
      studentName: 'Daniel Okafor',
      rating: 2,
      comment: 'Content felt outdated in a few sections.',
      visibility: ReviewVisibility.hidden,
      createdAt: DateTime(2025, 3, 28),
    ),
  ];

  static List<MockReview> byCourse(String courseId) =>
      all.where((r) => r.courseId == courseId).toList();

  static List<MockReview> byStudent(String studentId) =>
      all.where((r) => r.studentId == studentId).toList();
}