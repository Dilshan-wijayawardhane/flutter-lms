/// Central route name constants. Every route used anywhere in the app
/// must be declared here so it can be wired centrally in AppRouter.
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String registerStudent = '/register/student';
  static const String registerInstructor = '/register/instructor';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Student
  static const String studentDashboard = '/student/dashboard';
  static const String studentCourses = '/student/courses';
  static const String studentCourseDetails = '/student/course-details';
  static const String studentMyCourses = '/student/my-courses';
  static const String studentLearning = '/student/learning';
  static const String studentLesson = '/student/lesson';
  static const String studentQuiz = '/student/quiz';
  static const String studentQuizResult = '/student/quiz-result';
  static const String studentQuizAttempts = '/student/quiz-attempts';
  static const String studentAssignments = '/student/assignments';
  static const String studentAssignmentDetails =
      '/student/assignment-details';
  static const String studentAssignmentSubmission =
      '/student/assignment-submission';
  static const String studentReviews = '/student/reviews';
  static const String studentNotifications = '/student/notifications';
  static const String studentNotificationDetails =
      '/student/notification-details';
  static const String studentProfile = '/student/profile';
  static const String studentEditProfile = '/student/edit-profile';
  static const String studentAccount = '/student/account';
  static const String studentChangePassword = '/student/change-password';

  // Instructor
  static const String instructorDashboard = '/instructor/dashboard';
  static const String instructorCourses = '/instructor/courses';
  static const String instructorCreateCourse = '/instructor/create-course';
  static const String instructorEditCourse = '/instructor/edit-course';
  static const String instructorCourseDetails =
      '/instructor/course-details';
  static const String instructorSections = '/instructor/sections';
  static const String instructorCreateSection =
      '/instructor/create-section';
  static const String instructorEditSection = '/instructor/edit-section';
  static const String instructorReorderSections =
      '/instructor/reorder-sections';
  static const String instructorLessons = '/instructor/lessons';
  static const String instructorCreateLesson =
      '/instructor/create-lesson';
  static const String instructorEditLesson = '/instructor/edit-lesson';
  static const String instructorLessonMedia =
      '/instructor/lesson-media';
  static const String instructorQuizzes = '/instructor/quizzes';
  static const String instructorCreateQuiz = '/instructor/create-quiz';
  static const String instructorEditQuiz = '/instructor/edit-quiz';
  static const String instructorQuestions = '/instructor/questions';
  static const String instructorCreateQuestion =
      '/instructor/create-question';
  static const String instructorEditQuestion =
      '/instructor/edit-question';
  static const String instructorQuizAttempts =
      '/instructor/quiz-attempts';
  static const String instructorAssignments = '/instructor/assignments';
  static const String instructorCreateAssignment =
      '/instructor/create-assignment';
  static const String instructorEditAssignment =
      '/instructor/edit-assignment';
  static const String instructorSubmissions = '/instructor/submissions';
  static const String instructorSubmissionDetails =
      '/instructor/submission-details';
  static const String instructorGradeSubmission =
      '/instructor/grade-submission';
  static const String instructorEnrollments = '/instructor/enrollments';
  static const String instructorLearnerDetails =
      '/instructor/learner-details';
  static const String instructorReviews = '/instructor/reviews';
  static const String instructorProfile = '/instructor/profile';
  static const String instructorEditProfile = '/instructor/edit-profile';
  static const String instructorAccount = '/instructor/account';
  static const String instructorChangePassword =
      '/instructor/change-password';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminUserDetails = '/admin/user-details';
  static const String adminUserFilter = '/admin/user-filter';
  static const String adminCategories = '/admin/categories';
  static const String adminCreateCategory = '/admin/create-category';
  static const String adminEditCategory = '/admin/edit-category';
  static const String adminCourses = '/admin/courses';
  static const String adminCourseDetails = '/admin/course-details';
  static const String adminCourseFilter = '/admin/course-filter';
  static const String adminEnrollments = '/admin/enrollments';
  static const String adminEnrollmentDetails =
      '/admin/enrollment-details';
  static const String adminReviews = '/admin/reviews';
  static const String adminProfile = '/admin/profile';
  static const String adminAccount = '/admin/account';
  static const String adminChangePassword = '/admin/change-password';
}