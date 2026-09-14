/// Student dashboard statistics.
class MockStudentStats {
  const MockStudentStats({
    required this.enrolledCourses,
    required this.completedCourses,
    required this.inProgressCourses,
    required this.pendingAssignments,
    required this.upcomingQuizzes,
    required this.unreadNotifications,
    required this.averageProgressPercent,
    required this.totalLearningMinutes,
  });

  final int enrolledCourses;
  final int completedCourses;
  final int inProgressCourses;
  final int pendingAssignments;
  final int upcomingQuizzes;
  final int unreadNotifications;
  final int averageProgressPercent;
  final int totalLearningMinutes;

  factory MockStudentStats.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockStudentStats.fromJson');
  }
}

/// Instructor dashboard statistics.
class MockInstructorStats {
  const MockInstructorStats({
    required this.totalCourses,
    required this.draftCourses,
    required this.publishedCourses,
    required this.archivedCourses,
    required this.totalLearners,
    required this.activeEnrollments,
    required this.pendingSubmissions,
    required this.recentQuizAttempts,
    required this.averageCourseRating,
    required this.totalRevenue,
  });

  final int totalCourses;
  final int draftCourses;
  final int publishedCourses;
  final int archivedCourses;
  final int totalLearners;
  final int activeEnrollments;
  final int pendingSubmissions;
  final int recentQuizAttempts;
  final double averageCourseRating;
  final double totalRevenue;

  factory MockInstructorStats.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockInstructorStats.fromJson');
  }
}

/// Admin dashboard statistics.
class MockAdminStats {
  const MockAdminStats({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalInstructors,
    required this.totalAdmins,
    required this.activeUsers,
    required this.suspendedUsers,
    required this.totalCourses,
    required this.publishedCourses,
    required this.draftCourses,
    required this.archivedCourses,
    required this.totalEnrollments,
    required this.totalReviews,
    required this.hiddenReviews,
  });

  final int totalUsers;
  final int totalStudents;
  final int totalInstructors;
  final int totalAdmins;
  final int activeUsers;
  final int suspendedUsers;
  final int totalCourses;
  final int publishedCourses;
  final int draftCourses;
  final int archivedCourses;
  final int totalEnrollments;
  final int totalReviews;
  final int hiddenReviews;

  factory MockAdminStats.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockAdminStats.fromJson');
  }
}