import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../student/data/models/enrollment.dart';
import '../../../student/providers/instructor_course_provider.dart';
import '../../providers/admin_enrollment_provider.dart';
import '../../../instructor/presentation/widgets/learner_card.dart';

class AdminEnrollmentsPage extends StatefulWidget {
  const AdminEnrollmentsPage({super.key});

  @override
  State<AdminEnrollmentsPage> createState() =>
      _AdminEnrollmentsPageState();
}

class _AdminEnrollmentsPageState extends State<AdminEnrollmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Admin loads courses first, then enrollments for the first one.
      final courses = context.read<InstructorCourseProvider>();
      if (courses.listState != LoadState.success) {
        courses.loadMyCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<InstructorCourseProvider>().courses;
    final courseId = courses.isEmpty ? null : courses.first.id;
    final provider = context.watch<AdminEnrollmentProvider>();

    // Fire loads when courseId becomes available.
    if (courseId != null && provider.state == LoadState.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.load(courseId);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Enrollments'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: courseId == null
            ? const AppEmptyState(
          icon: Icons.how_to_reg_outlined,
          title: 'No courses yet',
          message: 'Enrollments will appear once courses exist.',
        )
            : _body(provider, courseId),
      ),
    );
  }

  Widget _body(AdminEnrollmentProvider p, String courseId) {
    if (p.state == LoadState.loading && p.enrollments.isEmpty) {
      return const AppLoading(message: 'Loading enrollments…');
    }
    if (p.state == LoadState.error && p.enrollments.isEmpty) {
      return AppErrorState(
        title: 'Could not load enrollments',
        message: p.errorMessage ?? 'Please try again.',
        onRetry: () => p.load(courseId, force: true),
      );
    }
    if (p.enrollments.isEmpty) {
      return const AppEmptyState(
        icon: Icons.how_to_reg_outlined,
        title: 'No enrollments',
        message: 'Students will appear here as they enroll.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => p.load(courseId, force: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: p.enrollments.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final Enrollment e = p.enrollments[i];
          return LearnerCard(enrollment: e);
        },
      ),
    );
  }
}