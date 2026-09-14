import 'package:flutter/material.dart';

// ============================================================
// AUTH
// ============================================================
import '../../features/admin/presentation/pages/admin_account_page.dart';
import '../../features/admin/presentation/pages/admin_change_password_page.dart';
import '../../features/admin/presentation/pages/admin_enrollments_page.dart';
import '../../features/admin/presentation/pages/admin_profile_page.dart';
import '../../features/admin/presentation/pages/admin_reviews_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/instructor_register_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/student_register_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';

// ============================================================
// STUDENT
// ============================================================
import '../../features/student/presentation/pages/student_account_page.dart';
import '../../features/student/presentation/pages/student_assignment_details_page.dart';
import '../../features/student/presentation/pages/student_assignment_submission_page.dart';
import '../../features/student/presentation/pages/student_assignments_page.dart';
import '../../features/student/presentation/pages/student_change_password_page.dart';
import '../../features/student/presentation/pages/student_course_details_page.dart';
import '../../features/student/presentation/pages/student_edit_profile_page.dart';
import '../../features/student/presentation/pages/student_learning_page.dart';
import '../../features/student/presentation/pages/student_lesson_page.dart';
import '../../features/student/presentation/pages/student_notification_details_page.dart';
import '../../features/student/presentation/pages/student_quiz_attempts_page.dart';
import '../../features/student/presentation/pages/student_quiz_page.dart';
import '../../features/student/presentation/pages/student_quiz_result_page.dart';
import '../../features/student/presentation/pages/student_reviews_page.dart';
import '../../features/student/presentation/student_shell.dart';

// ============================================================
// INSTRUCTOR
// ============================================================
import '../../features/instructor/presentation/instructor_shell.dart';
import '../../features/instructor/presentation/pages/instructor_account_page.dart';
import '../../features/instructor/presentation/pages/instructor_assignments_page.dart';
import '../../features/instructor/presentation/pages/instructor_change_password_page.dart';
import '../../features/instructor/presentation/pages/instructor_course_details_page.dart';
import '../../features/instructor/presentation/pages/instructor_create_assignment_page.dart';
import '../../features/instructor/presentation/pages/instructor_create_course_page.dart';
import '../../features/instructor/presentation/pages/instructor_create_lesson_page.dart';
import '../../features/instructor/presentation/pages/instructor_create_question_page.dart';
import '../../features/instructor/presentation/pages/instructor_create_quiz_page.dart';
import '../../features/instructor/presentation/pages/instructor_create_section_page.dart';
import '../../features/instructor/presentation/pages/instructor_edit_assignment_page.dart';
import '../../features/instructor/presentation/pages/instructor_edit_course_page.dart';
import '../../features/instructor/presentation/pages/instructor_edit_lesson_page.dart';
import '../../features/instructor/presentation/pages/instructor_edit_profile_page.dart';
import '../../features/instructor/presentation/pages/instructor_edit_question_page.dart';
import '../../features/instructor/presentation/pages/instructor_edit_quiz_page.dart';
import '../../features/instructor/presentation/pages/instructor_edit_section_page.dart';
import '../../features/instructor/presentation/pages/instructor_enrollments_page.dart';
import '../../features/instructor/presentation/pages/instructor_grade_submission_page.dart';
import '../../features/instructor/presentation/pages/instructor_learner_details_page.dart';
import '../../features/instructor/presentation/pages/instructor_lesson_media_page.dart';
import '../../features/instructor/presentation/pages/instructor_lessons_page.dart';
import '../../features/instructor/presentation/pages/instructor_questions_page.dart';
import '../../features/instructor/presentation/pages/instructor_quiz_attempts_page.dart';
import '../../features/instructor/presentation/pages/instructor_quizzes_page.dart';
import '../../features/instructor/presentation/pages/instructor_reorder_sections_page.dart';
import '../../features/instructor/presentation/pages/instructor_reviews_page.dart';
import '../../features/instructor/presentation/pages/instructor_sections_page.dart';
import '../../features/instructor/presentation/pages/instructor_submission_details_page.dart';
import '../../features/instructor/presentation/pages/instructor_submissions_page.dart';

