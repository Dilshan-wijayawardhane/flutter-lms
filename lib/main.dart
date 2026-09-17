import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/providers/admin_course_provider.dart';
import 'features/admin/providers/admin_enrollment_provider.dart';
import 'features/admin/providers/admin_review_provider.dart';
import 'features/admin/providers/admin_user_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/instructor/providers/instructor_assignment_provider.dart';
import 'features/instructor/providers/instructor_course_provider.dart';
import 'features/instructor/providers/instructor_learner_provider.dart';
import 'features/instructor/providers/instructor_quiz_provider.dart';
import 'features/student/providers/assignment_provider.dart';
import 'features/student/providers/category_provider.dart';
import 'features/student/providers/course_provider.dart';
import 'features/student/providers/enrollment_provider.dart';
import 'features/student/providers/learning_provider.dart';
import 'features/student/providers/lesson_provider.dart';
import 'features/student/providers/notification_provider.dart';
import 'features/student/providers/profile_provider.dart';
import 'features/student/providers/quiz_provider.dart';
import 'features/student/providers/review_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlutterLmsApp());
}

class FlutterLmsApp extends StatelessWidget {
  const FlutterLmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..restoreSession(),
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => InstructorCourseProvider()),
        ChangeNotifierProvider(create: (_) => InstructorQuizProvider()),
        ChangeNotifierProvider(create: (_) => InstructorAssignmentProvider()),
        ChangeNotifierProvider(create: (_) => InstructorLearnerProvider()),
        ChangeNotifierProvider(create: (_) => AdminUserProvider()),
        ChangeNotifierProvider(create: (_) => AdminCourseProvider()),
        ChangeNotifierProvider(create: (_) => AdminEnrollmentProvider()),
        ChangeNotifierProvider(create: (_) => AdminReviewProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter LMS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}