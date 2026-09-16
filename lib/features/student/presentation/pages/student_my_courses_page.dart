import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/enrollment.dart';
import '../../providers/enrollment_provider.dart';
import '../widgets/course_card.dart';
import '../../data/models/course.dart' as api;

class StudentMyCoursesPage extends StatefulWidget {
  const StudentMyCoursesPage({super.key});

  @override
  State<StudentMyCoursesPage> createState() =>
      _StudentMyCoursesPageState();
}

class _StudentMyCoursesPageState extends State<StudentMyCoursesPage> {
  int _tab = 0; // 0 = In Progress, 1 = Completed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EnrollmentProvider>();
      if (provider.state != LoadState.success) provider.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnrollmentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Learning'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Row(
              children: [
                _tabButton('In Progress', 0),
                const SizedBox(width: AppSpacing.xs),
                _tabButton('Completed', 1),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(top: false, child: _buildBody(provider)),
    );
  }

  Widget _buildBody(EnrollmentProvider provider) {
    if (provider.isLoading && provider.enrollments.isEmpty) {
      return const AppLoading(message: 'Loading your courses…');
    }
    if (provider.state == LoadState.error &&
        provider.enrollments.isEmpty) {
      return AppErrorState(
        title: 'Could not load your courses',
        message: provider.errorMessage ?? 'Please try again.',
        onRetry: () => provider.load(force: true),
      );
    }

    final list = _tab == 0
        ? provider.enrollments
        .where((e) => e.status != EnrollmentStatus.completed)
        .toList()
        : provider.enrollments
        .where((e) => e.status == EnrollmentStatus.completed)
        .toList();

    if (list.isEmpty) {
      return AppEmptyState(
        icon: _tab == 0
            ? Icons.play_lesson_outlined
            : Icons.verified_outlined,
        title: _tab == 0
            ? 'No courses in progress'
            : 'No completed courses yet',
        message: _tab == 0
            ? 'Enroll in a course to get started.'
            : 'Finish a course to see it here.',
        actionLabel: 'Browse Courses',
        onAction: () => Navigator.of(context)
            .pushNamed(AppRoutes.studentCourses),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.load(force: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final e = list[i];
          return CourseCard(
            course: _fakeCourseFromEnrollment(e),
            showProgress: true,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.studentLearning,
              arguments: e.courseId,
            ),
          );
        },
      ),
    );
  }

  /// Minimal adapter so we can reuse CourseCard without a second network
  /// call. Real fields fill in from the enrollment response.
  api.Course _fakeCourseFromEnrollment(Enrollment e) {
    return api.Course(
      id: e.courseId,
      title: e.courseName,
      description: '',
      instructorId: '',
      instructorName: e.instructorName ?? '',
      categoryId: '',
      categoryName: '',
      status: api.CourseStatus.published,
      level: api.CourseLevel.beginner,
      thumbnailUrl: e.courseThumbnailUrl,
      progressPercent: e.progressPercent,
      lessonCount: e.totalLessonCount,
      isEnrolled: true,
    );
  }

  Widget _tabButton(String label, int index) {
    final active = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primarySurface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: active ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: active
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}