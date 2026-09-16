import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart' hide LoadState;

class StudentCourseDetailsPage extends StatefulWidget {
  const StudentCourseDetailsPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<StudentCourseDetailsPage> createState() =>
      _StudentCourseDetailsPageState();
}

class _StudentCourseDetailsPageState
    extends State<StudentCourseDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadDetails(widget.courseId);
      final enroll = context.read<EnrollmentProvider>();
      if (enroll.state != LoadState.success) enroll.load();
    });
  }

  Future<void> _enroll() async {
    final provider = context.read<EnrollmentProvider>();
    final created = await provider.enroll(widget.courseId);
    if (!mounted) return;

    if (created != null) {
      context.read<CourseProvider>().markEnrolled(widget.courseId);
      AppSnackbar.showSuccess(context, 'Enrolled successfully');
    } else {
      AppSnackbar.showError(
        context,
        provider.errorMessage ?? 'Could not enroll.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseProvider>();
    final enroll = context.watch<EnrollmentProvider>();
    final state = courses.detailsStateFor(widget.courseId);
    final course = courses.courseById(widget.courseId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: _buildBody(state, course, courses, enroll),
      ),
      bottomNavigationBar:
      course == null ? null : _bottomCta(context, course, enroll),
    );
  }

  Widget _buildBody(
      LoadState state,
      dynamic course,
      CourseProvider courses,
      EnrollmentProvider enroll,
      ) {
    if (state == LoadState.loading && course == null) {
      return const AppLoading(message: 'Loading course…');
    }
    if (state == LoadState.error && course == null) {
      return AppErrorState(
        title: 'Could not load course',
        message: courses.detailsErrorFor(widget.courseId) ??
            'Please try again.',
        onRetry: () =>
            courses.loadDetails(widget.courseId, force: true),
      );
    }
    if (course == null) {
      return const Center(child: Text('Course not found'));
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.surface,
          flexibleSpace: FlexibleSpaceBar(
            background: (course.thumbnailUrl != null &&
                course.thumbnailUrl!.isNotEmpty)
                ? Image.network(
              course.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _heroPlaceholder(),
            )
                : _heroPlaceholder(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: AppTextStyles.headingLarge),
                const SizedBox(height: AppSpacing.md),
                _metaRow(course),
                const SizedBox(height: AppSpacing.md),
                _instructorRow(course),
                const SizedBox(height: AppSpacing.lg),
                Text('About this course',
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(course.description,
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroPlaceholder() => Container(
    color: AppColors.primary,
    child: const Center(
      child: Icon(
        Icons.play_circle_outline_rounded,
        size: 72,
        color: Colors.white,
      ),
    ),
  );

  Widget _metaRow(dynamic course) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        _chip(Icons.star_rounded, course.rating.toStringAsFixed(1)),
        _chip(Icons.people_alt_outlined,
            '${Formatters.count(course.learnerCount)} learners'),
        _chip(Icons.menu_book_outlined,
            '${course.lessonCount} lessons'),
        _chip(Icons.timer_outlined,
            Formatters.duration(course.totalDurationMinutes)),
        _chip(Icons.signal_cellular_alt_rounded, course.level.name),
      ],
    );
  }

  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: 4,
    ),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    ),
  );

  Widget _instructorRow(dynamic course) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySurface,
            child: Icon(Icons.person_outline_rounded,
                color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Instructor', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(course.instructorName,
                    style: AppTextStyles.labelLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomCta(
      BuildContext context,
      dynamic course,
      EnrollmentProvider enroll,
      ) {
    final isEnrolled = course.isEnrolled ||
        enroll.isEnrolledIn(course.id);
    final isEnrolling = enroll.isEnrollInFlight(course.id);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: isEnrolled
            ? AppButton.primary(
          label: 'Continue Learning',
          icon: Icons.play_arrow_rounded,
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoutes.studentLearning,
            arguments: course.id,
          ),
        )
            : AppButton.primary(
          label: isEnrolling
              ? 'Enrolling…'
              : (course.price == 0
              ? 'Enroll for Free'
              : 'Enroll · \$${course.price.toStringAsFixed(2)}'),
          icon: Icons.how_to_reg_outlined,
          isLoading: isEnrolling,
          onPressed: isEnrolling ? null : _enroll,
        ),
      ),
    );
  }
}