import 'models/mock_dashboard_stats.dart';

class MockStats {
  MockStats._();

  static const MockStudentStats student = MockStudentStats(
    enrolledCourses: 3,
    completedCourses: 0,
    inProgressCourses: 3,
    pendingAssignments: 2,
    upcomingQuizzes: 1,
    unreadNotifications: 2,
    averageProgressPercent: 34,
    totalLearningMinutes: 640,
  );

  static const MockInstructorStats instructor = MockInstructorStats(
    totalCourses: 6,
    draftCourses: 1,
    publishedCourses: 4,
    archivedCourses: 1,
    totalLearners: 4820,
    activeEnrollments: 1320,
    pendingSubmissions: 12,
    recentQuizAttempts: 34,
    averageCourseRating: 4.7,
    totalRevenue: 12480.50,
  );

  static const MockAdminStats admin = MockAdminStats(
    totalUsers: 8,
    totalStudents: 4,
    totalInstructors: 3,
    totalAdmins: 1,
    activeUsers: 6,
    suspendedUsers: 1,
    totalCourses: 8,
    publishedCourses: 6,
    draftCourses: 1,
    archivedCourses: 1,
    totalEnrollments: 320,
    totalReviews: 4,
    hiddenReviews: 1,
  );
}