// ============================================================
// ADMIN
// ============================================================
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/pages/admin_categories_page.dart';
import '../../features/admin/presentation/pages/admin_course_details_page.dart';
import '../../features/admin/presentation/pages/admin_course_filter_page.dart';
import '../../features/admin/presentation/pages/admin_create_category_page.dart';
import '../../features/admin/presentation/pages/admin_edit_category_page.dart';
import '../../features/admin/presentation/pages/admin_courses_page.dart'
    show AdminCourseFilterArgs, AdminCoursesPage;
import '../../features/admin/presentation/pages/admin_enrollment_details_page.dart';
import '../../features/admin/presentation/pages/admin_user_details_page.dart';
import '../../features/admin/presentation/pages/admin_user_filter_page.dart';

import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = _builders[settings.name];

    if (builder == null) {
      return _buildUnknownRoute(settings);
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (context) => builder(context, settings.arguments),
    );
  }

  // ============================================================
  // ROUTE TABLE
  // ============================================================
  static final Map<String, Widget Function(BuildContext, Object?)> _builders = {
    // ------------------------------------------------------------
    // AUTH
    // ------------------------------------------------------------
    AppRoutes.splash: (_, __) => const SplashPage(),
    AppRoutes.onboarding: (_, __) => const OnboardingPage(),
    AppRoutes.login: (_, __) => const LoginPage(),
    AppRoutes.registerStudent: (_, __) => const StudentRegisterPage(),
    AppRoutes.registerInstructor: (_, __) =>
    const InstructorRegisterPage(),
    AppRoutes.verifyEmail: (_, __) => const VerifyEmailPage(),
    AppRoutes.forgotPassword: (_, __) => const ForgotPasswordPage(),
    AppRoutes.resetPassword: (_, __) => const ResetPasswordPage(),

    // ------------------------------------------------------------
    // STUDENT (complete)
    // ------------------------------------------------------------
    AppRoutes.studentDashboard: (_, __) => const StudentShell(),
    AppRoutes.studentCourses: (_, __) =>
    const StudentShell(initialIndex: 1),
    AppRoutes.studentMyCourses: (_, __) =>
    const StudentShell(initialIndex: 2),
    AppRoutes.studentCourseDetails: (_, args) {
      final courseId = args is String ? args : '';
      return StudentCourseDetailsPage(courseId: courseId);
    },
    AppRoutes.studentLearning: (_, args) {
      final courseId = args is String ? args : '';
      return StudentLearningPage(courseId: courseId);
    },
    AppRoutes.studentLesson: (_, args) {
      final lessonId = args is String ? args : '';
      return StudentLessonPage(lessonId: lessonId);
    },
    AppRoutes.studentQuiz: (_, args) {
      final quizId = args is String ? args : '';
      return StudentQuizPage(quizId: quizId);
    },
    AppRoutes.studentQuizResult: (_, args) {
      final quizId = args is String ? args : '';
      return StudentQuizResultPage(quizId: quizId);
    },
    AppRoutes.studentQuizAttempts: (_, args) {
      final quizId = args is String ? args : '';
      return StudentQuizAttemptsPage(quizId: quizId);
    },
    AppRoutes.studentAssignments: (_, __) =>
    const StudentAssignmentsPage(),
    AppRoutes.studentAssignmentDetails: (_, args) {
      final id = args is String ? args : '';
      return StudentAssignmentDetailsPage(assignmentId: id);
    },
    AppRoutes.studentAssignmentSubmission: (_, args) {
      final id = args is String ? args : '';
      return StudentAssignmentSubmissionPage(assignmentId: id);
    },
    AppRoutes.studentReviews: (_, __) => const StudentReviewsPage(),
    // Notifications & Profile tabs are rendered inside StudentShell via
    // IndexedStack. Keep light placeholders so deep links don't 404.
    AppRoutes.studentNotifications: (_, __) => _placeholder(
      'Notifications',
      subtitle: 'Rendered inside StudentShell',
    ),
    AppRoutes.studentNotificationDetails: (_, args) {
      final id = args is String ? args : '';
      return StudentNotificationDetailsPage(notificationId: id);
    },
    AppRoutes.studentProfile: (_, __) => _placeholder(
      'Profile',
      subtitle: 'Rendered inside StudentShell',
    ),
    AppRoutes.studentEditProfile: (_, __) =>
    const StudentEditProfilePage(),
    AppRoutes.studentAccount: (_, __) => const StudentAccountPage(),
    AppRoutes.studentChangePassword: (_, __) =>
    const StudentChangePasswordPage(),

    // ------------------------------------------------------------
    // INSTRUCTOR (complete)
    // ------------------------------------------------------------
    AppRoutes.instructorDashboard: (_, __) => const InstructorShell(),
    AppRoutes.instructorCourses: (_, __) =>
    const InstructorShell(initialIndex: 1),
    AppRoutes.instructorCreateCourse: (_, __) =>
    const InstructorCreateCoursePage(),
    AppRoutes.instructorEditCourse: (_, args) {
      final id = args is String ? args : '';
      return InstructorEditCoursePage(courseId: id);
    },
    AppRoutes.instructorCourseDetails: (_, args) {
      final id = args is String ? args : '';
      return InstructorCourseDetailsPage(courseId: id);
    },
    AppRoutes.instructorSections: (_, args) {
      final id = args is String ? args : '';
      return InstructorSectionsPage(courseId: id);
    },
    AppRoutes.instructorCreateSection: (_, args) {
      final id = args is String ? args : '';
      return InstructorCreateSectionPage(courseId: id);
    },
    AppRoutes.instructorEditSection: (_, args) {
      final id = args is String ? args : '';
      return InstructorEditSectionPage(sectionId: id);
    },
    AppRoutes.instructorReorderSections: (_, args) {
      final id = args is String ? args : '';
      return InstructorReorderSectionsPage(courseId: id);
    },
    AppRoutes.instructorLessons: (_, args) {
      final id = args is String ? args : '';
      return InstructorLessonsPage(sectionId: id);
    },
    AppRoutes.instructorCreateLesson: (_, args) {
      final id = args is String ? args : '';
      return InstructorCreateLessonPage(sectionId: id);
    },
    AppRoutes.instructorEditLesson: (_, args) {
      final id = args is String ? args : '';
      return InstructorEditLessonPage(lessonId: id);
    },
    AppRoutes.instructorLessonMedia: (_, args) {
      final id = args is String ? args : '';
      return InstructorLessonMediaPage(lessonId: id);
    },
    AppRoutes.instructorQuizzes: (_, args) {
      final id = args is String ? args : '';
      return InstructorQuizzesPage(courseId: id);
    },
    AppRoutes.instructorCreateQuiz: (_, args) {
      final id = args is String ? args : '';
      return InstructorCreateQuizPage(courseId: id);
    },
    AppRoutes.instructorEditQuiz: (_, args) {
      final id = args is String ? args : '';
      return InstructorEditQuizPage(quizId: id);
    },
    AppRoutes.instructorQuestions: (_, args) {
      final id = args is String ? args : '';
      return InstructorQuestionsPage(quizId: id);
    },
    AppRoutes.instructorCreateQuestion: (_, args) {
      final id = args is String ? args : '';
      return InstructorCreateQuestionPage(quizId: id);
    },
    AppRoutes.instructorEditQuestion: (_, args) {
      final id = args is String ? args : '';
      return InstructorEditQuestionPage(questionId: id);
    },
    AppRoutes.instructorQuizAttempts: (_, args) {
      final id = args is String ? args : '';
      return InstructorQuizAttemptsPage(quizId: id);
    },
    AppRoutes.instructorAssignments: (_, args) {
      final id = args is String ? args : '';
      return InstructorAssignmentsPage(courseId: id);
    },
    AppRoutes.instructorCreateAssignment: (_, args) {
      final id = args is String ? args : '';
      return InstructorCreateAssignmentPage(courseId: id);
    },
    AppRoutes.instructorEditAssignment: (_, args) {
      final id = args is String ? args : '';
      return InstructorEditAssignmentPage(assignmentId: id);
    },
    AppRoutes.instructorSubmissions: (_, args) {
      final id = args is String ? args : '';
      return InstructorSubmissionsPage(assignmentId: id);
    },
    AppRoutes.instructorSubmissionDetails: (_, args) {
      final id = args is String ? args : '';
      return InstructorSubmissionDetailsPage(submissionId: id);
    },
    AppRoutes.instructorGradeSubmission: (_, args) {
      final id = args is String ? args : '';
      return InstructorGradeSubmissionPage(submissionId: id);
    },
    AppRoutes.instructorEnrollments: (_, __) =>
    const InstructorEnrollmentsPage(),
    AppRoutes.instructorLearnerDetails: (_, args) {
      final id = args is String ? args : '';
      return InstructorLearnerDetailsPage(enrollmentId: id);
    },
    AppRoutes.instructorReviews: (_, args) {
      final id = args is String ? args : null;
      return InstructorReviewsPage(courseId: id);
    },
    // Profile tab is rendered inside InstructorShell via IndexedStack.
    AppRoutes.instructorProfile: (_, __) => _placeholder(
      'Instructor Profile',
      subtitle: 'Rendered inside InstructorShell',
    ),
    AppRoutes.instructorEditProfile: (_, __) =>
    const InstructorEditProfilePage(),
    AppRoutes.instructorAccount: (_, __) =>
    const InstructorAccountPage(),
    AppRoutes.instructorChangePassword: (_, __) =>
    const InstructorChangePasswordPage(),

    // ------------------------------------------------------------
    // ADMIN (complete)
    // ------------------------------------------------------------
    AppRoutes.adminDashboard: (_, __) => const AdminShell(),
    AppRoutes.adminUsers: (_, __) => const AdminShell(initialIndex: 1),
    AppRoutes.adminUserDetails: (_, args) {
      final id = args is String ? args : '';
      return AdminUserDetailsPage(userId: id);
    },
    AppRoutes.adminUserFilter: (_, args) {
      final initial = args is AdminUserFilterArgs ? args : null;
      return AdminUserFilterPage(initial: initial);
    },
    AppRoutes.adminCategories: (_, __) => const AdminCategoriesPage(),
    AppRoutes.adminCreateCategory: (_, __) =>
    const AdminCreateCategoryPage(),
    AppRoutes.adminEditCategory: (_, args) {
      final id = args is String ? args : '';
      return AdminEditCategoryPage(categoryId: id);
    },
    AppRoutes.adminCourses: (_, __) => const AdminCoursesPage(),
    AppRoutes.adminCourseDetails: (_, args) {
      final id = args is String ? args : '';
      return AdminCourseDetailsPage(courseId: id);
    },
    AppRoutes.adminCourseFilter: (_, args) {
      final initial = args is AdminCourseFilterArgs ? args : null;
      return AdminCourseFilterPage(initial: initial);
    },
    AppRoutes.adminEnrollments: (_, __) =>
    const AdminEnrollmentsPage(),
    AppRoutes.adminEnrollmentDetails: (_, args) {
      final id = args is String ? args : '';
      return AdminEnrollmentDetailsPage(enrollmentId: id);
    },
    AppRoutes.adminReviews: (_, __) => const AdminReviewsPage(),
    AppRoutes.adminProfile: (_, __) => const AdminProfilePage(),
    AppRoutes.adminAccount: (_, __) => const AdminAccountPage(),
    AppRoutes.adminChangePassword: (_, __) =>
    const AdminChangePasswordPage(),
  };

  // ============================================================
  // HELPERS
  // ============================================================
  static Widget _placeholder(String title, {String? subtitle}) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Route<dynamic> _buildUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48),
                const SizedBox(height: 16),
                Text(
                  'No route defined for "${settings.name}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}