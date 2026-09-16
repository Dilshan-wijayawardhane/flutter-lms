import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../student/data/models/course.dart';
import '../../../student/providers/instructor_course_provider.dart';

class InstructorCourseDetailsPage extends StatefulWidget {
  const InstructorCourseDetailsPage({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  State<InstructorCourseDetailsPage> createState() =>
      _InstructorCourseDetailsPageState();
}

class _InstructorCourseDetailsPageState
    extends State<InstructorCourseDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure sections are loaded so the summary is accurate.
      context
          .read<InstructorCourseProvider>()
          .loadSections(widget.courseId);
    });
  }

  Future<void> _publish(Course c) async {
    final ok = await context
        .read<InstructorCourseProvider>()
        .publishCourse(c.id);
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Course published.' : 'Could not publish.',
    );
  }

  Future<void> _archive(Course c) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Archive course?',
      message:
      'The course will be hidden from students. You can restore it later.',
      confirmLabel: 'Archive',
      isDestructive: true,
      icon: Icons.archive_outlined,
    );
    if (!confirmed || !mounted) return;
    final ok = await context
        .read<InstructorCourseProvider>()
        .archiveCourse(c.id);
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Course archived.' : 'Could not archive.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstructorCourseProvider>();
    final course = provider.courseById(widget.courseId);

    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Course not found')),
      );
    }

    final sections = provider.sectionsFor(course.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          course.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Course',
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.instructorEditCourse,
              arguments: course.id,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _summaryCard(course),
            const SizedBox(height: AppSpacing.md),
            _manageTile(
              context,
              icon: Icons.list_alt_rounded,
              title: 'Sections & Lessons',
              subtitle:
              '${sections.length} sections · ${course.lessonCount} lessons',
              route: AppRoutes.instructorSections,
              args: course.id,
            ),
            const SizedBox(height: AppSpacing.sm),
            _manageTile(
              context,
              icon: Icons.quiz_outlined,
              title: 'Quizzes',
              subtitle: 'Manage quizzes',
              route: AppRoutes.instructorQuizzes,
              args: course.id,
            ),
            const SizedBox(height: AppSpacing.sm),
            _manageTile(
              context,
              icon: Icons.assignment_outlined,
              title: 'Assignments',
              subtitle: 'Manage assignments and submissions',
              route: AppRoutes.instructorAssignments,
              args: course.id,
            ),
            const SizedBox(height: AppSpacing.sm),
            _manageTile(
              context,
              icon: Icons.people_alt_outlined,
              title: 'Learners',
              subtitle: '${course.learnerCount} enrolled',
              route: AppRoutes.instructorEnrollments,
              args: course.id,
            ),
            const SizedBox(height: AppSpacing.sm),
            _manageTile(
              context,
              icon: Icons.star_outline_rounded,
              title: 'Reviews',
              subtitle: '${course.ratingCount} reviews',
              route: AppRoutes.instructorReviews,
              args: course.id,
            ),
            const SizedBox(height: AppSpacing.lg),
            _sectionHeader('Curriculum Summary'),
            const SizedBox(height: AppSpacing.xs),
            if (sections.isEmpty)
              _emptyCard('No sections yet. Add your first section.')
            else
              ...sections.map(_sectionRow),
            const SizedBox(height: AppSpacing.lg),
            _sectionHeader('Publishing'),
            const SizedBox(height: AppSpacing.xs),
            _publishCard(context, course),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(Course c) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(c.title,
                    style: AppTextStyles.headingSmall),
              ),
              const SizedBox(width: AppSpacing.xs),
              switch (c.status) {
                CourseStatus.draft =>
                const AppStatusChip(status: AppStatus.draft),
                CourseStatus.published =>
                const AppStatusChip(status: AppStatus.published),
                CourseStatus.archived =>
                const AppStatusChip(status: AppStatus.archived),
              },
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(c.categoryName, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _chip(Icons.people_alt_outlined,
                  Formatters.count(c.learnerCount)),
              _chip(Icons.star_rounded, c.rating.toStringAsFixed(1)),
              _chip(Icons.menu_book_outlined, '${c.lessonCount}'),
              _chip(Icons.timer_outlined,
                  Formatters.duration(c.totalDurationMinutes)),
            ],
          ),
        ],
      ),
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

  Widget _manageTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required String route,
        required Object args,
      }) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () =>
            Navigator.of(context).pushNamed(route, arguments: args),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) =>
      Text(title, style: AppTextStyles.headingSmall);

  Widget _sectionRow(dynamic section) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
            child: Text(
              '${section.order}',
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title,
                    style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text('${section.lessonCount} lessons',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _publishCard(BuildContext context, Course c) {
    final isPublished = c.status == CourseStatus.published;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isPublished
                ? 'This course is published and visible to students.'
                : 'Publish this course to make it visible to students.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (isPublished)
            AppButton.secondary(
              label: 'Archive Course',
              icon: Icons.archive_outlined,
              onPressed: () => _archive(c),
            )
          else
            AppButton.primary(
              label: 'Publish Course',
              icon: Icons.publish_rounded,
              onPressed: () => _publish(c),
            ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(text, style: AppTextStyles.bodySmall),
  );
}